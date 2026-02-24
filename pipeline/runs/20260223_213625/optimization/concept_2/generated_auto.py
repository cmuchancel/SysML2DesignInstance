#!/usr/bin/env python3
import os
import sys
import math
import random
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
from pymoo.core.problem import ElementwiseProblem
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize
from pymoo.operators.sampling.rnd import FloatRandomSampling
from pymoo.operators.crossover.sbx import SBX
from pymoo.operators.mutation.pm import PM
from pymoo.termination import get_termination

RUN_DIR = Path(__file__).parent
os.chdir(RUN_DIR)
PARETO_PLOT_PATH = RUN_DIR / "pareto_front.png"
PARETO_CSV_PATH = RUN_DIR / "pareto_solutions.csv"
ARTIFACT_SCHEMA_VERSION = "1.0"
OPTIMIZATION_METHOD = "NSGA-II"
OPTIMIZATION_NOTE = "Selected NSGA-II (multi-objective gate (2 objectives, Pareto-front routing); n_obj=2, n_var=13, obj_type=linear, con_type=nonlinear, convex=unknown, grad=true, continuous, constrained)."

# ----- Generated problem block (no imports) -----
SEED = 1
POP_SIZE = 100
N_GEN = 200
PROBLEM_NAME = "FlasherDesign"

# Variable bounds (order: timing_resistor_kohm, timing_cap_uF, resistor_ohm, led_current_mA,
#                       supply_voltage_V, driver_quiescent_mA, battery_capacity_mAh, efficiency_factor, blink_frequency_hz)
XL = np.array([1.0, 0.01, 100.0, 8.0, 4.75, 0.2, 500.0, 0.60, 9.5], dtype=float)
XU = np.array([200.0, 100.0, 2200.0, 20.0, 5.25, 20.0, 6000.0, 0.98, 10.5], dtype=float)

class Problem(ElementwiseProblem):
    def __init__(self):
        super().__init__(
            n_var=9,
            n_obj=2,
            n_constr=4,
            xl=XL,
            xu=XU,
        )

    def _evaluate(self, X, out, *args, **kwargs):
        # syspipe: elementwise guard
        elementwise = np.ndim(X) == 1
        X = np.asarray(X, dtype=float)
        X = np.asarray(X, dtype=float)
        if X.ndim > 1:
            X = X.reshape(-1)
        # Unpack design variables
        timing_resistor_kohm = float(X[0])   # kΩ
        timing_cap_uF = float(X[1])         # µF
        resistor_ohm = float(X[2])          # Ω
        led_current_mA = float(X[3])        # mA
        supply_voltage_V = float(X[4])      # V (unused in formulas but included)
        driver_quiescent_mA = float(X[5])   # mA
        battery_capacity_mAh = float(X[6])  # mAh
        efficiency_factor = float(X[7])     # unitless
        blink_frequency_hz = float(X[8])    # Hz (decision variable)

        # Derived quantities
        computed_blink = 1.44 / ((timing_resistor_kohm * 1000.0) * (timing_cap_uF * 1e-6))
        avg_current_mA = driver_quiescent_mA + 0.5 * led_current_mA
        # protect against division by zero though bounds should prevent it
        if avg_current_mA <= 0.0:
            runtime_hours = 1e6  # large violation handled by constraints below
        else:
            runtime_hours = battery_capacity_mAh / avg_current_mA

        total_cost_usd = (
            0.04 * timing_resistor_kohm
            + 0.12 * timing_cap_uF
            + 0.0025 * resistor_ohm
            + 0.02 * led_current_mA
            + 0.005 * battery_capacity_mAh
            + 0.4 / efficiency_factor
        )

        performance_penalty = (blink_frequency_hz - 10.0) ** 2 + (led_current_mA - 14.0) ** 2

        # Objectives (minimize)
        out["F"] = np.array([total_cost_usd, performance_penalty], dtype=float).reshape(1, 2)

        # Constraints: g <= 0 indicates feasibility
        # 1) Enforce blink_frequency_hz == computed_blink (within tolerance)
        tol_blink = 1e-3
        g1 = np.abs(blink_frequency_hz - computed_blink) - tol_blink

        # 2 & 3) avg_current_mA within [4.2, 30.0]
        g2 = 4.2 - avg_current_mA    # <=0 if avg_current_mA >= 4.2
        g3 = avg_current_mA - 30.0   # <=0 if avg_current_mA <= 30.0

        # 4) runtime_hours >= 8.0  --> g4 = 8.0 - runtime_hours <= 0 when ok
        g4 = 8.0 - runtime_hours

        out["G"] = np.array([g1, g2, g3, g4], dtype=float).reshape(1, 4)
        if elementwise:
            f_val = out.get("F")
            if f_val is not None:
                f_arr = np.asarray(f_val)
                if f_arr.ndim > 1:
                    out["F"] = f_arr[0]
            g_val = out.get("G")
            if g_val is not None:
                g_arr = np.asarray(g_val)
                if g_arr.ndim > 1:
                    out["G"] = g_arr[0]
# ----- End generated block -----

# Defaults if not set by the block
SEED = globals().get("SEED", 42)
POP_SIZE = int(globals().get("POP_SIZE", 200))
N_GEN = int(globals().get("N_GEN", 200))
PROBLEM_NAME = globals().get("PROBLEM_NAME", "LLM-generated problem")

np.random.seed(SEED)
random.seed(SEED)


def run():
    if "Problem" not in globals():
        raise SystemExit("Generated block must define a Problem(ElementwiseProblem) class.")
    problem = Problem()
    print(f"Optimization method: {OPTIMIZATION_METHOD}")
    if OPTIMIZATION_NOTE:
        print(f"Note: {OPTIMIZATION_NOTE}")
    algorithm = NSGA2(
        pop_size=POP_SIZE,
        sampling=FloatRandomSampling(),
        crossover=SBX(prob=0.9, eta=15),
        mutation=PM(eta=20),
        eliminate_duplicates=True,
    )
    termination = get_termination("n_gen", N_GEN)

    res = minimize(problem, algorithm, termination, seed=SEED, save_history=False, verbose=False, return_least_infeasible=True)

    F = np.atleast_2d(res.F)
    X = np.atleast_2d(res.X)
    feas_mask = np.ones(F.shape[0], dtype=bool)
    if getattr(res, "G", None) is not None:
        G = np.atleast_2d(res.G)
        feas_mask = np.all(G <= 1e-8, axis=1)

    print(f"Problem: {PROBLEM_NAME}")
    print(f"Population: {POP_SIZE}, Generations: {N_GEN}, Seed: {SEED}")
    print(f"Total solutions: {F.shape[0]}, Feasible: {feas_mask.sum()}")
    to_show = min(5, F.shape[0])
    for i in range(to_show):
        fvec = F[i]
        feas = "feasible" if feas_mask[i] else "infeasible"
        print(f"[{i+1}] F = {np.round(fvec, 6).tolist()}  ({feas})")

    # Save CSV (F, feasibility, X)
    try:
        n_obj = F.shape[1]
        n_var = X.shape[1]
        header_cols = [f"f{i+1}" for i in range(n_obj)] + ["feasible"] + [f"x{i+1}" for i in range(n_var)]
        data = np.hstack([F, feas_mask.reshape(-1, 1).astype(int), X])
        np.savetxt(PARETO_CSV_PATH, data, delimiter=",", header=",".join(header_cols), comments="")
        print(f"Pareto solutions CSV saved to: {PARETO_CSV_PATH}")
    except Exception as e:
        print("Warning: failed to save CSV:", e)

    # Plot
    n_obj = F.shape[1]
    if n_obj >= 2:
        plt.figure(figsize=(7, 5))
        plt.scatter(F[:, 0], F[:, 1], c=np.where(feas_mask, "tab:blue", "tab:orange"), s=24, alpha=0.8, edgecolors="k")
        plt.xlabel("f1")
        plt.ylabel("f2")
        plt.title(f"Pareto front (f1 vs f2): {PROBLEM_NAME}")
        plt.grid(True, linestyle="--", alpha=0.4)
        plt.tight_layout()
        plt.savefig(PARETO_PLOT_PATH, dpi=200)
        print(f"Pareto front plot saved to: {PARETO_PLOT_PATH}")
    else:
        print("Plot skipped (requires at least 2 objectives).")


if __name__ == "__main__":
    run()
