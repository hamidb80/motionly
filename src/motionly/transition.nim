import types, shapes

proc move*(st: SVGNode, states: HSlice[Point, Point]): UpdateFn =
  let v = states.b - states.a
  
  proc updater(p: Progress) = 
    st.pos = v * p
  
  updater
