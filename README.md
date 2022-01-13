# motionly
~~a logic less animation software for everyone

here, you code animations!
using konva and tweenjs

the first demo is gonna be something like this:
http://thesecretlivesofdata.com/raft/
or this https://github.com/EriKWDev/nanim

example: 
```nim

import random, algorithm
randomize()
# your nim code here -----------

# motionly area ----------------
motionly:
  stage: # known components before creating the scene
    rect(fill= "#fff", ..., @box) # assign svg component to box variable
    circ(fill= "#fff", ..., @blocks[0]) # as array
    line(...) # you don't need to store all components inside a variable

    group: # yes we have groups | we have everything in svg
      arc(...)  

  ## >>
  flow: # wrapper for all animations
    stage 0.ms .. 100.ms:
      @box.x = `rand(11)` # put your nim code inside backticks (`)
      @blocks[0].content = `"hamid".upper`
      
  ## <<
  
  # the `>>` means the frontend should start animation preview from here
  # `<<` is optional
```
