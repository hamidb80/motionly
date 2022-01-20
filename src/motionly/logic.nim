import std/[sequtils, tables, strutils, algorithm]
import types, utils

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
    cmp(k1.timeRange.a, k2.timeRange.a)

type
  CommonEasings* = enum
    ## see https://easings.net/
    eInSine, eOutSine, eInOutSine
    eInQuad, eOutQuad, eInOutQuad
    eInCubic, eOutCubic, eInOutCubic
    eInQuart, eOutQuart, eInOutQuart
    eInQuint, eOutQuint, eInOutQuint
    eInExpo, eOutExpo, eInOutExpo
    eInCirc, eOutCirc, eInOutCirc
    eInBack, eOutBack, eInOutBack
    eInElastic, eOutElastic, eInOutElastic
    eInBoune, eOutBoune, eInOutBounce

proc sinin(total, elapsed: int): Percent =
  discard

func applyTransition*(
  u: UpdateFn, len: int, e: EasingFn
): Transition =
  Transition(totalTime: len, easingFn: e, updateFn: u)

func tofn(e: CommonEasings): EasingFn =
  sinin

func `~>`*(
  u: UpdateFn, props: tuple[len: int, easing: CommonEasings]
): Transition =
  u.applyTransition(props.len, props.easing.tofn)

func toAnimation*(t: Transition, startTime: int): Animation =
  Animation(start: startTime, t: t)

template register*(t: Transition): untyped {.dirty.} =
  cntx.add t.toAnimation(dt.a)

proc save*(
  tl: TimeLine, outputPath: string, frameRate: int, size: Point,
  preview = (-1) .. (-1), repeat = 1
) =
  discard
