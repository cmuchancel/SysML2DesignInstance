# 12-Slide Executive Outline

## Slide 1: Mission Objective
- Message: Convert one natural-language requirement into validated, sourceable design options.
- Visual: One-line mission statement from prompt.
- Evidence: `../prompt.txt`

## Slide 2: Input Requirement Definition
- Message: Mission constraints are explicit before modeling starts.
- Visual: Highlighted requirement bullets (5V, 10 Hz ±5%, 8-20 mA, >=8h runtime, sourceable COTS).
- Evidence: `../prompt.txt`

## Slide 3: SysML Requirements Formalization
- Message: Plain text is transformed into machine-checkable requirements.
- Visual: SysML requirement excerpt and requirement list.
- Evidence: `../deliverables/final.sysml`

## Slide 4: Concept Expansion to Three Architectures
- Message: The process preserves design optionality.
- Visual: Three concept cards (NE555-astable, Microcontroller-PWM, OpAmp-Relaxation).
- Evidence: `../concepts/auto_concepts.json`

## Slide 5: Design-Instance Structure
- Message: Each concept is converted into component slots for downstream solve and sourcing.
- Visual: Slot map per concept.
- Evidence: `../deliverables/design_instances.sysml`

## Slide 6: Optimization Problem Definition
- Message: Decision variables, bounds, objectives, and constraints are explicit per concept.
- Visual: One table with variables and objective/constraint categories.
- Evidence: `../optimization/concept_1/model.sysml` (repeat for concepts 2 and 3)

## Slide 7: Optimization Results (3/3 Success)
- Message: All concepts solved with numeric parameter outputs.
- Visual: Per-concept solved values and objective outcomes.
- Evidence: `../optimization/concept_1/best_solution.json`, `../optimization/concept_2/best_solution.json`, `../optimization/concept_3/best_solution.json`

## Slide 8: Optimized Design Writeback
- Message: Solved values are embedded back into design instances.
- Visual: Excerpt showing optimized attributes in each concept block.
- Evidence: `../deliverables/design_instances_optimized.sysml`

## Slide 9: Supplier-Constrained Part Selection
- Message: Optimization outputs are translated into sourceable parts under supplier policy.
- Visual: Slot-to-part mapping and supplier domain constraint (`mouser.com`).
- Evidence: `../deliverables/bom_optimized.json`

## Slide 10: Constraint Validation Gate
- Message: Candidate designs are validated post-sourcing.
- Visual: Pass/fail summary by concept.
- Evidence: `../deliverables/constraint_validation.json`

## Slide 11: End-to-End Traceability
- Message: Every decision is traceable from mission brief to selected parts.
- Visual: Pipeline chain diagram with artifact pointers.
- Evidence: `../summary_auto.json`

## Slide 12: Program Impact and Next Phase
- Message: Demonstration shows accelerated, auditable concept-to-feasibility workflow.
- Visual: KPI panel.
- Evidence: `../summary_auto.json`

## KPI panel values (use on slides 11-12)
- Concepts generated: 3
- Optimization solved: 3/3
- Parts selected: 12/12
- Validation pass: 3/3
- Infeasible concepts: 0
