import std/[strformat, sequtils, strutils, tables]
import types, utils

func parseRect*(
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = SVGRect(name: tag)

  for (key, val) in attrs:
    case key:
    of "x": acc.position.x = parseFloat val
    of "y": acc.position.y = parseFloat val
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
    of "cx": acc.center.x = parseFloat val
    of "cy": acc.center.y = parseFloat val
    of "r": acc.radius = parseFloat val
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


let baseParserMap*: ParserMap = toTable {
  "rect": parseRect,
  "circle": parseCircle,
  "arc": parseRaw[SVGArc],
  "group": parseRaw[SVGGroup], # FIXME: "group" is not a tag name, use "g" instead 
  "g": parseRaw[SVGGroup],
  "test": parseRaw[SVGGroup],
}

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

method toIR(n: SVGNode): IRNode {.base.} =
  IRNode(
    tag: n.name,
    attrs: merge(specialAttrs(n), n.attrs).pairs.toseq,
    children: n.nodes.map toIR
  )

func toIR*(s: string): IRNode=
  result.tag = "test"

func `$`(ir: IRNode): string =
  let ats = ir.attrs.mapIt(fmt "{it[0]}=\"{it[1]}\"").join " "

  if ir.children.len == 0:
    fmt"<{ir.tag} {ats}/>"

  else:
    let body = ir.children.map(`$`).join
    fmt"<{ir.tag} {ats}>{body}</{ir.tag}>"

func `$`*(n: SVGNode): string {.inline.} =
  $ n.toIR
