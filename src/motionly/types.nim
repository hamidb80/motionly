import tables

# TODO use strtabs

type
  ## IR :: Intermediate representation | a bridge between compile time and runtime
  IRNode* = object
    tag*: string
    attrs*: seq[(string, string)]
    children*: seq[IRNode]

  IRParser* = proc(
    tag: string, attrs: Table[string, string], children: seq[SVGNode]
  ): SVGNode {.nimcall.}

  ParserMap* = Table[string, IRParser] # tag name => parser func
  ComponentMap* = Table[string, tuple[isseq: bool, count: int]]

  Point* = object
    x*, y*: float

  SVGNode* = ref object of RootObj
    name*: string
    attrs*, styles*: Table[string, string]
    parent*: SVGNode
    nodes*: seq[SVGNode]

  SVGCanvas* = ref object of SVGNode # <svg> ... </svg>
    width*, height*: int

  SVGStage* = ref object of RootObj
    canvas*: SVGCanvas

  Progress* = range[0.0 .. 1.0]
  MS* = float

  EasingFn* = proc(timeProgress: Progress): float {.nimcall.}
  UpdateFn* = proc(animationProgress: Progress) {.closure.}

  Transition* = object
    totalTime*: MS
    easingFn*: EasingFn
    updateFn*: UpdateFn

  Animation* = object
    startTime*: float
    t*: Transition

  Recording* = seq[Animation]

  KeyFrame* = tuple
    startTime: MS
    fn: proc(commonStage: SVGStage, cntx: var Recording) {.nimcall.}

  TimeLine* = seq[KeyFrame]

  PX* = float
  FPS* = float

func ms*(i: int): MS = i.toFloat
func ms*(f: float): MS = f

func px*(i: int): PX = i.toFloat
func px*(f: float): PX = f

func fps*(i: int): FPS = i.toFloat
func fps*(f: float): FPS = f

func toProgress*(n: float): Progress =
  if n > 1.0: 1.0
  elif n < 0.0: 0.0
  else: n

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
