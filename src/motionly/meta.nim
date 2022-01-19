import macros

func toBrackets*(sn: seq[NimNode]): NimNode =
  result = newNimNode(nnkbracket)
  for n in sn:
    result.add n

func toStmtList*(sn: seq[NimNode]): NimNode =
  result = newStmtList()

  for n in sn:
    result.add n

func toStringNode*(n: NimNode): NimNode =
  if n.kind in {nnkStrLit, nnkTripleStrLit}: n
  elif n.kind in nnkLiterals: newStrLitNode repr n
  else: newCall("$", n)

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
