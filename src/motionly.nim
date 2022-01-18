import std/[sequtils, strutils, strformat, tables, random]
import macros, macroplus
import motionly/[utils, meta, types, ir]

export ir
# randomize()

func findIdImpl*(n: SVGNode, id: string, result: var SVGNode) =
  discard

func findId*(n: SVGNode, id: string): SVGNode =
  discard

proc parseIRImpl*(ir: IRNode, parent: SVGNode, parserMap: ParserMap): SVGNode =
  let nodes = ir.children.mapIt parseIRImpl(it, result, parserMap)

  if ir.tag in parserMap:
    result = parserMap[ir.tag](ir.tag, ir.attrs, nodes)
  else:
    raise newException(ValueError, "no such parser for tag name: " & ir.tag)

proc parseIR*(ir: IRNode, parserMap: ParserMap): SVGCanvas =
  let attrs = toTable ir.attrs
  assert attrs.containsAll ["width", "height"]

  result = SVGCanvas(
    name: "svg",
    width: attrs["width"].parseFloat,
    height: attrs["height"].parseFloat,
  )

  result.nodes = ir.children.mapit parseIRImpl(it, result, parserMap)

func ast2IR(n: NimNode, storage: var seq[string]): NimNode =
  assert n.kind in {nnkCall, nnkInfix}, $n.kind
  let hasId = n.kind == nnkInfix
  var targetNode = n

  if hasId:
    assert n[InfixIdent].strVal == "as"
    storage.add n[InfixRightSide][1].strval
    targetNode = n[InfixLeftSide]

    if n.len == 4: # for named wrapper body
      targetNode.add n[3]

  let tag = targetNode[CallIdent].strVal
  var
    attrs: seq[(string, string)]
    children = newNimNode(nnkBracket)

  if hasId:
    attrs.add ("id", storage[^1])

  for arg in targetNode[CallArgs]:
    case arg.kind:
    of nnkExprEqExpr: # args
      attrs.add (arg[0].strval, arg[1].strVal)

    of nnkStmtList: # body
      children = toBrackets arg.toseq.mapIt ast2IR(it, storage)

    else:
      error "invalid arg type: " & $arg.kind

  result = quote:
    `IRNode`(
      tag: `tag`,
      attrs: @`attrs`,
      children: @`children`
    )

proc toSVGTree(stageConfig, parserMap, code: NimNode): NimNode =
  assert stageConfig.kind == nnkcall

  var idStore: seq[string]
  let
    varname = stageConfig[CallIdent]
    args = toBrackets stageConfig[CallArgs].mapIt newTree(
      nnkTupleConstr,
      newStrLitNode(it[0].strval),
      if it[1].kind in nnkLiterals: newStrLitNode repr it[1]
      else: it[1]
    )

    children = toBrackets code.toseq.mapIt ast2IR(it, idStore)

  let
    # id = $rand(1 .. 9999) # FIXME
    id = "22"
    cntx = ident "CustomComponents_" & id
    cntxWrapper = ident "CustomSVGStage_" & id
    stageIdent = ident("IR_" & id)

    objDef = newObjectType(cntx.exported, idStore.mapIt (it.ident.exported,
        quote do: `SVGNode`))

    idGets = toStmtList idStore.mapit do:
      let field = ident it
      quote:
        `varname`.components.`field` = findId(`varname`.canvas, `it`)

  result = quote:
    `objDef`

    type
      `cntxWrapper`* = ref object of `SVGStage`
        components*: `cntx`

    let `stageIdent` = `IRNode`(
      tag: "svg",
      attrs: @`args`,
      children: @`children`
    )

    var `varname` = `cntxWrapper`()
    `varname`.canvas = `parseIR`(`stageIdent`, `parserMap`)
    `idGets`

  debugecho "---------------"
  debugecho repr result

macro genSVGTree*(
  stageConfig: untyped, parserMap: typed, body: untyped
): untyped =
  return toSVGTree(stageConfig, parserMap, body)
