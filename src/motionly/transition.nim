import types, shapes

proc tmove*(s: SVGNode, states: HSlice[Point, Point]): UpdateFn =
  let v = states.b - states.a

  proc updater(ap: float, tp: Progress) =
    s.pos = states.a + (v * ap)

  updater

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