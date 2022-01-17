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
    of SVGGroup: seWrapper
    else: seShape

method specialAttrs(n: SVGNode): Table[string, string] {.base.} =
  raise newException(ValueError, "trying to stringify empty SVGnode?")

method specialAttrs(n: SVGGroup): Table[string, string] = discard

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

func `$`(n: SVGNode): string =
  let tag = inheritanceCase:
    case n:
    of SVGRect: "rect"
    of SVGCircle: "circle"
    of SVGGroup: "g"
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

proc toSVGTree(stageConfig, code: NimNode): NimNode =
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

    objDef = newObjectType(cntx.exported, idStore.mapIt (it.ident.exported, ident("SVGNode")))

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

    var `varname`: `cntxWrapper`

    ## initStage + resolve components at runtime
    ## search for ids

  debugecho "---------------"
  debugecho repr result

macro genSVGTree*(stageConfig, body): untyped =
  return toSVGTree(stageConfig, body)
