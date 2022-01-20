import motionly, tables, sugar, strutils


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

const
  posx = 10
  w = 100

defStage stage(width = w, height = 200), ff:
  # group(x = posx) as @myGroup:
  #   arc() as @myArc

  rect(x = posx) as @box
  rect(fill = "#000") as @blocks[]
  rect(fill = "#000") as @blocks[]

  # myComponent() as @myc: # yay, custom component
  #   circle()

  # embed """
  #   <rect />
  # """
  # embed readfile "./assets/atom.svg"

# --------------------------------

func myCoolAnimation(st: SVGNode, states: HSlice[Point, Point]): UpdateFn =
  proc updater(progress: Percent): SVGNode = st
  updater

func p(x, y: int): Point =
  Point(x: x.toFloat, y: y.toFloat)

defTimeline timeline, stage:
  # before:
  #   discard

  # # flows are just procs
  # flow reset:
  #   discard "flow.reset"

  on 0.ms .. 100.ms:
    # let k = move(@box, P(10.px, 100.px))
    # k.transition(delay = 10.ms, duration = dt, easing = eCubicIn, after = reset)
    discard "first kf"

  at 130.ms:
    discard "at"
    # reset()

  # on 150.ms .. 200.ms:
  #   scale(@blocks[0], 1.n:1).transition(dt, eCricleOut)
  #   scale(@blocks[0], 1.1) ~> (dt, eCricleOut)

  on 170.ms .. 210.ms:
    # myCoolAnimation(@box, (whereIs(@box), P(0, 0))) ~> (dt, eCubicIn)
    register @box.myCoolAnimation(p(100, 100) .. p(0, 0)) ~> (10, eInCubic)


echo timeline.join "\n"

timeline.save("out.gif", 120.fps, p(1000, 400), preview = 0.ms .. 1000.ms, repeat = 1)
