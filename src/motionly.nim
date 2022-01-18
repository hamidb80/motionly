import std/[sequtils, strutils, strformat, tables, random]
import macros, macroplus
import motionly/[utils, meta]

# randomize()

type
  Point* = object
    x*, y*: float

  SVGAbstractElemKind* = enum
    seWrapper, seShape

  SVGNode* = ref object of RootObj
    attrs*, styles*: Table[string, string]
    parent*: SVGNode
    nodes*: seq[SVGNode]

  SVGCanvas* = ref object of SVGNode # <svg> ... </svg>
    width, height: float

  SVGGroup* = ref object of SVGNode

  SVGRect* = ref object of SVGNode
    position*: Point
    width*, height*: float

  SVGCircle* = ref object of SVGNode
    center*: Point
    radius*: float

  # stGroup, stDef
  # of stText:
  # of stLine:
  # of stPath:
  # of stTextPath:
  # if stPolygon, stPolyline

  # IR :: Intermediate representation
  IRNode = object
    tag: string
    attrs: seq[(string, string)]
    children: seq[IRNode]

  SVGStage* = ref object of RootObj
    canvas*: SVGCanvas

  IRParser* = proc(
    attrs: seq[(string, string)], children: seq[SVGNode]
  ): SVGNode {.nimcall.}

  ParserMap* = Table[string, IRParser] # tag name => parser func

func parseRect*(attrs: seq[(string, string)], children: seq[SVGNode]): SVGNode =
  var acc = SVGRect()

  for (key, val) in attrs:
    case key:
    of "x": acc.position.x = parseFloat val
    of "y": acc.position.y = parseFloat val
    of "width": acc.width = parseFloat val
    of "height": acc.height = parseFloat val
    else:
      acc.attrs[key] = val

  acc

func parseCircle*(attrs: seq[(string, string)], children: seq[SVGNode]): SVGNode =
  var acc = SVGCircle()

  for (key, val) in attrs:
    case key:
    of "cx": acc.center.x = parseFloat val
    of "cy": acc.center.y = parseFloat val
    of "r": acc.radius = parseFloat val
    else:
      acc.attrs[key] = val

  acc
  
# let 

let baseParserMap*: ParserMap = toTable {
  "rect": parseRect,
  "circle": parseCircle
}

func genXmlElem(tag: string,
    attrs: Table[string, string],
    body: string = ""
): string =
  let ats = attrs.pairs.toseq.mapIt(fmt "{it[0]}=\"{it[1]}\"").join " "

  if body.len == 0:
    fmt"<{tag} {ats}/>"

  else:
    fmt"<{tag} {ats}>{body}</{tag}>"

func kind(n: SVGNode): SVGAbstractElemKind =
  inheritanceCase:
    case n:
    of SVGGroup, SVGCanvas: seWrapper
    else: seShape

method specialAttrs(n: SVGNode): Table[string, string] {.base.} = discard

method specialAttrs(n: SVGCanvas): Table[string, string] =
  {"width": $n.width, "height": $n.height}.toTable

method specialAttrs(n: SVGCircle): Table[string, string] =
  {"cx": $n.center.x, "cy": $n.center.y, "r": $n.radius}.toTable

method specialAttrs(n: SVGRect): Table[string, string] =
  {
    "x": $n.position.x, "y": $n.position.y,
    "width": $n.width, "height": $n.height
  }.toTable

func findIdImpl*(n: SVGNode, id: string, result: var SVGNode) =
  discard

func findId*(n: SVGNode, id: string): SVGNode =
  discard

proc parseIRImpl*(ir: IRNode, parent: SVGNode, parserMap: ParserMap): SVGNode =
  let nodes = ir.children.mapIt parseIRImpl(it, result, parserMap)

  if ir.tag in parserMap:
    result = parserMap[ir.tag](ir.attrs, nodes)
  else:
    raise newException(ValueError, "no such parser for tag name: " & ir.tag)

proc parseIR*(ir: IRNode, parserMap: ParserMap): SVGCanvas =
  let attrs = toTable ir.attrs
  assert attrs.containsAll ["width", "height"]
  
  result = SVGCanvas(
    width: attrs["width"].parseFloat,
    height: attrs["height"].parseFloat,
  )

  result.nodes = ir.children.mapit parseIRImpl(it, result, parserMap)


func `$`*(n: SVGNode): string =
  let tag = inheritanceCase:
    case n:
    of SVGRect: "rect"
    of SVGCircle: "circle"
    of SVGGroup: "g"
    of SVGCanvas: "svg"
    else: "??"

  genXmlElem(tag, merge(specialAttrs(n), n.attrs),
    if n.kind == seWrapper: n.nodes.mapit($it).join
    else: "")

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

macro genSVGTree*(stageConfig: untyped, parserMap: typed, body: untyped): untyped =
  return toSVGTree(stageConfig, parserMap,body)
