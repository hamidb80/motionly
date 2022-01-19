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

  # rect(fill = "#fff") as @blocks[]
  # rect(fill = "#000") as @blocks[]

  # myComponent() as @myc: # yay, custom component
  #   circle()

  embed """ 
    <rect />
  """
  # embed readfile "./assets/atom.svg"

echo stage.canvas

when false:
  # func mySuperCoolAnimation(
  #   st: SvgTree, kfstart, kfend: SomeType, p: Progress = 0.0
  # ): SvgTree =
  #   discard

  defShow recording, stage:
    before:
      discard
    
    flow reset:
      stage.remove @blocks[1]

    stage 0.ms .. 100.ms:
      let k = move(@box, (10.px, 100.px))
      k.transition(delay = 10.ms, duration = dt, easing = eCubicIn, after = reset)

    at 130.ms:
      reset()

    stage 150.ms .. 200.ms:
      scale(@blocks[0], 1.1).transition(dt, eCricleOut)

    stage 170.ms .. 210.ms: 
      mySuperCoolAnimation(@car, whereIs @car, (0, 0)) ~> (dt, eCubicIn)

  # recording.save("out.gif", 120.fps, size = (1000.px, 400.px), scale = 5.0,
    # preview = 0.ms .. 1000.ms, repeat = 1)
