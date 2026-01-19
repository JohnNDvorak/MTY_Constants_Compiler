(*
  MTY (Mossinghoff–Trudgian–Yang) constants compiler skeleton
  for the Korobov–Vinogradov (VK) “all t ≥ T0” contradiction step
  built around Lemma 4.7 and Section 5.

  This is Mathematica / Wolfram Language code.
  It is intended to be readable and hackable rather than micro-optimized.
*)

ClearAll[thetaSolve, w0FromTheta, W0prime0FromTheta, thetaData,
  c0FromTheta, c1FromTheta, c2FromTheta, c3FromTheta,
  HFromTheta, C5FromTheta,
  L1FromLogT, L2FromLogT,
  kappa1, kappa2, kappa3, kappa4,
  mainCoeff,
  RFromE,
  YBound,
  MLower,
  R2AsymptoticConstant,
  bkFromC
];

(* ------------------------
   1) Theta, w(0), W0'(0)
   ------------------------ *)

(* Solve sin^2 θ = (b1/b0)(1 - θ cot θ) for θ ∈ (0,π/2). *)
thetaSolve[b0_?NumericQ, b1_?NumericQ, prec_:80] := Module[{th},
  th /. FindRoot[
    Sin[th]^2 == (b1/b0) (1 - th Cot[th]),
    {th, 1.13},
    WorkingPrecision -> prec,
    AccuracyGoal -> Floor[prec/2],
    PrecisionGoal -> Floor[prec/2]
  ]
];

(* w(0) = (θ tan θ + 3 θ cot θ - 3) sec^2 θ *)
w0FromTheta[th_?NumericQ] := (th Tan[th] + 3 th Cot[th] - 3) Sec[th]^2;

(* Closed form (MTY eq. (4.6)) for W0'(0). *)
W0prime0FromTheta[th_?NumericQ] := (
  Csc[th] (3 (4 th^2 - 5) + th (15 - 4 th^2) Cot[th]) - 3 th Sec[th]
) / (3 Sin[th]);

(* Convenience wrapper. *)
thetaData[b0_?NumericQ, b1_?NumericQ, prec_:80] := Module[
  {th, w0, W0p, cos2},
  th  = thetaSolve[b0, b1, prec];
  w0  = w0FromTheta[th];
  W0p = W0prime0FromTheta[th];
  cos2 = Cos[th]^2;
  <|"theta" -> th, "w0" -> w0, "W0prime0" -> W0p, "cos2" -> cos2|>
];

(* ------------------------
   2) C5(R)
   ------------------------ *)

c0FromTheta[th_?NumericQ] := 1/(Sin[th] Cos[th]^3);
c1FromTheta[th_?NumericQ] := (th - Sin[th] Cos[th]) Tan[th]^4;
c2FromTheta[th_?NumericQ] := Tan[th]^3 Sin[th]^2;
c3FromTheta[th_?NumericQ] := (th - Sin[th] Cos[th]) Tan[th]^2;

(* MTY eq. (4.5)–(4.7): H(R) bound used to control F0(z). *)
HFromTheta[R_?NumericQ, th_?NumericQ] := Module[
  {c0, c1, c2, c3, denom},
  c0 = c0FromTheta[th];
  c1 = c1FromTheta[th];
  c2 = c2FromTheta[th];
  c3 = c3FromTheta[th];
  denom = (1 - (Tan[th]^2/R^2))^2;
  c0/denom * (
    c2 (R + 1)^2/R^3 * (Exp[2 th Cot[th]] + 1) + c1/R^2 + c3
  )
];

C5FromTheta[R_?NumericQ, th_?NumericQ] := Module[{w0},
  w0 = w0FromTheta[th];
  HFromTheta[R, th] (R + 1)^2/(R^3 w0) + 1 + 1/R
];

(* ------------------------
   3) Log-robust L1, L2
   ------------------------ *)

(* For huge t, it is numerically safer to work with log t.
   L1(t) = log(K t + 1) and L2(t) = log log(K t + 1).
   If logt = log t, then log(K t + 1) = logt + log(K + e^{-logt}).
*)
L1FromLogT[logt_?NumericQ, K_?NumericQ] := logt + Log[K + Exp[-logt]];
L2FromLogT[logt_?NumericQ, K_?NumericQ] := Log[L1FromLogT[logt, K]];

(* ------------------------
   4) κ-constants (Section 5)
   ------------------------ *)

kappa1[logT0_?NumericQ, K_?NumericQ] := Module[{L1, L2},
  L1 = L1FromLogT[logT0, K];
  L2 = L2FromLogT[logT0, K];
  (L1/L2)^(2/3) / (logT0^(2/3) * Log[logT0]^(1/3))
];

kappa2[logT0_?NumericQ, B_?NumericQ, K_?NumericQ] := Module[{L1, L2},
  L1 = L1FromLogT[logT0, K];
  L2 = L2FromLogT[logT0, K];
  EulerGamma * (L2/(B L1))^(2/3)
];

kappa3[logT0_?NumericQ, K_?NumericQ] := 1/3 + 5.409 + 209.1/(Log[K] + logT0);

kappa4[logT0_?NumericQ, K_?NumericQ] := 10^-100*(1 + Log[K + Exp[-logT0]]/logT0) + Log[K + Exp[-logT0]];

(* ------------------------
   5) Main coefficient (from T2 bound)
   ------------------------ *)

mainCoeff[E_?NumericQ, b_?NumericQ, b0_?NumericQ] := (1/(3 E))*(b/b0 + 1) + (b Sqrt[E])/(2 b0);

(* ------------------------
   6) Choose R from (E, M1)
   ------------------------ *)

RFromE[E_?NumericQ, M1_?NumericQ, logT0_?NumericQ, K_?NumericQ] := Module[{L2, r},
  L2 = L2FromLogT[logT0, K];
  r = Floor[E * L2/M1] - 1;
  Max[3, r]
];

(* ------------------------
   7) Y-bound (the secondary terms)
   ------------------------ *)

(*
  YBound returns the quantity Y(t) such that the combined bound from (5.10)-(5.14)
  can be written as

    1/λ * (cos^2θ - α κ4/log T0) ≤ (B L1)^(2/3) L2^(1/3) ( mainCoeff + Y(t) )

  where α = -W0'(0) b1/(w(0)b0).

  IMPORTANT: the /1.879 belongs to the ENTIRE bracket (log(A/η) + 2/3 L2)
  coming from Lemma 4.5/4.6, not just the 2/3 L2 term.
*)
YBound[
  logt_?NumericQ,
  A_?NumericQ, B_?NumericQ,
  E_?NumericQ, M1_?NumericQ,
  poly_Association,
  logT0_?NumericQ
] := Module[
  {b0, b1, b, K, thDat, th, w0, W0p, alpha, cos2, R, C5,
   L1, L2, kap1, kap2, kap3, kap4, main, term1, term2, term3, inner},

  b0 = poly["b0"]; b1 = poly["b1"]; b = poly["b"]; K = poly["K"];

  thDat = thetaData[b0, b1, 80];
  th = thDat["theta"]; w0 = thDat["w0"]; W0p = thDat["W0prime0"]; cos2 = thDat["cos2"];
  alpha = -(W0p*b1)/(w0*b0);

  R  = RFromE[E, M1, logT0, K];
  C5 = C5FromTheta[R, th];

  L1 = L1FromLogT[logt, K];
  L2 = L2FromLogT[logt, K];

  kap1 = kappa1[logT0, K];
  kap2 = kappa2[logT0, B, K];
  kap3 = kappa3[logT0, K];
  kap4 = kappa4[logT0, K];

  main = mainCoeff[E, b, b0];

  (* Contribution from 1.5*T1 bound, normalized by (B L1)^(2/3) L2^(1/3). *)
  term1 = 1.5 * kap1 * M1/(E^2 * L2);

  (* Contribution from the "secondary" part of T2, normalized similarly. *)
  term2 = (1/(2 E * L2)) * (
    (b/b0) Log[A] + (2/3) Log[B/L2] - Log[E] + kap2 * E/B^(2/3)
  );

  (* Contribution from C5*(b/b0)*T3, normalized similarly. *)
  inner = 5.392/Sqrt[E]
    + 4/(5.637 * E^2)
    + (kap3 - 10.784 B)/B^(4/3) * (L2/L1)^(1/3)
    + (1/(E^2 * L2)) * ( (Log[A] + (2/3) Log[B/L2] - Log[E])/1.879 + 0.213 );

  term3 = (C5 * (b/b0) * M1 / L2) * inner;

  (* Return only the secondary term Y(t), not including mainCoeff. *)
  term1 + term2 + term3
];

(* ------------------------
   8) Final M-lower bound
   ------------------------ *)

MLower[
  A_?NumericQ, B_?NumericQ,
  E_?NumericQ, M1_?NumericQ,
  poly_Association,
  logT0_?NumericQ
] := Module[
  {b0, b1, K, thDat, th, w0, W0p, alpha, cos2, kap4, main, Y0, num, den},

  b0 = poly["b0"]; b1 = poly["b1"]; K = poly["K"];

  thDat = thetaData[b0, b1, 80];
  th = thDat["theta"]; w0 = thDat["w0"]; W0p = thDat["W0prime0"]; cos2 = thDat["cos2"];
  alpha = -(W0p*b1)/(w0*b0);

  kap4 = kappa4[logT0, K];
  main = mainCoeff[E, poly["b"], b0];

  (* In MTY the monotonicity check shows Y(t) decreases for t ≥ T0, so the worst case is t=T0.
     The function below is written in terms of logt.
  *)
  Y0 = YBound[logT0, A, B, E, M1, poly, logT0];

  num = cos2 - alpha * kap4/logT0;
  den = main + Y0;

  num/den
];

(* ------------------------
   9) Asymptotic constant R2 (for Theorem 1.2 / eq. (8.2))
   ------------------------ *)

R2AsymptoticConstant[B_?NumericQ, poly_Association] := Module[
  {b0, b1, b, th, thDat, cos2},
  b0 = poly["b0"]; b1 = poly["b1"]; b = poly["b"];
  thDat = thetaData[b0, b1, 80];
  th = thDat["theta"]; cos2 = thDat["cos2"];
  (1/cos2) * (3/4)^(2/3) * (b/b0) * (1 + b0/b)^(1/3) * B^(2/3)
];

(* ------------------------
   10) Optional helper: compute b_k from c_k construction (Section 8)
   ------------------------ *)

bkFromC[c_List] := Module[
  {K, denom, b0, bk},
  K = Length[c] - 1;
  denom = Total[c^2];
  b0 = 1; (* by construction *)
  bk = Table[
    2*Sum[c[[j + 1]]*c[[j + k + 1]], {j, 0, K - k}]/denom,
    {k, 1, K}
  ];
  <|
    "b0" -> b0,
    "b1" -> bk[[1]],
    "bk" -> bk,
    "b" -> Total[bk],
    "K" -> K
  |>
];


(* --- Variants where R is supplied explicitly --- *)

ClearAll[YBoundWithR, MLowerWithR];

YBoundWithR[
  logt_?NumericQ,
  A_?NumericQ, B_?NumericQ,
  E_?NumericQ, M1_?NumericQ,
  R_Integer,
  poly_Association,
  logT0_?NumericQ
] := Module[
  {b0, b1, b, K, thDat, th, w0, W0p, alpha, cos2, C5,
   L1, L2, kap1, kap2, kap3, kap4, main, term1, term2, term3, inner},

  b0 = poly["b0"]; b1 = poly["b1"]; b = poly["b"]; K = poly["K"];

  thDat = thetaData[b0, b1, 80];
  th = thDat["theta"]; w0 = thDat["w0"]; W0p = thDat["W0prime0"]; cos2 = thDat["cos2"];
  alpha = -(W0p*b1)/(w0*b0);

  C5 = C5FromTheta[R, th];

  L1 = L1FromLogT[logt, K];
  L2 = L2FromLogT[logt, K];

  kap1 = kappa1[logT0, K];
  kap2 = kappa2[logT0, B, K];
  kap3 = kappa3[logT0, K];
  kap4 = kappa4[logT0, K];

  main = mainCoeff[E, b, b0];

  term1 = 1.5 * kap1 * M1/(E^2 * L2);

  term2 = (1/(2 E * L2)) * (
    (b/b0) Log[A] + (2/3) Log[B/L2] - Log[E] + kap2 * E/B^(2/3)
  );

  inner = 5.392/Sqrt[E]
    + 4/(5.637 * E^2)
    + (kap3 - 10.784 B)/B^(4/3) * (L2/L1)^(1/3)
    + (1/(E^2 * L2)) * ( (Log[A] + (2/3) Log[B/L2] - Log[E])/1.879 + 0.213 );

  term3 = (C5 * (b/b0) * M1 / L2) * inner;

  term1 + term2 + term3
];

MLowerWithR[
  A_?NumericQ, B_?NumericQ,
  E_?NumericQ, M1_?NumericQ,
  R_Integer,
  poly_Association,
  logT0_?NumericQ
] := Module[
  {b0, b1, K, thDat, th, w0, W0p, alpha, cos2, kap4, main, Y0, num, den},

  b0 = poly["b0"]; b1 = poly["b1"]; K = poly["K"];

  thDat = thetaData[b0, b1, 80];
  th = thDat["theta"]; w0 = thDat["w0"]; W0p = thDat["W0prime0"]; cos2 = thDat["cos2"];
  alpha = -(W0p*b1)/(w0*b0);

  kap4 = kappa4[logT0, K];
  main = mainCoeff[E, poly["b"], b0];

  Y0 = YBoundWithR[logT0, A, B, E, M1, R, poly, logT0];

  num = cos2 - alpha * kap4/logT0;
  den = main + Y0;

  num/den
];
