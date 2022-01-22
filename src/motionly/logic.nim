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

func toMagickFrameDelay(ms: MS): int =
  (ms / 10).ceil.toint.max(2)

func toAnimation*(t: Transition): Animation =
  Animation(t: t)

func genTransition*(u: UpdateFn, delay, len: MS, e: EasingFn): Transition =
  Transition(delay: delay, totalTime: len, easingFn: e, updateFn: u)

func genFrameFileName(fname: string, index: int): string =
  fmt"{fname}_{index:08}.svg"

func resolveTimeline*(kfs: seq[KeyFrameIR]): TimeLine =
  var lastTime = 0.ms
  for kf in kfs:
    let startTime = 
      if kf.isDependent:
        lastTime = kf.timeRange.b + lasttime
        lastTime
      else:
        lastTime = kf.timeRange.b
        kf.timeRange.a

    result.add (startTime, kf.fn)

proc saveGif*(
  tl: TimeLine, outputPath: string,
  stage: SVGStage, frameRate: FPS, scale = 1.0,
  preview = 0.ms .. 10_000.ms, justFirstFrame = false,
  keepUseless = false, repeat = 1,
) =
  ## note: the best fps for magick is 50.fps
  assert isSorted tl

  let
    (dir, fname, _) = splitFile(outputPath)
    frameDuration = 1000 / frameRate

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
            tl[tli].fn(stage, newAnimations)
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
          writeFile(dir / genFrameFileName(fname, savedCount), $stage.canvas)
          savedCount.inc

        if justFirstFrame:
          break loop

      currentTime += frameDuration

  echo execProcess("magick.exe", options = {poUsePath}, args = [
   "-delay", $frameDuration.toMagickFrameDelay,
    fmt"{dir}/*.svg", outputPath,
  ])
