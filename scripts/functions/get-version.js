/**
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

import { readFile } from 'fs/promises';

export const getVersion = async () => {
  const packageJson = JSON.parse(await readFile('package.json', 'utf8'));
  return packageJson.version;
};
