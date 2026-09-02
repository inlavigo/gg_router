---
name: publish
description: Prepares the release of a reviewed ticket and hands `gg do publish` over to the user. Use when the user says "/publish" or asks to release the ticket.
---

# Publish

`gg do publish` merges the pull requests, publishes to the registry and
creates and pushes the version tags. It is interactive — the user runs it.

## 1. Check the preconditions

- Every repo of the ticket is committed and pushed.
- The pull requests created by `gg do review` are green.

## 2. Configure the publish

```bash
gg do configure-publish
```

Check per repo that the version bump matches what the ticket changed and
that `CHANGELOG.md` reads well.

## 3. Let the user publish

Ask the user to run this **manually** from the ticket folder:

```bash
gg do publish
```

It asks whether the ticket and the remote feature branches may be deleted.
If the user declines, run `/cleanup` afterwards.

## Important

- Never run `gg do publish` yourself.
- Never write versions or tags by hand.
