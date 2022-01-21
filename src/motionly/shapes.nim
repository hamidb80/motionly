import std/[tables, strutils]
import types

type
  SVGWrapper* = ref object of SVGNode
    x*, y*: float

  SVGGroup* = ref object of SVGWrapper

  SVGShape* = ref object of SVGNode

  SVGRect* = ref object of SVGShape
    x, y*: float
    width*, height*: float

  SVGCircle* = ref object of SVGShape
    cx, cy*: float
    radius*: float

  SVGArc* = ref object of SVGShape


proc replaceNode*(n: var SVGNode, with: SVGNode) =
  for c in n.parent.nodes.mitems:
    if c == n:
      c = with
      c.parent = n.parent
      n = with
      return

  raise newException(ValueError, "parent is not registered")

proc `<-`*(n: var SVGNode, with: SVGNode) =
  replaceNode(n, with)

func parseRect*(
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = SVGRect(name: tag)

  for (key, val) in attrs:
    case key:
    of "x": acc.x = parseFloat val
    of "y": acc.y = parseFloat val
    of "width": acc.width = parseFloat val
    of "height": acc.height = parseFloat val
    else:
      acc.attrs[key] = val

  acc

func parseCircle*(
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = SVGCircle(name: tag)

  for (key, val) in attrs:
    case key:
    of "cx": acc.cx = parseFloat val
    of "cy": acc.cy = parseFloat val
    of "r": acc.radius = parseFloat val
    else:
      acc.attrs[key] = val

  acc

func parseGroup*(
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = SVGGroup(name: "g")

  for (key, val) in attrs:
    case key:
    of "x": acc.x = parseFloat val
    of "y": acc.y = parseFloat val
    else:
      acc.attrs[key] = val

  acc


func parseRaw*[S: SVGNode](
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = S(name: tag, nodes: children)

  for (key, val) in attrs:
    acc.attrs[key] = val

  acc


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


method pos*(n: SVGNode): Point {.base.} =
  raise newException(ValueError, "not implemented")

method pos*(n: SVGWrapper): Point =
  p(n.x, n.y)

method pos*(n: SVGRect): Point =
  p(n.x, n.y)

method pos*(n: SVGCircle): Point =
  p(n.cx, n.cy)


method `pos=`*(n: SVGNode, np: Point) {.base.} =
  raise newException(ValueError, "not implemented")

method `pos=`*(n: SVGWrapper, np: Point) =
  n.x = np.x
  n.y = np.y

method `pos=`*(n: SVGRect, np: Point) =
  n.x = np.x
  n.y = np.y

method `pos=`*(n: SVGCircle, np: Point) =
  n.cx = np.x
  n.cy = np.y