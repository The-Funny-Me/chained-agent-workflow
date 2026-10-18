# Chain contract

The planner writes this before any worker starts. Stages are the only units of delegation.

## Chain

```text
goal: <one paragraph>
stages:
  - id: <kebab-case>
    role: worker | verifier
    depends_on: [<stage id>, ...]
    outcome: <one sentence>
    writable: [<path>, ...]
    forbidden: [<path>, ...]
    done_when:
      - <observable condition>
    proof: <command or inspection>
```

Rules for the chain:

- `id` values are unique.
- `depends_on` lists only earlier stage ids. A cycle is an invalid chain; rewrite it.
- A `worker` stage lists every path it may create or edit. An empty `writable` list means the stage is read-only.
- A `verifier` stage has an empty `writable` list.
- `done_when` is something a later agent can check without trusting the worker's summary.
- `proof` is a command, a test name, or a specific file inspection. "Look around" is not proof.
- The last stage id is `verify`, with `role: verifier`, and it depends on every worker stage that must be true for the goal.

## Ready wave

A stage is ready when every id in `depends_on` is accepted. Dispatch all ready stages together, at most four. If five or more are ready, dispatch the four that unblock the most dependents and hold the rest for the next wave.

Two ready workers that list the same writable path are not ready together. Keep the one that appears first in the chain and hold the other.

## Handoff

The worker's final message is the handoff. Later stages may use this and nothing else from that worker.

```text
stage: <id>
status: done | blocked | failed
summary: <what this stage accomplished, in a few sentences>
changed:
  - <path>
decisions:
  - <decision the planner must carry forward>
proof:
  - check: <the contract proof>
    result: <pass or fail, with the relevant output>
follow_ups:
  - <work that belongs to a later stage, or "none">
risks:
  - <risk, or "none">
```

Accept a handoff only when all of these hold:

- `status` is `done`.
- Every `done_when` condition is supported by a `proof` entry whose result is pass.
- Every path under `changed` is inside `writable`.
- `summary` does not claim work outside `outcome`.

Reject by naming the contract line that failed. Do not accept a handoff and "note" a missing proof.

`blocked` means the stage lacks an input the planner must supply. Add that input and dispatch again; this does not count as the one retry.

`failed` counts as the one retry. The retry prompt includes the rejected handoff and the contract line.

## Example

Goal: add a health endpoint and prove the server answers.

```text
goal: Add GET /health that returns 200 and {"ok": true}, covered by a test.
stages:
  - id: route
    role: worker
    depends_on: []
    outcome: GET /health returns 200 and {"ok": true}.
    writable: [src/health.ts, src/server.ts]
    forbidden: [test/]
    done_when:
      - A request handler for GET /health exists and returns {"ok": true}.
    proof: rg -n "health" src/health.ts src/server.ts
  - id: test
    role: worker
    depends_on: [route]
    outcome: An automated test requests GET /health and expects 200 and {"ok": true}.
    writable: [test/health.test.ts]
    forbidden: [src/]
    done_when:
      - test/health.test.ts fails if the body is not {"ok": true}.
    proof: npm test -- test/health.test.ts
  - id: verify
    role: verifier
    depends_on: [route, test]
    outcome: The goal holds on a clean run of the proof.
    writable: []
    forbidden: [src/, test/]
    done_when:
      - npm test -- test/health.test.ts exits 0.
      - The handler still returns {"ok": true}.
    proof: npm test -- test/health.test.ts
```

`route` and `test` do not share a wave, because `test` depends on `route`. `verify` runs after both are accepted.
