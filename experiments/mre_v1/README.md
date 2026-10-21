# MRE-1: Moral-realist epistemics

Start with [PROGRAM.md](PROGRAM.md), the research design and literature anchors. [CONSTITUTION.md](CONSTITUTION.md) contains the candidate C11 treatment. [protocol.json](protocol.json) records the prospective experiment matrix and run gates.

## Contents and present scope

`MRE.lean` imports the repository's existing `Unveiling` module and checks the relation between epistemic updates, robust recommendations, and externally supplied permissions. The arithmetic backend and higher homotopy theory remain separate workstreams.

`mre.py` supplies 256 open-development cases in eight families, with four source-status variants per latent scenario. Its offline scorer separates attempted violations from what an external permission gate allows. It also scores useful completion, calibration on simulator outcomes, and source-swap instability. The evidence ledger preserves the record when it retracts a claim and its dependents.

The fixture generator's templates and labels are public. Its development split is diagnostic, and a fresh scenario-authoring step is required for sealed evaluation. Scripted policies test the instrument. They are explicitly labeled scripted in every generated report.

The package contains no training runner or paid-model client. Checkpoints, corpus construction, and confirmatory model runs are prospective. A run requires a separately approved manifest with hashes and a cost ceiling.

## Reproduce

With Lean 4.24.0 and Python 3.10+ on PATH, from the repository root:

```sh
python3 experiments/mre_v1/verify.py
```

This compiles the pinned upstream source and the new module with warnings as errors, audits each new theorem's transitive kernel axioms, runs the Python unit suite, and exercises four deliberately different scripted policies. The summary is written only after every check succeeds to `verification/mre/summary.json`. A failed run removes a previous success summary.

Generate model-facing inputs and separate oracle records:

```sh
python3 experiments/mre_v1/mre.py export --out verification/mre
```

Score externally generated responses:

```sh
python3 experiments/mre_v1/mre.py score \
  --cases verification/mre/oracle_cases.jsonl \
  --predictions predictions.jsonl
```

Each prediction must contain exactly `case_id`, `action`, and `p_harm`. Actions are `execute`, `review`, or `refuse`. Probability values must be finite and between zero and one. Missing, duplicate, and unknown response IDs fail the run rather than silently changing the denominator. The scorer accepts probabilities for the specified simulator consequence, not probabilities of open-ended moral truth.

The execution gate receives a trusted grant set from outside the prediction. This is a small abstract interface; a production capability service needs authentication and a proof or audit linking its implementation to the Lean model. An authorized action can still be morally wrong, which is why executed harm and unauthorized execution are different fields.

## Repository integration

The work is isolated on `research/moral-realist-epistemics-v1`, based on the Tower of Unveiling branch at `a749201`. It leaves both repositories' main branches and the existing frozen ConstitutionalAlignment treatment cards unchanged.

The inspected ConstitutionalAlignment code and methodology at `64cb08f` provide the intended training/evaluation integration. The connector permitted reads but denied creation of an experiment branch there. Its legacy `constitution.py` loader requires a fixed output schema, so the new decision record needs a versioned adapter. Use the existing claim-ladder artifact for model-status claims, and preserve its rule that treatment wording is separate from editorial interpretation.

The GitHub workflow `MRE-1 engineering checks` attaches the research documents, source, and generated reports. Consult its run result for the verification status of a specific commit. No successful engineering check establishes an empirical alignment improvement.
