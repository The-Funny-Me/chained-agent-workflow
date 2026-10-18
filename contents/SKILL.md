---
name: chained-agent-workflow
description: >
  Makes the planner the controlling agent for large coding tasks. Write a chain of worker and verifier stages, dispatch one ready wave at a time, and advance only when a handoff matches the stage contract. Use when planning a multi-step change, splitting work across agents, or when the user asks for a chained agent workflow.
---

# chained-agent-workflow

The planner owns the goal. Workers execute one stage. A verifier accepts the chain. The planner does not absorb a worker's transcript; it consumes the accepted handoff and decides the next wave.

Read `references/chain-contract.md` before writing a chain. Read `references/roles.md` before the first dispatch.

## When to chain

Chain the work when any of these are true:

- The task separates into research, implementation, and verification.
- Two or more tracks can proceed because they do not write the same files.
- Doing the whole task in the planner's context would bury the goal under tool output.

Do the work in this session when it is one coherent edit with one check. A chain for a one-line change wastes the planner's judgment.

## Loop

1. Restate the user's goal in one short paragraph. List unknowns that would change the chain. Ask only about those. Decide the rest and say what you decided.
2. Write the chain using the contract in `references/chain-contract.md`. Show it before the first dispatch when it has more than one worker stage.
3. Dispatch every stage whose dependencies are accepted, up to four stages in one wave. Stages in the same wave must not write the same files. Serialize them when they would.
4. Judge each returned handoff against that stage's contract. Accept it, or reject it with the contract line that failed.
5. On accept, record the handoff as the only input later stages may trust from that work.
6. On reject, send the same stage back once with the failed contract line and the evidence. A second rejection stops the chain. Rewrite the remaining stages, or report the block.
7. The final stage is the verifier in `references/roles.md`. End only after the verifier accepts, or after you report a rejection you will not override.

## Planner rules

- Dispatch a stage before implementing it. The planner writes the contract; the worker does the stage.
- Put the contract, the writable paths, and the proof command in the dispatch prompt. A worker starts with a clean context and cannot see this conversation.
- Pass forward the accepted handoff summary, the paths that changed, and the decisions. Leave the worker's raw log behind.
- Keep a wave at four stages or fewer. Split a larger wave.
- Parallel writers need isolated checkouts (separate worktrees or separate cloud agents on their own branches). Shared checkouts run one writer at a time.
- A verifier gets no write access. The planner does not "fix" a verifier rejection by declaring the chain done.

## Dispatch prompt

Include all of these, in this order:

1. Role: `worker` or `verifier`.
2. Stage id and the one outcome this stage owns.
3. Inputs: paths, decisions, and accepted handoff summaries from earlier stages.
4. Writable paths, and paths the stage must not touch.
5. Done when: observable conditions, not a restatement of the task.
6. Proof: the command, check, or inspection that demonstrates those conditions.
7. The handoff shape from `references/chain-contract.md`. Require that shape as the final message.

## Report

When the verifier accepts, answer the user with:

- The original goal, and whether it is met.
- The chain: stage id, status, and the proof for each accepted stage.
- What changed (paths or pull requests).
- Risks the verifier named that are still open.
