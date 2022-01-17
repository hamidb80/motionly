import macros, macroplus

macro inheritanceCase*(body): untyped =
  let caseStmt = body[0]
  doAssert caseStmt.kind == nnkCaseStmt

  result = newNimNode(nnkIfStmt)
  let target = caseStmt[CaseIdent]

  for branch in caseStmt[CaseBranches]:
    case branch.kind:
    of nnkOfBranch:
      let classes = branch[CaseBranchIdents]

      for class in classes: # support for multi of `of 1, 2: `
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

