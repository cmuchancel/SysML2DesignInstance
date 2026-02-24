# Artifact Exhibit Checklist (Non-Code Demo)

Use this as your click-through sequence during the live demonstration.

## Stage 1: Natural-language requirement intake
- [ ] Open `../prompt.txt`
- [ ] Read mission sentence and quantitative constraints.
- [ ] State: "This is the single human-authored input to the pipeline."

## Stage 2: Requirements formalization into SysML
- [ ] Open `../deliverables/final.sysml`
- [ ] Point to explicit requirement fields (voltage, frequency, current, runtime).
- [ ] State: "Requirements are now formal and machine-checkable."

## Stage 3: Concept generation (three alternatives)
- [ ] Open `../concepts/auto_concepts.json`
- [ ] Show concept names: `NE555-astable`, `Microcontroller-PWM`, `OpAmp-Relaxation`.
- [ ] State: "The pipeline preserves architectural diversity."

## Stage 4: Optimization model creation per concept
- [ ] Open `../optimization/concept_1/model.sysml`
- [ ] Open `../optimization/concept_2/model.sysml`
- [ ] Open `../optimization/concept_3/model.sysml`
- [ ] State: "Each concept becomes a bounded, constrained optimization problem."

## Stage 5: Optimization solve output per concept
- [ ] Open `../optimization/concept_1/best_solution.json`
- [ ] Open `../optimization/concept_2/best_solution.json`
- [ ] Open `../optimization/concept_3/best_solution.json`
- [ ] State: "Each concept is solved into concrete numeric attribute values."

## Stage 6: Optimized attribute writeback
- [ ] Open `../deliverables/design_instances_optimized.sysml`
- [ ] Show optimized attributes inside each concept block.
- [ ] State: "Optimization results are written back into design instances as authoritative values."

## Stage 7: Part selection with supplier constraint
- [ ] Open `../deliverables/bom_optimized.json`
- [ ] Open `../parts/auto_c1_sdriver_q1.log` (example slot trace)
- [ ] State: "Slot-level part selection is constrained to mouser.com and ranked by fit, stock, then price."

## Stage 8: Constraint validation
- [ ] Open `../deliverables/constraint_validation.json`
- [ ] Show all three concepts are pass.
- [ ] State: "A post-selection validation gate confirms requirements consistency."

## Stage 9: Run summary and decision readiness
- [ ] Open `../summary_auto.json`
- [ ] Point to `concept_status`, `infeasible_concepts`, and part picker settings.
- [ ] State: "We end with a traceable decision package, not just intermediate engineering data."

## Closing KPI callout
- [ ] 3 concepts generated
- [ ] 3/3 optimization success
- [ ] 12/12 slots sourced
- [ ] 3/3 validation pass
- [ ] 0 infeasible concepts
