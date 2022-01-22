import std/[tables, random]
import motionly

randomize()

const
  pink = "#E05297"
  lightPink = "#EA86B6"
  white = "#FFFFFF"

defStage mystage(width = 1080, height = 1080), baseParserMap:
  rect(width = 1080, height = 1080) as @bg

  group() as @center:
    circle(r = 340, fill = lightPink) as @outer
    circle(r = 300) as @inner

    group() as @textWrapper:
      embed readFile("./assets/dayT.svg")
      embed readFile("./assets/motherT.svg")
      embed readFile("./assets/blessT.svg")

    group() as @party


let
  screen = p(1080.px, 1080.px)
  hscreen = screen / 2

proc randDeg(): float =
  let direction =
    if sample([false, true]): -1
    else: +1

  toFloat:
    direction * rand(20 .. 50)


defTimeline timeline, mystage:
  flow hideTextsExcept(index: int):
    for i, n in @textWrapper.nodes:
      n.opacity =
        if i == index: 1.0
        else: 0.0

  flow setPink():
    @inner.attrs["fill"] = white
    @bg.attrs["fill"] = pink

  flow setWhite():
    @inner.attrs["fill"] = pink
    @bg.attrs["fill"] = white

  flow drop(rotate: bool):
    @center.transforms.setLen 1
    @textWrapper.transforms.setLen 0

    register @center.tscale(2.4 .. 0.6) ~> (700.ms, eInExpo)

    if rotate:
      register @textWrapper.trotate(randDeg()) ~> (400.ms, eInBack, 400.ms)

  flow genFLowers():
    discard

  flow animateFlowers():
    discard

  before:
    @center.transforms = @[translate(hscreen.x, hscreen.y)]

  frame 1000.ms:
    !setPink()
    !hideTextsExcept(0)
    !drop(true)

  frame 1000.ms:
    !setWhite()
    !hideTextsExcept(1)
    !drop(true)

  frame 1000.ms:
    !setPink()
    !hideTextsExcept(2)
    !drop(false)

  after 300.ms:
    register @center.tmove(p(0, -500.px)) ~> (300.ms, eOutCirc)

  after 500.ms:
    discard


timeline.quickView("./temp/out.html", mystage, 50.fps, preview = 3000.ms .. 5000.ms)
