import std/[sequtils, strutils, strformat, tables]
import macros, macroplus
import motionly/[utils, meta]

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

let
  c = SVGCircle(center: Point(x: 0.0, y: 1.1), radius: 3.0)
  r = SVGRect(position: Point(x: 2.2, y: 3.3), width: 300, height: 500)
  g = SVGGroup(nodes: @[c, r])

# echo g
type
  # IR :: Intermediate representation
  IRNode = object
    tag: string
    attrs: seq[(string, string)]
    children: seq[IRNode]

func ast2IR(n: NimNode): NimNode =
  assert n.kind in {nnkCall, nnkInfix}, $n.kind

  # of nnkInfix:
  # assert node[InfixIdent].strVal == "as"

  # let
  #   component = node[InfixLeftSide]
  #   alias = block:
  #     let t = node[InfixRightSide]
  #     assert t.kind == nnkPrefix
  #     t[1].strval


  # if node[^1].kind == nnkStmtList: # has body
  #   # parse its body first


  let tag = n[CallIdent].strVal
  var
    attrs: seq[(string, string)]
    children = newNimNode(nnkBracket)

  for arg in n[CallArgs]:
    case arg.kind:
    of nnkExprEqExpr: # args
      attrs.add (arg[0].strval, arg[1].strVal)

    of nnkStmtList: # body
      children = arg.toseq.map(ast2IR).toBrackets

    else:
      error "invalid arg type: " & $arg.kind

  result = quote:
    `IRNode`(
      tag: `tag`,
      attrs: @`attrs`,
      children: @`children`
    )

func toSVGTree(wrapper, code: NimNode): NimNode =
  assert wrapper.kind == nnkcall

  debugEcho treeRepr wrapper
  debugEcho treeRepr code

  let
    varname = wrapper[CallIdent]
    args = toBrackets wrapper[CallArgs].mapIt do:
      newTree(nnkTupleConstr, newStrLitNode(it[0].strval),
        if it[1].kind in nnkLiterals: newStrLitNode repr it[1]
        else: it[1]
      )

    brkt = code.toseq.map(ast2IR).toBrackets

  result = quote:
    var `varname` = `IRNode`(
      tag: "svg",
      attrs: @`args`,
      children: @`brkt`
    )

  # debugecho "--------------"
  # debugecho treerepr result
  # debugecho repr result


macro genSVGTree*(stageVariable, body): untyped =
  return toSVGTree(stageVariable, body)
