module

public import Mathlib.Data.Rat.Defs
public import Mathlib.Data.Rat.Floor
public import Mathlib.Logic.Function.Iterate
public import Mathlib.Tactic.NormNum
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.Ring

public section

/-
Copyright (c) 2026 Cosmo Chou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Author: Cosmo Chou

! This file was designed for the Palomar Registry of Lean Verified Mathematics.
! Solution File: Complete formal constructive proofs of Discrete Metric Contraction, Finite-Time Basin Coalescence,
! Eventual Ground-State Collapse, and Infinite-Horizon Attractor Stabilization on Discrete Grids.
! Conforms to Palomar requirement (a): 100% typechecked, zero added axioms.
-/

namespace H3QM.Palomar

/--
A rational metric space structure on an arbitrary type X with rational distance.
Quantifies non-negativity, self-distance vanishing, point separation
(identity of indiscernibles: dist x y = 0 ↔ x = y), symmetry, and the triangle inequality.
Represents a separated metric space.
-/
structure MetricSpaceQ (X : Type) where
  dist : X → X → ℚ
  dist_nonneg : ∀ x y, dist x y ≥ 0
  dist_self : ∀ x, dist x x = 0
  dist_eq_zero : ∀ x y, dist x y = 0 ↔ x = y
  dist_symm : ∀ x y, dist x y = dist y x
  dist_triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/--
A discrete grid metric condition: any two distinct points have distance at least 1.
Characterizes integer lattices and quantized discrete state spaces.
-/
def IsDiscreteGrid {X : Type} (M : MetricSpaceQ X) : Prop :=
  ∀ x y, x ≠ y → M.dist x y ≥ 1

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
def iterate {X : Type} (T : X → X) (n : ℕ) (x : X) : X :=
  T^[n] x

/--
The discrete orbital displacement Lyapunov functional V(x) = dist(x, T(x)).
Measures the non-equilibrium deviation of state x from stationarity.
-/
def lyapunov {X : Type} (M : MetricSpaceQ X) (T : X → X) (x : X) : ℚ :=
  M.dist x (T x)

/--
The canonical ℓ₁ product metric distance on X × Y: dist_X(p1.1, p2.1) + dist_Y(p1.2, p2.2).
Combines two metric spaces under product distance.
-/
def product_dist {X Y : Type} (MX : MetricSpaceQ X) (MY : MetricSpaceQ Y)
    (p1 p2 : X × Y) : ℚ :=
  MX.dist p1.1 p2.1 + MY.dist p1.2 p2.2

/--
The geometric contraction ratio: κ = 2^(-3) = 1/8.
-/
def kappa : ℚ := (1 : ℚ) / 8

/--
Lemma: The contraction ratio κ = 1/8 is strictly non-negative.
-/
theorem kappa_nonneg : 0 ≤ kappa := by
  dsimp [kappa]
  norm_num

/--
Lemma: The 8-th compound power of κ = 1/8 equals 1 / 16,777,216.
-/
theorem kappa_pow_8 : kappa ^ 8 = (1 : ℚ) / 16777216 := by
  dsimp [kappa]
  norm_num

/--
Commutation lemma for iterate: iterate T n (T x) = T (iterate T n x).
-/
theorem iterate_comm {X : Type} (T : X → X) (n : ℕ) (x : X) :
    iterate T n (T x) = T (iterate T n x) :=
  ((Function.Commute.refl T).iterate_right n x).symm

/--
Successor step lemma for iterate: iterate T (n + 1) x = T (iterate T n x).
-/
theorem iterate_succ {X : Type} (T : X → X) (n : ℕ) (x : X) :
    iterate T (n + 1) x = T (iterate T n x) := by
  change iterate T n (T x) = T (iterate T n x)
  exact iterate_comm T n x

/--
Lemma: Separation gap collapse on discrete grids.
-/
theorem discrete_grid_gap_collapse {X : Type} (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (x y : X) (h_lt : M.dist x y < 1) :
    x = y := by
  by_contra h_ne
  have h_ge : M.dist x y ≥ 1 := hG x y h_ne
  linarith

/--
THEOREM 1 PROOF (General Metric Contraction Iterate Bound):
On an arbitrary separated rational metric space (X, dist) and for any mapping T with contraction ratio κ ≥ 0,
the distance between n-th iterates satisfies the geometric bound:
    dist(T^n(x), T^n(y)) ≤ κ^n * dist(x, y).
-/
theorem metric_contraction_iterate_decay {X : Type} (M : MetricSpaceQ X) (T : X → X)
    (κ : ℚ) (hκ : 0 ≤ κ) (hT : IsContraction M T κ) (n : ℕ) (x y : X) :
    M.dist (iterate T n x) (iterate T n y) ≤ κ ^ n * M.dist x y := by
  induction n with
  | zero =>
    dsimp [iterate]
    rw [pow_zero, one_mul]
  | succ k ih =>
    rw [iterate_succ, iterate_succ]
    have h_step : M.dist (T (iterate T k x)) (T (iterate T k y)) ≤ κ * M.dist (iterate T k x) (iterate T k y) :=
      hT (iterate T k x) (iterate T k y)
    have h_dist_nonneg : 0 ≤ M.dist x y := M.dist_nonneg x y
    have h_step_dist_nonneg : 0 ≤ M.dist (iterate T k x) (iterate T k y) := M.dist_nonneg _ _
    rw [pow_succ]
    have h_mul : κ * (κ ^ k * M.dist x y) = κ ^ k * κ * M.dist x y := by ring
    nlinarith

/--
THEOREM 2 PROOF (Lyapunov Energy n-Step Exponential Decay):
Under a contraction mapping with ratio κ ≥ 0, the orbital displacement Lyapunov functional decays exponentially:
    V(T^n(x)) ≤ κ^n * V(x).
-/
theorem lyapunov_iterate_decay {X : Type} (M : MetricSpaceQ X) (T : X → X)
    (κ : ℚ) (hκ : 0 ≤ κ) (hT : IsContraction M T κ) (n : ℕ) (x : X) :
    lyapunov M T (iterate T n x) ≤ κ ^ n * lyapunov M T x := by
  dsimp [lyapunov]
  have h_comm : T (iterate T n x) = iterate T n (T x) := (iterate_comm T n x).symm
  rw [h_comm]
  exact metric_contraction_iterate_decay M T κ hκ hT n x (T x)

/--
THEOREM 3 PROOF (Coupled Product Metric Space Contraction):
Given two metric spaces (X, MX) and (Y, MY) and contraction mappings TX and TY with ratio κ,
the joint parallel product map (TX × TY) on the ℓ₁ product space is strictly a contraction with ratio κ:
    product_dist MX MY (TX p1.1, TY p1.2) (TX p2.1, TY p2.2) ≤ κ * product_dist MX MY p1 p2.
-/
theorem product_metric_contraction {X Y : Type}
    (MX : MetricSpaceQ X) (MY : MetricSpaceQ Y)
    (TX : X → X) (TY : Y → Y) (κ : ℚ)
    (hTX : IsContraction MX TX κ) (hTY : IsContraction MY TY κ) (p1 p2 : X × Y) :
    product_dist MX MY (TX p1.1, TY p1.2) (TX p2.1, TY p2.2) ≤ κ * product_dist MX MY p1 p2 := by
  dsimp [product_dist]
  have hX := hTX p1.1 p2.1
  have hY := hTY p1.2 p2.2
  have h_sum : κ * MX.dist p1.1 p2.1 + κ * MY.dist p1.2 p2.2 = κ * (MX.dist p1.1 p2.1 + MY.dist p1.2 p2.2) := by ring
  linarith

/--
THEOREM 4 PROOF (Finite-Time Basin Coalescence under Sufficient Hypotheses):
On a discrete grid metric space with minimum point separation 1, under contraction ratio κ = 1/8,
any two distinct initial states x, y with separation dist(x, y) < 16,777,216 eventually coalesce
into the exact same dynamical state at step 8:
    dist(x, y) < 16,777,216 → T^8(x) = T^8(y).
-/
theorem discrete_grid_contraction_basin_coalescence {X : Type}
    (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (T : X → X) (hT : IsContraction M T kappa)
    (x y : X) (h_dist : M.dist x y < 16777216) :
    iterate T 8 x = iterate T 8 y := by
  have h_decay := metric_contraction_iterate_decay M T kappa kappa_nonneg hT 8 x y
  have h_k8 : kappa ^ 8 = (1 : ℚ) / 16777216 := kappa_pow_8
  rw [h_k8] at h_decay
  have h_lt : M.dist (iterate T 8 x) (iterate T 8 y) < 1 := by
    linarith
  exact discrete_grid_gap_collapse M hG (iterate T 8 x) (iterate T 8 y) h_lt

/--
THEOREM 5 PROOF (Eventual Ground-State Collapse and Stationary Fixed-Point Lock-In):
On a discrete grid metric space under contraction ratio κ = 1/8, any initial state x with
initial displacement V(x) < 16,777,216 eventually collapses to an exact stationary fixed point at step 8,
with its Lyapunov energy vanishing identically to exact zero:
    V(x) < 16,777,216 → T(T^8(x)) = T^8(x) ∧ V(T^8(x)) = 0.
-/
theorem discrete_contraction_eventual_ground_state_collapse {X : Type}
    (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (T : X → X) (hT : IsContraction M T kappa)
    (x : X) (h_init : lyapunov M T x < 16777216) :
    T (iterate T 8 x) = iterate T 8 x ∧ lyapunov M T (iterate T 8 x) = 0 := by
  dsimp [lyapunov] at h_init
  have h_coal := discrete_grid_contraction_basin_coalescence M hG T hT x (T x) h_init
  have h_comm : iterate T 8 (T x) = T (iterate T 8 x) := iterate_comm T 8 x
  rw [h_comm] at h_coal
  have h_fp : T (iterate T 8 x) = iterate T 8 x := h_coal.symm
  have h_dist_zero : M.dist (iterate T 8 x) (T (iterate T 8 x)) = 0 := by
    have h_symm : iterate T 8 x = T (iterate T 8 x) := h_fp.symm
    exact (M.dist_eq_zero (iterate T 8 x) (T (iterate T 8 x))).mpr h_symm
  constructor
  · exact h_fp
  · dsimp [lyapunov]
    exact h_dist_zero

/--
THEOREM 6 PROOF (Eventual Infinite-Horizon Freezing from Initial Conditions):
Under the sufficient initial displacement bound V(x) < 16,777,216 on a discrete grid with κ = 1/8,
the entire forward infinite trajectory freezes identically for all future time steps:
    V(x) < 16,777,216 → ∀ m : ℕ, T^(8 + m)(x) = T^8(x).
-/
theorem discrete_contraction_eventual_infinite_freezing {X : Type}
    (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (T : X → X) (hT : IsContraction M T kappa)
    (x : X) (h_init : lyapunov M T x < 16777216) (m : ℕ) :
    iterate T (8 + m) x = iterate T 8 x := by
  have h_collapse := discrete_contraction_eventual_ground_state_collapse M hG T hT x h_init
  have h_fp := h_collapse.1
  induction m with
  | zero =>
    rw [Nat.add_zero]
  | succ k ih =>
    have h_add : 8 + (k + 1) = (8 + k) + 1 := by ring
    rw [h_add]
    rw [iterate_succ]
    rw [ih]
    exact h_fp

/--
THEOREM 7 PROOF (Basin-Wide Fixed-Point Uniqueness):
Any two fixed points z₁ and z₂ in the discrete grid metric space with distance strictly less
than 16,777,216 are identically equal: z₁ = z₂.
-/
theorem discrete_grid_contraction_unique_fixed_point {X : Type}
    (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (T : X → X) (hT : IsContraction M T kappa)
    (z₁ z₂ : X) (hz₁ : T z₁ = z₁) (hz₂ : T z₂ = z₂)
    (h_dist : M.dist z₁ z₂ < 16777216) :
    z₁ = z₂ := by
  have h_coal := discrete_grid_contraction_basin_coalescence M hG T hT z₁ z₂ h_dist
  have h_iter_z₁ : iterate T 8 z₁ = z₁ := by
    dsimp [iterate]
    exact Function.iterate_fixed hz₁ 8
  have h_iter_z₂ : iterate T 8 z₂ = z₂ := by
    dsimp [iterate]
    exact Function.iterate_fixed hz₂ 8
  rw [h_iter_z₁, h_iter_z₂] at h_coal
  exact h_coal

/--
THEOREM 8 PROOF (Master Stabilization Theorem):
Unifies the complete dynamical evolution under sufficient hypotheses:
For any initial state x with V(x) < 16,777,216 in a discrete grid under contraction ratio κ = 1/8,
the system reaches an exact stationary fixed point at step 8, its Lyapunov energy vanishes to exact zero,
and its forward orbit freezes for all infinite future iterations:
    T(T^8(x)) = T^8(x) ∧ V(T^8(x)) = 0 ∧ (∀ m, T^(8 + m)(x) = T^8(x)).
-/
theorem discrete_contraction_master_stabilization {X : Type}
    (M : MetricSpaceQ X) (hG : IsDiscreteGrid M)
    (T : X → X) (hT : IsContraction M T kappa)
    (x : X) (h_init : lyapunov M T x < 16777216) :
    T (iterate T 8 x) = iterate T 8 x ∧
    lyapunov M T (iterate T 8 x) = 0 ∧
    ∀ m : ℕ, iterate T (8 + m) x = iterate T 8 x := by
  have h_coll := discrete_contraction_eventual_ground_state_collapse M hG T hT x h_init
  have h_frz := discrete_contraction_eventual_infinite_freezing M hG T hT x h_init
  exact ⟨h_coll.1, h_coll.2, h_frz⟩

end H3QM.Palomar

end
