import std/[os, osproc, strformat, tables, algorithm, math, sequtils]
import types, ir

func findIdImpl*(n: SVGNode, id: string, result: var SVGNode) =
  if n.attrs.getOrDefault("id", "") == id:
    result = n
  else:
    for c in n.nodes:
      findIdImpl(c, id, result)

func findId*(n: SVGNode, id: string): SVGNode =
  findIdImpl(n, id, result)

  if result == nil:
    raise newException(ValueError, "no such elem with id: " & id)

func cmp*(k1, k2: KeyFrame): int =
  cmp(k1.startTime, k2.startTime)

func sort*(tl: var TimeLine) =
  tl.sort cmp

func toAnimation*(t: Transition): Animation =
  Animation(t: t)

func genTransition*(u: UpdateFn, delay, len: MS, e: EasingFn): Transition =
  Transition(delay: delay, totalTime: len, easingFn: e, updateFn: u)

func resolveTimeline*(kfs: seq[KeyFrameIR]): TimeLine =
  var lastTime = 0.ms
  for kf in kfs:
    let startTime =
      if kf.isDependent:
        let res = kf.timeRange.a + lasttime
        lastTime = kf.timeRange.b + lastTime
        res
      else:
        lastTime = kf.timeRange.b
        kf.timeRange.a

    result.add (startTime, kf.fn)

func toMagickFrameDelay(ms: MS): int =
  (ms / 10).floor.toint.max(2)

func genFrameFileName(fname: string, index: int): string =
  fmt"{fname}_{index:06}.svg"

# TODO clean svg files unless you're in debug mode
# TODO use web browser preview in debug mode
proc save(
  tl: TimeLine, stage: SVGStage,
  frameDuration: float, preview: HSlice[MS, MS],
  justFirstFrame = false, keepUseless = false,
  saveFn: proc(i: int, content: string),
): int =
  assert isSorted tl

  var
    currentTime = 0.0
    activeAnimations: Recording
    animationQueue: Recording
    tli = 0
    savedCount = 0

  block loop:
    while (
        keepUseless or tli <= tl.high or
        activeAnimations.len + animationQueue.len != 0
      ) and currentTime <= preview.b:

      block collectNewAnimations:
        var newAnimations: Recording

        while tli <= tl.high:
          if currentTime >= tl[tli].startTime:
            tl[tli].fn(stage, newAnimations, currentTime)
            tli.inc
          else: break

        for a in newAnimations.mitems:
          a.startTime = currentTime + a.t.delay
          animationQueue.add a
          # FIXME animations starttime are set to the time that
          # the currentTime arrives, not the actual start time

      block applyAndFilterAnimations:
        animationQueue.keepItIf:
          if currentTime >= it.startTime:
            activeAnimations.add it
            false
          else:
            true

        activeAnimations.keepItIf:
          let timeProgress = toProgress:
            (currentTime - it.startTime) / it.t.totalTime

          it.t.updateFn(it.t.easingFn(timeProgress), timeProgress)
          not timeProgress.ended

      block takeSnapShot:
        if currentTime in preview:
          # writeFile(dir / genFrameFileName(fname, savedCount), $stage.canvas)
          saveFn(savedCount, $stage.canvas)
          savedCount.inc

        if justFirstFrame:
          break loop

      currentTime += frameDuration

  savedCount

func wrapSVG*(id, svg: string): string =
  fmt"""<div id="{id}" class="frame">{svg}</div>"""

proc saveGif*(
  tl: TimeLine, outputPath: string,
  stage: SVGStage, frameRate: FPS, scale = 1.0,
  preview = 0.ms .. 10_000.ms, repeat = 1,
  justFirstFrame = false, keepUseless = false,
) =
  ## note: the best fps for magick is 50.fps
  ## TODO apply FRAME LIMIT | 50 for GIF
  let
    frameDuration = 1000 / frameRate
    (dir, fname, _) = outputPath.splitFile

  proc saveCallback(i: int, s: string) =
    writeFile dir/genFrameFileName(fname, i), s

  let framesCount = save(
    tl, stage, frameDuration,
    preview, justFirstFrame, keepUseless,
    saveCallback,
  )

  echo execProcess("magick.exe", options = {poUsePath}, args = [
   "-delay", $frameDuration.toMagickFrameDelay,
    dir/"*.svg", outputPath,
  ])

proc quickView*(
  tl: TimeLine, outputPath: string,
  stage: SVGStage, frameRate: FPS, scale = 1.0,
  preview = 0.ms .. 10_000.ms, repeat = 1,
  justFirstFrame = false, keepUseless = false,
) =
  ## TODO apply FRAME LIMIT :: 60 for quickview
  let frameDuration = 1000 / frameRate

  var acc = ""
  proc saveCallback(i: int, s: string) =
    acc &= wrapSVG(fmt"f-{i}", s)

  let framesCount = save(
    tl, stage, frameDuration,
    preview, justFirstFrame, keepUseless,
    saveCallback,
  )

  writeFile("./temp/out.html", fmt"""
    <html>
    <body>{acc}</body>
    <script>
      var 
        i = 0,
        len = {framesCount},
        frameHeight = {stage.canvas.height},
        frameDuration = {frameDuration}

      setInterval(() => {{
        window.scroll(0, frameHeight * i)
        i += 1

        if (i == len) i = 0
      }}, frameDuration)
    </script>
    </html>
  """)
