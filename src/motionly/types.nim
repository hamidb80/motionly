import std/[tables, options, strformat, strutils]

# TODO use strtabs

type
  MajorSVGKinds* = enum
    mjELem, mjText

  ## IR :: Intermediate representation | a bridge between compile time and runtime
  IRNode* = object
    tag*: string
    attrs*: seq[(string, string)]
    children*: seq[IRNode]
    content*: string

  IRParser* = proc(tag: string, attrs: Table[string, string],
    children: seq[SVGNode]): SVGNode {.nimcall.}

  ParserMap* = Table[string, IRParser] # tag name => parser func
  ComponentMap* = Table[string, tuple[isseq: bool, count: int]]

  Point* = object
    x*, y*: float

  TransformFns* = enum
    tfTranslate, tfRotate, tfScale, tfSkew, tfMatrix

  Transform* = ref object
    case kind*: TransformFns
    of tfTranslate:
      tx*, ty*: float

    of tfRotate:
      deg*: float
      center*: Option[Point]

    of tfScale:
      sx*, sy*: float

    of tfSkew:
      kx*, ky*: float

    of tfMatrix:
      args*: array[6, float]

  SVGNode* = ref object of RootObj
    parent*: SVGNode

    case kind*: MajorSVGKinds
    of mjELem:
      name*: string
      attrs*, styles*: Table[string, string]
      nodes*: seq[SVGNode]
      transforms*: seq[Transform]

    of mjText:
      content*: string

  SVGCanvas* = ref object of SVGNode # <svg> ... </svg>
    width*, height*: int

  SVGStage* = ref object of RootObj
    canvas*: SVGCanvas

  Progress* = range[0.0 .. 1.0]
  MS* = float

  EasingFn* = proc(timeProgress: Progress): float {.nimcall.}
  # in some easing functions, the animation progress violates the Progress range
  UpdateFn* = proc(animationProgress: float, timeProgress: Progress) {.closure.}

  Transition* = object
    delay*: MS
    totalTime*: MS
    easingFn*: EasingFn
    updateFn*: UpdateFn

  Animation* = object
    startTime*: float
    t*: Transition

  Recording* = seq[Animation]

  # ActionFn* = proc(commonStage: SVGStage, cntx: ptr Recording,
  ActionFn* = proc(commonStage: SVGStage, cntx: var Recording,
      currentTime: MS) {.nimcall.}

  KeyFrameIR* = tuple
    timeRange: HSlice[MS, MS]
    isDependent: bool # whether is dependent on prevous keyframe or not
    fn: ActionFn

  KeyFrame* = tuple
    startTime: MS
    fn: ActionFn

  TimeLine* = seq[KeyFrame]

  PX* = float
  FPS* = float
  DEG* = float

func len*(rng: HSlice[float, float]): float =
  rng.b - rng.a

func ms*(i: int): MS = i.toFloat
func ms*(f: float): MS = f

func px*(i: int): PX = i.toFloat
func px*(f: float): PX = f

func deg*(i: int): DEG = i.toFloat
func deg*(f: float): DEG = f

func fps*(i: int): FPS = i.toFloat
func fps*(f: float): FPS = f

func toProgress*(n: float): Progress =
  if n > 1.0: 1.0
  elif n < 0.0: 0.0
  else: n

func ended*(p: Progress): bool =
  p == Progress.high


func p*(x, y: int): Point =
  Point(x: x.toFloat, y: y.toFloat)

func p*(x, y: float): Point =
  Point(x: x, y: y)

func `+`*(p1, p2: Point): Point =
  Point(x: p1.x + p2.x, y: p1.y + p2.y)

func `-`*(p: Point): Point =
  Point(x: -p.x, y: -p.y)

func `-`*(p1, p2: Point): Point =
  p1 + -p2

func `*`*(p: Point, n: float): Point =
  Point(x: p.x * n, y: p.y * n)

func `/`*(p: Point, n: float): Point =
  p * (1/n)

func rotation*(r: float): Transform =
  Transform(kind: tfRotate, deg: r)

func rotation*(r: float, center: Point): Transform =
  Transform(kind: tfRotate, deg: r, center: some center)

func scale*(s: float): Transform =
  Transform(kind: tfScale, sx: s, sy: s)

func scale*(sx, sy: float): Transform =
  Transform(kind: tfScale, sx: sx, sy: sy)

func translate*(tx, ty: float): Transform =
  Transform(kind: tfTranslate, tx: tx, ty: ty)

func translate*(p: Point): Transform =
  translate(p.x, p.y)

func translateX*(tx: float): Transform =
  translate(tx, 0)

func translateY*(ty: float): Transform =
  translate(0, ty)

func skewX*(deg: float): Transform =
  Transform(kind: tfSkew, kx: deg)

func skewY*(deg: float): Transform =
  Transform(kind: tfSkew, ky: deg)

func tmatrix*(a, b, c, d, e, f: float): Transform =
  Transform(kind: tfMatrix, args: [a, b, c, d, e, f])

func `$`*(tr: Transform): string =
  case tr.kind:
  of tfTranslate: fmt"translate({tr.tx}, {tr.ty})"

  of tfRotate:
    if isSome tr.center:
      fmt"rotate({tr.deg}, {tr.center.get.x}, {tr.center.get.y})"
    else:
      fmt"rotate({tr.deg})"

  of tfScale: fmt"scale({tr.sx}, {tr.sy})"

  of tfSkew:
    if tr.kx != 0: fmt"skewX({tr.kx})"
    else: fmt"skewY({tr.ky})"

  of tfMatrix: "matrix(" & tr.args.join(",") & ")"
