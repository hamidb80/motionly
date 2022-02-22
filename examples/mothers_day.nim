import std/[random, sugar, threadpool]
import motionly

randomize()

const
  pink = "#E05297"
  lightPink = "#EA86B6"
  white = "#FFFFFF"

defStage mystage(width = 1080, height = 1080), baseParserMap:
  rect(width = 1080, height = 1080) as @bg

  group() as @center:
    circle(r = 340, fill = lightPink)
    circle(r = 300) as @inner

    group() as @textWrapper:
      embed readFile("./assets/dayT.svg")
      embed readFile("./assets/motherT.svg")
      embed readFile("./assets/blessT.svg")

  group() as @party

proc randSign(): int =
  if sample([false, true]): -1
  else: +1

proc randDeg(): float =
  toFloat randSign() * rand(20 .. 50)

func eFall(t: Progress): float =
  -4 * t * (t-1)

let screen = mystage.canvas.getsize()

proc hideTextsExcept(textWrapper: SVGNode, index: int) =
  for i, n in textWrapper.nodes:
    n.opacity =
      if i == index: 1.0
      else: 0.0

defTimeline timeline, mystage:
  before:
    let
      frameLen = 1000.ms
      sc = scale(1.0)
      rt = rotation(0.0)

    @center.transforms = @[translate(screen / 2), sc]
    @textWrapper.transforms.add rt


    for i in 0 ..< 3:
      let
        delay = frameLen * i.toFloat
        u = capture(i, delay): toUpdateFn:
          if i mod 2 == 0:
            @inner.fill = white
            @bg.fill = pink
          else:
            @inner.fill = pink
            @bg.fill = white

          hideTextsExcept(@textWrapper, i)
        
      register u |> delay
      register @center.tscale(2.4 .. 0.6, sc) ~> (700.ms, eInExpo, delay)

      register @textWrapper.trotate(0.deg .. 0.deg, rt) |> delay
      if i != 2:
        register @textWrapper.trotate(0.deg .. randDeg(), rt) ~> (400.ms,
            eInBack, 400.ms + delay)


  after 3000.ms:
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

      var myf = deepCopy(rose)
      myf.transforms.add translate(x, y)
      @party.add myf

      register myf.tmove(p(dx, 0)) ~> (dt, eLinear, delay)
      register myf.tmove(p(0, dy)) ~> (dt, eFall, delay)
      register myf.trotate(0.deg .. dr) ~> (dt, eLinear, delay)


setMaxPoolSize(12)
timeline.quickView("./temp/out.html", mystage, 60.fps)
# timeline.saveGif("./temp/out.gif", mystage, 50.fps)
