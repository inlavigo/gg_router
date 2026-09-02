/**
 * @license
 * Copyright (c) ggsuite
 *
 * Use of this source code is governed by terms that can be
 * found in the LICENSE file in the root of this package.
 */

// checkRepo.js
import { execSync } from 'child_process';

export function isCleanRepo(path) {
  const cwd = path ?? '.';

  try {
    // Aktuellen Branch ermitteln
    const branch = execSync('git rev-parse --abbrev-ref HEAD', {
      cwd,
    })
      .toString()
      .trim();
    if (branch !== 'main') {
      return false;
    }

    // Git-Fetch ausführen (still)
    execSync('git fetch', { stdio: 'ignore', cwd });

    // Prüfen, ob Arbeitsverzeichnis sauber ist
    const status = execSync('git status --porcelain', { cwd })
      .toString()
      .trim();
    if (status.length > 0) {
      return false;
    }

    // Prüfen, ob main auf dem neuesten Stand mit origin/main ist
    const revList = execSync(
      'git rev-list --left-right --count origin/main...main',
      { cwd },
    )
      .toString()
      .trim();

    const [behind, ahead] = revList.split('\t').map(Number);
    return behind === 0 && ahead === 0;
  } catch (err) {
    console.error('Git error:', err.message);
    return false;
  }
}
