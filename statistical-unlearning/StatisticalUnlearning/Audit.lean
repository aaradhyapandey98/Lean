import StatisticalUnlearning.Unlearning

/-! Run `lake env lean StatisticalUnlearning/Audit.lean` to print the actual
transitive axiom dependencies of every initial theorem. Output must be inspected;
this source file alone is not evidence of a successful audit. -/

#print axioms StatisticalUnlearning.typeIError_zero
#print axioms StatisticalUnlearning.typeIIError_zero
#print axioms StatisticalUnlearning.tradeOff_antitone
#print axioms StatisticalUnlearning.tradeOff_le_one
#print axioms StatisticalUnlearning.Unlearns.mono
#print axioms StatisticalUnlearning.mem_feasibleRegion
#print axioms StatisticalUnlearning.feasibleRegion_mono
