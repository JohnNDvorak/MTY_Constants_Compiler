(*
  P40 sanity check: Reproduce all MTY paper values with assertions

  This script verifies the compiler produces the exact values stated in
  Mossinghoff-Trudgian-Yang arXiv:2212.06867 for their P40 polynomial.
*)

(* Load compiler *)
Get[FileNameJoin[{ParentDirectory[NotebookDirectory[]], "src", "MTY_constants_compiler.wl"}]];

(* P40 polynomial from Table 2 *)
polyP40 = <|
  "b0" -> 1,
  "b1" -> 1.74600190914994,
  "b"  -> 3.56453965437134,
  "K"  -> 40
|>;

(* MTY paper parameters *)
A = 1125.56;
B = 3;
Eparam = 0.1375;
M1 = 0.048976;
R = 416;
logT0 = 3010299.95663981;

(* Expected values from MTY paper (with stated precision) *)
expectedTheta  = 1.13331020636697525818;
expectedCos2   = 0.17949091786645927783;
expectedW0     = 5.64530242431405198661;
expectedW0p    = -0.66171942027334783714;
expectedC5     = 1.02415653378907392;
expectedY0     = 0.41105021806479028;
expectedMLower = 0.04897629343721149;

(* Tolerance for comparison *)
tol = 10^-14;

(* Helper function for assertions *)
assertClose[name_String, computed_, expected_, tolerance_] := Module[{diff},
  diff = Abs[computed - expected];
  If[diff < tolerance,
    Print["PASS: ", name, " = ", NumberForm[computed, 20]],
    Print["FAIL: ", name];
    Print["  Expected: ", NumberForm[expected, 20]];
    Print["  Computed: ", NumberForm[computed, 20]];
    Print["  Difference: ", diff]
  ];
  diff < tolerance
];

(* Compute all values *)
Print["=== MTY P40 Sanity Check ===\n"];

thData = thetaData[polyP40["b0"], polyP40["b1"], 80];
theta = thData["theta"];
cos2  = thData["cos2"];
w0    = thData["w0"];
W0p   = thData["W0prime0"];
C5    = C5FromTheta[R, theta];
Y0    = YBoundWithR[logT0, A, B, Eparam, M1, R, polyP40, logT0];
Mlower = MLowerWithR[A, B, Eparam, M1, R, polyP40, logT0];

(* Run assertions *)
Print["--- Derived Quantities ---"];
pass1 = assertClose["theta", theta, expectedTheta, tol];
pass2 = assertClose["cos^2(theta)", cos2, expectedCos2, tol];
pass3 = assertClose["w(0)", w0, expectedW0, tol];
pass4 = assertClose["W0'(0)", W0p, expectedW0p, tol];

Print["\n--- Section 5 Quantities ---"];
pass5 = assertClose["C5(416)", C5, expectedC5, tol];
pass6 = assertClose["Y(T0)", Y0, expectedY0, tol];
pass7 = assertClose["M_lower", Mlower, expectedMLower, tol];

(* Final summary *)
Print["\n--- Summary ---"];
allPassed = And[pass1, pass2, pass3, pass4, pass5, pass6, pass7];

If[allPassed,
  Print["All checks PASSED!"],
  Print["Some checks FAILED - review output above"]
];

(* Critical check: M_lower > M1 threshold *)
Print["\n--- Contradiction Check ---"];
Print["M_lower = ", NumberForm[Mlower, 18]];
Print["M1 threshold = ", M1];
Print["M_lower > 0.048976? ", If[Mlower > 0.048976, "YES - Contradiction holds!", "NO - Problem!"]];
