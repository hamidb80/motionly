when false:

  expectation:
    ## on | off with true | false
    ## no runtime checks
    ## compile time loop and macro expand
    ## strong compile checks

    import std / [Table, Array]

    shape tb1 Table {type= int, rows = 4, cols = 3 }
    shape arr Array {type= int, len= 8, &with_index }

    def ops {}
    def delay 120ms
    def degree 54deg
    def number 66

    ## everyThing that comes in animat
    call Array.setPosition, arr, 130, 40

    animate {delay = 200ms, executionPolicy = &parallel}:
      call Array.setIndex, arr, 0, 4
      call Array.setIndexVisibility, arr, off


    call delay 120ms

    macro set0 {num}:
      call Array.setIndex, arr, 0, num

    
    loop i =  1..5|2:
      call set0, i


