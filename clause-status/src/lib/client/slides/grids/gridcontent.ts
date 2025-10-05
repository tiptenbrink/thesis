import type { Snippet } from "svelte"
import { empty } from "../snippets/Mod.svelte"
import * as content from "../snippets/GridContent.svelte"

const gridcontents: {
  name: string,
  notAllowed: number[][][],
  blockedInput?: string,
  noInference?: boolean,
  gridInput: string,
  colorInput: string,
  knowledge: string,
  inputNoInference?: string,
  check: string,
  infStep?: number
  leftSide?: Snippet<[any]>
}[] = [
  {
    name: 'gridsat',

    gridInput: `
      0 4 1 0 0
      0 2 0 4 0
      3 0 4 1 2
      0 0 0 5 1
      5 0 3 0 0
    `,

    blockedInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    leftSide: content.rules,

    noInference: true,
  },

  {
    name: 'gridsatsol',

    gridInput: `
      2 4 1 3 5
      1 2 5 4 3
      3 5 4 1 2
      4 3 2 5 1
      5 1 3 2 4
    `,

    blockedInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    leftSide: content.solutionExample,
  },
  
  {
    name: 'grid',

    noInference: true,

    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,

    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    blockedInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    leftSide: content.unsat
  },

  {
    name: 'gridmodel',

    noInference: true,

    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,

    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    blockedInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    leftSide: content.model,
  },
  {
    name: 'gridcol',

    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 0
      0 0 5 4 0
      0 0 0 0 4
    `,

    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
  },
  {
    name: 'grid1',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      2 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    check: `A3 = 2 → ⊥`
  },
  {
    name: 'grid2',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      2 0 4 0 3
      0 0 5 4 0
      5 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,

    check: `A3 = 2 → ⊥`
  },
  {
    name: 'grid3',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      3 4 0 0 0
      2 0 4 0 3
      0 0 5 4 0
      5 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      g2 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,

    check: `A3 = 2 → ⊥\nconflict!`
  },
  {
    name: 'grid4',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      5 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    check: `A3 = 5 → ⊥`
  },
  {
    name: 'grid5',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      5 0 4 0 3
      0 0 5 4 0
      2 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,

    check: `A3 = 5 → ⊥`
  },
  {
    name: 'grid6',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      3 4 0 0 0
      5 0 4 0 3
      0 0 5 4 0
      2 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      g2 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,

    check: `A3 = 5 → ⊥\nconflict!`
  },
  {
    name: 'grid7',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[2,5], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      r 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,

    knowledge: `(1) A3 = 2 → ⊥\n(2) A3 = 5 → ⊥`,
    check: `T → ⊥ by [1,2]`
  },
  {
    name: 'grid8',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      2 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    infStep: 0
  },
  {
    name: 'grid9',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[2], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      2 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,
    infStep: 1
  },
  {
    name: 'grid10',
    notAllowed: [
      [[], [], [], [], []],
      [[2], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[2], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      2 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,
    infStep: 2
  },
  {
    name: 'grid11',
    notAllowed: [
      [[], [], [], [], []],
      [[2, 5], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[2], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      2 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      g2 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,
    infStep: 3
  },
  {
    name: 'grid12',
    notAllowed: [
      [[], [], [], [], []],
      [[2, 5], [], [], [], []],
      [[], [], [], [], []],
      [[3], [], [], [], []],
      [[2], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      2 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      g2 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      g2 0 0 0 0
    `,
    infStep: 4
  },
  {
    name: 'grid13',
    notAllowed: [
      [[], [], [], [], []],
      [[2, 5], [], [], [], []],
      [[], [], [], [], []],
      [[3, 2], [], [], [], []],
      [[2], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      2 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      g2 0 0 0 0
      g 0 0 0 0
      r 0 0 0 0
      g2 0 0 0 0
    `,
    infStep: 5
  },
  {
    name: 'grid14',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      5 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      g 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    leftSide: content.inference2
  },
  {
    name: 'grid15',
    notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ],
    gridInput: `
      1 0 0 0 0
      0 4 0 0 0
      0 0 4 0 3
      0 0 5 4 0
      0 0 0 3 4
    `,
    inputNoInference: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    colorInput: `
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
      0 0 0 0 0
    `,
    leftSide: content.conflSet
  },
].map(s => {
  return {
    knowledge: '', check: '', notAllowed: [
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
      [[], [], [], [], []],
    ], colorInput: `
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
    0 0 0 0 0
  `, ...s
  }
})

export default gridcontents