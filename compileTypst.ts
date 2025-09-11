import { exec } from 'node:child_process'

export function typstCode(content: string) {
    return `
        #set page(margin: 0pt, width: 10cm, height: 5cm)
        ${content}
    `
}

function compileCode(code: string, outputFile: string) {
    return new Promise((resolve, reject) => {
        const process = exec(`typst compile - ${outputFile}`, (error, stdout, stderr) => {
            if (error) {
                reject(`Error: ${error.message}`);
                return;
            }
            if (stderr) {
                console.error(`Stderr: ${stderr}`);
            }
            resolve(`Compiled successfully: ${outputFile}`);
        });
        if (process.stdin !== null) {
            // Write Typst code to stdin
            process.stdin.write(code);
            process.stdin.end();
        } else {
            throw new Error("stdin was null!")
        }
    });
}

export async function compileAll(codes: [string, string][]) {
    const compilePromises = codes.map(([code, file]) => compileCode(code, file));
    return Promise.all(compilePromises);
}

const cumulFigure = 
`
#import "@preview/cetz:0.4.1": canvas, draw
#set page(margin: 0pt, width: 10cm, height: 4.2cm, fill: none)
#canvas(length: 1cm, {
    import draw: *
    
    // Set up coordinate system
    let time-scale = 1.2
    let usage-scale = 0.8
    let horizon = 5
    
    // Draw time axis
    line((0, 0), (horizon * time-scale, 0), stroke: 1pt + black)
    
    // Draw usage axis  
    line((0, 0), (0, 4 * usage-scale), stroke: 1pt + black)
    
    // Time axis labels
    for t in range(horizon+1) {
      content((t * time-scale, -0.3), text(size: 10pt, str(t)))
      line((t * time-scale, -0.1), (t * time-scale, 0.1), stroke: 0.5pt + black)
    }
    
    // Usage axis labels
    for u in range(1, 4) {
      content((-0.3, u * usage-scale), text(size: 10pt, str(u)))
      line((-0.1, u * usage-scale), (0.1, u * usage-scale), stroke: 0.5pt + black)
    }
    
    // Axis labels
    content((horizon/2 * time-scale, -0.8), text(size: 12pt, [Time]))
    content((-0.8, 2 * usage-scale), text(size: 12pt, [Usage]), angle: 90deg)
    
    // Activity ranges and mandatory parts
    // Activity a: bounds [0,1], duration 2 → possible at t=0,1,2; mandatory at t=1
    // Activity b: bounds [0,1], duration 3 → possible at t=0,1,2,3; mandatory at t=1,2  
    // Activity c: bounds [2,3], duration 2 → possible at t=2,3,4; mandatory at t=3
    
    let activities = (
      (name: "a", start: 2, duration: 1, color: red, usage: 1),
      (name: "b", start: 2, duration: 2, color: blue, usage: 1),  
      (name: "c", start: 0, duration: 2, color: green, usage: 2),
    )
    
    
    // Draw mandatory parts (highlighted)
    for activity in activities {
      let y-offset = if activity.name == "a" { 1 } else if activity.name == "b" { 0 } else { 0 }
          let height = activity.usage
          
          rect(
            (activity.start * time-scale, y-offset * usage-scale), 
            ((activity.start + activity.duration) * time-scale, (y-offset + height) * usage-scale),
            fill: activity.color.lighten(20%), 
            stroke: 2pt + activity.color.darken(30%)
          )
          
          content(
            (activity.start * time-scale + 0.6, (y-offset + height/2) * usage-scale), 
            text(size: 9pt, weight: "bold", fill: white, activity.name)
          )
    }
    
    // Add capacity line (assuming capacity = 3)
    line((0, 2 * usage-scale), (horizon * time-scale, 2 * usage-scale), 
         stroke: (paint: gray, dash: "dashed", thickness: 1pt))

    content((horizon * time-scale + 0.8, 2 * usage-scale), text(size: 9pt, [Capacity]))
  })
`

const cumulFigureBad = 
`
#import "@preview/cetz:0.4.1": canvas, draw
#set page(margin: 0pt, width: 10cm, height: 4.2cm, fill: none)
#canvas(length: 1cm, {
    import draw: *
    
    // Set up coordinate system
    let time-scale = 1.2
    let usage-scale = 0.8
    let horizon = 5
    
    // Draw time axis
    line((0, 0), (horizon * time-scale, 0), stroke: 1pt + black)
    
    // Draw usage axis  
    line((0, 0), (0, 4 * usage-scale), stroke: 1pt + black)
    
    // Time axis labels
    for t in range(horizon+1) {
      content((t * time-scale, -0.3), text(size: 10pt, str(t)))
      line((t * time-scale, -0.1), (t * time-scale, 0.1), stroke: 0.5pt + black)
    }
    
    // Usage axis labels
    for u in range(1, 4) {
      content((-0.3, u * usage-scale), text(size: 10pt, str(u)))
      line((-0.1, u * usage-scale), (0.1, u * usage-scale), stroke: 0.5pt + black)
    }
    
    // Axis labels
    content((horizon/2 * time-scale, -0.8), text(size: 12pt, [Time]))
    content((-0.8, 2 * usage-scale), text(size: 12pt, [Usage]), angle: 90deg)
    
    // Activity ranges and mandatory parts
    // Activity a: bounds [0,1], duration 2 → possible at t=0,1,2; mandatory at t=1
    // Activity b: bounds [0,1], duration 3 → possible at t=0,1,2,3; mandatory at t=1,2  
    // Activity c: bounds [2,3], duration 2 → possible at t=2,3,4; mandatory at t=3
    
    let activities = (
      (name: "a", start: 2, duration: 1, color: red, usage: 1),
      (name: "b", start: 3, duration: 2, color: blue, usage: 1),  
      (name: "c", start: 0, duration: 2, color: green, usage: 2),
    )
    
    
    // Draw mandatory parts (highlighted)
    for activity in activities {
      let y-offset = 0
          let height = activity.usage
          
          rect(
            (activity.start * time-scale, y-offset * usage-scale), 
            ((activity.start + activity.duration) * time-scale, (y-offset + height) * usage-scale),
            fill: activity.color.lighten(20%), 
            stroke: 2pt + activity.color.darken(30%)
          )
          
          content(
            (activity.start * time-scale + 0.6, (y-offset + height/2) * usage-scale), 
            text(size: 9pt, weight: "bold", fill: white, activity.name)
          )
    }
    
    // Add capacity line (assuming capacity = 3)
    line((0, 2 * usage-scale), (horizon * time-scale, 2 * usage-scale), 
         stroke: (paint: gray, dash: "dashed", thickness: 1pt))

    content((horizon * time-scale + 0.8, 2 * usage-scale), text(size: 9pt, [Capacity]))
  })
`

const cumulFigureClaim = 
`
#import "@preview/cetz:0.4.1": canvas, draw
#set page(margin: 0pt, width: 10cm, height: 4.2cm, fill: none)
#canvas(length: 1cm, {
    import draw: *
    
    // Set up coordinate system
    let time-scale = 1.2
    let usage-scale = 0.8
    let horizon = 3
    
    // Draw time axis
    line((0, 0), (horizon * time-scale, 0), stroke: 1pt + black)
    
    // Draw usage axis  
    line((0, 0), (0, 4 * usage-scale), stroke: 1pt + black)
    
    // Time axis labels
    for t in range(horizon+1) {
      content((t * time-scale, -0.3), text(size: 10pt, str(t)))
      line((t * time-scale, -0.1), (t * time-scale, 0.1), stroke: 0.5pt + black)
    }
    
    // Usage axis labels
    for u in range(1, 4) {
      content((-0.3, u * usage-scale), text(size: 10pt, str(u)))
      line((-0.1, u * usage-scale), (0.1, u * usage-scale), stroke: 0.5pt + black)
    }
    
    // Axis labels
    content((horizon/2 * time-scale, -0.8), text(size: 12pt, [Time]))
    content((-0.8, 2 * usage-scale), text(size: 12pt, [Usage]), angle: 90deg)
    
    // Activity ranges and mandatory parts
    // Activity a: bounds [0,1], duration 2 → possible at t=0,1,2; mandatory at t=1
    // Activity b: bounds [0,1], duration 3 → possible at t=0,1,2,3; mandatory at t=1,2  
    // Activity c: bounds [2,3], duration 2 → possible at t=2,3,4; mandatory at t=3
    
    let activities = (
      (name: "a", start: 0, duration: 1, color: red, usage: 1),
      (name: "b", start: 1, duration: 2, color: blue, usage: 1),  
    )
    
    
    // Draw mandatory parts (highlighted)
    for activity in activities {
      let y-offset = 0
          let height = activity.usage
          
          rect(
            (activity.start * time-scale, y-offset * usage-scale), 
            ((activity.start + activity.duration) * time-scale, (y-offset + height) * usage-scale),
            fill: activity.color.lighten(20%), 
            stroke: 2pt + activity.color.darken(30%)
          )
          
          content(
            (activity.start * time-scale + 0.6, (y-offset + height/2) * usage-scale), 
            text(size: 9pt, weight: "bold", fill: white, activity.name)
          )
    }
    
    // Add capacity line (assuming capacity = 3)
    line((0, 2 * usage-scale), (horizon * time-scale, 2 * usage-scale), 
         stroke: (paint: gray, dash: "dashed", thickness: 1pt))

    content((horizon * time-scale + 0.8, 2 * usage-scale), text(size: 9pt, [Capacity]))
  })
`
const cumulFigureConfl = 
`
#import "@preview/cetz:0.4.1": canvas, draw
#set page(margin: 0pt, width: 10cm, height: 4.2cm, fill: none)
#canvas(length: 1cm, {
    import draw: *
    
    // Set up coordinate system
    let time-scale = 1.2
    let usage-scale = 0.8
    let horizon = 3
    
    // Draw time axis
    line((0, 0), (horizon * time-scale, 0), stroke: 1pt + black)
    
    // Draw usage axis  
    line((0, 0), (0, 4 * usage-scale), stroke: 1pt + black)
    
    // Time axis labels
    for t in range(horizon+1) {
      content((t * time-scale, -0.3), text(size: 10pt, str(t)))
      line((t * time-scale, -0.1), (t * time-scale, 0.1), stroke: 0.5pt + black)
    }
    
    // Usage axis labels
    for u in range(1, 4) {
      content((-0.3, u * usage-scale), text(size: 10pt, str(u)))
      line((-0.1, u * usage-scale), (0.1, u * usage-scale), stroke: 0.5pt + black)
    }
    
    // Axis labels
    content((horizon/2 * time-scale, -0.8), text(size: 12pt, [Time]))
    content((-0.8, 2 * usage-scale), text(size: 12pt, [Usage]), angle: 90deg)
    
    // Activity ranges and mandatory parts
    // Activity a: bounds [0,1], duration 2 → possible at t=0,1,2; mandatory at t=1
    // Activity b: bounds [0,1], duration 3 → possible at t=0,1,2,3; mandatory at t=1,2  
    // Activity c: bounds [2,3], duration 2 → possible at t=2,3,4; mandatory at t=3
    
    let activities = (
      (name: "b", start: 0, duration: 2, color: red, usage: 1),
      (name: "c", start: 0, duration: 2, color: green, usage: 2),  
    )
    
    
    // Draw mandatory parts (highlighted)
    for activity in activities {
      let y-offset = if activity.name == "c" { 0 } else { 2 }
          let height = activity.usage
          
          
          rect(
            (activity.start * time-scale, y-offset * usage-scale), 
            ((activity.start + activity.duration) * time-scale, (y-offset + height) * usage-scale),
            fill: activity.color.lighten(20%), 
            stroke: 2pt + activity.color.darken(30%)
          )
          
          content(
            (activity.start * time-scale + 0.6, (y-offset + height/2) * usage-scale), 
            text(size: 9pt, weight: "bold", fill: white, activity.name)
          )
    }
    
    // Add capacity line (assuming capacity = 3)
    line((0, 2 * usage-scale), (horizon * time-scale, 2 * usage-scale), 
         stroke: (paint: gray, dash: "dashed", thickness: 1pt))

    content((horizon * time-scale + 0.8, 2 * usage-scale), text(size: 9pt, [Capacity]))
  })
`

compileAll([
    [cumulFigure, 'src/lib/assets/cumulFigure.svg'],
    [cumulFigureBad, 'src/lib/assets/cumulFigureBad.svg'],
    [cumulFigureClaim, 'src/lib/assets/cumulFigureClaim.svg'],
    [cumulFigureConfl, 'src/lib/assets/cumulFigureConfl.svg']

])