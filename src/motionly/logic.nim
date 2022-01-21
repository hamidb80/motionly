import std/[sequtils, tables, strutils, algorithm]
import macros, macroplus
import types, utils, meta

proc parseIRImpl*(ir: IRNode, parent: SVGNode, parserMap: ParserMap): SVGNode =
  let nodes = ir.children.mapIt parseIRImpl(it, result, parserMap)

  if ir.tag in parserMap:
    result = parserMap[ir.tag](ir.tag, ir.attrs, nodes)
  else:
    raise newException(ValueError, "no such parser for tag name: " & ir.tag)

proc parseIR*(ir: IRNode, parserMap: ParserMap): SVGCanvas =
  let attrs = toTable ir.attrs
  assert attrs.containsAll ["width", "height"]

  result = SVGCanvas(
    name: "svg",
    width: attrs["width"].parseFloat,
    height: attrs["height"].parseFloat,
  )

  result.nodes = ir.children.mapit parseIRImpl(it, result, parserMap)

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

func linearEasing(p: Percent): Percent =
  p

func toFn(e: CommonEasings): EasingFn =
  case e:
  of eLinear: linearEasing
  else:
    raise newException(ValueError, "corresponding easing function is not defined yet: " & $e)

func applyTransition*(u: UpdateFn, len: MS, e: EasingFn): Transition =
  Transition(totalTime: len, easingFn: e, updateFn: u)

func `~>`*(
  u: UpdateFn, props: tuple[len: MS, easing: CommonEasings]
): Transition =
  u.applyTransition(props.len, props.easing.tofn)

func len*(rng: HSlice[float, float]): float=
  rng.b - rng.a

func toAnimation*(t: Transition): Animation =
  Animation(t: t)

template register*(t: Transition): untyped {.dirty.} =
  cntx.add t.toAnimation()

template r*(t: Transition): untyped {.dirty.} =
  register t

proc resolveFlowCall(flowCall: NimNode): NimNode =
  assert flowCall.kind == nnkCall
  flowCall.insertMulti(CallIdent + 1, "commonStage".ident, "cntx".ident)
  flowCall

macro `!`*(flowCall): untyped =
  ## for calling flows
  resolveFlowCall(flowCall)

func percentLimit(n: float): Percent =
  min(n, 100.0)

const fullTimeRange = 0.ms .. 100_000.ms
proc save*(
  tl: TimeLine, outputPath: string,
  stage: SVGStage, frameRate: FPS, size: Point,
  preview = fullTimeRange, repeat = 1
) =
  assert isSorted tl

  let frameDuration = 1000 / frameRate
  var
    currentTime = 0.0
    activeAnimations: Recording
    tli = 0

  while tli <= tl.high or activeAnimations.len != 0:
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
        let timeProgress = percentLimit:
          (currentTime - a.startTime) / a.t.totalTime * 100

        a.t.updateFn(a.t.easingFn(timeProgress))

        if timeProgress != 100.0:
          anims.add a

      activeAnimations = anims

    currentTime += frameDuration
