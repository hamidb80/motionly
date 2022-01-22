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
    transforms: @[translateY(attrs["y"].parseFloat)],
    attrs: {"id": attrs["id"]}.totable
  )

var pm = baseParserMap
pm["stackLayer"] = stackLayerParser

# --------------------------------------

defStage mystage(width = 185, height = 310), pm:
  stackLayer(y = 50, fill = dark) as @layers[]
  stackLayer(y = 100, fill = blue) as @layers[]
  stackLayer(y = 150, fill = dark) as @layers[]
  stackLayer(y = 200, fill = blue) as @layers[]
  stackLayer(y = 250, fill = dark) as @layers[]

defTimeline timeline, mystage:
  flow moveUp(i: int, dt: float, delay: float):
    register @layers[i].tmove(p(0, -50)) ~> (dt, eOutCubic, delay)

  flow show(i: int, dt: float):
    register @layers[i].fadeIn() ~> (dt, eInQuad)

  flow hide(i: int, dt: float):
    register @layers[i].fadeOut() ~> (dt, eInOutQuad)

  flow showFull(i: int, dt: float):
    register (StackLayer @layers[i]).full.fadeIn() ~> (dt, eOutQuad)

  before:
    for l in @layers[3 .. ^1]:
      l.opacity = 0.0

    for l in @layers[1..^1]:
      (StackLayer l).full.opacity = 0.0

  # --- part 1
  on 0.ms .. 400.ms:
    !hide(0, dt)
    !moveUp(0, dt, 0)

  on 300.ms .. 700.ms:
    for i in 1 .. 4:
      !moveUp(i, dt, toFloat i * 100)

  on 500.ms .. 800.ms:
    !showFull(1, dt)
    !show(3, dt)

  # --- part 2
  on 1400.ms .. 1800.ms:
    !hide(1, dt)
    !moveUp(1, dt, 0)

  on 1800.ms .. 2200.ms:
    for i in 2 .. 4:
      !moveUp(i, dt, toFloat i * 100)

  on 2000.ms .. 2300.ms:
    !showFull(2, dt)
    !show(4, dt)

  at 2900.ms:
    discard

timeline.saveGif("./temp/out.gif", mystage, 50.fps, justFirstFrame = false)
