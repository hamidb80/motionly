# motionly
~~a logic less animation software for everyone~~

here, you code animations!

**see these for inspiration:**
1. http://thesecretlivesofdata.com/raft/
2. https://github.com/EriKWDev/nanim
3. https://github.com/bluenote10/NimSvg
4. https://github.com/jiro4989/svgo

example: 
```nim

import algorithm, sequtils, ...


genSVGTree stage:
  rect(fill= "#fff", ...) as @box # assign svg component to box variable
  circ(fill= "#fff", ...) as @blocks[0] # as array
  line(...) # you don't need to store all components inside a variable

  group: # yes we have groups | we have everything in SVG
    arc(...)  

  myComponent("arg1", ..., <injected_here>) as @table: # yay, custom component
    # your custom component can have slots like vue-js
    # the slot injected as its last argument when parsed to svgTree
    circ(...) as @targer
    
  embed """ # you can throw raw SVG by the way
    <rect .../>
  """
  embed readfile "./assets/car.svg" # or embed external svg?
  

      
var mySpecialComponenetThatIForgot = stage.query(".class #id")

# kf: key frame
# type Progress = range[0.0 .. 100.0]
func mySuperCoolAnimation(
  st: SvgTree, kfstart, kfend: SomeType, p: Progress = 0.0
): SvgTree =
  discard


let 
  recording = show(stage):
    before:
      discard # do anything before starting animation
    
    # flows can have args
    flow reset: # a named flow
      stage.remove @blocks[1]
    
    stage 0.ms .. 100.ms:
      # @box is a syntax suger for stage.components.box
      let k = move(@box, (10.px, 100.px)) # define a keyframe
      
      # register a transition 
      k.transition(delay= 10.ms, duration = dt, easing= eCubicIn, after = reset)
        
    at 130.ms:
      reset()      

    stage 150.ms .. 200.ms:
      scale(@blocks[0], 1.1).transition(dt, eCricleOut)
      
    stage 170.ms .. 210.ms: # yes, stages can have innersects in timing
      # custom operator is cool
      mySuperCoolAnimation(@car, whereIs @car, (0, 0)) ~> (dt, eCubicIn) 

recording.save("out.gif", 120.fps, size=(1000.px, 400.px), scale=5.0, preview = 0.ms .. 1000.ms, repeat= 1)
```

## Goals:
* [ ] add svg manipulation like: scale, transform, ...
* [ ] add deep copy or delete from screen
* [ ] custom animation function
* [ ] runs on browser
* [ ] control preview like start and stop frame
* [ ] useing nim code with DLS

