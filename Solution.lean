/-
Copyright (c) 2026 Cosmo Chou and H3QM Research Foundation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Cosmo Chou

! This file was designed for the Palomar Registry of Lean Verified Mathematics.
! Solution File: Complete formal constructive proof of Discrete Metric Contraction Dynamics,
! IEEE 754 Binary32 Unit Roundoff Bound, and Discrete Grid Fixed-Point Collapse.
! Conforms to Palomar requirement (a): 100% typechecked, zero added axioms.
-/

import Mathlib.Data.Rat.Defs
import Mathlib.Data.Rat.Floor
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace H3QM.Palomar

/--
A pseudo-metric structure on an arbitrary type X with rational distance.
Quantifies non-negativity, self-distance vanishing, point separation,
symmetry, and the triangle inequality.
-/
structure MetricSpaceQ (X : Type) where
  dist : X → X → ℚ
  dist_nonneg : ∀ x y, dist x y ≥ 0
  dist_self : ∀ x, dist x x = 0
  dist_eq_zero : ∀ x y, dist x y = 0 ↔ x = y
  dist_symm : ∀ x y, dist x y = dist y x
  dist_triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/--
A contraction mapping on a metric space (X, dist) with contraction ratio κ.
For all states x and y, the metric distance between images contracts by at least κ.
-/
def IsContraction {X : Type} (M : MetricSpaceQ X) (T : X → X) (κ : ℚ) : Prop :=
  ∀ x y, M.dist (T x) (T y) ≤ κ * M.dist x y

/--
The n-fold iterate of a state evolution map T : X → X.
Defines the discrete dynamical trajectory starting from initial state x.
-/
def iterate {X : Type} (T : X → X) : ℕ → X → X
  | 0, x => x
  | n + 1, x => T (iterate T n x)

/--
Rational power function κ^n for contraction factor compounding.
-/
def ratPow (κ : ℚ) : ℕ → ℚ
  | 0 => 1
  | n + 1 => κ * ratPow κ n

/--
The discrete geometric contraction ratio: κ = 2^(-3) = 1/8.
-/
def kappa : ℚ := (1 : ℚ) / 8

/--
The discrete geometric contraction ratio κ = 1/8 is non-negative.
-/
theorem kappa_nonneg : 0 ≤ kappa := by
  dsimp [kappa]
  norm_num

/--
The IEEE 754 binary32 unit roundoff (half-epsilon, u = 2^(-24))
represented as an exact rational number:
u_binary32 = 2^(-24) = 1 / 16777216.
-/
def unit_roundoff_binary32 : ℚ := (1 : ℚ) / 16777216

/--
A discrete grid metric condition: any two distinct points have distance at least 1.
Characterizes integer lattices and quantized discrete state spaces.
-/
def IsDiscreteGrid {X : Type} (M : MetricSpaceQ X) : Prop :=
  ∀ x y, x ≠ y → M.dist x y ≥ 1

/--
THEOREM 1 PROOF (Contraction Ratio 8-Fold Compounding Identity):
Proved constructively by definitional unfolding and rational arithmetic.
-/
theorem ratPow_kappa_8_eq_unit_roundoff :
    ratPow kappa 8 = unit_roundoff_binary32 := by
  dsimp [ratPow, kappa, unit_roundoff_binary32]
  norm_num

/--
THEOREM 2 PROOF (Integer Scale Normalization):
Proved constructively by rational normalization.
-/
theorem scaled_roundoff_normalizes_to_one :
    (16777216 : ℚ) * ratPow kappa 8 = 1 := by
  have h : ratPow kappa 8 = unit_roundoff_binary32 := ratPow_kappa_8_eq_unit_roundoff
  rw [h]
  unfold unit_roundoff_binary32
  norm_num

/--
THEOREM 3 PROOF (General Metric Contraction Decay):
Proved constructively by mathematical induction on the iteration step n.
-/
theorem metric_contraction_iterate_decay {X : Type} (M : MetricSpaceQ X) (T : X → X)
    (κ : ℚ) (hκ : 0 ≤ κ) (hT : IsContraction M T κ) (n : ℕ) (x y : X) :
    M.dist (iterate T n x) (iterate T n y) ≤ ratPow κ n * M.dist x y := by
  induction n with
  | zero =>
    dsimp [iterate, ratPow]
    rw [one_mul]
  | succ k ih =>
    dsimp [iterate, ratPow]
    have h_step : M.dist (T (iterate T k x)) (T (iterate T k y)) ≤ κ * M.dist (iterate T k x) (iterate T k y) :=
      hT (iterate T k x) (iterate T k y)
    have h_dist_nonneg : 0 ≤ M.dist x y := M.dist_nonneg x y
    have h_step_dist_nonneg : 0 ≤ M.dist (iterate T k x) (iterate T k y) := M.dist_nonneg _ _
    nlinarith

/--
THEOREM 4 PROOF (8-Step Binary32 Metric Bound):
Specialization of general contraction decay to n = 8 and κ = 1/8.
-/
theorem metric_contraction_step8_bound {X : Type} (M : MetricSpaceQ X) (T : X → X)
    (hT : IsContraction M T kappa) (x y : X) :
    M.dist (iterate T 8 x) (iterate T 8 y) ≤ unit_roundoff_binary32 * M.dist x y := by
  have h_decay := metric_contraction_iterate_decay M T kappa kappa_nonneg hT 8 x y
  have h_eq : ratPow kappa 8 = unit_roundoff_binary32 := ratPow_kappa_8_eq_unit_roundoff
  rw [h_eq] at h_decay
  exact h_decay

/--
THEOREM 5 PROOF (Discrete Grid Gap Collapse):
On a discrete grid, any distance strictly less than 1 forces exact identity.
-/
theorem discrete_grid_gap_collapse {X : Type} (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (x y : X) (h_lt : M.dist x y < 1) :
    x = y := by
  by_contra h_neq
  have h_ge := hG x y h_neq
  linarith

/--
THEOREM 6 PROOF (Finite-Time Attractor Collapse on Discrete Grids):
Every state pair in a ball of diameter < 2^24 collapses in exactly 8 steps.
-/
theorem discrete_grid_contraction_collapse {X : Type} (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (T : X → X) (hT : IsContraction M T kappa) (x y : X)
    (h_dist : M.dist x y < 16777216) :
    iterate T 8 x = iterate T 8 y := by
  have h_bound := metric_contraction_step8_bound M T hT x y
  have h_lt : M.dist (iterate T 8 x) (iterate T 8 y) < 1 := by
    dsimp [unit_roundoff_binary32] at h_bound
    linarith
  exact discrete_grid_gap_collapse M hG (iterate T 8 x) (iterate T 8 y) h_lt

end H3QM.Palomar
