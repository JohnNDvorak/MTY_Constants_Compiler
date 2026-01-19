(*
  Basic usage example for MTY constants compiler

  This script demonstrates the core workflow:
  1. Load the compiler
  2. Set up the P40 polynomial
  3. Compute derived quantities (theta, w(0), W0'(0))
  4. Compute C5(R)
  5. Compute Y(T0) and M_lower
*)

(* --- 1. Load the compiler --- *)
Get[FileNameJoin[{ParentDirectory[NotebookDirectory[]], "src", "MTY_constants_compiler.wl"}]];
(* Or if running as a script: *)
(* Get["/Users/john.n.dvorak/Documents/Git/MTY_Constants_Compiler/src/MTY_constants_compiler.wl"]; *)

(* --- 2. Define the P40 polynomial --- *)
polyP40 = <|
  "b0" -> 1,
  "b1" -> 1.74600190914994,
  "b"  -> 3.56453965437134,
  "K"  -> 40
|>;

(* --- 3. Compute theta and related quantities --- *)
thData = thetaData[polyP40["b0"], polyP40["b1"], 80];

Print["theta = ", thData["theta"]];
Print["cos^2(theta) = ", thData["cos2"]];
Print["w(0) = ", thData["w0"]];
Print["W0'(0) = ", thData["W0prime0"]];

(* --- 4. Compute C5(R) --- *)
R = 416;
C5 = C5FromTheta[R, thData["theta"]];
Print["C5(", R, ") = ", C5];

(* --- 5. Set up MTY paper parameters --- *)
A = 1125.56;
B = 3;
Eparam = 0.1375;
M1 = 0.048976;
logT0 = 3010299.95663981;  (* log(10^(3010300)) *)

(* --- 6. Compute Y(T0) bound --- *)
Y0 = YBoundWithR[logT0, A, B, Eparam, M1, R, polyP40, logT0];
Print["Y(T0) = ", Y0];

(* --- 7. Compute M_lower --- *)
Mlower = MLowerWithR[A, B, Eparam, M1, R, polyP40, logT0];
Print["M_lower = ", Mlower];

(* --- 8. Verify contradiction holds --- *)
If[Mlower > M1,
  Print["SUCCESS: M_lower > M1, contradiction holds!"],
  Print["FAILED: M_lower <= M1, no contradiction"]
];
