import std/[sequtils, strutils, strformat, tables, macros]
import motionly/[utils]

type
  Point* = object
    x, y: float

  SVGAbstractElemKind = enum
    seWrapper, seShape

  SVGNode* = ref object of RootObj
    kind*: SVGAbstractElemKind
    otherAttrs*, styles*: Table[string, string]
    parent*: SVGNode
    nodes*: seq[SVGNode]

  SVGRect* = ref object of SVGNode
    position*: Point
    width*, height*: float

  SVGCircle* = ref object of SVGNode
    center*: Point
    radius*: float

    # stGroup, stDef
    # of stText:
    # of stLine:
    # of stPath:
    # of stTextPath:
    # if stPolygon, stPolyline

func genXmlElem(tag: string,
    attrs: Table[string, string],
    body: string = ""
): string =
  let ats = attrs.pairs.toseq.mapIt(fmt "{it[0]}=\"{it[1]}\"").join " "
  fmt"<{tag} {ats}>{body}</{tag}>"

method getPrivateAttrs(n: SVGNode): Table[string, string] {.base.} =
  raise newException(ValueError, "trying to stringify empty SVGnode?")

method getPrivateAttrs(n: SVGCircle): Table[string, string] =
  {"cx": $n.center.x, "cy": $n.center.y, "r": $n.radius}.toTable

method getPrivateAttrs(n: SVGRect): Table[string, string] =
  {
    "x": $n.position.x, "y": $n.position.y,
    "width": $n.width, "height": $n.height
  }.toTable

func `$`(n: SVGNode): string =
  let tag =
    if n of SVGRect: "rect"
    elif n of SVGCircle: "circle"
    else: "??"

  genXmlElem(tag, merge(getPrivateAttrs(n), n.otherAttrs), "")

echo SVGCircle(kind: seShape, center: Point(x: 0.0, y: 1.1), radius: 3.0)

func toSVGTree(code: NimNode): SVGNode =
  discard

when false:
  genSVGTree stage:
    rect(fill = "#fff", _) as @box # assign svg component to box variable
    circ(fill = "#fff", _) as @blocks[0] # as array
    line(_) # you don't need to store all components inside a variable

    group: # yes we have groups | we have everything in SVG
      arc(_)

    myComponent("arg1", _, injected_here) as @table: # yay, custom component
      # your custom component can have slots like vue-js
      # the slot injected as its last argument when parsed to svgTree
      circ(_) as @targer

    embed """ # you can throw raw SVG by the way
      <rect _/>
    """
    embed readfile "./assets/car.svg" # or embed external svg?

when false:
  var mySpecialComponenetThatIForgot = stage.query(".class #id")

  # kf: key frame
  # type Progress = range[0.0 .. 100.0]
  func mySuperCoolAnimation(
    st: SvgTree, kfstart, kfend: SomeType, p: Progress = 0.0
  ): SvgTree =
    discard


  let
    recording = show(stage):
      before:
        discard                             # do anything before starting animation
                                            # flows can have args
      flow reset:                           # a named flow
        stage.remove @blocks[1]

      stage 0.ms .. 100.ms:
        # @box is a syntax suger for stage.components.box
        let k = move(@box, (10.px, 100.px)) # define a keyframe

        # register a transition
        k.transition(delay = 10.ms, duration = dt, easing = eCubicIn, after = reset)

      at 130.ms:
        reset()

      stage 150.ms .. 200.ms:
        scale(@blocks[0], 1.1).transition(dt, eCricleOut)

      stage 170.ms .. 210.ms: # yes, stages can have innersects in timing
                                # custom operator is cool
        mySuperCoolAnimation(@car, whereIs @car, (0, 0)) ~> (dt, eCubicIn)

  recording.save("out.gif", 120.fps, size = (1000.px, 400.px), scale = 5.0,
      preview = 0.ms .. 1000.ms, repeat = 1)

