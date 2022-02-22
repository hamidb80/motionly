import std/[threadpool, tables, with, algorithm]
import motionly

type
  ActionKinds = enum
    akMoveCursor, akCopy, akAssign, akSetKey, akResetLoop

  Cursors = enum
    cI, cJ

  Action = object
    value: int

    case kind: ActionKinds
    of akMoveCursor:
      cursor: Cursors
      toIndex: int

    of akCopy:
      dest_i, source_i: int

    of akAssign:
      index: int

    of akSetKey, akResetLoop:
      discard


func genAnimationActions(s: seq[int]): seq[Action] =
  var A = s

  for j in 1 .. A.high:
    result.add [
      Action(kind: akResetLoop),
      Action(kind: akMoveCursor, cursor: cJ, toIndex: j)]

    let key = A[j]
    result.add Action(kind: akSetKey, value: key)

    var i = j - 1
    result.add Action(kind: akMoveCursor, cursor: cI, toIndex: i)

    while i >= 0 and A[i] > key:
      result.add Action(kind: akCopy, dest_i: i+1, source_i: i, value: A[i])
      A[i+1] = A[i]
      result.add Action(kind: akMoveCursor, cursor: cI, toIndex: i)
      dec i


    A[i+1] = key
    result.add Action(kind: akAssign, index: i+1, value: key)

# -------------------------------------------------

proc cursorParser(tag: string, attrs: Table[string, string],
  children: seq[SVGNode]): SVGNode =

  var newAttrs = attrs
  newAttrs["d"] = "M31.1447 0L0.73114 61.8758L31.0587 46.0587L61.5582 61.8758L31.1447 0Z"

  parseRaw[SVGPath]("path", newAttrs, children)


var customIRparser = baseParserMap
customIRparser["cursor"] = cursorParser

# -------------------------------------------------

const
  WIDTH = 1000
  HEIGHT = 600
  PADDING_LEFT = 100.0
  PADDING_TOP = 240.0
  BOX_SIZE = 100.0
  BOX_STROKE = 3.0
  FONT = FontConfig(family: "monospace", size: 60.px)
  TRANSITION = 300.ms
  TRANSITION_2 = 300.ms / 2
  PINK = "#C01050"
  PURPLE = "#8A3EC6"

  numberList = @[2, 7, 9, 4, 1, 3, 5, 2]


defStage mainStage(width = WIDTH, height = HEIGHT), customIRparser:
  rect(width = WIDTH, height = HEIGHT, fill = "#eee")

  group() as @title:
    embed readFile "./assets/insertion_sortT.svg"

  group() as @vars:
    text(content = "j", y = 400, x = 30, fill = PINK, font_family = FONT.family,
        font_size = FONT.size - 10)
    text(content = "i", y = 500, x = 30, fill = PURPLE,
        font_family = FONT.family, font_size = FONT.size - 10)

  group() as @key:
    embed readFile "./assets/keyT.svg"
    text(content = "~", x = 160, y = 50,
      font_family = FONT.family, font_size = FONT.size - 10) as @keyContent

  cursor(fill = PINK) as @cursorJ
  cursor(fill = PURPLE) as @cursorI

  group() as @list

  text(content = "@hamidb80", y = 580, x = 820, fill = "#898989",
        font_family = FONT.family, font_size = 30)

var cursorStates: array[Cursors, tuple[index: int, visible: bool]]

proc getCursor(c: Cursors): SVGNode =
  case c:
  of cI: mainStage.components.cursorI
  of cj: mainStage.components.cursorJ

defTimeline timeline, mainStage:
  flow initCursors():
    let tx = translateX(116.px)
    @cursorJ.transforms.add [tx, translateY(370.px), translateX(0.px)]
    @cursorI.transforms.add [tx, translateY(470.px), translateX(0.px)]

  flow initNumberBoxes():
    for i, n in numberList:
      let
        wrapper = newGroup()
        box = newRect()
        number = newText($n, FONT)

      number.transforms.add translate(34, 68)

      with box:
        name = "rect"
        width = BOX_SIZE
        height = BOX_SIZE

      box.styles["stroke-width"] = $BOX_STROKE
      box.styles["stroke"] = "black"
      box.attrs["fill"] = "white"

      wrapper.transforms.add translate(
        PADDING_LEFT + BOX_SIZE * i.toFloat,
        PADDING_TOP)

      wrapper.add [box, number]
      @list.add wrapper

  flow setCursorIndex(c: Cursors, newIndex: int,
      delay: MS, disableAnimation: bool):

    let
      cur = getCursor c
      dx = (newIndex - cursorStates[c].index).toFloat * BOX_SIZE
      pmove = p(dx, 0)

    register:
      if disableAnimation:
        cur.tmove(pmove) |> delay
      else:
        cur.tmove(pmove) ~> (TRANSITION, eOutCubic, delay)

    cursorStates[c].index = newIndex

  flow setElemContent(el: SVGNode, newVal: int, delay: MS):
    let
      pt = p(0, 100.px)
      changeNumber = toUpdateFn:
        el.nodes[0].content = $newVal

    register el.tmove(pt) ~> (TRANSITION_2, eInCirc, delay)
    register el.fadeOut() ~> (TRANSITION_2, eInCirc, delay)
    register changeNumber |> (delay + TRANSITION_2)
    register el.fadeIn() ~> (TRANSITION_2, eOutCirc, delay + TRANSITION_2)
    register el.tmove(-pt) ~> (TRANSITION_2, eOutCirc, delay + TRANSITION_2)

  flow setValue(index: int, value: int, delay: MS):
    !setElemContent(@list.nodes[index].nodes[1], value, delay)

  before:
    @key.transforms.add translate(113.px, 100.px)
    @title.transforms.add translate((WIDTH.toFloat - 384.0) / 2, 30.0)
    !initCursors()
    !initNumberBoxes()
    !setCursorIndex(cJ, 1, 0.0, true)

    let actions = genAnimationActions numberList

    for i, ac in actions:
      let delay = TRANSITION * i.toFloat

      case ac.kind:
      of akMoveCursor:
        !setCursorIndex(ac.cursor, ac.toIndex, delay - 100.ms, false)

      of akCopy:
        !setValue(ac.dest_i, ac.value, delay)

      of akAssign:
        !setValue(ac.index, ac.value, delay)

      of akSetKey:
        !setElemContent(@keyContent, ac.value, delay)

      of akResetLoop:
        discard

    register @keyContent.fadeOut() ~> (1000.ms, eLinear, actions.len.toFloat * TRANSITION)

# ----------------------------------------

when isMainModule:
  echo sorted numberList

  setMaxPoolSize 12
  timeline.quickView("./temp/out.html", mainStage, 60.fps)
  # timeline.quickView("./temp/out.html", mainStage, 60.fps, justFirstFrame = true)
  # timeline.saveGif("./temp/out.gif", mainStage, 50.fps)
