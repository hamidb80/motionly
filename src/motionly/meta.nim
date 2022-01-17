import macros, macroplus

macro inheritanceCase*(body): untyped =
  let caseStmt = body[0]
  doAssert caseStmt.kind == nnkCaseStmt

  result = newNimNode(nnkIfStmt)

  for branch in caseStmt[CaseBranches]:
    case branch.kind:
    of nnkOfBranch:
      let
        class = branch[CaseBranchIdent]
        target = caseStmt[CaseIdent]

      result.add newTree(
        nnkElifBranch,
        quote do: (`target` of `class`),
        branch[CaseBranchBody])

    of nnkElse:
      result.add branch

    else:
      error "invalid branch"

  # echo repr result
  return result

