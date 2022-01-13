# motionly
~~a logic less animation software for everyone

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
let controlFlow = motionly:
  stage: # known components before creating the scene
    rect(fill= "#fff", ..., @box) # assign svg component to box variable
    circ(fill= "#fff", ..., @blocks[0]) # as array
    line(...) # you don't need to store all components inside a variable

    group: # yes we have groups | we have everything in SVG
      arc(...)  
      
    # you can throw raw SVG by the way
    raw """
      <rect .../>
    """
  
  # defining function that works with DSL
  util do_it_whenever_you_want(arg1: seq[int])= # utlls doesn't return anything
    # your nim code ...
    1

  # animation area ----
  stage 0.ms .. 100.ms:
    @box.x = `rand(11)` # put your nim code inside backticks (`)
    @blocks[0].content = `"hamid".upper`
    
  ## >>
  stage 150.ms .. 200.ms:
    @box.x = `rand(11)` # put your nim code inside backticks (`)
    @blocks[0].content = `"hamid".upper`
  ## <<
  
  # the `>>` means the front-end should start animation preview from here
  # `<<` means opposite, optional
  
controlFlow.run
```
