import std/[tables]
import motionly

# -------------------------------

type
  MyComponent = ref object of SVGShape
    s: seq[int]

proc initMyComponent(data: seq[int]): MyComponent =
  result = MyComponent(name: "my-component", s: data)
  result.attrs["d"] = $result.s

# --------------------------------------

defStage mystage(width = 200, height = 200), baseParserMap:
  g() as @here # my cool component gonna be replaced with @here at runtime

defTimeline timeline, mystage:
  before:
    @here <- initMyComponent(@[1, 2, 3]) # see ?

  at 0.ms:
    echo (MyComponent)(@here).s

timeline.saveGif("./temp/out.gif", mystage, 50.fps)
