<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# README DNA Guide

Follow this guide for the README of a DNA repo — a repo that ships a
hand-authored `dna/` folder. For every other repo follow the
[README Guide](./readme-guide.md).

## Copy the template

- Copy `doc/templates/readme-dna-template.md` to `README.md`
- Drop every section this layer has nothing for
- Write the README in english only, a DNA layer carries no `README.de.md`

## Say what the layer does

- Open with one sentence: what a repo gets by adding this layer
- Name the topic it owns, not the machinery behind it
- Name what it deliberately leaves to other layers

## List what the layer ships

- Give guides, templates, skills, scripts and configuration their own
  section
- Name each file with its path below `dna/` and one line on its purpose
- Name a skill by the command a user types, e.g. `/translate`
- Say which guide calls a script

## Name the layers it builds on

- List the parent layers from `dna/_dna.json`, each linked to its repo
- Say what each parent contributes, not just its name
- State that the layer is orthogonal when it has no parents
- Name the sections it extends in a parent, and the tag it uses

## Document the variables

- List every variable of `dna/_vars.json` a consuming repo overrides
- Give the meaning, not the default value

## Keep it current

- Update the README in the same change that adds or removes a DNA file
