import std/math
import motionly

const
  pink = "#E05297"
  lightPink = "#EA86B6"
  white = "#FFFFFF"

defStage mystage(width = 1080, height = 1080), baseParserMap:
  rect(width = 1080, height = 1080, fill = pink) as @bg

  group() as @center:
    circle(r=340, fill="#EA86B6") as @outer
    circle(r=300, fill="white") as @inner
    embed readFile("./assets/dayT.svg")

let 
  size = p(680.px, 680.px)
  hsize = p(680.px, 680.px) / 2.0
  hscreen = p(1080.px, 1080.px) / 2

defTimeline timeline, mystage:
  before:
    # --------
    # @center.transforms.add translate(hscreen.x, hscreen.y)
    # @center.transforms.add scale(0.6)
    # @center.transforms.add translate(hscreen.x * 1.6, hscreen.y * 1.6)
    # --------
    @center.transforms.add translate(hscreen.x, hscreen.y)
    # @center.transforms.add translate(hscreen.x * 1.6, hscreen.y * 1.6)


  # flow sscale(ds: float, currentp: Point, dt: float, e: EasingFn):
  #   let sf = 1.0 + ds # scale factor
                
  #   register @center.tmove(currentp * -ds) ~> (dt, e)
  #   register @center.tscale(1.0 .. sf) ~> (dt, e)

  on 0.ms .. 700.ms: 
    register @center.tscale(2.4 .. 0.6) ~> (dt, eInExpo)
    # register @center.tmove(p(400.px, 0)) ~> (dt, eInExpo)

  on 400.ms .. 800.ms: 
    register @center.trotate(-30.0) ~> (dt, eInExpo)
    # register @center.tmove(p(400.px, 0)) ~> (dt, eInExpo)

  after 500.ms:
    discard

timeline.quickView("./temp/out.gif", mystage, 50.fps)
