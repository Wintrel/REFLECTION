const lines = [
" ├─ Sinks:",
" │      58. Easy Effects Sink                   [vol: 0.00]",
" │  *  175. Ryzen HD Audio Controller Analog Stereo [vol: 0.35 MUTED]",
" ├─ Sources:"
];
let inSinks = false;
for (const line of lines) {
    if (line.includes("Sinks:")) { inSinks = true; continue; }
    if (line.includes("Sources:")) { inSinks = false; continue; }
    if (inSinks) {
        const m = line.match(/^[^0-9\*]*(\*)?[^0-9]*(\d+)\.\s+(.*?)(?:\s+\[vol:.*\])?$/);
        if (m) console.log(m[1] === '*', m[2], m[3].trim());
    }
}
