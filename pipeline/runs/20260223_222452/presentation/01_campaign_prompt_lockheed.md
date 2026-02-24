# Campaign Prompt (Lockheed Martin Research Funders)

Use this prompt in your preferred presentation-writing assistant:

"""
Create an executive-grade, non-code demonstration narrative for Lockheed Martin research funders.

Context:
- Demonstration date context: February 24, 2026.
- Pipeline mission: transform one natural-language design brief into validated, sourceable hardware design options.
- Required flow: Natural-language brief -> SysML requirements -> concept generation -> 3 design instances -> optimization per instance -> optimized attribute writeback -> part selection with supplier constraint -> constraint validation -> final feasibility summary.

Audience:
- Technical research leaders and program sponsors.
- They care about traceability, feasibility, sourcing realism, and decision speed.

Tone:
- Evidence-driven, operational, and concise.
- No code snippets.
- No implementation internals beyond plain-language method explanations.

Required evidence from this run:
- Prompt source: `prompt.txt`
- SysML requirements artifact: `deliverables/final.sysml`
- Concepts artifact: `concepts/auto_concepts.json`
- Optimization solutions: `optimization/concept_1/best_solution.json`, `optimization/concept_2/best_solution.json`, `optimization/concept_3/best_solution.json`
- Optimized design artifact: `deliverables/design_instances_optimized.sysml`
- Parts sourcing artifact: `deliverables/bom_optimized.json`
- Constraint validation artifact: `deliverables/constraint_validation.json`
- Run summary artifact: `summary_auto.json`

Required factual outcomes to state:
- Exactly 3 concepts produced: NE555-astable, Microcontroller-PWM, OpAmp-Relaxation.
- Optimization status: 3/3 success.
- Part selection status: 12/12 slots selected, supplier-filtered to mouser.com.
- Constraint validation status: 3/3 pass.
- Infeasible concepts: none.

Build a 12-slide storyline:
1. Mission and relevance
2. Input requirement statement
3. Requirements formalization into SysML
4. Concept generation and architectural diversity
5. Design-instance construction
6. Optimization problem framing (variables, bounds, objectives, constraints)
7. Optimization outcomes for all three instances
8. Attribute writeback into design instances
9. Supplier-constrained part selection process
10. Constraint validation results
11. End-to-end traceability and decision-readiness
12. Program value and next-phase asks

For each slide, include:
- What is happening
- How it is happening
- Evidence artifact shown
- One crisp talk-track paragraph (50-90 words)

Close with three program-impact claims:
- Reduced concept-to-feasibility cycle time
- Increased requirements traceability to procurement decisions
- Higher confidence in design viability before physical prototyping
"""
