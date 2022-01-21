import motionly
import helper

func move(st: SVGNode, states: HSlice[Point, Point]): UpdateFn =
  let
    s = (SVGRect)(st)
    v = states.b - states.a

  proc updater(p: Progress) =
    s.position = v * p

  updater

# -------------------------------

defStage mystage(width = 200, height = 200), baseParserMap:
  rect(x = 10, y = 20, width = 20, height = 14, fill = "red") as @box

defTimeline timeline, mystage:
  on 0.ms .. 400.ms:
    register @box.move(p(0, 0) .. p(100, 100)) ~> (dt, eOutCubic)


timeline.save("./temp/out.gif", mystage,
  100.fps, preview = 0.ms .. 300.ms)
