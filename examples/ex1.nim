import motionly

const posx = 10

genSVGTree stage(width = 200, height = 200), baseParserMap:
  # rect(fill = "#fff")
  # circle(fill = "#fff")

  group(x = posx) as @myGroup:
    arc() as @myArc

  # rect(fill = "#fff", _) as @box # assign svg component to box variable
  # circle(fill = "#fff", _) as @blocks[0] # as array
  # line(_) # you don't need to store all components inside a variable

  # group as @name: # yes we have groups | we have everything in SVG
  #   arc(_)

  # myComponent("arg1", _, injected_here) as @table: # yay, custom component
  #   # your custom component can have slots like vue-js
  #   # the slot injected as its last argument when parsed to svgTree
  #   circ(_) as @targer

  # embed """ # you can throw raw SVG by the way
  #   <rect _/>
  # """
  # embed readfile "./assets/car.svg" # or embed external svg?

echo stage.canvas
echo "----------"
echo stage.components.myArc

when false:
  let
    c = SVGCircle(center: Point(x: 0.0, y: 1.1), radius: 3.0)
    r = SVGRect(position: Point(x: 2.2, y: 3.3), width: 300, height: 500)
    g = SVGGroup(nodes: @[c, r])

  echo g

when false:
  var mySpecialComponenetThatIForgot = stage.query(".class #id")

  # kf: key frame
  # type Progress = range[0.0 .. 100.0]
  func mySuperCoolAnimation(
    st: SvgTree, kfstart, kfend: SomeType, p: Progress = 0.0
  ): SvgTree =
    discard


  let
    recording = show(stage):
      before:
        discard                             # do anything before starting animation
                                            # flows can have args
      flow reset:                           # a named flow
        stage.remove @blocks[1]

      stage 0.ms .. 100.ms:
        # @box is a syntax suger for stage.components.box
        let k = move(@box, (10.px, 100.px)) # define a keyframe

        # register a transition
        k.transition(delay = 10.ms, duration = dt, easing = eCubicIn, after = reset)

      at 130.ms:
        reset()

      stage 150.ms .. 200.ms:
        scale(@blocks[0], 1.1).transition(dt, eCricleOut)

      stage 170.ms .. 210.ms: # yes, stages can have innersects in timing
                                # custom operator is cool
        mySuperCoolAnimation(@car, whereIs @car, (0, 0)) ~> (dt, eCubicIn)

  recording.save("out.gif", 120.fps, size = (1000.px, 400.px), scale = 5.0,
      preview = 0.ms .. 1000.ms, repeat = 1)
