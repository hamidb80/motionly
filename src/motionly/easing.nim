import math
import types

## see real examples here: https://easings.net/
## code converted from: https://github.com/nicolausYes/easing-functions

const PI2 = PI / 2

func elinear*(p: Progress): Progress =
  toProgress p

func eInSine*(t: Progress): Progress =
  toProgress sin(PI2 * t)

func eOutSine*(t: Progress): Progress =
  toProgress 1 + sin(PI2 * (t - 1.0))

func eInOutSine*(t: Progress): Progress =
  toProgress 0.5 * (1 + sin(PI * (t - 0.5)))

func eInQuad*(t: Progress): Progress =
  toProgress t * t

func eOutQuad*(t: Progress): Progress =
  toProgress t * (2 - t)

func eInOutQuad*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      2.0 * t * t
    else:
      t * (4 - 2 * t) - 1

func eInCubic*(t: Progress): Progress =
  toProgress t * t * t

func eOutCubic*(t: Progress): Progress =
  toProgress 1 + (t-1).pow 3

func eInOutCubic*(t: Progress): Progress =
  # FIXME wrong result
  toProgress:
    if t < 0.5:
      4 * t * t * t
    else:
      1 + (t-1) * (2 * (t-2)).pow(2)

func eInQuart*(t: Progress): Progress =
  toProgress t.pow 4

func eOutQuart*(t: Progress): Progress =
  toProgress 1 - (t-1).pow 4

func eInOutQuart*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      8 * (t-1).pow 4
    else:
      1 - 8 * (t-1).pow 4

func eInQuint*(t: Progress): Progress =
  toProgress t.pow 5

func eOutQuint*(t: Progress): Progress =
  toProgress 1 + t * (t-1).pow 4

func eInOutQuint*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      16 * t.pow 5
    else:
      1 + 16 * (t-1).pow 4

func eInExpo*(t: Progress): Progress =
  toProgress (pow(2, 8 * t) - 1) / 255

func eOutExpo*(t: Progress): Progress =
  toProgress 1 - pow(2, -8 * t)

func eInOutExpo*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      (pow(2, 16 * t) - 1) / 510
    else:
      1 - 0.5 * pow(2, -16 * (t - 0.5))

func eInCirc*(t: Progress): Progress =
  toProgress 1 - sqrt(1 - t)

func eOutCirc*(t: Progress): Progress =
  toProgress sqrt t

func eInOutCirc*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      (1 - sqrt(1 - 2 * t)) * 0.5
    else:
      (1 + sqrt(2 * t - 1)) * 0.5

func eInBack*(t: Progress): Progress =
  toProgress t * t * (E * t - PI2)

func eOutBack*(t: Progress): Progress =
  toProgress 1 + (t-1).pow 2 * (E * (t-1) + PI2)

func eInOutBack*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      t * t * (7 * t - 2.5) * 2
    else:
      1 + (t-1).pow(2) * 2 * (7 * (t-1) + 2.5)

func eInElastic*(t: Progress): Progress =
  toProgress t.pow(4) * sin(t * PI * 4.5)

func eOutElastic*(t: Progress): Progress =
  toProgress 1 - (t-1).pow(4) * cos(t * PI * 4.5)

func eInOutElastic*(t: Progress): Progress =
  toProgress:
    if t < 0.45:
      8 * t.pow(4) * sin(t * PI * 9)
    elif t < 0.55:
      0.5 + 0.75 * sin(t * PI * 4)
    else:
      1 - 8 * (t - 1).pow(4) * sin(t * PI * 9)

func eInBounce*(t: Progress): Progress =
  toProgress:
    pow(2, 6 * (t - 1)) * abs(sin(t * PI * 3.5))

func eOutBounce*(t: Progress): Progress =
  toProgress:
    1 - pow(2, -6 * t) * abs(cos(t * PI * 3.5))

func eInOutBounce*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      8 * pow(2, 8 * (t - 1)) * abs(sin(t * PI * 7))
    else:
      1 - 8 * pow(2, -8 * t) * abs(sin(t * PI * 7))
