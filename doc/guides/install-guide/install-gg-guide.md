<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Install gg

`gg` is the unified Dart CLI used for development at ggsuite. It runs
pre-commit checks in a single repository and orchestrates commits, pushes,
reviews and publishes across all repositories of a ticket.

## Prerequisites

Install [Flutter](./install-flutter-guide.md) first. It provides the `dart`
command used below.

```bash
dart --version
```

## Install gg

```bash
dart pub global activate gg
```

## Add the pub cache to your PATH

Globally activated Dart executables are installed into the pub cache. Add its
`bin` folder to your `PATH`, otherwise the `gg` command will not be found.

Mac and Linux:

```bash
echo 'export PATH="$HOME/.pub-cache/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

On Windows, add the following folder to your `Path` environment variable:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

Restart your terminal afterwards.

## Verify installation

```bash
gg --help
```

## Update gg

Run the activation again to install the latest version:

```bash
dart pub global activate gg
```

## Usage

`gg` is ticket driven: run it inside a ticket and every action applies to
all repositories that belong to that ticket.

```bash
gg                # the command groups: do, can, did
gg do -h          # everything you can act on
gg can commit     # check before committing
```

See also the [Develop Guide](../develop-guide.md).
