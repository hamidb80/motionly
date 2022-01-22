import std/[tables, strutils]
import motionly


type
  StackLayer = ref object of SVGGroup
    half, full: SVGNode

const
  dark = "#483D3D"
  blue = "#0088A6"

  stackLayerIR = toIR readFile "./assets/stack-layer.svg"

# --------------------------------------------

method specialAttrs(n: StackLayer): Table[string, string] =
  discard

proc stackLayerParser(
  tag: string, attrs: Table[string, string], children: seq[SVGNode]
): SVGNode =
  var stack = parseIR stackLayerIR

  for n in stack.nodes.mitems:
    n.attrs["fill"] = attrs["fill"]

  StackLayer(
    name: "g", nodes: stack.nodes,
    half: stack.nodes[0],
    full: stack.nodes[1],
    attrs: {"id": attrs["id"]}.totable
  )

var pm = baseParserMap
pm["stackLayer"] = stackLayerParser

# --------------------------------------

defStage mystage(width = 185, height = 500), pm:
  stackLayer(y = 00, fill = dark) as @layers[]
  stackLayer(y = 30, fill = blue) as @layers[]
  stackLayer(y = 60, fill = dark) as @layers[]
  stackLayer(y = 90, fill = blue) as @layers[]

defTimeline timeline, mystage:
  flow hideStack(i: int, dt: float):
    discard
    # let currentp = @layers[i].pos
    # register @layers[i].tmove(p(0, -30)) ~> (dt, eOutQuad)
    # register @layers[i].hide() ~> (dt, eOutQuad)

  on 100.ms .. 500.ms:
    !hideStack(2, dt)

  on 600.ms .. 1000.ms:
    !hideStack(2, dt)


timeline.saveGif("./temp/out.gif", mystage, 50.fps)
