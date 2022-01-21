import std/[strformat, sequtils, strutils, tables, strtabs, xmlparser, xmltree]
import types, utils, shapes

proc parseIRImpl*(ir: IRNode, parent: SVGNode, parserMap: ParserMap): SVGNode =
  let nodes = ir.children.mapIt parseIRImpl(it, nil, parserMap)

  if ir.tag in parserMap:
    result = parserMap[ir.tag](ir.tag, ir.attrs, nodes)

    for n in nodes:
      n.parent = result

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

let baseParserMap*: ParserMap = toTable {
  "rect": parseRect,
  "circle": parseCircle,
  "arc": parseRaw[SVGArc],
  "group": parseRaw[SVGGroup], # FIXME: "group" is not a tag name, use "g" instead
  "g": parseRaw[SVGGroup],
  "path": parseRaw[SVGGroup],
  "svg": parseRaw[SVGCanvas],
}

method toIR(n: SVGNode): IRNode {.base.} =
  IRNode(
    tag: n.name,
    attrs: merge(specialAttrs(n), n.attrs).pairs.toseq,
    children: n.nodes.map toIR
  )

func toIRImpl(xml: XmlNode, result: var IRNode) =
  result.tag = xml.tag

  if xml.attrs != nil:
    result.attrs = xml.attrs.pairs.toseq

  for n in xml:
    var acc = IRNode()
    toIRImpl(n, acc)
    result.children.add acc

proc toIR*(svgContent: string, ignoreSVGTag = true): IRNode =
  toIRImpl parseXml(svgContent), result

func `$`(ir: IRNode): string =
  let ats = ir.attrs.mapIt(fmt "{it[0]}=\"{it[1]}\"").join " "

  if ir.children.len == 0:
    fmt"<{ir.tag} {ats}/>"

  else:
    let body = ir.children.map(`$`).join
    fmt"<{ir.tag} {ats}>{body}</{ir.tag}>"

func `$`*(n: SVGNode): string {.inline.} =
  $ n.toIR