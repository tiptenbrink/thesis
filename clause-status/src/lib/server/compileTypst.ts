import { exec } from 'node:child_process'

import { promises as fs } from 'node:fs'


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