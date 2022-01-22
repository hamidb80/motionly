import std/[sequtils, strformat, tables, macros]
import macroplus
import motionly/[meta, types, ir, logic, easing, transition, shapes]

export ir, types, logic, easing, transition, shapes

func ast2IR(n: NimNode, storageid: var ComponentMap): NimNode =
  assert n.kind in {nnkCall, nnkInfix, nnkCommand}, $n.kind
  let
    hasId = n.kind == nnkInfix
    isComponent = n.kind in {nnkCall, nnkInfix}
  var
    targetNode = n
    id = ""

  if hasId:
    assert n[InfixIdent].strVal == "as"
    let isseq = n[InfixRightSide].kind == nnkBracketExpr

    id = strVal:
      if isseq: n[InfixRightSide][0][1]
      else: n[InfixRightSide][1]

    if (not isseq) or (id notin storageid):
      storageid[id] = (isseq, 1)
    else:
      storageid[id].count.inc

    targetNode = n[InfixLeftSide]

    if n.len == 4: # for named wrapper body
      targetNode.add n[3]

  let tag = targetNode[CallIdent].strVal
  var
    attrs = newNimNode(nnkBracket)
    children = newNimNode(nnkBracket)

  if hasId:
    attrs.add toTupleNode(
      newStrLitNode("id"),
      if storageid[id].isseq:
        (fmt"{id}_{storageid[id].count-1}").newStrLitNode
      else:
        id.newStrLitNode
    )

  if isComponent:
    for arg in targetNode[CallArgs]:
      case arg.kind:
      of nnkExprEqExpr: # args
        attrs.add toTupleNode(arg[0].strval.newStrLitNode, arg[1].toStringNode)

      of nnkStmtList: # body
        children = toBrackets arg.toseq.mapIt ast2IR(it, storageid)

      else:
        error "invalid arg type: " & $arg.kind

    quote:
      `IRNode`(
        tag: `tag`,
        attrs: @`attrs`,
        children: @`children`
      )

  else:
    assert targetNode[CommandIdent].strval == "embed"
    let code = targetNode[CommandBody]
    quote:
      `toIR`(`code`)

proc toSVGTree(stageConfig, parserMap, code: NimNode): NimNode =
  assert stageConfig.kind == nnkcall

  var idStore: ComponentMap
  let
    varname = stageConfig[CallIdent]
    args = toBrackets stageConfig[CallArgs].mapIt toTupleNode(
      it[0].strval.newStrLitNode,
      it[1].toStringNode
    )

    children = toBrackets code.toseq.mapIt ast2IR(it, idStore)

    # id = $rand(1 .. 9999) # FIXME
    id = "22"
    cntx = ident "CustomComponents_" & id
    cntxWrapper = ident "CustomSVGStage_" & id
    stageIdent = ident("IR_" & id)

    objDef = newObjectType(cntx.exported, idStore.pairs.toseq.mapIt do: (
      it[0].ident.exported,
      if it[1].isSeq:
        newTree(nnkBracketExpr, ident"seq", quote do: `SVGNode`)
      else:
        quote do: `SVGNode`
    ))

    idGets = toStmtList idStore.pairs.toseq.mapit do:
      let
        fname = it[0]
        field = fname.ident

      if it[1].isseq:
        var res = newTree(nnkBracket)
        for i in 0 ..< it[1].count:
          let iname = fmt"{fname}_{i}"
          res.add quote do:
            findId(`varname`.canvas, `iname`)

        quote:
          `varname`.components.`field` = @`res`

      else:
        quote:
          `varname`.components.`field` = findId(`varname`.canvas, `fname`)

  result = quote:
    `objDef`

    type
      `cntxWrapper`* = ref object of `SVGStage`
        components*: `cntx`

    var `stageIdent` = `IRNode`(
      tag: "svg",
      attrs: @`args`,
      children: @`children`
    )

    var `varname` = `cntxWrapper`()
    `varname`.canvas = (SVGCanvas)`parseIR`(`stageIdent`, nil, `parserMap`)
    `idGets`

  # debugecho "++++++++++++++"
  # debugEcho repr result

macro defStage*(stageConfig: untyped, parserMap: typed, body): untyped =
  return toSVGTree(stageConfig, parserMap, body)

# ----------------------------------------------------------

func replaceStageComponents*(body: NimNode): NimNode =
  result = body

  for i, n in body.pairs:
    if n.kind == nnkPrefix and n[0].strval == "@" and n[1].kind == nnkIdent:
      let componentName = n[1]
      result[i] = quote:
        stage.components.`componentName`

    else:
      result[i] = replaceStageComponents(n)

func defTimelineImpl(timelineVar, stageVar, body: NimNode): NimNode =
  var
    timelineIR: seq[tuple[timeRange, isDependent, fn: NimNode]]
    procDefs = newStmtList()

  for i, entity in body:
    template add2Timeline(
      timeRange: untyped, isDependent: bool = false
    ): untyped {.dirty.} =
      assert entity.len in [2, 3]
      let
        stgName = ident fmt"timeRange_{i}"
        sident = ident "stage"
        dti = ident "dt"
        defs = quote do:
          let
            `sident` {.used.} = (typeof `stageVar`)(commonStage)
            `dti` {.used.} = len(`timeRange`)

      procDefs.add newProc(
        stgName,
        genFormalParams(newEmptyNode(), [
          newIdentDefs("commonStage".ident, "SVGStage".ident),
          newIdentDefs("cntx".ident, newTree(nnkVarTy, "Recording".ident)),
          newIdentDefs("currentTime".ident, "float".ident),
        ]).toseq,
        newStmtList(defs, resolvedBody))

      timelineIR.add (timeRange, ident($isDependent), stgName)

    case entity.kind:
    of nnkCommand, nnkCall:
      let
        name = entity[CommandIdent].strVal
        resolvedBody = replaceStageComponents(entity[CommandBody])

      case name:
      of "before":
        let timeRange = quote: 0.ms .. 0.ms
        add2Timeline timeRange

      of "flow":
        let
          flowName = entity[1][ObjConstrIdent]
          args = entity[1][ObjConstrFields].mapIt newIdentDefs(it[0], it[1])
          sident = ident "stage"
          defs = quote do:
            let `sident` {.used.} = (typeof `stageVar`)(commonStage)

          params = genFormalParams(newEmptyNode(), @[
            newIdentDefs("commonStage".ident, "SVGStage".ident),
            newIdentDefs("cntx".ident, newTree(nnkVarTy, "Recording".ident))
          ] & args).toseq

        procDefs.add newProc(flowName, params, newStmtList(defs, resolvedBody))

      of "on":
        add2Timeline entity[1]

      of "at":
        add2Timeline infix(entity[1], "..", entity[1])

      of "after":
        add2Timeline infix(entity[1], "..", entity[1]), true

      of "frame":
        add2Timeline infix(newFloatLitNode(0), "..", entity[1]), true

      else:
        error "invalid entity name: " & name

    else:
      error "not valid entity kind: " & $entity.kind

  let tb = toBrackets timelineIR.mapIt toTupleNode(it[0], it[1], it[2])

  result = quote:
    `procDefs`
    var `timelineVar`: `TimeLine` = resolveTimeline @`tb`
    `timelineVar`.sort ## sort before usage

  # debugEcho "=============="
  # debugEcho repr result
  # debugEcho "////////////////"

macro defTimeline*(timelineVar: untyped, stageVar: typed, body): untyped =
  defTimelineImpl(timelineVar, stageVar, body)

# ---------------------------------------------------------

func `~>`*(
  u: UpdateFn, props: tuple[len: MS, easing: EasingFn]
): Transition =
  u.genTransition(0, props.len, props.easing)

func `~>`*(
  u: UpdateFn, props: tuple[len: MS, easing: EasingFn, delay: MS]
): Transition =
  u.genTransition(props.delay, props.len, props.easing)


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
