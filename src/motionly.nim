import std/[sequtils, strutils, strformat, tables, random]
import macros, macroplus
import motionly/[utils, meta, types, ir]

export ir, types
# randomize()

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

func findIdImpl*(n: SVGNode, id: string, result: var SVGNode) =
  if n.attrs.getOrDefault("id", "") == id:
    result = n
  else:
    for c in n.nodes:
      findIdImpl(c, id, result)

func findId*(n: SVGNode, id: string): SVGNode =
  findIdImpl(n, id, result)

  if result == nil:
    raise newException(ValueError, "no such elem with id: " & id)

func ast2IR(n: NimNode, storageid: var ComponentMap): NimNode =
  assert n.kind in {nnkCall, nnkInfix, nnkCommand}, $n.kind
  let 
    hasId = n.kind == nnkInfix
    isComponent = n.kind in {nnkCall, nnkInfix}
  var
    targetNode = n
    id = ""

  if hasId:
    assert n[InfixIdent].strVal == "as"
    let isseq = n[InfixRightSide].kind == nnkBracketExpr

    id = strVal:
      if isseq: n[InfixRightSide][0][1]
      else: n[InfixRightSide][1]

    if (not isseq) or (id notin storageid):
      storageid[id] = (isseq, 1)
    else:
      storageid[id].count.inc

    targetNode = n[InfixLeftSide]

    if n.len == 4: # for named wrapper body
      targetNode.add n[3]

  let tag = targetNode[CallIdent].strVal
  var
    attrs = newNimNode(nnkBracket)
    children = newNimNode(nnkBracket)

  if hasId:
    attrs.add toTupleNode(
      newStrLitNode("id"),
      if storageid[id].isseq:
        (fmt"{id}_{storageid[id].count-1}").newStrLitNode
      else:
        id.newStrLitNode
    )

  if isComponent:
    for arg in targetNode[CallArgs]:
      case arg.kind:
      of nnkExprEqExpr: # args
        attrs.add toTupleNode(arg[0].strval.newStrLitNode, arg[1].toStringNode)

      of nnkStmtList: # body
        children = toBrackets arg.toseq.mapIt ast2IR(it, storageid)

      else:
        error "invalid arg type: " & $arg.kind

    quote:
      `IRNode`(
        tag: `tag`,
        attrs: @`attrs`,
        children: @`children`
      )

  else:
    assert targetNode[CommandIdent].strval == "embed"
    let code = targetNode[CommandBody]
    quote:
      `toIR`(`code`)

proc toSVGTree(stageConfig, parserMap, code: NimNode): NimNode =
  assert stageConfig.kind == nnkcall

  var idStore: ComponentMap
  let
    varname = stageConfig[CallIdent]
    args = toBrackets stageConfig[CallArgs].mapIt toTupleNode(
      it[0].strval.newStrLitNode,
      it[1].toStringNode
    )

    children = toBrackets code.toseq.mapIt ast2IR(it, idStore)

  let
    # id = $rand(1 .. 9999) # FIXME
    id = "22"
    cntx = ident "CustomComponents_" & id
    cntxWrapper = ident "CustomSVGStage_" & id
    stageIdent = ident("IR_" & id)

    objDef = newObjectType(cntx.exported, idStore.pairs.toseq.mapIt do:(
      it[0].ident.exported,
      if it[1].isSeq:
        newTree(nnkBracketExpr, ident"seq", quote do: `SVGNode`)
      else:
        quote do: `SVGNode`
    ))

    idGets = toStmtList idStore.pairs.toseq.mapit do:
      let
        fname = it[0]
        field = fname.ident

      if it[1].isseq:
        var res = newTree(nnkBracket)
        for i in 0 ..< it[1].count:
          let iname = fmt"{fname}_{i}"
          res.add quote do:
            findId(`varname`.canvas, `iname`)

        quote:
          `varname`.components.`field` = @`res`

      else:
        quote:
          `varname`.components.`field` = findId(`varname`.canvas, `fname`)

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
