// Logger console : [INFO], [STEP], [WARN], [ERROR], [DEBUG] + la "cartouche"
// d'info affichée avant chaque test (voir _common/types/test-info.ts).

import type { TestInfo } from '../_common/types/test-info';

const COLOR = {
    reset: '\x1b[0m',
    bold: '\x1b[1m',
    gray: '\x1b[90m',
    cyan: '\x1b[36m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    red: '\x1b[31m',
};

function timestamp(): string {
    return new Date().toISOString().split('T')[1]!.replace('Z', '');
}

function write(level: string, color: string, message: string) {
    console.log(`${color}[${level}]${COLOR.reset} ${COLOR.gray}${timestamp()}${COLOR.reset} ${message}`);
}

export const logger = {
    info: (message: string) => write('INFO', COLOR.cyan, message),
    step: (message: string) => write('STEP', COLOR.green, message),
    warn: (message: string) => write('WARN', COLOR.yellow, message),
    error: (message: string) => write('ERROR', COLOR.red, message),
    debug: (message: string) => write('DEBUG', COLOR.gray, message),

    /** Affiche la cartouche d'info d'un test, avant son exécution. */
    testInfo(info: TestInfo) {
        const lines = [
            `ID         : ${info.id}`,
            `Référence  : ${info.reference}`,
            `Titre      : ${info.title}`,
            ...(info.description ? [`Description: ${info.description}`] : []),
        ];
        const width = Math.max(...lines.map((l) => l.length)) + 2;
        const bar = '─'.repeat(width);

        console.log('');
        console.log(`${COLOR.bold}${COLOR.cyan}┌${bar}┐${COLOR.reset}`);
        for (const line of lines) {
            console.log(`${COLOR.bold}${COLOR.cyan}│ ${COLOR.reset}${line.padEnd(width - 1)}${COLOR.bold}${COLOR.cyan}│${COLOR.reset}`);
        }
        console.log(`${COLOR.bold}${COLOR.cyan}└${bar}┘${COLOR.reset}`);
        console.log('');
    },
};
