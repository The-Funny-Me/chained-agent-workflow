# chained-agent-workflow

A Cursor skill for large coding tasks. The planner writes a chain, dispatches one ready wave of workers, and advances only when a handoff matches that stage's contract. The last link is a verifier.

## Install

```bash
git clone https://github.com/The-Funny-Me/chained-agent-workflow.git
cd chained-agent-workflow
./unpack.sh
```

`unpack.sh` copies `contents/` to `~/.cursor/skills/chained-agent-workflow/`. It does not ask for a password and it does not use root. Set `CURSOR_SKILLS_DIR` when the skills directory should be somewhere else.

Open a new Agent chat and invoke `/chained-agent-workflow`.

## Layout

```text
├── README.md          how to clone and unpack
├── unpack.sh          installer
├── LICENSE
└── contents/          skill payload copied into ~/.cursor/skills/
    ├── SKILL.md
    └── references/
        ├── chain-contract.md
        └── roles.md
```

## Use

After unpack, Cursor loads the skill from the user skills directory. Invoke it when a task should be planned first and then carried out as a chain of agents.
