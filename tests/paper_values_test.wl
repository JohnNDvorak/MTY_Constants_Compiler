(*
  Automated test suite for MTY constants compiler

  Tests compiler output against stated values in Mossinghoff-Trudgian-Yang
  arXiv:2212.06867.
*)

(* Load compiler *)
Get[FileNameJoin[{ParentDirectory[NotebookDirectory[]], "src", "MTY_constants_compiler.wl"}]];

(* Test framework *)
$testsPassed = 0;
$testsFailed = 0;

SetAttributes[testCase, HoldFirst];
testCase[name_String, expr_, expected_, tolerance_:10^-14] := Module[{result, diff},
  result = expr;
  diff = Abs[N[result] - N[expected]];
  If[diff < tolerance,
    $testsPassed++;
    Print["PASS: ", name],
    $testsFailed++;
    Print["FAIL: ", name];
    Print["  Expected: ", expected];
    Print["  Got: ", result];
    Print["  Diff: ", diff]
  ]
];

(* P40 test polynomial *)
polyP40 = <|"b0" -> 1, "b1" -> 1.74600190914994, "b" -> 3.56453965437134, "K" -> 40|>;

(* MTY parameters *)
A = 1125.56; B = 3; Eparam = 0.1375; M1 = 0.048976; R = 416;
logT0 = 3010299.95663981;

Print["=== MTY Constants Compiler Test Suite ===\n"];

(* --- Test 1: theta computation --- *)
Print["--- Section 4: Theta Tests ---"];
thData = thetaData[1, 1.74600190914994, 80];
testCase["thetaSolve", thData["theta"], 1.13331020636697525818];
testCase["cos^2(theta)", thData["cos2"], 0.17949091786645927783];

(* --- Test 2: w(0) and W0'(0) --- *)
Print["\n--- Section 4: Weight Function Tests ---"];
testCase["w0FromTheta", thData["w0"], 5.64530242431405198661];
testCase["W0prime0FromTheta", thData["W0prime0"], -0.66171942027334783714];

(* --- Test 3: C5(R) --- *)
Print["\n--- Section 4: C5 Tests ---"];
testCase["C5FromTheta(416)", C5FromTheta[416, thData["theta"]], 1.02415653378907392, 10^-13];

(* --- Test 4: kappa functions --- *)
Print["\n--- Section 5: Kappa Tests ---"];
(* Note: Paper doesn't give explicit kappa values, so we test self-consistency *)
kap1 = kappa1[logT0, 40];
kap4 = kappa4[logT0, 40];
testCase["kappa1 positive", kap1 > 0, True, 0];
testCase["kappa4 > 0", kap4 > 0, True, 0];

(* --- Test 5: Y bound --- *)
Print["\n--- Section 5: Y Bound Tests ---"];
Y0 = YBoundWithR[logT0, A, B, Eparam, M1, R, polyP40, logT0];
testCase["YBoundWithR", Y0, 0.41105021806479028, 10^-12];

(* --- Test 6: M_lower --- *)
Print["\n--- Section 5: M Lower Tests ---"];
Mlower = MLowerWithR[A, B, Eparam, M1, R, polyP40, logT0];
testCase["MLowerWithR", Mlower, 0.04897629343721149, 10^-12];

(* --- Test 7: Critical inequality --- *)
Print["\n--- Contradiction Check ---"];
testCase["M_lower > M1", Mlower > 0.048976, True, 0];

(* --- Test 8: R2 asymptotic constant --- *)
Print["\n--- Theorem 1.2: R2 Asymptotic ---"];
R2 = R2AsymptoticConstant[B, polyP40];
testCase["R2 positive", R2 > 0, True, 0];
testCase["R2 reasonable magnitude", R2 > 5 && R2 < 20, True, 0];

(* --- Test 9: bkFromC construction --- *)
Print["\n--- Section 8: c_k Construction ---"];
cTest = {1.0, 0.5, 0.25};
polyFromC = bkFromC[cTest];
testCase["bkFromC b0 = 1", polyFromC["b0"], 1, 0];
testCase["bkFromC K correct", polyFromC["K"], 2, 0];
testCase["bkFromC b1 positive", polyFromC["b1"] > 0, True, 0];

(* Summary *)
Print["\n=== Test Summary ==="];
Print["Passed: ", $testsPassed];
Print["Failed: ", $testsFailed];
Print["Total:  ", $testsPassed + $testsFailed];

If[$testsFailed == 0,
  Print["\nAll tests passed!"],
  Print["\nSome tests failed - review output above."]
];
