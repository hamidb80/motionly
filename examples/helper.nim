import motionly/types

func p*(x, y: int): Point =
  Point(x: x.toFloat, y: y.toFloat)

func `+`*(p1, p2: Point): Point =
  Point(x: p1.x + p2.x, y: p1.y + p2.y)

func `-`*(p: Point): Point =
  Point(x: -p.x, y: -p.y)

func `-`*(p1, p2: Point): Point =
  p1 + -p2

func `*`*(p: Point, n: float): Point =
  Point(x: p.x * n, y: p.y * n)
