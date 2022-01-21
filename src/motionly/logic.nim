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

func sort*(tl: var TimeLine) =
  tl.sort proc (k1, k2: KeyFrame): int =
    cmp(k1.startTime, k2.startTime)

proc linearEasing(p: Percent): Percent =
  p

func toFn(e: CommonEasings): EasingFn =
  case e:
  of eLinear: linearEasing
  else:
    raise newException(ValueError, "corresponding easing function is not defined yet")

func applyTransition*(u: UpdateFn, len: int, e: EasingFn): Transition =
  Transition(totalTime: len, easingFn: e, updateFn: u)

func `~>`*(
  u: UpdateFn, props: tuple[len: int, easing: CommonEasings]
): Transition =
  u.applyTransition(props.len, props.easing.tofn)

func toAnimation*(t: Transition, startTime: int): Animation =
  Animation(start: startTime, t: t)

template register*(t: Transition): untyped {.dirty.} =
  cntx.add t.toAnimation(dt)

template r*(t: Transition): untyped {.dirty.} =
  register t

proc resolveFlowCall(flowCall: NimNode): NimNode =
  assert flowCall.kind == nnkCall
  flowCall.insertMulti(CallIdent + 1, "commonStage".ident, "cntx".ident)
  flowCall

macro `!`*(flowCall): untyped =
  ## for calling flows
  resolveFlowCall(flowCall)

const allFrames = (-1) .. (-1)
proc save*(
  tl: TimeLine, outputPath: string, frameRate: int, size: Point,
  preview = allFrames, repeat = 1
) =
  discard
