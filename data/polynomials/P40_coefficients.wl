(*
  P40 polynomial coefficients from MTY Table 2
  Korobov polynomial with K=40 numerically optimized for R2 asymptotic constant
*)

polyP40 = <|
  "b0" -> 1,
  "b1" -> 1.74600190914994,
  "b"  -> 3.56453965437134,
  "K"  -> 40
|>;

(* Expected values when using P40:
   theta        = 1.13331020636697525818
   cos^2(theta) = 0.17949091786645927783
   w(0)         = 5.64530242431405198661
   W0'(0)       = -0.66171942027334783714
*)
