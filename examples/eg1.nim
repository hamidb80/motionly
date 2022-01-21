import std/[tables]
import motionly

type
  MyComponent = ref object of SVGNode
    isThatTrue: bool

method specialAttrs(n: MyComponent): Table[string, string] =
  result["style"] = "display: none"

func parseMyComponent(
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = MyComponent(name: tag, nodes: children)

  for (key, val) in attrs:
    acc.attrs[key] = val

  acc

var ff = baseParserMap
ff["myComponent"] = parseMyComponent

const
  posx = 10
  w = 100

defStage mystage(width = w, height = 200), ff:
  # group(x = posx) as @myGroup:
  #   arc() as @myArc

  rect(x = posx) as @box
  rect(fill = "#fff") as @blocks[]
  rect(fill = "#000") as @blocks[]

  # myComponent() as @myc: # yay, custom component
  #   circle()

  # embed """
  #   <rect />
  # """
  # embed readfile "./assets/atom.svg"

# --------------------------------

func myCoolAnimation(st: SVGNode, states: HSlice[Point, Point]): UpdateFn =
  proc updater(progress: Progress) = discard
  updater

func p(x, y: int): Point =
  Point(x: x.toFloat, y: y.toFloat)

defTimeline timeline, mystage:
  flow reset():
    discard "flow.reset"

  before:
    discard "blue"
    !reset()

  on 0.ms .. 100.ms:
    # let k = move(@box, P(10.px, 100.px))
    # k.transition(delay = 10.ms, duration = dt, easing = eCubicIn, after = reset)
    discard "first kf"

  at 130.ms:
    discard "at"

  on 170.ms .. 210.ms:
    register @box.myCoolAnimation(p(100, 100) .. p(0, 0)) ~> (10.ms, eLinear)

timeline.saveGif("./temp/out.gif", mystage, 120.fps,
  preview = 0.ms .. 100.ms, repeat = 1)
