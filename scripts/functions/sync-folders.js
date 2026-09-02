/**
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

import * as fs from 'fs';
import * as path from 'path';

// Create a node.js script that recursively copies all files from one folder
// to another

export async function syncFolders(
  source,
  target,
  options = { excludeHidden: true },
) {
  if (!fs.existsSync(source)) {
    console.error(`Source folder "${source}" does not exist.`);
    return;
  }

  if (!fs.existsSync(target)) {
    await fs.promises.mkdir(target, { recursive: true });
  }

  const items = await fs.promises.readdir(source);

  for (const item of items) {
    if (options.excludeHidden && item.startsWith('.')) {
      continue; // Skip hidden files and folders
    }

    const sourcePath = path.join(source, item);
    const targetPath = path.join(target, item);

    const stat = await fs.promises.lstat(sourcePath);
    if (stat.isDirectory()) {
      await syncFolders(sourcePath, targetPath, options.excludeHidden);
    } else {
      await fs.promises.copyFile(sourcePath, targetPath);
    }
  }
}
