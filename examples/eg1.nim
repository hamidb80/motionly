import motionly, tables, sugar

const posx = 10

func update[K, V](t1: var Table[K, V], t2: Table[K, V]) =
  for k, v in t2:
    t1[k] = v

type
  MyComponent = ref object of SVGNode
    isThatTrue: bool

method specialAttrs(n: MyComponent): Table[string, string] =
  result["style"] = "display: none"

func parseMyComponent*(
  tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
): SVGNode =
  var acc = MyComponent(name: tag, nodes: children)

  for (key, val) in attrs:
    acc.attrs[key] = val

  acc

let ff = baseParserMap.dup update totable {
  "myComponent": parseMyComponent
}

defStage stage(width = 200, height = 200), ff:
  # group(x = posx) as @myGroup:
  #   arc() as @myArc

  rect(fill = "#fff") as @box
  rect(fill = "#000") as @blocks[]
  rect(fill = "#000") as @blocks[]

  # myComponent() as @myc: # yay, custom component
  #   circle()

  # embed """
  #   <rect />
  # """
  # embed readfile "./assets/atom.svg"

# echo stage.canvas

# --------------------------------

type
  PointState = ref object of State
    x, y: float

func myCoolAnimationUpdate(
  st: SVGNode, states: Switch, progress: Percent = 0.0
): SVGNode =
  st

func p(x, y: int): PointState =
  PointState(x: x.toFloat, y: y.toFloat)

method myCoolAnimation(
  n: SVGNode, states: (PointState, PointState)
): UpdateAgent =
  # assert n of SVGRect
  UpdateAgent(node: n, states: states, fn: myCoolAnimationUpdate)


defShow recording, stage:
  before:
    discard

  # flows are just procs
  flow reset:
    discard "flow.reset"

  # 'stage's are procs that are also stored in the timeline with implicitly defined 'dt' in them as time range
  # the entities in timeline are sorted based on their start time

  on 0.ms .. 100.ms:
    # let k = move(@box, P(10.px, 100.px))
    # k.transition(delay = 10.ms, duration = dt, easing = eCubicIn, after = reset)
    discard "first kf"

  # 'at's are just a on that it's time range is t..t
  at 130.ms:
    discard "at"
    # reset()

  # on 150.ms .. 200.ms:
  #   scale(@blocks[0], 1.n:1).transition(dt, eCricleOut)
  #   scale(@blocks[0], 1.1) ~> (dt, eCricleOut)

  on 170 .. 210:
    # myCoolAnimation(@box, (whereIs(@box), P(0, 0))) ~> (dt, eCubicIn)
    echo @box.myCoolAnimation (p(100, 100), p(0, 0))


# recording.save("out.gif", 120.fps, size = (1000.px, 400.px), scale = 5.0,
  # preview = 0.ms .. 1000.ms, repeat = 1)
