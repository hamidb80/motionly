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

# method specialAttrs(n: StackLayer): Table[string, string] =
#   discard

proc stackLayerParser(
  tag: string, attrs: Table[string, string], children: seq[SVGNode]
): SVGNode =
  var stack = parseIR stackLayerIR

  for n in stack.nodes.mitems:
    n.attrs["fill"] = attrs["fill"]

  let shape = StackLayer(
    name: "g", nodes: stack.nodes,
    half: stack.nodes[0],
    full: stack.nodes[1],
    transforms: @[translateY(attrs["y"].parseFloat)],
    attrs: {"id": attrs["id"]}.totable
  )

  if not attrs.getOrDefault("visible", "false").parseBool:
    shape.full.attrs["opacity"] = $0

  shape

var pm = baseParserMap
pm["stackLayer"] = stackLayerParser

# --------------------------------------

defStage mystage(width = 185, height = 260), pm:
  stackLayer(y = 0, fill = dark, visible = true) as @layers[]
  stackLayer(y = 50, fill = blue) as @layers[]
  stackLayer(y = 100, fill = dark) as @layers[]
  stackLayer(y = 150, fill = blue) as @layers[]

defTimeline timeline, mystage:
  flow hideStack(i: int, dt: float):
    register @layers[i].tmove(p(0, -30)) ~> (dt, eOutQuad)
    # register @layers[i].hide() ~> (dt, eOutQuad)

  on 100.ms .. 500.ms:
    # !hideStack(1, dt)
    # !hideStack(2, dt)
    discard

  on 400.ms .. 1000.ms:
    !hideStack(3, dt)

  at 1200.ms:
    discard

timeline.saveGif("./temp/out.gif", mystage, 50.fps, justFirstFrame = false)
