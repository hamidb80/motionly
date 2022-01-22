import motionly

const
  pink = "#E05297"
  lightPink = "#EA86B6"
  white = "#FFFFFF"

defStage mystage(width = 1080, height = 1080), baseParserMap:
  rect(width = 1080, height = 1080, fill = pink) as @bg

  group() as @center:
    circle(r = 340, fill = "#EA86B6") as @outer
    circle(r = 300, fill = "white") as @inner
    embed readFile("./assets/dayT.svg")

let
  screen = p(1080.px, 1080.px)
  hscreen = screen / 2

defTimeline timeline, mystage:
  before:
    @center.transforms = @[translate(hscreen.x, hscreen.y)]

  flow animate():
    @center.transforms.setLen 1
    register @center.tscale(2.4 .. 0.6) ~> (700.ms, eInExpo)
    register @center.trotate(-30.0) ~> (400.ms, eInExpo, 400.ms)

  frame 1000.ms: 
    !animate()
  
  frame 1000.ms: 
    !animate()
  
  frame 1000.ms: 
    !animate()


timeline.quickView("./temp/out.html", mystage, 50.fps)
