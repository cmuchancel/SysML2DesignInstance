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
OPTIMIZATION_NOTE = "Selected NSGA-II (multi-objective gate (2 objectives, Pareto-front routing); n_obj=2, n_var=11, obj_type=linear, con_type=none, convex=true, grad=unknown, continuous, unconstrained)."

# ----- Generated problem block (no imports) -----
SEED = 42
POP_SIZE = 100
N_GEN = 200
PROBLEM_NAME = "FlasherDesign"

# Decision variable bounds (order below)
# 0 timing_resistor_kohm
# 1 timing_cap_uF
# 2 resistor_ohm
# 3 led_current_mA
# 4 supply_voltage_V
# 5 driver_quiescent_mA
# 6 battery_capacity_mAh
# 7 efficiency_factor
# 8 blink_frequency_hz
# 9 avg_current_mA
# 10 runtime_hours
XL = np.array([
    1.0,       # timing_resistor_kohm (kΩ)
    0.01,      # timing_cap_uF (µF)
    100.0,     # resistor_ohm (Ω)
    8.0,       # led_current_mA (mA)
    4.75,      # supply_voltage_V (V)
    0.2,       # driver_quiescent_mA (mA)
    500.0,     # battery_capacity_mAh (mAh)
    0.60,      # efficiency_factor (unitless)
    9.5,       # blink_frequency_hz (Hz)
    4.2,       # avg_current_mA (mA)
    16.6667    # runtime_hours (h)
], dtype=float)

XU = np.array([
    200.0,     # timing_resistor_kohm (kΩ)
    100.0,     # timing_cap_uF (µF)
    2200.0,    # resistor_ohm (Ω)
    20.0,      # led_current_mA (mA)
    5.25,      # supply_voltage_V (V)
    20.0,      # driver_quiescent_mA (mA)
    6000.0,    # battery_capacity_mAh (mAh)
    0.98,      # efficiency_factor (unitless)
    10.5,      # blink_frequency_hz (Hz)
    30.0,      # avg_current_mA (mA)
    1428.5714  # runtime_hours (h)
], dtype=float)

class Problem(ElementwiseProblem):
    def __init__(self):
        super().__init__(n_var=len(XL), n_obj=2, n_constr=7, xl=XL, xu=XU, type_var=np.double)  # syspipe: n_var from bounds

    def _evaluate(self, X, out, *args, **kwargs):
        # syspipe: elementwise guard
        elementwise = np.ndim(X) == 1
        X = np.asarray(X, dtype=float)
        if X.ndim > 1:
            X = X.reshape(-1)
        # Unpack decision variables
        timing_resistor_kohm = X[0]
        timing_cap_uF = X[1]
        resistor_ohm = X[2]
        led_current_mA = X[3]
        supply_voltage_V = X[4]
        driver_quiescent_mA = X[5]
        battery_capacity_mAh = X[6]
        efficiency_factor = X[7]
        blink_frequency_hz = X[8]
        avg_current_mA = X[9]
        runtime_hours = X[10]

        # Derived (model) values
        blink_calc = 1440.0 / (timing_resistor_kohm * timing_cap_uF)
        avg_calc = driver_quiescent_mA + 0.5 * led_current_mA
        # Avoid division by zero (shouldn't occur due to bounds)
        runtime_calc = battery_capacity_mAh / (avg_current_mA if avg_current_mA != 0.0 else 1e-12)

        total_cost_calc = (
            0.04 * timing_resistor_kohm
            + 0.12 * timing_cap_uF
            + 0.0025 * resistor_ohm
            + 0.02 * led_current_mA
            + 0.005 * battery_capacity_mAh
            + 0.4 / efficiency_factor
        )

        performance_penalty_calc = (blink_calc - 10.0) ** 2 + (led_current_mA - 14.0) ** 2

        # Objectives: minimize total cost and performance penalty
        f1 = total_cost_calc
        f2 = performance_penalty_calc
        out["F"] = np.array([f1, f2], dtype=float)

        # Constraints (inequalities in form g(x) <= 0)
        # Enforce equalities by two inequalities each (expr - var <= 0 and var - expr <= 0)
        g_blink = blink_calc - blink_frequency_hz
        g_avg = avg_calc - avg_current_mA
        g_runtime = runtime_calc - runtime_hours

        # runtime_hours >= 8.0  -->  8.0 - runtime_hours <= 0
        g_runtime_min8 = 8.0 - runtime_hours

        out["G"] = np.array([
            g_blink,        # blink_calc - blink_frequency_hz <= 0
            -g_blink,       # blink_frequency_hz - blink_calc <= 0
            g_avg,          # avg_calc - avg_current_mA <= 0
            -g_avg,         # avg_current_mA - avg_calc <= 0
            g_runtime,      # runtime_calc - runtime_hours <= 0
            -g_runtime,     # runtime_hours - runtime_calc <= 0
            g_runtime_min8  # 8.0 - runtime_hours <= 0
        ], dtype=float)
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

    res = minimize(problem, algorithm, termination, seed=SEED, save_history=False, verbose=False)

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
