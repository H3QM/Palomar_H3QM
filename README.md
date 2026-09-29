# Palomar_H3QM: Discrete Lyapunov Dissipation, Product Contraction & Attractor Freezing

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22928921.svg)](https://doi.org/10.5281/zenodo.22928921)
[![CI](https://github.com/H3QM/Palomar_H3QM/actions/workflows/lean_verify.yml/badge.svg)](https://github.com/H3QM/Palomar_H3QM/actions/workflows/lean_verify.yml)
[![Lean 4](https://img.shields.io/badge/Lean%204-v4.35.0--rc2-blue.svg)](https://github.com/leanprover/lean4)
[![Mathlib 4](https://img.shields.io/badge/Mathlib%204-v4.35.0--rc2-green.svg)](https://github.com/leanprover-community/mathlib4)
[![Axioms Used](https://img.shields.io/badge/Axioms%20Added-0%20(Strictly%20Zero)-brightgreen.svg)](#zero-axiom-guarantee)
[![Unproved Sorries](https://img.shields.io/badge/Unproved%20Sorries-0%20(100%25%20Closed)-brightgreen.svg)](#zero-axiom-guarantee)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

**Author**: Cosmo Chou (Independent Researcher, `cosmo@h3qm.org`, ORCID: [0009-0006-5048-1406](https://orcid.org/0009-0006-5048-1406))  
**Classification**: Mathematics / Dynamical Systems (`math.DS`), General Topology (`math.GN`), Logic in Computer Science (`cs.LO`)  
**MSC 2020**: `37C25` (Fixed points and periodic points of dynamical systems), `37C75` (Stability theory of dynamical systems), `54E35` (Metric spaces)  
**Primary Formalized Source**: Cosmo Chou, *Discrete Lyapunov Dissipation and Topological Attractor Dynamics in Metric Spaces*, Zenodo (2026), [DOI: 10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921).

---

## 1. Overview & Research Scope

This repository provides a machine-checked, constructive formalization in **Lean 4** of discrete Lyapunov energy dissipation, product metric contraction dynamics, ground-state exact energy zeroing, and infinite-horizon attractor freezing, formalizing the dynamical theorems of Chou (2026, [DOI: 10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921)).

All 8 core theorems evaluated by the Palomar Comparator are proved constructively with **strictly zero added axioms** (`axioms_used: []`) and zero `sorry` placeholders, verified by both the Lean 4 kernel and the independent NanoDa checker.

### Literature Foundations
1. **Primary Source**: Cosmo Chou (2026), *Discrete Lyapunov Dissipation and Topological Attractor Dynamics in Metric Spaces*, Zenodo, [DOI: 10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921).
2. **Stefan Banach (1922)**: *Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales*, Fundamenta Mathematicae, Vol. 3, pp. 133–181. (Classical contraction mapping principle).
3. **Aleksandr M. Lyapunov (1892)**: *The General Problem of the Stability of Motion*, Kharkov Mathematical Society. (Theory of motion stability and dissipation functionals along dynamical trajectories).
4. **George D. Birkhoff (1927)**: *Dynamical Systems*, American Mathematical Society Colloquium Publications, Vol. 9. (Qualitative structure of discrete dynamical orbits and invariant attractor sets).

### Mathematical Model & Scope
- **Separated Rational Metric Spaces**: The development formalizes separated metric spaces over the rationals (`MetricSpaceQ X`) satisfying identity of indiscernibles ($\text{dist}(x, y) = 0 \iff x = y$), symmetry, and the triangle inequality.
- **Quantized Discrete State Spaces**: Under the discrete grid hypothesis (`IsDiscreteGrid M`, $\forall x \ne y, \text{dist}(x, y) \ge 1$), continuous asymptotic convergence is upgraded to finite-time exact collapse to zero residual ($V(x) = 0$).

---

## 2. Formalized Theorems (`Challenge.lean` / `Solution.lean`)

The 8 quantified theorems selected and verified by `comparator.json` establish the following mathematical progression:

1. **`lyapunov_strict_dissipation` (Orbital Energy Dissipation)**:
   For any contraction mapping $T$ with ratio $\kappa$ on a metric space $(X, M)$, the displacement Lyapunov functional $V(x) = \text{dist}(x, T(x))$ dissipates strictly along dynamical orbits:
   $$V(T(x)) \le \kappa \cdot V(x)$$
   *(Proved constructively via the metric contraction condition on $(x, T(x))$)*

2. **`discrete_grid_gap_collapse` (Discreteness Gap Separation)**:
   On a discrete grid metric space where distinct states are separated by at least 1, any pair of states with distance strictly less than 1 are identically equal:
   $$\text{dist}(x, y) < 1 \implies x = y$$
   *(Proved by contradiction and linear arithmetic)*

3. **`lyapunov_ground_state_exact_zero` (Ground-State Energy Zeroing)**:
   Whenever the Lyapunov functional drops strictly below the discreteness gap 1, the energy collapses identically to exact zero ($V(x) = 0$), forcing $x$ into an exact stationary fixed point ($T(x) = x$):
   $$V(x) < 1 \implies V(x) = 0 \;\land\; T(x) = x$$
   *(Proved via discrete gap collapse and the metric identity of indiscernibles)*

4. **`metric_contraction_iterate_decay` (General Geometric Iterate Bound)**:
   On an arbitrary separated rational metric space $(X, \text{dist})$ and for any mapping $T$ with contraction ratio $\kappa \ge 0$, the distance between $n$-th iterates satisfies:
   $$\text{dist}(T^n(x), T^n(y)) \le \kappa^n \cdot \text{dist}(x, y)$$
   *(Proved by mathematical induction on $n$ with non-linear arithmetic)*

5. **`lyapunov_iterate_decay` (Exponential Lyapunov Energy Decay)**:
   Under a contraction mapping with ratio $\kappa \ge 0$, the Lyapunov displacement functional decays exponentially under iteration:
   $$V(T^n(x)) \le \kappa^n \cdot V(x)$$
   *(Proved by combining orbit iterate commutation with metric iterate decay)*

6. **`product_metric_contraction` (Coupled Product Metric Space Contraction)**:
   Given two metric spaces $(X, M_X)$ and $(Y, M_Y)$ and contraction mappings $T_X$ and $T_Y$ with ratio $\kappa$, the parallel product map $(T_X \times T_Y)$ on the $\ell_1$ product space strictly preserves the contraction ratio $\kappa$:
   $$\text{product\_dist}((T_X(x), T_Y(y)), (T_X(x'), T_Y(y'))) \le \kappa \cdot \text{product\_dist}((x, y), (x', y'))$$
   *(Proved constructively by componentwise linearity and ring arithmetic)*

7. **`discrete_infinite_horizon_freezing` (Infinite-Horizon Attractor Invariance)**:
   Once a discrete dynamical state reaches a stationary fixed point at step 8 ($T(T^8(x)) = T^8(x)$), its entire forward infinite trajectory freezes identically:
   $$\forall m \in \mathbb{N}, \quad T^{8+m}(x) = T^8(x)$$
   *(Proved by induction on $m$ using the iterate successor lemma)*

8. **`discrete_grid_contraction_unique_fixed_point` (Basin-Wide Fixed-Point Uniqueness)**:
   Any two fixed points $z_1, z_2$ in the discrete grid metric space whose $n$-step contracted distance drops below 1 are identically equal:
   $$\kappa^n \cdot \text{dist}(z_1, z_2) < 1 \implies z_1 = z_2$$
   *(Proved by fixed-point invariance, iterate decay, and discrete gap collapse)*

---

## 3. Verification & Build Instructions

### Prerequisites
- Lean 4 toolchain: `leanprover/lean4:v4.35.0-rc2` (managed via `elan`)
- Lake package manager

### Local Build & Verification
```bash
# Clone repository
git clone https://github.com/H3QM/Palomar_H3QM.git
cd Palomar_H3QM

# Fetch dependencies and cache
lake exe cache get

# Build Palomar Challenge and Solution modules
lake build Challenge Solution

# Run Lean 4 kernel and NanoDa independent kernel checks via lake comparator
lake comparator
```

---

## 4. Metadata & Licensing

- **Specification**: Conforms to `mathlib-initiative/formalization.yaml` v0.4 schema.
- **License**: Apache 2.0 (`LICENSE`).
- **Archive**: Zenodo [10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921).
