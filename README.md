# MTY Constants Compiler

A Wolfram Language implementation of the Korobov–Vinogradov zero-free region contradiction machinery from the Mossinghoff–Trudgian–Yang paper [arXiv:2212.06867](https://arxiv.org/abs/2212.06867).

## Overview

This compiler implements the computational pipeline for establishing explicit zero-free regions for the Riemann zeta function via the Korobov–Vinogradov method. The key mathematical components are:

1. **Lemma 4.7**: Computes θ, w(0), W₀'(0) from polynomial coefficients b₀, b₁
2. **Section 4**: Evaluates the C₅(R) constant controlling F₀(z) bounds
3. **Section 5**: Combines all bounds into Y(t) and the final M_lower test

The contradiction argument shows that for suitable parameters, M_lower > M₁, proving the zero-free region holds.

## Installation

```mathematica
Get["/path/to/MTY_Constants_Compiler/src/MTY_constants_compiler.wl"];
```

## Quick Start

```mathematica
(* Load compiler *)
Get["src/MTY_constants_compiler.wl"];

(* Define polynomial (P40 from paper) *)
poly = <|"b0" -> 1, "b1" -> 1.74600190914994,
         "b" -> 3.56453965437134, "K" -> 40|>;

(* Compute theta data *)
thData = thetaData[poly["b0"], poly["b1"], 80];
(* Returns: theta, cos2, w0, W0prime0 *)

(* Compute C5 for R=416 *)
C5 = C5FromTheta[416, thData["theta"]];

(* Compute M_lower with MTY parameters *)
A = 1125.56; B = 3; E = 0.1375; M1 = 0.048976;
logT0 = 3010299.95663981;
Mlower = MLowerWithR[A, B, E, M1, 416, poly, logT0];

(* Verify contradiction: Mlower > M1 *)
```

## Key Functions

| Function | Description |
|----------|-------------|
| `thetaSolve[b0, b1, prec]` | Solve sin²θ = (b₁/b₀)(1 - θ cot θ) |
| `thetaData[b0, b1, prec]` | Compute θ, cos²θ, w(0), W₀'(0) |
| `w0FromTheta[th]` | Weight function w(0) from θ |
| `W0prime0FromTheta[th]` | Derivative W₀'(0) from θ |
| `C5FromTheta[R, th]` | C₅(R) constant from eq. (4.5)-(4.7) |
| `HFromTheta[R, th]` | H(R) bound for F₀(z) |
| `kappa1[logT0, K]` | κ₁ constant from Section 5 |
| `kappa2[logT0, B, K]` | κ₂ constant from Section 5 |
| `kappa3[logT0, K]` | κ₃ constant from Section 5 |
| `kappa4[logT0, K]` | κ₄ constant from Section 5 |
| `mainCoeff[E, b, b0]` | Main coefficient from T₂ bound |
| `RFromE[E, M1, logT0, K]` | Compute R from E, M₁ |
| `YBound[...]` | Y(t) secondary terms bound |
| `YBoundWithR[...]` | Y(t) with explicit R |
| `MLower[...]` | Final M_lower computation |
| `MLowerWithR[...]` | M_lower with explicit R |
| `R2AsymptoticConstant[B, poly]` | R₂ asymptotic constant (Theorem 1.2) |
| `bkFromC[c]` | Construct bₖ from cₖ (Section 8) |

## Optimization Workflow

1. **Optimize polynomial for R₂ (asymptotic)**:
   ```mathematica
   (* Minimize R2AsymptoticConstant over c_k parameters *)
   R2 = R2AsymptoticConstant[B, bkFromC[cVec]];
   ```

2. **Feed candidates into M_lower pipeline**:
   ```mathematica
   Mlower = MLowerWithR[A, B, E, M1, R, poly, logT0];
   ```

3. **Tune E to maximize fixed-point margin**:
   ```mathematica
   (* Search over E values for maximum Mlower - M1 *)
   ```

4. **Solve for largest feasible M₁**:
   ```mathematica
   (* Find maximum M1 such that MLower[...] > M1 *)
   ```

## Directory Structure

```
MTY_Constants_Compiler/
├── src/
│   └── MTY_constants_compiler.wl   # Main compiler
├── examples/
│   ├── basic_usage.wl              # Usage examples
│   └── P40_sanity_check.wl         # Paper value verification
├── tests/
│   └── paper_values_test.wl        # Automated tests
├── notebooks/                       # Interactive work
├── data/
│   └── polynomials/
│       ├── P40_coefficients.wl     # Table 2 polynomial
│       ├── ck_template.wl          # Section 8 template
│       └── optimization_results.wl # Best parameters
└── README.md
```

## Verification

Run the sanity check to verify against MTY paper values:

```mathematica
Get["examples/P40_sanity_check.wl"];
```

Expected output confirms:
- θ = 1.13331020636697525818
- cos²θ = 0.17949091786645927783
- w(0) = 5.64530242431405198661
- W₀'(0) = -0.66171942027334783714
- C₅(416) = 1.02415653378907392
- Y(T₀) = 0.41105021806479028
- M_lower = 0.04897629343721149 > 0.048976 ✓

## References

- Mossinghoff, Trudgian, Yang. "Explicit zero-free regions for the Riemann zeta function." arXiv:2212.06867 (2022).
