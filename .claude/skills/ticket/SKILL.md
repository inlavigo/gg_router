---
name: ticket
description: Creates a gg ticket and adds the repos it needs. Use when the user says "/ticket", "new ticket", "fix bug X", or "implement feature Y".
---

# Create a ticket

All `gg do` commands run inside the workspace. Ask for the workspace
directory if none is known.

## 1. Ask for the ticket data

- Ticket ID, e.g. `GGS-145`
- Title, one imperative line, e.g. `Fix issue abc`

## 2. Create the ticket

```bash
cd ~/dev/ # workspace
gg do create ticket GGS-145 -m"Fix issue abc"
cd tickets/GGS-145
```

## 3. Choose the repos

Read the `index.md` of the candidate repos in `.ocean`. Tell the user which
repos the ticket needs and what you roughly want to change in each one. If a
part belongs to a domain that has no repo yet, say so and ask whether to
create one.

After the confirmation:

```bash
gg do add repo1 repo2
```

## 4. Open the workspace

```bash
gg do code
```

## Important

- Never add repos without confirmation. Rather too few than too many — more
  can be added later.
- Do not start the implementation unasked.
