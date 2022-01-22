import types, shapes

proc move*(st: SVGNode, states: HSlice[Point, Point]): UpdateFn =
  let v = states.b - states.a

  proc updater(ap: float, tp: Progress) =
    st.pos = states.a + (v * ap)

  updater

proc tmove*(st: SVGNode, vec: Point): UpdateFn =
  let t = translate(0, 0)
  st.transforms.add t

  proc updater(ap: float, tp: Progress) =
    let pv = vec * ap
    t.tx = pv.x
    t.ty = pv.y

  updater
