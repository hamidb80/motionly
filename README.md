# motionly
~~a logic less animation software for everyone~~

here, you code animations!
using konva and tweenjs

the first demo is gonna be something like this:
http://thesecretlivesofdata.com/raft/
or this https://github.com/EriKWDev/nanim

before:
https://github.com/bluenote10/NimSvg
https://github.com/jiro4989/svgo

example: 
```nim

import random, algorithm
randomize()
# your nim code here -----------

# motionly area ----------------
var 
  stage = genSVGTree:
    rect(fill= "#fff", ..., @box) # assign svg component to box variable
    circ(fill= "#fff", ..., @blocks[0]) # as array
    line(...) # you don't need to store all components inside a variable

    group: # yes we have groups | we have everything in SVG
      arc(...)  

    embed """ # you can throw raw SVG by the way
      <rect .../>
    """
    embed readfile "./assets/car.svg" # or embed external svg?
    embed someFunctionThatReturnsStringOrSvgTree()

let 
  recording = record(stage): # animation area ----
    before:
      discard # do anything before starting animation
    
    flow reset: # a named flow
      stage.remove @blocks[1]
    
    stage 0.ms .. 100.ms:
      let k = move(@box, (10.px, 100.px)) # define a keyframe
      
      # register a transition 
      k.transition(delay= 10.ms, duration = dt, easing= eCubicIn, after = reset)
        
    at 130.ms:
      reset()      

    stage 150.ms .. 200.ms:
      scale(@blocks[0], 1.1).transition(dt, eCricleOut)
      
    stage 170.ms .. 210.ms: # yes, stages can have innersects in timing
      scale(@blocks[1], 0.9).transition(dt, eCricleOut)

recording.save("out.gif", 120.fps, size=(1000.px, 400.px), scale=5.0, preview = 0.ms .. 1000.ms)
```

## Goals:
* [ ] add svg manipulation like: scale, transform, ...
* [ ] add deep copy or delete from screen
* [ ] runs on browser
* [ ] control prevoewL like start and stop framw
* [ ] useing nim code with DLS

