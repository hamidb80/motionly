import motionly

defStage mystage(width = 200, height = 200), baseParserMap:
  rect(width = 20, height = 14, fill = "red") as @box

defTimeline timeline, mystage:
  on 0.ms .. 400.ms:
    register @box.tmove(p(0.px, 0.px) .. p(100.px, 100.px)) ~> (dt, eOutCubic)

  on 400.ms .. 800.ms:
    register @box.tmove(p(100.px, 100.px) .. p(0.px, 100.px)) ~> (dt, elinear)

  after 300.ms: discard # waste some time

  frame 500.ms:
    register @box.tmove(p(100.px, 0.px)) ~> (dt, eOutCubic)

  frame 100.ms:
    register @box.tmove(p(100.px, 0.px)) ~> (dt, eOutCubic)

timeline.saveGif("./temp/out.gif", mystage, 50.fps)
