import math
import types

## see real examples here: https://easings.net/

func elinear*(p: Progress): Progress =
  toProgress p

func eInSine*(p: Progress): Progress =
  toProgress 1 - cos((p * PI) / 2)

func eOutSine*(p: Progress): Progress =
  toProgress sin((p * PI) / 2)

func eInOutSine*(p: Progress): Progress =
  toProgress -(cos(PI * p) - 1) / 2

func eInQuad*(p: Progress): Progress =
  toProgress p * p

func eOutQuad*(p: Progress): Progress =
  toProgress 1 - (1 - p).pow 2

func eInOutQuad*(p: Progress): Progress =
  toProgress:
    if p < 0.5:
      2 * p * p
    else:
      1 - pow(-2 * p + 2, 2) / 2

func eInCubic*(p: Progress): Progress =
  toProgress p.pow 3

func eOutCubic*(p: Progress): Progress =
  toProgress 1 - pow(1 - p, 3)

func eInOutCubic*(p: Progress): Progress =
  toProgress:
    if p < 0.5:
      4 * p.pow 3
    else:
      1 - pow(-2 * p + 2, 3) / 2

func eInQuart*(p: Progress): Progress =
  toProgress p.pow 4

func eOutQuart*(p: Progress): Progress =
  toProgress 1 - (p-1).pow 4

func eInOutQuart*(p: Progress): Progress =
  toProgress:
    if p < 0.5:
      8 * p.pow 4
    else:
      1 - pow(-2 * p + 2, 4) / 2

func eInQuint*(t: Progress): Progress =
  toProgress t.pow 5

func eOutQuint*(p: Progress): Progress =
  toProgress 1 - pow(1 - p, 5)

func eInOutQuint*(p: Progress): Progress =
  toProgress:
    if p < 0.5:
      16 * p.pow(5)
    else:
      1 - pow(-2 * p + 2, 5) / 2

func eInExpo*(p: Progress): Progress =
  toProgress:
    if p == 0:
      0.0
    else:
      pow(2, 10 * p - 10)

func eOutExpo*(p: Progress): Progress =
  toProgress:
    if p == 1:
      1.0
    else:
      1 - pow(2, -10 * p)

func eInOutExpo*(p: Progress): Progress =
  toProgress:
    if p == 0.0:
      0.0
    elif p == 1.0:
      1.0
    elif p < 0.5:
      pow(2, 20 * p - 10) / 2
    else:
      (2 - pow(2, -20 * p + 10)) / 2

func eInCirc*(p: Progress): Progress =
  toProgress 1 - sqrt(1 - pow(p, 2))

func eOutCirc*(p: Progress): Progress =
  toProgress sqrt(1 - pow(p - 1, 2))

func eInOutCirc*(p: Progress): Progress =
  toProgress:
    if p < 0.5:
      (1 - sqrt(1 - pow(2 * p, 2))) / 2
    else:
      (sqrt(1 - pow(-2 * p + 2, 2)) + 1) / 2
