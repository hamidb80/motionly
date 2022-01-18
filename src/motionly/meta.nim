import macros, macroplus

func toBrackets*(sn: seq[NimNode]): NimNode =
  result = newNimNode(nnkbracket)
  for n in sn:
    result.add n

func toStmtList*(sn: seq[NimNode]): NimNode = 
  result = newStmtList()

  for n in sn:
    result.add n

func toStrLitOrIdent*(n: NimNode): NimNode = 
  if n.kind in nnkLiterals: newStrLitNode repr n
  else: n

func exported*(identNode: NimNode): NimNode =
  postfix(identnode, "*")

func newObjectType*(
  objName: NimNode, fields: seq[tuple[field: NimNode, `type`: NimNode]]
): NimNode =
  var
    typeDef = newTree(nnkTypeDef, newEmptyNode(), newEmptyNode())
    objectDef = newTree(nnkObjectTy, newEmptyNode(), newEmptyNode(), newTree(nnkRecList))

  for fname, ftype in fields.items:
    objectdef[^1].add newIdentDefs(fname, ftype)

  typedef[0] = objName
  result = newTree(nnkTypeSection, typeDef.add(objectDef))

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

