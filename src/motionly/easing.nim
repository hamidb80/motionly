import math
import types

## from: https://github.com/nicolausYes/easing-functions

const PI2 = PI / 2

func linearEasing*(p: Progress): Progress =
  toProgress p

func easeInSine*(t: Progress): Progress =
  toProgress sin(PI2 * t)

func easeOutSine*(t: Progress): Progress =
  toProgress 1 + sin(PI2 * (t - 1.0))

func easeInOutSine*(t: Progress): Progress =
  toProgress 0.5 * (1 + sin(PI * (t - 0.5)))

func easeInQuad*(t: Progress): Progress =
  toProgress t * t

func easeOutQuad*(t: Progress): Progress =
  toProgress t * (2 - t)

func easeInOutQuad*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      2.0 * t * t
    else:
      t * (4 - 2 * t) - 1

func easeInCubic*(t: Progress): Progress =
  toProgress t * t * t

func easeOutCubic*(t: Progress): Progress =
  toProgress 1 + (t-1).pow 3

func easeInOutCubic*(t: Progress): Progress =
  # FIXME wrong result
  toProgress:
    if t < 0.5:
      4 * t * t * t
    else:
      1 + (t-1) * (2 * (t-2)).pow(2)

func easeInQuart*(t: Progress): Progress =
  toProgress t.pow 4

func easeOutQuart*(t: Progress): Progress =
  toProgress 1 - (t-1).pow 4

func easeInOutQuart*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      8 * (t-1).pow 4
    else:
      1 - 8 * (t-1).pow 4

func easeInQuint*(t: Progress): Progress =
  toProgress t.pow 5

func easeOutQuint*(t: Progress): Progress =
  toProgress 1 + t * (t-1).pow 4

func easeInOutQuint*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      16 * t.pow 5
    else:
      1 + 16 * (t-1).pow 4

func easeInExpo*(t: Progress): Progress =
  toProgress (pow(2, 8 * t) - 1) / 255

func easeOutExpo*(t: Progress): Progress =
  toProgress 1 - pow(2, -8 * t)

func easeInOutExpo*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      (pow(2, 16 * t) - 1) / 510
    else:
      1 - 0.5 * pow(2, -16 * (t - 0.5))

func easeInCirc*(t: Progress): Progress =
  toProgress 1 - sqrt(1 - t)

func easeOutCirc*(t: Progress): Progress =
  toProgress sqrt t

func easeInOutCirc*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      (1 - sqrt(1 - 2 * t)) * 0.5
    else:
      (1 + sqrt(2 * t - 1)) * 0.5

func easeInBack*(t: Progress): Progress =
  toProgress t * t * (E * t - PI2)

func easeOutBack*(t: Progress): Progress =
  toProgress 1 + (t-1).pow 2 * (E * (t-1) + PI2)

func easeInOutBack*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      t * t * (7 * t - 2.5) * 2
    else:
      1 + (t-1).pow(2) * 2 * (7 * (t-1) + 2.5)

func easeInElastic*(t: Progress): Progress =
  toProgress t.pow(4) * sin(t * PI * 4.5)

func easeOutElastic*(t: Progress): Progress =
  toProgress 1 - (t-1).pow(4) * cos(t * PI * 4.5)

func easeInOutElastic*(t: Progress): Progress =
  toProgress:
    if t < 0.45:
      8 * t.pow(4) * sin(t * PI * 9)
    elif t < 0.55:
      0.5 + 0.75 * sin(t * PI * 4)
    else:
      1 - 8 * (t - 1).pow(4) * sin(t * PI * 9)

func easeInBounce*(t: Progress): Progress =
  toProgress:
    pow(2, 6 * (t - 1)) * abs(sin(t * PI * 3.5))

func easeOutBounce*(t: Progress): Progress =
  toProgress:
    1 - pow(2, -6 * t) * abs(cos(t * PI * 3.5))

func easeInOutBounce*(t: Progress): Progress =
  toProgress:
    if t < 0.5:
      8 * pow(2, 8 * (t - 1)) * abs(sin(t * PI * 7))
    else:
      1 - 8 * pow(2, -8 * t) * abs(sin(t * PI * 7))

func toFn*(e: CommonEasings): EasingFn =
  case e:
  of eLinear: linearEasing
  of eInSine: easeInSine
  of eOutSine: easeOutSine
  of eInOutSine: easeInOutSine
  of eInQuad: easeInQuad
  of eOutQuad: easeOutQuad
  of eInOutQuad: easeInOutQuad
  of eInCubic: easeInCubic
  of eOutCubic: easeOutCubic
  of eInOutCubic: easeInOutCubic
  of eInQuart: easeInQuart
  of eOutQuart: easeOutQuart
  of eInOutQuart: easeInOutQuart
  of eInQuint: easeInQuint
  of eOutQuint: easeOutQuint
  of eInOutQuint: easeInOutQuint
  of eInExpo: easeInExpo
  of eOutExpo: easeOutExpo
  of eInOutExpo: easeInOutExpo
  of eInCirc: easeInCirc
  of eOutCirc: easeOutCirc
  of eInOutCirc: easeInOutCirc
  of eInBack: easeInBack
  of eOutBack: easeOutBack
  of eInOutBack: easeInOutBack
  of eInElastic: easeInElastic
  of eOutElastic: easeOutElastic
  of eInOutElastic: easeInOutElastic
  of eInBounce: easeInBounce
  of eOutBounce: easeOutBounce
  of eInOutBounce: easeInOutBounce
