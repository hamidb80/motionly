import tables

# TODO use `strtabs` instead of `tables

type
  Point* = object
    x*, y*: float

  SVGNode* = ref object of RootObj
    name*: string
    attrs*, styles*: Table[string, string]
    parent*: SVGNode
    nodes*: seq[SVGNode]

  SVGCanvas* = ref object of SVGNode # <svg> ... </svg>
    width*, height*: float

  SVGGroup* = ref object of SVGNode

  SVGRect* = ref object of SVGNode
    position*: Point
    width*, height*: float

  SVGCircle* = ref object of SVGNode
    center*: Point
    radius*: float

  SVGArc* = ref object of SVGNode

  # IR :: Intermediate representation
  IRNode* = object
    tag*: string
    attrs*: seq[(string, string)]
    children*: seq[IRNode]

  SVGStage* = ref object of RootObj
    canvas*: SVGCanvas

  IRParser* = proc(
    tag: string, attrs: seq[(string, string)], children: seq[SVGNode]
  ): SVGNode {.nimcall.}

  ParserMap* = Table[string, IRParser] # tag name => parser func

  ComponentMap* = Table[string, tuple[isseq: bool, count: int]]

  KeyFrame* = tuple[timeRange: HSlice[int, int], fn: proc() {.nimcall.}]
  TimeLine* = seq[KeyFrame]

  State* = ref object of RootObj
  Switch* = tuple[first, last: State]

  EasingFn* = proc(total, elapsed: int): Percent {.nimcall.}

  UpdateAgent* = object
    node*: SVGNode
    states*: Switch
    fn*: proc(n: SVGNode, states: Switch, progress: Percent
    ): SVGNode {.nimcall.}

  Transition* = object
    totalTime*: int
    easingFn*: EasingFn
    updateAgent*: UpdateAgent

  Animation* = object
    start*: int
    t*: Transition

  Percent* = range[0.0 .. 100.0]
  ms* = int
  px* = float
