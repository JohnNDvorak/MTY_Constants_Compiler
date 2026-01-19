(*
  Section 8 c_k parametrization for constructing valid Korobov polynomials

  The c_k construction ensures the polynomial W(x) = sum_{k=0}^K b_k cos(2 pi k x)
  is nonnegative with W(0) = 1 (normalized).

  Given c = {c_0, c_1, ..., c_K}, the b_k are computed via:
    b_k = 2 * sum_{j=0}^{K-k} c_j * c_{j+k} / sum_j c_j^2

  This automatically guarantees:
    - b_0 = 1 (normalization)
    - W(x) >= 0 for all x (positive definiteness)
*)

(* Usage example: *)
(*
  c = {1.0, 0.8, 0.5, 0.3, 0.1};  (* Example c_k values *)
  poly = bkFromC[c];
  (* poly now has keys: "b0", "b1", "bk", "b", "K" *)
*)

(* Constraints on c_k:
   - All c_k should be real
   - At least one c_k must be nonzero
   - The choice of c_k affects the asymptotic constant R2
   - Optimization: minimize R2AsymptoticConstant[B, poly] over c_k
*)

(* Example c_k that produces a near-optimal K=40 polynomial: *)
(* See optimization_results.wl for best known parameters *)
