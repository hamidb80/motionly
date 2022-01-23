import std/[tables, random, sugar]
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

proc randSign(): int =
  if sample([false, true]): -1
  else: +1

proc randDeg(): float =
  toFloat randSign() * rand(20 .. 50)

func eFall(t: Progress): float =
  -4 * t * (t-1)

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

  after 300.ms:
    let rose = parseIR toIR readFile("./assets/rose.svg")
    for i in 1..30:
      let
        y = screen.y + 100.px
        x = rand(0.px .. screen.x)
        dx = rand(50.px .. 200.px) * randSign().toFloat
        dy = -screen.y * rand(0.4 .. 0.9)
        dt = rand 800.ms .. 1300.ms
        delay = rand 0.ms .. 800.ms
        dr = randSign().toFloat * rand(0.0 .. 50.0) 

      var myf: SVGNode
      deepCopy(myf, rose)
      myf.transforms.add translate(x, y)
      @party.add myf

      register myf.tmove(p(dx, 0)) ~> (dt, eLinear, delay)
      register myf.tmove(p(0, dy)) ~> (dt, eFall, delay)
      register myf.trotate(dr) ~> (dt, eLinear, delay)


timeline.quickView("./temp/out.html", mystage, 50.fps)
# timeline.saveGif("./temp/out.gif", mystage, 50.fps)
