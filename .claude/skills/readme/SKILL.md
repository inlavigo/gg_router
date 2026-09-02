---
name: readme
description: Checks the README against the README guide and template and fixes what is missing. Use when the user says "/readme" or asks to write or review the README.
---

<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Readme

## 1. Pick the guide

A repo with a hand-authored `dna/` folder is a DNA repo: read
`doc/guides/readme-dna-guide.md` and
`doc/templates/readme-dna-template.md`.

Every other repo: read `doc/guides/readme-guide.md` and
`doc/templates/readme-template.md`.

## 2. Compare against the template

Check the README for the sections the template defines, in that order.

Report missing sections, sections in the wrong place, and sections that
carry content the guide places elsewhere.

## 3. Check the content

In a DNA repo, list `dna/` and report every guide, template, skill,
script and config file the README does not mention — and every entry it
mentions that no longer exists.

Elsewhere, verify that every code example runs unchanged and matches
`example/`, and that the documentation section links instead of
duplicating.

## 4. Fix

Write the corrections, then show the diff before committing.
