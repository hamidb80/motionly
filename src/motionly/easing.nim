import math
import types

## see real examples here: https://easings.net/
const
  c1 = 1.70158
  c2 = c1 * 1.525
  c3 = c1 + 1
  c4 = (2 * PI) / 3
  c5 = (2 * PI) / 4.5
  n1 = 7.5625
  d1 = 2.75

func eLinear*(p: Progress): float =
  toProgress p

func eInSine*(p: Progress): float =
  toProgress 1 - cos((p * PI) / 2)

func eOutSine*(p: Progress): float =
  toProgress sin((p * PI) / 2)

func eInOutSine*(p: Progress): float =
  toProgress -(cos(PI * p) - 1) / 2

func eInQuad*(p: Progress): float =
  toProgress p * p

func eOutQuad*(p: Progress): float =
  toProgress 1 - (1 - p).pow 2

func eInOutQuad*(p: Progress): float =
  toProgress:
    if p < 0.5:
      2 * p * p
    else:
      1 - pow(-2 * p + 2, 2) / 2

func eInCubic*(p: Progress): float =
  toProgress p.pow 3

func eOutCubic*(p: Progress): float =
  toProgress 1 - pow(1 - p, 3)

func eInOutCubic*(p: Progress): float =
  toProgress:
    if p < 0.5:
      4 * p.pow 3
    else:
      1 - pow(-2 * p + 2, 3) / 2

func eInQuart*(p: Progress): float =
  toProgress p.pow 4

func eOutQuart*(p: Progress): float =
  toProgress 1 - (p-1).pow 4

func eInOutQuart*(p: Progress): float =
  toProgress:
    if p < 0.5:
      8 * p.pow 4
    else:
      1 - pow(-2 * p + 2, 4) / 2

func eInQuint*(t: Progress): float =
  toProgress t.pow 5

func eOutQuint*(p: Progress): float =
  toProgress 1 - pow(1 - p, 5)

func eInOutQuint*(p: Progress): float =
  toProgress:
    if p < 0.5:
      16 * p.pow(5)
    else:
      1 - pow(-2 * p + 2, 5) / 2

func eInExpo*(p: Progress): float =
  toProgress:
    if p == 0:
      0.0
    else:
      pow(2, 10 * p - 10)

func eOutExpo*(p: Progress): float =
  toProgress:
    if p == 1:
      1.0
    else:
      1 - pow(2, -10 * p)

func eInOutExpo*(p: Progress): float =
  toProgress:
    if p == 0.0:
      0.0
    elif p == 1.0:
      1.0
    elif p < 0.5:
      pow(2, 20 * p - 10) / 2
    else:
      (2 - pow(2, -20 * p + 10)) / 2

func eInCirc*(p: Progress): float =
  toProgress 1 - sqrt(1 - pow(p, 2))

func eOutCirc*(p: Progress): float =
  toProgress sqrt(1 - pow(p - 1, 2))

func eInOutCirc*(p: Progress): float =
  toProgress:
    if p < 0.5:
      (1 - sqrt(1 - pow(2 * p, 2))) / 2
    else:
      (sqrt(1 - pow(-2 * p + 2, 2)) + 1) / 2

func eInBack*(x: Progress): float =
  c3 * x.pow(3) - c1 * x.pow(2)

func eOutBack*(x: Progress): float =
  1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2)

func eInOutBack*(x: Progress): float =
  if x < 0.5:
    (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
  else:
    (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2

func eInElastic*(x: Progress): float =
  if x == 0:
    0.0
  elif x == 1:
    1.0
  else:
    -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4)

func eOutElastic*(x: Progress): float =
  if x == 0:
    0.0
  elif x == 1:
    1.0
  else:
    pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1

func eInOutElastic*(x: Progress): float =
  if x == 0:
    0.0
  elif x == 1:
    1.0
  elif x < 0.5:
    -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
  else:
    (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1

func eOutBounce*(x: Progress): float =
  if x < 1 / d1:
    n1 * x.pow(2)
  elif x < 2 / d1:
    n1 * (x - 1.5) / d1 * (x - 1.5) + 0.75
  elif x < 2.5 / d1:
    n1 * (x - 2.25) / d1 * (x - 2.25) + 0.9375
  else:
    n1 * (x - 2.625) / d1 * (x - 2.625) + 0.984375

func eInBounce*(x: Progress): float =
  1 - eOutBounce(1 - x)

func eInOutBounce*(x: Progress): float =
  if x < 0.5:
    (1 - eOutBounce(1 - 2 * x)) / 2
  else:
    (1 + eOutBounce(2 * x - 1)) / 2
