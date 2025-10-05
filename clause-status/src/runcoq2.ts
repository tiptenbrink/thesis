// coq-http-worker.ts  ───────────────────────────────────────────────────────
// One‑file HTTP driver for a single `coqtop -emacs` session
// ---------------------------------------------------------------------------
//  ▼  Discussion summary – what this script guarantees
//  -------------------------------------------------------------------------
//  1.  **Single Coq process**:  `coqtop -quiet -emacs` is spawned once and
//      kept alive for all HTTP requests.
//  2.  **Pre.v bootstrap**
//         • Streams `./Pre.v` to stdin.
//         • Waits until Coq is quiet, plus an extra 1 s, then issues `Show.`
//           and captures the prompt; that state number is stored as
//           `BASE_STATE` (index –1).
//  3.  **Step queue & mapping**
//         • `STEPS[]` holds the scripted proof lines.
//         • For each `/next`, the script sends the next tactic *once* and
//           waits for the prompt *after* it – that state becomes the value
//           for the new index in `idx2state`.
//         • For `/back`, we look up the previous index’s state and send
//           `BackTo <state>.`, followed by `Show.` to print fresh goals.
//  4.  **Logging & debugging**
//         • Every command sent to Coq is logged: `[Coq] → <command>`.
//         • Internal table prints after each move: `[Coq] map { idx:state }`.
//         • `DEBUG_COQ=1` streams raw duplex traffic (▶ stdout, ◆ stderr).
//  5.  **HTTP API**
//         • `GET /next`  → advance one step, returns goal text (prompts stripped).
//         • `GET /back`  → undo one step via BackTo, returns goal text.
//         • `GET /state` → JSON `{ step, state, table }`.
//  6.  **Concurrency safety**: simple FIFO job queue serialises requests so
//      commands reach Coq in order.
//  -------------------------------------------------------------------------
//  With just this summary, you could recreate the entire file.
// ---------------------------------------------------------------------------
//  ▸ Streams Pre.v, waits 1 s for quiet, records BASE_STATE.
//  ▸ Maps each scripted step index → state number *after* the step.
//  ▸ Logs every command (`[Coq] → …`).
//  ▸ Endpoints: /next, /back, /state.
//  ▸ DEBUG_COQ=1 prints duplex traffic (▶ stdout, ◆ stderr).
// ---------------------------------------------------------------------------

import { spawn } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { createServer } from 'node:http';
import { parse } from 'node:url';

/*──────────────────────── Configuration ───────────────────────────*/
const COQ_CWD = '/home/tipcl-pop/files/gitp/fzn-drcp-check/_build/default';
const PORT = 7373;
const STEPS = [
  'intros H.',
  'destruct H as [confl_vars [Hsub Hlt]].',
  'intros [v [Hvstate Hdiff]].',
  'enough (dom_size (vars_dom_union st confl_vars) >= vars_len confl_vars).',
  '{ ', 
  'apply Nat.lt_nge in Hlt.',
  'contradiction.',
  ' }',
  'apply all_different_subset with (vs\' := confl_vars) in Hdiff; try assumption.',
  'unfold vars_dom_union.',
  'rewrite sstr.fold_spec.',
  'rewrite <- fold_left_rev_right.',
  'rewrite sstr.cardinal_spec.',
  'rewrite <- length_rev.'
];
/*──────────────────────────────────────────────────────────────────*/

/*─────────── Session state ───────────────────────────────────────*/
let stepIdx = -1;     // current scripted index (−1 ⇒ after Pre.v)
let lastState = -1;   // latest state number from prompt
let BASE_STATE = -1;  // immutable: state after Pre.v
const idx2state = new Map<number, number>();

const chunkBuf: string[] = [];  // gathers stdout & stderr between prompts

/*─────────── Spawn Coq (‑emacs) ─────────────────────────────────*/
const coq = spawn('coqtop', ['-quiet', '-emacs', '-R', 'theories', 'Checker'], {
  cwd: COQ_CWD,
  stdio: ['pipe', 'pipe', 'pipe']
});

function debug(prefix: string, data: Buffer): void {
  if (process.env.DEBUG_COQ)
    process.stdout.write(prefix + data.toString().replace(/\n/g, `\n${prefix}`));
}

function onChunk(src: 'stdout' | 'stderr', buf: Buffer): void {
  debug(src === 'stdout' ? '▶ ' : '◆ ', buf);
  const txt = buf.toString();
  chunkBuf.push(txt);
  for (const m of txt.matchAll(/<\s*(\d+)\s*\|/g)) lastState = +m[1];
}
coq.stdout.on('data', (b) => onChunk('stdout', b));
coq.stderr.on('data', (b) => onChunk('stderr', b));

/*─────────── Utilities ─────────────────────────────────────────*/
function waitQuiet(gap = 120): Promise<string> {
  return new Promise((res) => {
    let len = chunkBuf.join('').length;
    const iv = setInterval(() => {
      const cur = chunkBuf.join('').length;
      if (cur === len) {
        clearInterval(iv);
        const out = chunkBuf.join('');
        chunkBuf.length = 0;
        res(out);
      } else {
        len = cur;
      }
    }, gap);
  });
}

function waitPrompt(prev: number): Promise<string> {
  return new Promise((res) => {
    const iv = setInterval(() => {
      if (lastState !== prev && lastState !== -1) {
        clearInterval(iv);
        const out = chunkBuf.join('');
        chunkBuf.length = 0;
        res(out);
      }
    }, 20);
  });
}

async function coqSend(cmd: string, quiet = false): Promise<string> {
  console.log(`[Coq] → ${cmd}`);
  const before = lastState;
  coq.stdin.write(cmd + '\n');
  return quiet ? await waitQuiet() : await waitPrompt(before);
}

async function showGoals(): Promise<string> {
  return await coqSend('Show.');
}

function stripPrompts(raw: string): string {
  return raw
    .replace(/<prompt>[\s\S]*?<\/prompt>/g, '')
    .split(/\n/)
    .filter((l) => !/<\s*\d+\s*\|/.test(l))
    .join('\n')
    .trim();
}

function logTable(): void {
  const tbl = [...idx2state]
    .sort(([a], [b]) => a - b)
    .map(([i, s]) => `${i}:${s}`)
    .join(', ');
  console.log(`[Coq] map { ${tbl} }`);
}

/*─────────── Bootstrap – load Pre.v ───────────────────────────*/
async function loadPre(): Promise<void> {
  console.log('[Coq] loading Pre.v …');
  const pre = await readFile(join(process.cwd(), 'Pre.v'), 'utf8');
  console.log('[Coq] → (stream Pre.v)');
  coq.stdin.write(pre + '\n');
  await waitQuiet();                          // initial quiet
  await new Promise((r) => setTimeout(r, 1000)); // extra settle
  await showGoals();                          // capture prompt

  BASE_STATE = lastState;
  idx2state.set(-1, BASE_STATE);
  logTable();
  console.log(`[Coq] ready – BASE_STATE ${BASE_STATE}`);
}

/*─────────── Job queue ───────────────────────────────────────*/
let busy = false;
const queue: (() => Promise<void>)[] = [];
function pump(): void {
  if (busy || !queue.length) return;
  busy = true;
  queue.shift()!().finally(() => {
    busy = false;
    setImmediate(pump);
  });
}
function enqueue(job: () => Promise<void>): void {
  queue.push(job);
  pump();
}

/*─────────── HTTP server ─────────────────────────────────────*/
const server = createServer((req, res) => {
  const { pathname } = parse(req.url ?? '/');

  /*──────────── /next ─────────────────────────────*/
  if (pathname === '/next') {
    enqueue(async () => {
      const next = stepIdx + 1;
      console.log(`[Coq] stepId=${next}`)
      if (next >= STEPS.length) {
        res.end('[Coq] ❌ end of proof');
        return 
      }

      const raw = await coqSend(STEPS[next]); // no extra Show.
      idx2state.set(next, lastState);         // state **after** step
      stepIdx = next;
      logTable();
      res.end(stripPrompts(raw) || '(no goals)');
    });

    /*──────────── /back ─────────────────────────────*/
  } else if (pathname === '/back') {
    enqueue(async () => {
      if (stepIdx < 0) {
        res.end('[Coq] ❌ at beginning');
        return
      }
      const tgtIdx = stepIdx - 1;
      console.log(`[Coq] stepId=${tgtIdx}/`)
      const tgtState = idx2state.get(tgtIdx);
      if (tgtState === undefined) {
        res.end('[Coq] ❌ unknown state');
        return
      }

      await coqSend(`BackTo ${tgtState}.`);
      const goal = stripPrompts(await showGoals()); // need Show
      stepIdx = tgtIdx;
      logTable();
      res.end(goal || '(no goals)');
    });

    /*──────────── /state ────────────────────────────*/
  } else if (pathname === '/state') {
    res.setHeader('Content-Type', 'application/json');
    res.end(
      JSON.stringify({ step: stepIdx, state: lastState, table: Object.fromEntries(idx2state) })
    );
  } else {
    res.statusCode = 404;
    res.end('Use /next | /back | /state');
  }
});

/*─────────── Launch ─────────────────────────────────────────*/
(async () => {
  try {
    await loadPre();
    server.listen(PORT, '127.0.0.1', () =>
      console.log(`[Coq] listening at http://127.0.0.1:${PORT}/`)
    );
  } catch (e) {
    console.error('[Coq] fatal:', e);
    process.exit(1);
  }
})();
