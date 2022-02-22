import std/[tables, strutils]
import types
import utils

type
  SVGGroup* = ref object of SVGNode

  SVGStrLiteral* = ref object of SVGNode

  SVGRect* = ref object of SVGNode
    x*, y*: float
    width*, height*: float

  SVGText* = ref object of SVGNode
    x*, y*: float

  SVGCircle* = ref object of SVGNode
    cx, cy*: float
    radius*: float

  SVGArc* = ref object of SVGNode
  SVGPath* = ref object of SVGNode


proc replaceNode*(n: var SVGNode, with: SVGNode) =
  ## replaces node in the DOM and the container
  for c in n.parent.nodes.mitems:
    if c == n:
      c = with
      c.parent = n.parent
      n = with
      return

  raise newException(ValueError, "parent is not registered")

proc add*(n, sub: SVGNode) =
  n.nodes.add sub
  sub.parent = n

proc add*(n: SVGNode, subs: openArray[SVGNode]) =
  for sub in subs:
    n.add sub

proc `<-`*(n: var SVGNode, with: SVGNode) =
  replaceNode(n, with)

# ----------------------------------------------

type
  FontConfig* = object
    family*, weight*: string
    size*: float

func applyFont(n: SVGNode, fc: FontConfig) =
  if not isEmpty fc.family:
    n.styles["font-family"] = fc.family

  if fc.size != 0:
    n.styles["font-size"] = $fc.size

  if not isEmpty fc.weight:
    n.styles["font-weight"] = fc.weight

# ----------------------------------------------

template newElem(class): untyped =
  class(kind: mjElem)

# TODO, use macro : better arguments

func newText*(text: string, fc = FontConfig()): SVGText =
  result = newElem SVGText
  result.name = "text"
  result.applyFont fc
  result.add SVGStrLiteral(kind: mjText, content: text)

func newRect*(): SVGRect =
  result = newElem SVGRect
  result.name = "rect"

func newCircle*(): SVGCircle =
  result = newElem SVGCircle
  result.name = "circle"

func newGroup*(): SVGGroup =
  result = newElem SVGGroup
  result.name = "g"

func newCanvas*(): SVGCanvas =
  result = newElem SVGCanvas
  result.name = "svg"


func getSize*(c: SVGCanvas): Point =
  p(c.width, c.height)


method specialAttrs*(n: SVGNode): Table[string, string] {.base.} = discard

method specialAttrs*(n: SVGCanvas): Table[string, string] =
  {"width": $n.width, "height": $n.height}.toTable

method specialAttrs*(n: SVGCircle): Table[string, string] =
  {"cx": $n.cx, "cy": $n.cy, "r": $n.radius}.toTable

method specialAttrs*(n: SVGRect): Table[string, string] =
  {
    "x": $n.x, "y": $n.y,
    "width": $n.width, "height": $n.height
  }.toTable

method specialAttrs*(n: SVGText): Table[string, string] =
  {"x": $n.x, "y": $n.y}.toTable


method pos*(n: SVGNode): Point {.base.} =
  raise newException(ValueError, "not implemented")

method pos*(n: SVGRect): Point =
  p(n.x, n.y)

method pos*(n: SVGCircle): Point =
  p(n.cx, n.cy)

method `pos=`*(n: SVGNode, np: Point) {.base.} =
  raise newException(ValueError, "not implemented")

method `pos=`*(n: SVGRect, np: Point) =
  n.x = np.x
  n.y = np.y

method `pos=`*(n: SVGCircle, np: Point) =
  n.cx = np.x
  n.cy = np.y

method opacity*(n: SVGNode): float {.base.} =
  n.styles.getOrDefault("opacity", "1").parseFloat

method `opacity=`*(n: SVGNode, o: Progress) {.base.} =
  n.styles["opacity"] = $o

method fill*(n: SVGNode): string {.base.} =
  n.styles["fill"]

method `fill=`*(n: SVGNode, f: string) {.base.} =
  n.styles["fill"] = f

method fontFamily*(n: SVGNode): string {.base.} =
  n.styles["font-family"]

method `fontFamily=`*(n: SVGNode, ff: string) {.base.} =
  n.styles["font-family"] = ff

method fontSize*(n: SVGNode): float {.base.} =
  parseFloat n.styles["font-family"]

method `fontSize=`*(n: SVGNode, fz: float) {.base.} =
  n.styles["font-size"] = $fz

method fontWeight*(n: SVGNode): float {.base.} =
  parseFloat n.styles["font-weight"]

method `fontWeight=`*(n: SVGNode, fw: float) {.base.} =
  n.styles["font-weight"] = $fw

# -------------------------------------
# ----------------------------------------------
# TODO parse "styles" too

func parseText*(tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =

  var acc = newText(attrs.getOrDefault("content", ""))

  for key, val in attrs:
    case key:
    of "x": acc.x = parseFloat val
    of "y": acc.y = parseFloat val
    of "font_family": acc.fontFamily = val
    of "font_size": acc.fontSize = parseFloat val
    of "font_weight": acc.fontWeight = parseFloat val
    else:
      acc.attrs[key] = val

  acc

func parseRect*(tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =

  var acc = newRect()

  for key, val in attrs:
    case key:
    of "x": acc.x = parseFloat val
    of "y": acc.y = parseFloat val
    of "width": acc.width = parseFloat val
    of "height": acc.height = parseFloat val
    else:
      acc.attrs[key] = val

  acc

func parseCircle*(tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =
  var acc = newCircle()

  for key, val in attrs:
    case key:
    of "cx": acc.cx = parseFloat val
    of "cy": acc.cy = parseFloat val
    of "r": acc.radius = parseFloat val
    else:
      acc.attrs[key] = val

  acc

func parseGroup*(tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =

  result = newGroup()
  result.attrs = attrs
  result.nodes = children

func parseSVGCanvas*(tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =

  var c = newCanvas()
  c.nodes = children

  for k, v in attrs:
    case k:
    of "width": c.width = v.parseInt
    of "height": c.height = v.parseInt
    else: c.attrs[k] = v

  c

func parseRaw*[S: SVGNode](tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =
  var acc = newElem S
  acc.name = tag
  acc.nodes = children

  for key, val in attrs:
    acc.attrs[key] = val

  acc
