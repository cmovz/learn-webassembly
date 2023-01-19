(module
  (import "console" "log" (func $Log (param i32 i32)))
  (import "console" "logIdx" (func $LogIdx (param i32)))
  (table $first_table 4 funcref)
  (elem (table $first_table) (i32.const 0) $Add2 $Main $GetRange $TestLoop)
  (type $add2_ret_type (func (param i32 i32) (result i32)))
  (type $main_ret_type (func))
  (type $getrange_ret_type (func (result i32 i32)))
  (type $testloop_ret_type (func))
  (memory (export "memory") 1)
  (data (i32.const 0) "Hello World!")
  (func $Add2
    (export "Add2ExportedFromInside")
    (param $x i32) (param $y i32)
    (result i32)
    local.get $x
    local.get $y
    i32.add
  )
  (func $Main
    (export "Main")
    ;; log hello world to the console
    i32.const 0
    i32.const 12
    call $Log
  )
  (func $GetRange
    (export "GetRange")
    (result i32 i32) 
    i32.const 30
    i32.const 42
  )
  (func
    (export "TestIf")
    (result i32)

    ;; default return value
    i32.const 0

    ;; test if condition
    i32.const 0
    (if
      (then
        i32.const 10
        return
      )
    )
  )
  (func $TestLoop
    (export "TestLoop")
    (local $idx i32)

    loop $idx_loop
      ;; call log idx
      local.get $idx
      call $LogIdx

      ;; increment idx
      local.get $idx
      i32.const 1
      i32.add
      local.tee $idx

      ;; check if idx is not equal to 10
      i32.const 10
      i32.ne
     
      br_if $idx_loop
    end
  )
  (func
    (export "TestBlock")

    block $outer_block
      block $main_block
        ;; instructions here
        i32.const 1
        br_if $outer_block

        i32.const 10
        call $LogIdx
      end

      ;; this code here doesn't run if the br_if above is taken
      i32.const 42
      call $LogIdx
    end

    (block $secondary_block
      ;; instructions here
    )
  )
  (func
    (export "TestNop")
    nop
    nop
  )
  (func
    (export "TestUnreachable")
    (result i32)
    i32.const 42
    if
      i32.const 1
      return
    else
      i32.const 2
      return
    end
    unreachable
  )
  (func
    (export "TestDrop")
    call $GetRange
    call $LogIdx
    return
  )
  (func
    (export "TestTable")
    ;;(type $add2_ret_type (func (param i32 i32) (result i32)))
    i32.const 37
    i32.const 5
    i32.const 0
    call_indirect $first_table (type $add2_ret_type)
    call $LogIdx

    ;;(type $main_ret_type (func))
    i32.const 1
    call_indirect $first_table (type $main_ret_type)

    ;;(type $getrange_ret_type (func (result i32 i32)))
    i32.const 2
    call_indirect $first_table (type $getrange_ret_type)
    call $LogIdx
    call $LogIdx

    ;;(type $testloop_ret_type (func))
    i32.const 3
    call_indirect $first_table (type $testloop_ret_type)
  )
  (func
    (export "TestSelect")
    i32.const 10
    i32.const 42

    i32.const 1
    select
    call $LogIdx
  )
  (func
    (export "TestSwitch")
    block $switch
      block $a
        block $b
          block $c
            block $d
              i32.const 2
              br_table $a $b $c $d
            end
            i32.const 40
            call $LogIdx
            br $switch
          end
          i32.const 30
          call $LogIdx
          br $switch
        end
        i32.const 20
        call $LogIdx
        br $switch
      end
      i32.const 10
      call $LogIdx
    end

    i32.const 42
    call $LogIdx
  )
)