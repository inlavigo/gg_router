<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# Development guide for AIs

## Ask the developer for the ticket infos

- Ask for the ticket ID
- Ask for the ticket title
- Ask for the ticket description

## Replace in this document

- Replace `~/dev/` by the workspace directory from the memory
- Ask for the workspace directory if none is known
- Replace `gGS-145` by the ticket ID you asked for
- Replace `Fix issue abc` by the ticket title you asked for

## Create a ticket

```bash
cd ~/dev/ # workspace
gg do create ticket gGS-145 -m"Fix issue abc"
cd tickets/gGS-145
```

## Add git repositories

Look at the `index.jsonc` of each repo in .ocean and decide which repos need to
be added to the ticket.
Make a plan for how you roughly want to implement the ticket.
If certain parts of the implementation belong to a domain that does not yet
exist in the .ocean folder, consider creating a new repository.
Ask the user about this. Also explain to the user what you roughly want to
change in which repo to implement the ticket and let them confirm that the
corresponding repos are added to the ticket.

After the user's confirmation, add the repos to the ticket:

```bash
gg do add repo1 repo2
```

## Open the workspace in Vscode

```bash
gg do code
```

## Implement

Implement your features based on the guides

## Commit

```bash
gg do commit
```

## Push

```bash
gg do push
```

## Review

Let the user confirm that the review phase is started.

```bash
gg do review
```

gg creates pull requests for each repo and prints the URLs to the
terminal.

Afterwards load the review-light skill and execute it.

## Publish

- Create a blog post for the current ticket
- Update the index.jsonc and README.md
- Create the configuration for gg do publish

Ask the user to run the following command **manually**:

```bash
gg do publish
```

gg triggers the pull request merge and publishes the changes to the
registry. Finally the version tag is created and pushed.
