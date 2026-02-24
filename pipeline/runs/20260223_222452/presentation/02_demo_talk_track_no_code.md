# No-Code Demo Talk Track (Step by Step)

## Step 1: Mission Intake (Natural Language)
- What is happening: We start from a plain-language system brief.
- How it is happening: The pipeline captures the mission statement and key operating targets from the user prompt.
- What to show: `../prompt.txt`
- What to say: "We begin with an operator-level requirement statement, not a technical model. This ensures the process starts where real mission planning starts and then carries that intent forward into formal engineering artifacts."

## Step 2: Requirements Formalization (SysML)
- What is happening: The free-text brief is transformed into formal, machine-checkable requirements.
- How it is happening: The pipeline builds a concise SysML requirements model that encodes voltage, blink-rate tolerance, current limits, runtime target, and sourcing expectations.
- What to show: `../deliverables/final.sysml`
- What to say: "This is the first traceability anchor. Every downstream decision is now linked to explicit formal requirements instead of ambiguous narrative text."

## Step 3: Concept Generation (Exactly 3 Alternatives)
- What is happening: The system creates three distinct design approaches.
- How it is happening: Concept synthesis expands the requirement model into architecture alternatives: NE555-astable, Microcontroller-PWM, and OpAmp-Relaxation.
- What to show: `../concepts/auto_concepts.json`
- What to say: "We do not lock into a single architecture early. We intentionally generate three feasible design directions so trade-space exploration is built in from the beginning."

## Step 4: Design-Instance Scaffolding
- What is happening: Each concept is instantiated into slots and component roles.
- How it is happening: The pipeline defines role-based slots per concept such as driver/mcu/opamp, LED, resistor, and supply.
- What to show: `../concepts/auto_concepts.json` and `../deliverables/design_instances.sysml`
- What to say: "At this point, each concept has a concrete structure that can be optimized and sourced. This is where abstract concepts become actionable design instances."

## Step 5: Optimization Problem Construction
- What is happening: Each concept gets its own optimization-ready model.
- How it is happening: For every concept, the pipeline defines decision variables, numeric bounds, objective tradeoffs, and requirement-derived constraints.
- What to show: `../optimization/concept_1/model.sysml`, `../optimization/concept_2/model.sysml`, `../optimization/concept_3/model.sysml`
- What to say: "Each design becomes a constrained optimization problem. We explicitly encode what can move, the safe operating ranges, and what outcomes we are trying to improve."

## Step 6: Optimization Solve and Best Solutions
- What is happening: The optimizer solves each concept and returns concrete numeric attribute values.
- How it is happening: Multi-objective search balances competing goals and outputs best candidate parameter sets per concept.
- What to show: `../optimization/concept_1/best_solution.json`, `../optimization/concept_2/best_solution.json`, `../optimization/concept_3/best_solution.json`
- What to say: "Instead of guessing component values, we solve for them. This gives defensible parameter choices tied directly to mission constraints and objective tradeoffs."

## Step 7: Optimized Attribute Writeback
- What is happening: Solved values are written back into each design instance as authoritative attributes.
- How it is happening: The pipeline stamps optimized numeric values into the integrated design model for each concept.
- What to show: `../deliverables/design_instances_optimized.sysml`
- What to say: "The design model is now not just structural. It is quantitatively specified with optimized values, ready for sourcing and feasibility checks."

## Step 8: Supplier-Constrained Part Selection
- What is happening: The system selects concrete purchasable parts for every slot.
- How it is happening: Slot-level requirements are converted into structured search criteria and resolved against supplier-constrained web results (`mouser.com`). Selection priority is constraint match, then stock, then price.
- What to show: `../deliverables/bom_optimized.json` and `../parts/auto_c1_sdriver_q1.log`
- What to say: "This step bridges design intent to procurement reality. We convert optimized attributes into sourceable parts while enforcing supplier constraints and ranking candidates by mission relevance first."

## Step 9: Constraint Validation
- What is happening: Selected-part designs are validated against modeled constraints.
- How it is happening: Each concept is rechecked through a formal constraint validation stage to confirm consistency between requirements, optimized attributes, and selected parts.
- What to show: `../deliverables/constraint_validation.json`
- What to say: "This is the gate that prevents attractive but non-compliant designs from moving forward. A design is only accepted if it remains constraint-consistent after part substitution."

## Step 10: Decision Package and Feasibility Outcome
- What is happening: The run emits an executive decision package with full traceability.
- How it is happening: The pipeline compiles per-concept status, sourcing outcome, validation result, and artifact paths into one summary.
- What to show: `../summary_auto.json`
- What to say: "The final output is decision-ready: three optimized and validated designs, sourced parts, and full artifact traceability from original mission brief to procurement candidates."

## Final Demonstration Metrics to State Verbally
- Exactly 3 design instances generated.
- Optimization solved: 3/3 concepts.
- Parts selected: 12/12 slots.
- Constraint validation: 3/3 pass.
- Infeasible concepts: 0.
