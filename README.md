# Palomar_H3QM: Discrete Metric Contraction Dynamics & Binary32 Roundoff Collapse

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22928921.svg)](https://doi.org/10.5281/zenodo.22928921)
[![CI](https://github.com/H3QM/Palomar_H3QM/actions/workflows/lean_verify.yml/badge.svg)](https://github.com/H3QM/Palomar_H3QM/actions/workflows/lean_verify.yml)
[![Lean 4](https://img.shields.io/badge/Lean%204-v4.35.0--rc2-blue.svg)](https://github.com/leanprover/lean4)
[![Mathlib 4](https://img.shields.io/badge/Mathlib%204-v4.35.0--rc2-green.svg)](https://github.com/leanprover-community/mathlib4)
[![Axioms Used](https://img.shields.io/badge/Axioms%20Added-0%20(Strictly%20Zero)-brightgreen.svg)](#zero-axiom-guarantee)
[![Unproved Sorries](https://img.shields.io/badge/Unproved%20Sorries-0%20(100%25%20Closed)-brightgreen.svg)](#zero-axiom-guarantee)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE)

**Author**: Cosmo Chou (Independent Researcher, `cosmo@h3qm.org`, ORCID: [0009-0006-5048-1406](https://orcid.org/0009-0006-5048-1406))  
**Classification**: Mathematics / Dynamical Systems (`math.DS`), Numerical Analysis (`math.NA`), Logic in Computer Science (`cs.LO`)  
**MSC 2020**: `37C25` (Fixed points and periodic points), `65G50` (Roundoff error), `68V15` (Theorem proving and formal verification)  
**Primary Formalized Source**: Cosmo Chou, *Discrete Metric Contraction Dynamics and IEEE 754 Binary32 Machine Roundoff Bounds*, Zenodo (2026), [DOI: 10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921).

---

## 1. Overview & Research Scope

This repository provides a machine-checked, constructive formalization in **Lean 4** of the discrete metric contraction dynamics, machine roundoff saturation bounds, finite-time orbit coalescence, and invariant attractor collapse published in Chou (2026, [DOI: 10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921)).

All 8 core theorems evaluated by the Palomar Comparator are proved constructively with **strictly zero added axioms** (`axioms_used: []`) and zero `sorry` placeholders, verified by both the Lean 4 kernel and the independent NanoDa checker.

### Literature Foundations
1. **Primary Source**: Cosmo Chou (2026), *Discrete Metric Contraction Dynamics and IEEE 754 Binary32 Machine Roundoff Bounds*, Zenodo, [DOI: 10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921).
2. **Stefan Banach (1922)**: *Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales*, Fundamenta Mathematicae, Vol. 3, pp. 133–181. (Classical continuous contraction mapping principle).
3. **IEEE Computer Society (2008)**: *IEEE Standard for Floating-Point Arithmetic*, IEEE Std 754-2008. (Definition of binary32 single-precision unit roundoff $u = 2^{-24} = 1/16{,}777{,}216$).
4. **Nicholas J. Higham (2002)**: *Accuracy and Stability of Numerical Algorithms*, SIAM. (Discretization and roundoff error analysis).

### Limitations and Mathematical Model
- **Rational Metric Space Formulation**: This formalization operates on exact rational numbers ($\mathbb{Q}$) and separated metric spaces with an assumed discrete lattice gap ($\text{dist}(x, y) \ge 1$ for $x \ne y$).
- **Machine Roundoff Relationship**: It establishes the exact algebraic saturation identity matching the IEEE 754 binary32 unit roundoff ($u = 2^{-24} = 1/16{,}777{,}216$), but does not model low-level hardware floating-point mantissa rounding modes, denormals, or machine overflows in Lean.

---

## 2. Formalized Theorems (`Challenge.lean` / `Solution.lean`)

The 8 quantified theorems selected and verified by `comparator.json` establish the following mathematical chain:

1. **`ratPow_kappa_8_eq_unit_roundoff`**:
   The 8-th power of the geometric contraction ratio $\kappa = 1/8$ evaluates identically to the IEEE 754 binary32 unit roundoff:
   $$\kappa^8 = \left(\frac{1}{8}\right)^8 = (2^{-3})^8 = 2^{-24} = u_{\text{binary32}} = \frac{1}{16{,}777{,}216}$$
   *(Proved constructively via rational arithmetic unfolding and `norm_num`)*

2. **`scaled_roundoff_normalizes_to_one`**:
   Exact rational normalization $(2^{24} \cdot \kappa^8 = 1)$. *(Proved via `norm_num`)*

3. **`metric_contraction_iterate_decay` (General Geometric Iterate Bound)**:
   On an arbitrary separated rational metric space $(X, \text{dist}_Q)$ and for any mapping $T : X \to X$ with contraction ratio $\kappa \ge 0$, the distance between $n$-th iterates satisfies the geometric bound:
   $$\text{dist}(T^n(x), T^n(y)) \le \kappa^n \cdot \text{dist}(x, y)$$
   *(Proved by mathematical induction on $n$ with non-linear rational arithmetic; exhibits contraction decay when $\kappa < 1$)*

4. **`metric_contraction_step8_bound`**:
   After exactly 8 iterations under $\kappa = 1/8$, the metric distance contracts by at least the binary32 unit roundoff:
   $$\text{dist}(T^8(x), T^8(y)) \le u_{\text{binary32}} \cdot \text{dist}(x, y)$$
   *(Proved by specialization to $n = 8$ and rational rewrite)*

5. **`discrete_grid_gap_collapse`**:
   On a discrete grid metric space where distinct states are separated by at least 1 ($\forall x \ne y, \text{dist}(x, y) \ge 1$), any pair of states with metric distance strictly less than 1 are identically equal:
   $$\text{dist}(x, y) < 1 \implies x = y$$
   *(Proved constructively by contradiction and `linarith`)*

6. **`discrete_grid_contraction_collapse` (Finite-Time Pairwise Orbit Coalescence)**:
   On a discrete grid metric space with contraction ratio $\kappa = 1/8$, any two states with initial distance strictly bounded by $2^{24} = 16{,}777{,}216$ collapse into the exact same state in 8 steps:
   $$\text{dist}(x, y) < 16{,}777{,}216 \implies T^8(x) = T^8(y)$$
   *(Proved constructively via 8-step contraction bound and discrete gap collapse)*

7. **`discrete_grid_contraction_fixed_point` (Exact Fixed-Point Invariance)**:
   Under $\kappa = 1/8$ on a discrete grid, any state $x$ whose single-step distance is bounded by $2^{24}$ collapses into an exact fixed point at step 8:
   $$\text{dist}(x, T(x)) < 16{,}777{,}216 \implies T(T^8(x)) = T^8(x)$$
   *(Proved by orbit coalescence on $(x, T(x))$ combined with the iterate commutation lemma)*

8. **`discrete_grid_contraction_unique_fixed_point` (Basin-Wide Fixed-Point Uniqueness)**:
   Any two fixed points $z_1, z_2$ in the discrete grid metric space with distance strictly less than $2^{24}$ are identically equal:
   $$\text{dist}(z_1, z_2) < 16{,}777{,}216 \implies z_1 = z_2$$
   *(Proved by invariance induction and 8-step orbit collapse)*

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

# Typecheck Solution with Lean 4 kernel
lake env lean Solution.lean

# Run the 5-stage automated conformance suite
python3 test_palomar_suite.py
```

---

## 4. Downstream Computational Applications (Observatories)

*Note: The 8 theorems verified above by the Palomar Comparator formalize the foundational constructive metric contraction layer of Chou (2026). The multi-scale physical, biological, and hardware systems represent downstream computational applications:*

- **Equivalency Mathematics & TopoNPU Observatory**: [https://h3qm.com/math/](https://h3qm.com/math/)
- **Biomedical & Macromolecular Conformational Platform**: [https://h3qm.com/bio/](https://h3qm.com/bio/)
- **Unified Geometric Physics Simulation**: [https://h3qm.com/physics/](https://h3qm.com/physics/)

---

## 5. Metadata & Licensing

- **Specification**: Conforms to `mathlib-initiative/formalization.yaml` v0.4 schema.
- **License**: Apache 2.0 (`LICENSE`).
- **Archive**: Zenodo [10.5281/zenodo.22928921](https://doi.org/10.5281/zenodo.22928921).
