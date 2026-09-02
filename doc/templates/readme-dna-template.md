<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# <dna_name>

<One sentence: what a repo gets by adding this layer.>

<Optional: what this layer deliberately leaves to other layers.>

## Guides

- `dna/doc/guides/<topic>-guide.md` — <what it tells the reader to do>

## Templates

- `dna/doc/templates/<topic>-template.md` — <what it is a template for>

## Skills

- `/<command>` — <what it checks or produces, and which guide it follows>

## Scripts

- `dna/scripts/<name>.js` — <what it does, and which guide calls it>

## Configuration

- `dna/dot-github/workflows/<name>.yaml` — <which pipeline it defines>
- `dna/dot-vscode/<name>.json` — <which editor setting it contributes>

## Layers

<Which parents this layer builds on and what each contributes — or that
it is orthogonal and carries only its own topic.>

<Which section of a parent it extends, and under which tag.>

## Variables

- `dnaXxx` — <what a consuming repo sets it to>

## Usage

Declare it as a dev-dependency and initialize once:

```bash
pnpm add -D @<scope>/<npm-name>   # TypeScript projects
dart pub add dev:<dart_name>      # Dart projects
helix init
```

The placed test instantiates and verifies the DNA on every test run.

## Development

The `dna/` folder is hand-authored source and is never generated. The repo
instantiates its own DNA — run `dart test` after changes; commit first, a
file the DNA would overwrite must not carry uncommitted work.
