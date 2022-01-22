import motionly

defStage mystage(width = 200, height = 200), baseParserMap:
  rect(width = 20, height = 14, fill = "red") as @box

defTimeline timeline, mystage:
  on 0.ms .. 400.ms:
    register @box.tmove(p(0, 0) .. p(100, 100)) ~> (dt, eOutCubic)

  on 400.ms .. 800.ms:
    register @box.tmove(p(100, 100) .. p(0, 100)) ~> (dt, eOutCubic)

  frame 500.ms:
    register @box.tmove(p(100, 0)) ~> (dt, eOutCubic)

  frame 100.ms:
    register @box.tmove(p(100, 0)) ~> (300.ms, eOutCubic)

timeline.saveGif("./temp/out.gif", mystage, 50.fps)
