import types, shapes

#TODO add a animation option type for tweaking soething like
# reset state after animation, end functions or ....

proc tmove*(s: SVGNode, vec: Point): UpdateFn =
  let t = translate(0, 0)
  s.transforms.add t

  proc updater(ap: float, tp: Progress) =
    let pv = vec * ap
    t.tx = pv.x
    t.ty = pv.y

  updater

proc topacity*(s: SVGNode, states: HSlice[float, float]): UpdateFn =
  let d = states.len

  proc updater(ap: float, tp: Progress) =
    s.opacity = states.a + d * ap

  updater

proc fadeOut*(s: SVGNode): UpdateFn =
  topacity(s, 1.0 .. 0.0)

proc fadeIn*(s: SVGNode): UpdateFn =
  topacity(s, 0.0 .. 1.0)

proc tscale*(s: SVGNode, states: HSlice[float, float]): UpdateFn =
  let 
    t = scale(states.a)
    ds = states.len

  s.transforms.add t

  proc updater(ap: float, tp: Progress) =
    let sc = states.a + ap * ds
    t.sx = sc
    t.sy = sc

  updater

proc trotate*(s: SVGNode, r: float): UpdateFn =
  let t = rotation(0)
  s.transforms.add t

  proc updater(ap: float, tp: Progress) =
    t.deg = r * ap

  updater
