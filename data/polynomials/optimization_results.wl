(*
  Optimization results placeholder

  This file stores the best known polynomial parameters from optimization runs.
*)

(* --- Best known polynomial for R2 asymptotic constant --- *)

bestPolyR2 = <|
  "b0" -> 1,
  "b1" -> Null,  (* Fill from optimization *)
  "b"  -> Null,
  "K"  -> Null,
  "R2" -> Null,  (* R2AsymptoticConstant value *)
  "notes" -> "Placeholder - run optimization to populate"
|>;

(* --- Best known polynomial for R1 explicit constant --- *)

bestPolyR1 = <|
  "b0" -> 1,
  "b1" -> Null,
  "b"  -> Null,
  "K"  -> Null,
  "E"  -> Null,   (* Optimal E parameter *)
  "M1" -> Null,   (* Optimal M1 parameter *)
  "R"  -> Null,   (* Resulting R value *)
  "MLower" -> Null,
  "notes" -> "Placeholder - run optimization to populate"
|>;

(* --- P40 reference values (MTY paper) --- *)

P40Reference = <|
  "b0" -> 1,
  "b1" -> 1.74600190914994,
  "b"  -> 3.56453965437134,
  "K"  -> 40,
  "R"  -> 416,
  "E"  -> 0.1375,
  "M1" -> 0.048976,
  "A"  -> 1125.56,
  "B"  -> 3,
  "logT0" -> 3010299.95663981,  (* log(10^(3010300)) *)
  "MLower" -> 0.04897629343721149,
  "notes" -> "MTY paper values for verification"
|>;
