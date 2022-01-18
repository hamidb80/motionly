import motionly

const posx = 10

genSVGTree stage(width = 200, height = 200), baseParserMap:
  group(x = posx) as @myGroup:
    arc() as @myArc

  # rect(fill = "#fff")
  # circle(fill = "#fff") as @blocks[0] # as array

  # myComponent() as @table: # yay, custom component
  #   # your custom component can have slots like vue-js
  #   # the slot injected as its last argument when parsed to svgTree
  #   circ() as @targer

  # embed """ # you can throw raw SVG by the way
  #   <rect _/>
  # """
  # embed readfile "./assets/car.svg" # or embed external svg?

echo stage.canvas
# echo "----------"
# echo stage.components.myArc

when false:
  func mySuperCoolAnimation(
    st: SvgTree, kfstart, kfend: SomeType, p: Progress = 0.0
  ): SvgTree =
    discard

  let recording = show(stage):
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
