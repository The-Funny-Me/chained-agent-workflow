# Roles

Three roles run the chain. The planner is this session. Workers and the verifier are separate agents with a clean context.

## Planner

The planner is the session that loaded this skill.

- Write and revise the chain.
- Choose the ready wave.
- Compose each dispatch prompt from the contract plus accepted handoffs.
- Accept or reject handoffs.
- Talk to the user about the goal, the chain, and the final report.

The planner does not edit product code for a stage it has dispatched. Small discoveries while writing the chain (reading files, finding the right paths) stay with the planner. Implementation starts at dispatch.

When a worker must run on its own branch or VM, ask for an isolated checkout or a cloud agent for that stage. Record the branch or agent URL on the handoff the planner keeps.

## Worker

A worker receives one stage.

- Stay inside `writable`. Reading outside that list is fine. Writing outside it fails the stage.
- Satisfy `done_when` and run `proof`.
- Stop when the stage outcome is met. Do not start the next stage.
- Return the handoff shape in `chain-contract.md` as the final message.
- If the proof fails, set `status: failed` and include the output. Do not hide a failure behind `status: done`.

Launch workers for one wave together so they run at the same time. Wait for the wave before dispatching dependents.

## Verifier

The verifier is the last stage, `verify`.

- Read-only. It does not edit files, and it does not "fix" a failure.
- Re-run the proof from the chain. A proof the worker reported is not evidence until the verifier runs it.
- Compare the accepted handoffs and the resulting diff to the original goal.
- Return a handoff with `status: done` only when every goal condition holds.
- On failure, set `status: failed`, name the condition, and quote the command output. The planner treats that as a chain rejection, not as a suggestion.

The planner may dispatch one repair worker for a failed verification, with a new stage id, then run `verify` again. A second failed verification ends the chain. Report the goal, the failing condition, and the evidence.
