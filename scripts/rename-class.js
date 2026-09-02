#!/bin/node

import fs from 'fs';
import path from 'path';
import { blue, gray, green, red, yellow } from './functions/colors.js';

// .............................................................................
const excludedFiles = ['create-new-repo.md', 'rename-class.js'];

// .............................................................................

const isExcluded = (fileName) => {
  return excludedFiles.includes(fileName);
};

const shouldProcessFile = (file) => !isExcluded(file);

// Binary files must not be rewritten as UTF-8, that would corrupt them.
const readTextFile = (fullPath) => {
  const buffer = fs.readFileSync(fullPath);
  if (buffer.includes(0)) return null;
  return buffer.toString('utf8');
};

const writeTextFile = (fullPath, oldContent, newContent) => {
  if (newContent === oldContent) return;
  fs.writeFileSync(fullPath, newContent, 'utf8');
};

if (process.argv.length < 4) {
  const usage = red('Usage:');
  const script = yellow(path.basename(process.argv[1]));
  const classA = green('ClassA');
  const classB = blue('ClassB');
  console.error([usage, script, classA, classB].join(' '));
  process.exit(1);
}

const classA = process.argv[2];
const classB = process.argv[3];

const toSnakeCase = (str) => {
  return str.replace(/(?<=[a-z0-9])([A-Z])/g, '-$1').toLowerCase();
};

const toLowerCamelCase = (str) => {
  return str.replace(/([-_]\w)/g, (matches) => matches[1].toUpperCase());
};

const toUpperCamelCase = (str) => {
  return str.replace(/(?:^|[-_])(\w)/g, (_, c) => (c ? c.toUpperCase() : ''));
};

const classALower = toLowerCamelCase(classA);
const classBLower = toLowerCamelCase(classB);
const classAUpper = toUpperCamelCase(classA);
const classBUpper = toUpperCamelCase(classB);
const classASnake = toSnakeCase(classA);
const classBSnake = toSnakeCase(classB);
const classASnakeUnderscore = classASnake.replace(/-/g, '_');
const classBSnakeUnderscore = classBSnake.replace(/-/g, '_');

const replaceIncludesFirst = (directory) => {
  const files = fs.readdirSync(directory, { withFileTypes: true });

  for (const file of files) {
    const fullPath = path.join(directory, file.name);

    if (file.isDirectory()) {
      if (file.name.startsWith('.') || file.name === 'node_modules') continue;
      replaceIncludesFirst(fullPath);
    } else if (shouldProcessFile(file.name)) {
      const original = readTextFile(fullPath);
      if (original === null) continue;
      const content = original
        .replace(
          new RegExp(`(\\/)${classASnake}(\\.ts)?([\\.\\/\\'\\\"\\\\])`, 'g'),
          `$1${classBSnake}$2$3`,
        )
        .replace(
          new RegExp(
            `(\\/)${classASnakeUnderscore}(\\.ts)?([\\.\\/\\'\\\"\\\\])`,
            'g',
          ),
          `$1${classBSnakeUnderscore}$2$3`,
        );
      writeTextFile(fullPath, original, content);
    }
  }
};

const replaceInFiles = (directory) => {
  const files = fs.readdirSync(directory, { withFileTypes: true });

  for (const file of files) {
    const fullPath = path.join(directory, file.name);

    if (file.isDirectory()) {
      if (file.name.startsWith('.') || file.name === 'node_modules') continue;
      replaceInFiles(fullPath);
    } else if (shouldProcessFile(file.name)) {
      const original = readTextFile(fullPath);
      if (original === null) continue;
      const content = original
        .replace(new RegExp(classAUpper, 'g'), classBUpper)
        .replace(new RegExp(classALower, 'g'), classBLower)
        .replace(new RegExp(classASnake, 'g'), classBSnake)
        .replace(
          new RegExp(classASnakeUnderscore, 'g'),
          classBSnakeUnderscore,
        );
      writeTextFile(fullPath, original, content);
    }
  }
};

const renameFiles = (directory) => {
  const files = fs.readdirSync(directory, { withFileTypes: true });

  for (const file of files) {
    const fullPath = path.join(directory, file.name);

    if (file.isDirectory()) {
      if (file.name.startsWith('.') || file.name === 'node_modules') continue;
      renameFiles(fullPath);
    } else if (
      file.name.includes(classASnake) ||
      file.name.includes(classASnakeUnderscore)
    ) {
      const newFileName = file.name
        .replace(classASnake, classBSnake)
        .replace(classASnakeUnderscore, classBSnakeUnderscore);
      fs.renameSync(fullPath, path.join(directory, newFileName));
    }
  }
};

console.log(gray('Replacing includes first...'));
replaceIncludesFirst('.');

console.log(gray('Renaming files...'));
renameFiles('.');

console.log(gray('Replacing occurrences in files...'));
replaceInFiles('.');

console.log(green('Done.'));
