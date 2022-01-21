import std/[os, osproc, strformat, tables, algorithm, math]
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

func linearEasing(p: Progress): Progress =
  p

func toMagickFrameDelay(ms: MS): int =
  (ms / 10).ceil.toint.max(2)

func toFn*(e: CommonEasings): EasingFn =
  case e:
  of eLinear: linearEasing
  else:
    raise newException(ValueError, "corresponding easing function is not defined yet: " & $e)

func len*(rng: HSlice[float, float]): float =
  rng.b - rng.a

func toAnimation*(t: Transition): Animation =
  Animation(t: t)

func applyTransition*(u: UpdateFn, len: MS, e: EasingFn): Transition =
  Transition(totalTime: len, easingFn: e, updateFn: u)

func applyTransition*(u: UpdateFn, len: MS, e: CommonEasings): Transition =
  Transition(totalTime: len, easingFn: e.tofn, updateFn: u)

func progressLimit(n: float): Progress =
  min(n, 1.0)

func genFrameFileName(fname: string, index: int): string =
  fmt"{fname}_{index:08}.svg"

proc save*(
  tl: TimeLine, outputPath: string,
  stage: SVGStage, frameRate: FPS, scale = 1.0,
  preview = 0.ms .. 10_000.ms, repeat = 1, justFirstFrame = false
) =
  assert isSorted tl

  let
    (dir, fname, _) = splitFile(outputPath)
    frameDuration = 1000 / frameRate

  var
    currentTime = 0.0
    activeAnimations: Recording
    tli = 0
    savedCount = 0

  block loop:
    while (tli <= tl.high or activeAnimations.len != 0) and currentTime <= preview.b:
      block collectNewAnimations:
        var newAnimations: Recording

        while tli <= tl.high:
          if currentTime >= tl[tli].startTime:
            tl[tli].fn(stage, newAnimations)
            tli.inc
          else: break

        for a in newAnimations.mitems:
          a.startTime = currentTime

        activeAnimations.add newAnimations

      block applyAndFilterAnimations:
        var anims: Recording
        for a in activeAnimations:
          let timeProgress = progressLimit:
            (currentTime - a.startTime) / a.t.totalTime

          a.t.updateFn(a.t.easingFn(timeProgress))

          if timeProgress != 100.0:
            anims.add a

        activeAnimations = anims

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
