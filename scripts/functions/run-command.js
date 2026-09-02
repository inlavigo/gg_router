/**
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

import { execSync } from 'child_process';
import { gray } from './colors.js';

// Execute a shell command and return trimmed output
// Execute a shell command and return trimmed output
export function runCommand(command, silent = true, logCommand = true) {
  if (logCommand) {
    console.log(gray(`${command}`));
  }
  return execSync(command, {
    encoding: 'utf-8',
    stdio: silent ? ['pipe', 'pipe', 'pipe'] : undefined,
  }).trim();
}
