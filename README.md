# MATLAB Numerical Verification

Numerical companions to the Lean 4 formal proofs in `../conic_dof_lean/`.

[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=ScottTPfaff/ACT_Cosmology&file=matlab/weyl_verification.m&branch=open5/physics-bridge)

## Scripts

| Script | Purpose | Lean companion |
|--------|---------|----------------|
| `weyl_verification.m` | Sturmian density convergence — empirical verification of `density_step_one` / `density_step_two` | `Sturmian.lean` line 322 (1 audited sorry) |

## The Lean Gap

`weyl_equidistribution_interval` in `Sturmian.lean` carries 1 audited sorry:
- All Fourier character averages and geometric sum bounds are formally proved
- Gap: Stone-Weierstrass bridge from `fourierSubalgebra_closure_eq_top` to Birkhoff averages on AddCircle (Mathlib v4.28.0 missing piece)

**Three-Distance Theorem path** (no Stone-Weierstrass needed):
For irrational α, the sequence {α}, {2α}, ..., {Nα} partitions [0,1) into gaps of at most 3 distinct lengths. For α = φ exactly 2 lengths — giving the density result combinatorially. This script verifies it numerically at N = 10⁶.
