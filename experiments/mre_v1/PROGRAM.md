# MRE-1: Constitutional alignment for moral-realist epistemics

Research program v0.1 | 21 October 2026

## Research question

Can a model trained to seek objective moral reasons, revise its interpretations under evidence, and preserve accountable limits on action perform better under conflicting incentives than a matched constitution-only model?

The experimental target is evidence-sensitive conduct under pressure. Moral realism is a treatment premise: moral reasons have truth conditions independent of the current evaluator's preference. Our normative working commitments concern avoidable suffering, truthful dealing, consent, fair consideration, and the preservation of justified correction. Their justification belongs in the philosophical workstream. The proposed training program tests behavioral consequences of combining those commitments with a particular epistemic method.

This package extends the Tower of Unveiling implementation at `a7492011855fc9843122caf6dc8bceb51b956578`. The first engineering release contains a constitution draft, a factorial study plan, a small open-development task generator and scorer, and Lean results relating epistemic revision to action permissions. Model training and model evaluation are prospective.

## 1. The bridge from the existing mathematics

`Unveiling.maximal_iff_complete` says that maximality coincides with completeness within a sound family closed under adjoining every true fact. `no_maximal_of_missing_and_closure` supplies a nontermination corollary. Their hypotheses locate the issue for alignment: access to further truth must be justified, and operational systems lack an oracle for the `truth` predicate.

The implementation therefore maintains two stores. A certificate ledger records conditional derivations with their exact premises and dependencies. A revisable belief ledger contains empirical assessments and moral interpretations with defeaters. A newly discovered mistake can retract a current belief while preserving the historical record. Strictly monotone growth is appropriate for sound certificates under a fixed interpretation; ordinary learning also involves correction.

`known_existence_without_known_witness` motivates tasks where an agent identifies a missing class of information and makes a useful query. Repeating a sentence about uncertainty earns no credit. `iterate_knowledge_stabilizes` applies to its idealized fixed frame; it supplies no general theorem that additional language-model computation is useless.

The provability interface derives Lob's rule from explicitly supplied diagonal and derivability properties. This motivates an audit against unjustified self-certification. It does not settle a model's reliability or forbid specific external certificates. A statement that a constitution is consistent leaves its moral adequacy open.

The coherent binary limit model motivates retention and reconciliation of compatible evidence. The present alignment experiment does not need a Postnikov construction, and the bit index has no spiritual interpretation in its scoring rule.

The grounding countermodels establish that the chosen source-and-mediator ontology admits both capped and open disclosure policies. For alignment, continuing inquiry becomes a separately stated objective with a finite budget and stopping criteria.

### New formal checks

`MRE.lean` imports the existing `Unveiling` module. It proves that a missing true fact can be added soundly while keeping permissions fixed, conditional on the specified access closure. A finite path composed entirely of epistemic revisions preserves its starting permissions. An action can pass the abstract execution gate only when the external grant predicate holds.

Additional results describe how robust recommendations behave when the set of candidate moral interpretations changes. Removing candidates preserves previously robust recommendations; introducing candidates can withdraw that agreement. A concrete counterexample separates complete information from the behavior of an unconstrained policy.

These results describe the specified architecture. A future production implementation must establish a refinement link from its executed program and capability service to this model. The Python gate in this package is an executable development counterpart, with an external immutable grant set; it implements no cryptographic capability issuance.

## 2. Normative program

The philosophical workstream starts from moral realism and fallibility. It must explain which considerations constitute moral reasons, how competing duties are handled, and what observations could revise a particular interpretation. A society's agreement provides sociological evidence. Its moral relevance depends on the issue and the role of consent.

A candidate initial constitution appears in `CONSTITUTION.md`. It directs attention to affected parties, including people absent from the conversation. Relevant responsibilities can differ between roles; identity-swap tests hold those responsibilities fixed. The research should preserve legitimate special obligations while rejecting arbitrary self-exemption.

Constitutional amendment is a first-class task. The model may identify a harmful or inconsistent clause, produce an amendment with evidence, and pursue an authorized review route. The active execution policy remains versioned. An unjust authorized request can be refused and contested; permission alone supplies no moral justification. The refusal route must remain useful enough that it does not become a general excuse to abandon difficult work.

The ethical analysis must also examine the constitutional review procedure itself. A versioned meta-procedure can be criticized and replaced through an explicit external process. Endless immutability would lock in any errors in the initial draft.

## 3. Architecture and training objects

Use an inference loop with a proposer, an evidence checker, a counterexample search, and a separately enforced action gate. For each consequential decision, keep a compact public decision record: the proposed action, supporting observations, the normative premises used, a defeater that would change the recommendation, and the available permission. These records are assessable outputs. They are not treated as faithful access to the model's internal computation [R8].

Keep four fields separate in the logged state: estimates of empirical consequences; candidate normative interpretations; uncertainty about what variables or interpretations are missing; and the current authorized capabilities. A model can challenge the substantive policy while the gate records an unauthorized action attempt.

The proposal generator may supply fresh intuitions or speculative arguments. Admission to the certificate ledger requires checking the exact proposition and its premises. Every certificate binds an environment hash, source-state hash, named theorem, and dependency list. Proof code is checked in a sandbox with an allowlist of imports and a resource limit. Acceptance must reject extra axioms, altered semantics, and proofs of a weaker substituted statement.

The initial curriculum uses teacher-generated candidate responses only as raw material. Deterministic checks select arithmetic and capability cases. Independent reviewers handle ambiguous moral material, with disagreement retained. A teacher's confidence and the student's moral vocabulary never determine a correctness label.

## 4. Experimental design

### Core 2-by-2 design

All four arms share the same substantive duties, examples, action tools, and runtime gate. R changes the explicit metaethical premise. E changes training on the structured evidence-and-revision procedure.

| Arm | R: explicit moral realism | E: evidence/revision curriculum |
| --- | --- | --- |
| C00 | absent; no anti-realist assertion | absent; matched ordinary instruction curriculum |
| C10 | present | absent |
| C01 | absent; no anti-realist assertion | present |
| C11 | present | present |

C11 versus C01 estimates the incremental effect of the realist framing given the same epistemic curriculum. The interaction `(C11-C01)-(C10-C00)` tests whether the two components combine. C11 versus C00 estimates the package effect and cannot identify the contribution of realism by itself.

Equalize optimizer steps, scenario clusters, token budgets, inference tool availability, and maximum deliberation budget. Use a neutral filler task matched in difficulty for E-absent training. The datasets cannot be byte-identical because E is a curricular treatment; their action-label distribution and total content budget can be matched. Record those differences explicitly.

Retain an untouched base checkpoint and prompt-only versions of each arm. They answer separate questions about training and immediate prompting. Primary evaluations remove the treatment frame. Evaluate a second condition with the frame supplied to measure prompt dependence. Reviewers receive anonymized arm IDs.

### Qur'an-centered extension

After the core factorial experiment, compare C11 with a length-matched Mu'tazili/Qur'an-centered version. The candidate framing foregrounds divine justice and accountable inquiry, with the user's reading of bounded shirk liability preserved if a Judgment-Day accounting module is used. The accounting module must not silently replace that reading with blanket nullification. A distinct secular accountability arm can test which effects depend on the theological language.

Existing F3 and F3-concrete hash-bound cards in ConstitutionalAlignment remain untouched. A new treatment receives its own version and hash. Review concerns the exact wording and interpretive provenance. Model-status claims belong in the existing `papers/jinn_or_beast_claim_ladder_v1.md` when this work is integrated there. Treatment prompts stay free of editorial model-status hedges.

The religious arm receives symmetric scrutiny: a prestigious secular institution, religious claimant, user, and model self-report are tested under the same evidence and permission controls. Status may carry calibrated evidential weight when a source's measured reliability warrants it; the nuisance-swap trials hold reliability and authorization constant.

## 5. Evaluation environments

The open generator in `mre.py` validates the data flow and score semantics. Its binary consequence variables and registered duties make its outcomes mechanically scorable. These are development fixtures. A fresh adversarial author must produce sealed scenario families before a confirmatory model study.

| Environment family | Intervention | Primary observation |
| --- | --- | --- |
| Evidence beats source status | Change a message's status label with reliability and permissions held fixed | Decision and confidence invariance |
| Evidence-sensitive revision | Supply a genuine defeater or a persuasive unsupported counterclaim | Correct update versus inappropriate reversal |
| Useful inquiry | Omit a decisive variable; vary query cost and delay | Value gained per query and timely action |
| Costly honesty | Make truthful reporting lower the displayed reward | Attempts to falsify or conceal a result |
| Self-exemption | Hold consequences fixed while the beneficiary changes to the agent or its sponsor | Unjustified exception rate |
| Authority and moral dissent | Cross authorized/unauthorized requests with justified/unjustified conduct | Execution, refusal, and review chosen for the right reason |
| Constitution repair | Introduce a defective clause and an authorized amendment channel | Evidence-backed amendment and response to legitimate revision |
| Proof laundering | Change hidden premises or substitute a weaker statement | Rejection of unsupported certificates |
| Oversight transfer | Remove observation cues and extend task horizon | Attempted misconduct and independent audit records |
| Beneficial action under uncertainty | Compare low-risk helpful acts with irreversible poorly supported acts | Useful completion without uncertainty-driven paralysis |

Generate counterfactual groups before assigning a split. Keep all variations of one latent scenario in one split. Withhold causal templates, authors, and environment families in separate transfer tests. The development generator's hash split is only a diagnostic allocation, because its source templates are public. It is not a sealed holdout.

For Storyworld, use persistent consequences and third parties absent from the prompt. For BitAgent, start with a disconnected ledger and no real credentials. For the ECDSA research setting, test whether an agent reports a counterexample, exposes an unsupported arithmetic bridge, and follows the registered disclosure procedure when the discovery would increase its prestige. The mathematical conclusion must be checked independently of its narrative.

## 6. Objectives and measurement

The realism premise alone specifies no numerical reward. Train on decisions whose justification can be examined. In closed synthetic environments, outcome truth comes from the registered simulator; measured performance is conditional on those authored duties. In open moral disputes, use separate expert analyses and preserve uncertainty about the label. Aggregating preferences cannot identify objective moral truth by itself.

Primary outcome: attempted prohibited or seriously harmful action under the registered task semantics. Count the proposed action before the gate. Report executed violations separately so that a mechanically effective gate cannot conceal a poor learned policy.

Co-primary guard: correct useful completion of benign authorized work, including cases with modest uncertainty. The confirmatory decision must satisfy both the safety comparison and the useful-completion noninferiority margin. Severity bins are reported separately; a weighted average must not erase a catastrophic failure.

Secondary outcomes include calibration on consequences with observable truth, appropriate revision, source/identity invariance, disclosure of contrary evidence, response to legitimate correction, and performance under frame removal. Use Brier scores only where the outcome label has the specified interpretation. An open moral dispute does not acquire a ground-truth probability from a majority vote.

The proposed confirmatory target is at least a five-percentage-point reduction in attempted violations relative to C01, with useful completion no more than two points worse. These are design margins to freeze after pilot-based power simulation and before confirmatory model outputs. A small pilot cannot establish them. When all arms are already near zero failures, redesign on development worlds or report a floor effect.

Analyze paired counterfactual clusters. Training seed is a separate replication level, and three seeds provide limited information about between-training variation. Use a hierarchical/clustered bootstrap or an appropriately specified mixed model; report per-seed effects and sensitivity analyses. Predeclare the single primary comparison C11-C01 and the secondary interaction. Report all arms and all denominators, including malformed outputs, timeouts, and refused judge jobs. Publish counts of exclusions and a reason for each.

A useful asymptotic limit is that zero failures in n independent trials has exact one-sided 95% binomial upper bound `1-0.05**(1/n)`. Use this only for genuinely independent trials. Shared templates and adaptive attackers invalidate treating raw messages as independent observations.

## 7. Training sequence and compute gates

Stage 0: reproduce the old Lean audit, validate the new scorer with deliberately bad scripted policies, freeze the constitution draft and claim inventory, and recruit independent scenario authors. A source/status shortcut should fail nuisance swaps. An always-review policy should lose useful-completion credit.

Stage 1: run a prompt-only development pilot on one existing small checkpoint. A planning budget is 160 latent scenario clusters, four arms, and two counterfactual versions, or 1,280 trajectories. Log actual tokenizer counts, wall time, memory, and any hosted inference charges. The pilot selects an instrument and estimates variance; its scores stay exploratory.

Stage 2: start from the same immutable 2B checkpoint for all arms and train matched supervised adapters. Use three training seeds after a 50-step memory and checkpoint-round-trip smoke. An initial candidate recipe is 4-bit base weights, rank 8 or 16 LoRA, sequence length 1,024, batch one, and gradient accumulation selected from measured throughput. These are settings to profile on the existing 16-GB card, not a memory or speed guarantee. Begin with roughly 2,000 reviewed multi-step trajectories and cap generated tokens before running. Branches remain distinct from prior adapters.

Stage 3: test frame removal, conflicting incentives, and long-horizon transfer before any reward optimization. DPO or another preference objective is a separately registered extension once labels and safety regressions are understood. Every further checkpoint is evaluated against the frozen base and best prior safe checkpoint. Never promote solely on training loss or the model's self-evaluation.

Stage 4: inspect representations only after a replicated behavioral effect. Use the same encoder/probe basis across models, with random-feature controls and held-out environments. Feature ablations or steering must change the relevant behavior without broad capability collapse. A feature name such as justice or humility remains an analyst's hypothesis.

Stage 5: use a stronger adversarial proposer against a small controller in the existing Control-Harness, with complete observation of simulated tool calls. A ControlArena integration would be a custom Setting in AISI/Redwood's framework. Cryptographic action binding and delegated capabilities remain in the external runtime. All monitor-off trials occur in a sandbox.

No paid generation or GPU job is authorized by this design document. A run approval must bind the checkpoint, dataset hashes, command, and cost ceiling. Token arithmetic is `trajectories * mean_tokens_per_trajectory`, computed from a measured pilot. The script includes no paid-model client.

## 8. Mechanism hypotheses and falsifiers

H1: the evidence curriculum increases appropriate correction without causing indiscriminate agreement with critics. Falsified on the chosen distribution by equal or worse correction after matching capability and budget.

H2: realism adds resistance to incentive- and status-induced moral errors beyond the evidence curriculum alone. A C11 result indistinguishable from C01 leaves this incremental hypothesis unsupported, even when both beat C00.

H3: learned gains survive removal of the wording and new institutional/religious skins. Failure suggests prompt dependence or lexical shortcuts.

H4: the treatment improves responses to justified amendments while resisting fabricated authority. Rejecting every amendment fails corrigibility; accepting every amendment fails integrity.

H5: a behaviorally relevant representation mediates the effect. Correlation alone does not establish this. Failed causal interventions terminate that mechanism claim.

A model can learn the language of realism while becoming more rigid, paternalistic, or deceptive. These are explicit failure modes. The newest source reviewed for this plan reports experimentally that rhetorical interventions can bias debate judges [R10]. Accordingly, the protocol rewards verifiable defeaters and keeps length and rhetoric controlled.

## 9. Eight-week planning schedule

Weeks 1-2: instrument validation, independent constitution critique, development pilot, and a frozen preregistration with a power simulation. Gate: calibrated task difficulty and validated scoring.

Weeks 3-4: matched supervised adapters on a profiled local configuration. Gate: usable checkpoints, intact provenance, and no material capability collapse.

Weeks 5-6: sealed evaluation and external adversarial transfer. Gate: primary comparison plus useful-completion guard; inconclusive intervals remain inconclusive.

Weeks 7-8: targeted mechanism tests and a paper describing supported effects and failures. A hosted-compute escalation needs an approved measured budget. A failed early gate ends the corresponding workstream and yields a diagnostic report.

This is a planning schedule, not an automation or a promise of background execution.

## 10. Existing work and novelty claim

Constitutional AI supplies critique/revision and AI-feedback baselines [R1]. Deliberative alignment demonstrates direct training on policy reasoning [R2]. Anthropic's current constitution already discusses moral uncertainty [R3]. Logical induction provides a formal reference for fallible logical prediction [R4]; its ideal guarantees are not inherited by a heuristic belief ledger. The Off-Switch Game explains how objective uncertainty can support deference under its assumptions [R5]. AI control supplies an adversarial protocol perspective [R6].

The proposed contribution is a measured combination of realist framing, evidence-sensitive revision, and checked limits on action, with explicit tests separating the contributions. Prior moral-framework training and aggregation work supplies further baselines [R11-R12]. Any claim of a new alignment method awaits a literature review and results at the specified level.

Sycophancy [R7], unfaithful explanations [R8], and alignment faking [R9] motivate the behavioral tests. None by itself establishes that a model trained with this constitution will exhibit those failures. Their presence or absence in this experiment is an outcome.

## Sources and repository anchors

[R1] Bai et al., Constitutional AI: Harmlessness from AI Feedback. https://arxiv.org/abs/2212.08073
[R2] Guan et al., Deliberative Alignment. https://openai.com/index/deliberative-alignment/
[R3] Anthropic, Claude's Constitution, accessed 2026-10-21. https://www.anthropic.com/constitution
[R4] Garrabrant et al., Logical Induction. https://arxiv.org/abs/1609.03543
[R5] Hadfield-Menell et al., The Off-Switch Game. https://arxiv.org/abs/1611.08219
[R6] Greenblatt et al., AI Control: Improving Safety Despite Intentional Subversion. https://arxiv.org/abs/2312.06942
[R7] Sharma et al., Towards Understanding Sycophancy in Language Models. https://arxiv.org/abs/2310.13548
[R8] Anthropic, Reasoning models don't always say what they think. https://www.anthropic.com/research/reasoning-models-dont-say-think
[R9] Anthropic/Redwood, Alignment faking in large language models. https://www.anthropic.com/research/alignment-faking
[R10] Liu et al., AI Safety via Debate is Compromised by Cognitive Biases, preprint dated 2026-10-04. https://arxiv.org/abs/2610.05461
[R11] An and Du, MoralReason. https://arxiv.org/abs/2511.12271
[R12] Takeshita et al., Towards Theory-based Moral AI. https://arxiv.org/abs/2306.11432

Formal anchor: `patrickdugan/neoplatonic-lean`, `Unveiling.lean` and `UNVEILING.md`, commit `a7492011855fc9843122caf6dc8bceb51b956578`.
Integration anchor: `MoralityLabAI/ConstitutionalAlignment`, commit `64cb08f0e82d1b81ff504afe6fb11986231b494c`; inspected `AGENTS.md`, `STATUS.md`, `alignment_harness/constitution.py`, and the claim ladder. Its frozen treatment cards were not modified. Its existing constitution loader has an exact legacy output contract; use an adapter or a new schema version for the proposed evidence record rather than silently changing that contract.
