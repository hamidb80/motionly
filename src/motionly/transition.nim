import types, shapes

#TODO add a animation option type for tweaking soething like
# reset state after animation, end functions or ....

type
  TransitionOptions* = object
    finishHook: proc()
    removeEffects: bool

    # TODO set of enum is a better idea

const
  noOption* = TransitionOptions()

template addIfNotNil(s: SVGNode, trWrapper, existing, newTr: untyped): untyped =
  let trWrapper =
    if existing != nil:
      existing

    else:
      let acc = newTr
      s.transforms.add acc
      acc

proc tmove*(s: SVGNode, vec: Point,
  existing: Transform = nil, ops = noOption
): UpdateFn =

  addIfNotNil s, t, existing, translate(0, 0)

  proc update(ap: float, tp: Progress) =
    let pv = vec * ap
    t.tx = pv.x
    t.ty = pv.y

  update

proc topacity*(
  s: SVGNode, states: HSlice[float, float], ops = noOption
): UpdateFn =
  let d = states.len

  proc update(ap: float, tp: Progress) =
    s.opacity = states.a + d * ap

  update

proc fadeOut*(s: SVGNode): UpdateFn =
  topacity(s, 1.0 .. 0.0)

proc fadeIn*(s: SVGNode): UpdateFn =
  topacity(s, 0.0 .. 1.0)

proc tscale*(s: SVGNode, states: HSlice[float, float],
    existing: Transform = nil, ops = noOption
): UpdateFn =

  let ds = states.len
  addIfNotNil s, t, existing, scale(1, 1)

  proc update(ap: float, tp: Progress) =
    let sc = states.a + ap * ds
    t.sx = sc
    t.sy = sc

  update

proc trotate*(
  s: SVGNode, r: HSlice[float, float], existing: Transform = nil, ops = noOption
): UpdateFn =

  addIfNotNil s, t, existing, rotation(r.a)
  let dr = len r

  proc update(ap: float, tp: Progress) =
    t.deg = r.a + dr * ap

  update
