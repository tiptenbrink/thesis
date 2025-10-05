// coq‑http‑worker.ts — HTTP wrapper around a single `coqtop ‑emacs` instance
// ────────────────────────────────────────────────────────────────────────────
//  SUMMARY  (everything you need to re‑create this file)
//  ────────────────────────────────────────────────────────────────────────────
//  • One long‑running `coqtop -quiet -emacs -R theories Checker` process.
//  • Streams `./Pre.v`, waits 1 s for quiescence, then `Show.` → captures
//    the first prompt: that state is BASE_STATE (index –1).
//  • Proof script lives in STEPS[].  We keep a Map  idx ↦ state‑number .
//  • Endpoints (all GET):
//      /next   → run next scripted step;  JSON {info,context,first_goal,other_goals,steps}
//      /back   → BackTo previous idx’s state + Show.; same JSON.
//      /reset  → BackTo BASE_STATE + Show.;    idx = –1; same JSON.
//      /state  → diagnostic  { step, state, table }.
//  • Response JSON includes **steps** = array of proof‑step strings already run.
//  • Queue serialises requests.  Every command logged `[Coq] → …`
//  • DEBUG_COQ=1 streams raw Coq I/O (▶ stdout, ◆ stderr).
// ────────────────────────────────────────────────────────────────────────────

import { spawn }          from 'node:child_process';
import { readFile }       from 'node:fs/promises';
import { join }           from 'node:path';
import { createServer }   from 'node:http';
import { parse }          from 'node:url';

/*───────────── Configuration ───────────────────────────────────────────────*/
const COQ_CWD = '/home/tip-wsl/files/localp/fzn-drcp-check-constraints/fzn-drcp-check-constraints/_build/default';
const PORT    = 7373;

const STEPS: string[] = [
  'intros (conflict_variables & conflict_domain_union & Hnodup & Hsub & Hunion & Hlengths).',
  'intros [A [Hastate Halldiff]].',
  'enough (length conflict_domain_union >= length conflict_variables).',
  '{', 'apply Nat.lt_nge in Hlengths.', 'contradiction.', '}',
  'clear Hlengths; rewrite <- length_map with (f := A).',
  'apply NoDup_incl_length.',
  '-', 'clear -Hnodup Halldiff Hsub.',
  'apply Injective_map_NoDup_in.',
  '*', 'intros x y Hinx Hiny Hvxvy.',
  'destruct (String.string_dec x y) as [Hxy | Hxy].',
  '{ ', 'assumption.', '}',
  'enough (A x <> A y) by contradiction.',
  'apply Halldiff; try apply Hsub; assumption.',
  '*', 'apply Hnodup.',
  '-', 'clear -Hunion Hastate Hsub.',
  'unfold incl.', 'intros n Hin.',
  'apply Hunion; clear Hunion.',
  'rewrite in_map_iff in Hin.',
  'destruct Hin as (x & Hxn & Hxin).',
  'exists x.', 'split.',
  '+', 'exact Hxin.',
  '+', 'rewrite <- Hxn.', 'apply Hastate.',
  'apply Hsub.', 'exact Hxin.',
  'Qed.'
  ]
/*────────────────────────────────────────────────────────────────────────────*/

/*───────────── Global session state ────────────────────────────────────────*/
let stepIdx   = -1;      // current script index  (‑1 ⇒ just after Pre.v)
let lastState = -1;      // most recent state# read from a prompt
let BASE_STATE = -1;     // state after Pre.v  (never changes)
const idx2state = new Map<number, number>();   // index → state map

const chunkBuf: string[] = [];                 // collects Coq output chunks

/*───────────── Spawn Coq in ‑emacs mode ─────────────────────────────────────*/
const coq = spawn(
  'coqtop',
  ['-quiet', '-emacs', '-R', 'theories', 'Checker'],
  { cwd: COQ_CWD, stdio: ['pipe', 'pipe', 'pipe'] }
);

function dbg(prefix: string, buf: Buffer) {
  if (process.env.DEBUG_COQ)
    process.stdout.write(prefix + buf.toString().replace(/\n/g, `\n${prefix}`));
}

function onChunk(src: 'stdout' | 'stderr', buf: Buffer) {
  dbg(src === 'stdout' ? '▶ ' : '◆ ', buf);
  const txt = buf.toString();
  chunkBuf.push(txt);
  for (const m of txt.matchAll(/<\s*(\d+)\s*\|/g)) lastState = +m[1];
}
coq.stdout.on('data', b => onChunk('stdout', b));
coq.stderr.on('data', b => onChunk('stderr', b));

/*───────────── Small helpers ───────────────────────────────────────────────*/
function waitQuiet(gap = 120): Promise<string> {
  return new Promise(res => {
    let len = chunkBuf.join('').length;
    const iv = setInterval(() => {
      const cur = chunkBuf.join('').length;
      if (cur === len) {
        clearInterval(iv);
        const out = chunkBuf.join('');
        chunkBuf.length = 0;
        res(out);
      } else len = cur;
    }, gap);
  });
}

function waitPrompt(prev: number): Promise<string> {
  return new Promise(res => {
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

async function coqSend(cmd: string, needQuiet = false): Promise<string> {
  console.log(`[Coq] → ${cmd}`);
  const before = lastState;
  coq.stdin.write(cmd + '\n');
  return needQuiet ? await waitQuiet() : await waitPrompt(before);
}

const showGoals = () => coqSend('Show.');

/*───────────── Text post‑processing ────────────────────────────────────────*/

/* strip XML & raw prompt lines */
function stripPrompts(raw: string): string {
  return raw
    .replace(/<prompt>[\s\S]*?<\/prompt>/g, '')
    .split('\n')
    .filter(l => !/<\s*\d+\s*\|/.test(l))
    .join('\n')
    .trimEnd();
}

/* remove duplicate block (BackTo + Show often duplicates the goals) */
function dedup(txt: string): string {
  const m = txt.match(/^\s*\d+\s+goal[^\n]*\n/m);
  if (!m) return txt;
  const hdr = m[0];
  const second = txt.indexOf(hdr, (m.index ?? 0) + hdr.length);
  return second !== -1 ? txt.slice(0, second).trimEnd() : txt;
}

/* join lines, preserve leading indent, strip trailing spaces */
const joinBlock = (arr: string[]) => arr.map(l => l.replace(/\s+$/, '')).join('\n');

/* parse goals */
function parseGoals(raw: string) {
  const out = { info: '', context: '', first_goal: '', other_goals: [] as string[] };
  const lines = raw.split('\n').map(l => l.replace(/\s+$/, ''));

  let i = 0;

  /* optional <infomsg> blocks */
  while (i < lines.length && lines[i].startsWith('<infomsg>')) {
    const j = lines.indexOf('</infomsg>', i);
    out.info += (out.info ? '\n' : '') +
      joinBlock(lines.slice(i, j + 1)).replace(/<\/?infomsg>/g, '');
    i = j + 1;
  }

  /* header “X goal(s) …” */
  if (/^\s*\d+\s+goal/i.test(lines[i])) {
    out.info += (out.info ? '\n' : '') + lines[i].trim();
    i++;
  }
  while (i < lines.length && lines[i].trim() === '') i++;           // blank lines

  /* context until bar */
  const bar = lines.findIndex((l, k) => k >= i && l.trim() === '============================');
  if (bar !== -1) {
    out.context = joinBlock(lines.slice(i, bar));
    i = bar + 1;
  }

  /* first goal */
  const nextHdr = lines.findIndex((l, k) => k >= i && /^goal\s+\d+/i.test(l.trim()));
  const end = nextHdr === -1 ? lines.length : nextHdr - 1;
  out.first_goal = joinBlock(lines.slice(i, end + 1));
  i = nextHdr;

  /* remaining goals */
  while (i !== -1 && i < lines.length) {
    const hdr = i;
    const nxt = lines.findIndex((l, k) => k > hdr && /^goal\s+\d+/i.test(l.trim()));
    out.other_goals.push(joinBlock(lines.slice(hdr, nxt === -1 ? lines.length : nxt)));
    i = nxt;
  }

  return out;
}

const cleanAndParse = (raw: string) => parseGoals(dedup(stripPrompts(raw)));

function logTable() {
  const s = [...idx2state].sort(([a], [b]) => a - b).map(([k,v]) => `${k}:${v}`).join(', ');
  console.log(`[Coq] map { ${s} }`);
}

/*───────────── bootstrap: load Pre.v ───────────────────────────────────────*/
async function loadPre() {
  console.log('[Coq] loading Pre.v …');
  const pre = await readFile(join(process.cwd(), 'Pre.v'), 'utf8');
  console.log('[Coq] → (stream Pre.v)');
  coq.stdin.write(pre + '\n');
  await waitQuiet();
  await new Promise(r => setTimeout(r, 1000));
  await showGoals();

  BASE_STATE = lastState;
  idx2state.set(-1, BASE_STATE);
  logTable();
  console.log(`[Coq] ready – BASE_STATE ${BASE_STATE}`);
}

/*───────────── FIFO job queue ─────────────────────────────────────────────*/
let busy = false;
const q: (() => Promise<void>)[] = [];
function pump() {
  if (busy || !q.length) return;
  busy = true;
  q.shift()!().finally(() => { busy = false; setImmediate(pump); });
}
const enqueue = (job: () => Promise<void>) => { q.push(job); pump(); };

/*───────────── HTTP server ────────────────────────────────────────────────*/
const server = createServer((req, res) => {
  const { pathname } = parse(req.url ?? '/');
  res.setHeader('Content-Type', 'application/json');

  /*── /next ───────────────────────────────────────────────────*/
  if (pathname === '/next') {
    enqueue(async () => {
      const next = stepIdx + 1;
      if (next >= STEPS.length) {
        res.end(JSON.stringify({ error: 'end_of_proof' }));
        return;
      }
      const raw = await coqSend(STEPS[next]);
      idx2state.set(next, lastState);
      stepIdx = next;
      logTable();
      const json = cleanAndParse(raw);
      const with_steps = { ...json, steps: STEPS.slice(0, stepIdx + 1) }
      res.end(JSON.stringify(with_steps));
    });

  /*── /back ───────────────────────────────────────────────────*/
  } else if (pathname === '/back') {
    enqueue(async () => {
      if (stepIdx < 0) {
        res.end(JSON.stringify({ error: 'at_beginning' }));
        return;
      }
      const tgtIdx = stepIdx - 1;
      const tgtState = idx2state.get(tgtIdx) ?? BASE_STATE;
      await coqSend(`BackTo ${tgtState}.`);
      const raw = await showGoals();
      stepIdx = tgtIdx;
      logTable();
      const json = cleanAndParse(raw);
      const with_steps = { ...json, steps: STEPS.slice(0, stepIdx + 1) }
      res.end(JSON.stringify(with_steps));
    });

  /*── /reset ──────────────────────────────────────────────────*/
  } else if (pathname === '/reset') {
    enqueue(async () => {
      await coqSend(`BackTo ${BASE_STATE}.`, true);
      const raw = await showGoals();
      stepIdx = -1;
      logTable();
      const json = cleanAndParse(raw);
      const with_steps = { ...json, steps: STEPS.slice(0, stepIdx + 1) }
      res.end(JSON.stringify(with_steps));
    });

  /*── /state ──────────────────────────────────────────────────*/
  } else if (pathname === '/state') {
    res.end(JSON.stringify({
      step: stepIdx,
      state: lastState,
      table: Object.fromEntries(idx2state)
    }));

  } else {
    res.statusCode = 404;
    res.end(JSON.stringify({ error: 'use /next | /back | /reset | /state' }));
  }
});

/*───────────── main ───────────────────────────────────────────────────────*/
(async () => {
  try {
    await loadPre();
    server.listen(PORT, '127.0.0.1', () =>
      console.log(`[Coq] listening on http://127.0.0.1:${PORT}/`)
    );
  } catch (err) {
    console.error('[Coq] fatal:', err);
    process.exit(1);
  }
})();
