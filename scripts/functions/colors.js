/**
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

export const red = (str) => `\x1b[31m${str}\x1b[0m`;
export const green = (str) => `\x1b[32m${str}\x1b[0m`;
export const yellow = (str) => `\x1b[33m${str}\x1b[0m`;
export const blue = (str) => `\x1b[34m${str}\x1b[0m`;
export const magenta = (str) => `\x1b[35m${str}\x1b[0m`;
export const cyan = (str) => `\x1b[36m${str}\x1b[0m`;
export const white = (str) => `\x1b[37m${str}\x1b[0m`;
export const black = (str) => `\x1b[30m${str}\x1b[0m`;
export const bgRed = (str) => `\x1b[41m${str}\x1b[0m`;
export const bgGreen = (str) => `\x1b[42m${str}\x1b[0m`;
export const bgYellow = (str) => `\x1b[43m${str}\x1b[0m`;
export const bgBlue = (str) => `\x1b[44m${str}\x1b[0m`;
export const bgMagenta = (str) => `\x1b[45m${str}\x1b[0m`;
export const bgCyan = (str) => `\x1b[46m${str}\x1b[0m`;
export const bgWhite = (str) => `\x1b[47m${str}\x1b[0m`;
export const bgBlack = (str) => `\x1b[40m${str}\x1b[0m`;
export const gray = (str) => `\x1b[90m${str}\x1b[0m`;
export const lightGray = (str) => `\x1b[37m${str}\x1b[0m`;
export const reset = (str) => `\x1b[0m${str}\x1b[0m`;
