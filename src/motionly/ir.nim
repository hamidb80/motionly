import std/[strformat, sequtils, strutils, tables, strtabs, xmlparser, xmltree]
import types, utils, shapes

let baseParserMap*: ParserMap = toTable {
  "svg": parseSVGCanvas,
  "group": parseGroup,
  "g": parseGroup,

  "rect": parseRect,
  "circle": parseCircle,
  "path": parseRaw[SVGPath],
  "text": parseText,
  # "arc": parseRaw[SVGArc],
}

proc parseIR*(ir: IRNode, parent: SVGNode = nil,
  parserMap: ParserMap = baseParserMap): SVGNode =

  let nodes = ir.children.mapIt parseIR(it, nil, parserMap)

  if ir.tag in parserMap:
    result = parserMap[ir.tag](ir.tag, ir.attrs.toTable, nodes)
    result.parent = parent

    for n in nodes:
      n.parent = result

  else:
    raise newException(ValueError, "no such parser for tag name: " & ir.tag)

func toIRImpl(xml: XmlNode, result: var IRNode) =
  result.tag = xml.tag

  if xml.attrs != nil:
    result.attrs = xml.attrs.pairs.toseq

  for n in xml:
    var acc = IRNode()
    toIRImpl(n, acc)
    result.children.add acc

proc toIR*(svgContent: string): IRNode =
  toIRImpl parseXml(svgContent), result

func toIR(n: SVGNode): IRNode =
  case n.kind:
  of mjText: IRNode(content: n.content)
  of mjELem:
    var otherAttrs: Table[string, string]

    if n.transforms.len != 0:
      otherAttrs["transform"] = n.transforms.join(" ")

    if n.styles.len != 0:
      otherAttrs["style"] = n.styles.pairs.toseq.mapIt(
          fmt"{it[0]}: {it[1]}").join "; "

    IRNode(tag: n.name,
      attrs: merge(specialAttrs(n), otherAttrs, n.attrs).pairs.toseq,
      children: n.nodes.map toIR)

func `$`(ir: IRNode): string =
  if not isEmpty ir.content: ir.content
  else:
    let ats = ir.attrs.mapIt(fmt "{it[0]}=\"{it[1]}\"").join " "

    if ir.children.len == 0:
      fmt"<{ir.tag} {ats}/>"

    else:
      let body = ir.children.map(`$`).join
      fmt"<{ir.tag} {ats}>{body}</{ir.tag}>"

func `$`*(n: SVGNode): string {.inline.} =
  $ n.toIR
