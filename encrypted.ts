

export const salt = Uint8Array.from([
    59, 43, 199, 35, 129, 113, 2, 223, 131, 162, 8, 205, 12, 241, 28, 53
]);

export const iv = Uint8Array.from([
    55, 140, 134, 225, 151, 2, 103, 200, 202, 129, 39, 188
]);

export const cypherText = [
    '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',
    'hMn2ikpyDmmA'
].join('');

