import tables

# TODO use `strtabs` instead of `tables

type
  ## IR :: Intermediate representation | a bridge between compile time and runtime
  IRNode* = object
    tag*: string
    attrs*: seq[(string, string)]
    children*: seq[IRNode]

  IRParser* = proc(
    tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
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
    width*, height*: float

  SVGStage* = ref object of RootObj
    canvas*: SVGCanvas

  SVGGroup* = ref object of SVGNode

  SVGRect* = ref object of SVGNode
    position*: Point
    width*, height*: float

  SVGCircle* = ref object of SVGNode
    center*: Point
    radius*: float

  SVGArc* = ref object of SVGNode

  EasingFn* = proc(timeProgress: Percent): Percent {.nimcall.}
  UpdateFn* = proc(animationProgress: Percent) {.closure.}

  Transition* = object
    totalTime*: int
    easingFn*: EasingFn
    updateFn*: UpdateFn

  Animation* = object
    startTime*: float
    t*: Transition

  Recording* = seq[Animation]

  KeyFrame* = tuple
    startTime: int
    fn: proc(commonStage: SVGStage, cntx: var Recording) {.nimcall.}

  TimeLine* = seq[KeyFrame]

  CommonEasings* = enum
    ## see https://easings.net/
    eLinear
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

  Percent* = range[0.0 .. 100.0]
  MS* = int
  PX* = float
  FPS* = float

func ms*(i: int): MS = i
func px*(i: int): PX = i.toFloat
func fps*(i: int): FPS = i.toFloat

