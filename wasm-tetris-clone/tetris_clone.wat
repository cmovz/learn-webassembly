(module
  (import "js" "memory" (memory 1))
  (import "js" "jsRender" (func $JsRender (param i32)))
  (import "js" "jsUpdateScore" (func $JsUpdateScore (param i32)))
  (import "js" "random" (func $Random (result i32)))
  (import "console" "logIdx" (func $LogIdx (param i32)))

  ;; constants
  (global $grid_ptr i32 (i32.const 0))
  (global $ai_grid_ptr i32 (i32.const 1004))
  (global $rot_ptr i32 (i32.const 264))
  (global $pieces_ptr i32 (i32.const 292))
  (global $grid_width i32 (i32.const 12))
  (global $grid_height i32 (i32.const 22))
  (global $tick_time i64 (i64.const 100))
  (global $fall_time i64 (i64.const 1000))

  ;; game state
  (global $last_update (mut i64) (i64.const 0))
  (global $last_fall_update (mut i64) (i64.const 0))
  (global $score (mut i32) (i32.const 0))
  (global $piece (mut i32) (i32.const 0))
  (global $piece_x (mut i32) (i32.const 0))
  (global $piece_y (mut i32) (i32.const 0))
  (global $piece_rot (mut i32) (i32.const 0))
  (global $available_ptr (mut i32) (i32.const 1268))
  (global $ai_piece_x (mut i32) (i32.const 0))
  (global $ai_piece_rot (mut i32) (i32.const 0))
  (global $ai_enabled (mut i32) (i32.const 0))

  ;; movement state
  (global $pressing_left (mut i32) (i32.const 0))
  (global $pressing_right (mut i32) (i32.const 0))
  (global $pressing_down (mut i32) (i32.const 0))
  (global $pressing_up (mut i32) (i32.const 0))
  (global $pressing_space (mut i32) (i32.const 0))
  (global $moved_left (mut i32) (i32.const 0))
  (global $moved_right (mut i32) (i32.const 0))
  (global $moved_down (mut i32) (i32.const 0))
  (global $moved_up (mut i32) (i32.const 0))
  (global $moved_space (mut i32) (i32.const 0))

  (func 
    (export "SetLeftKeyState")
    (param $pressed i32)
    local.get $pressed
    global.set $pressing_left
    local.get $pressed
    if
      i32.const 0
      global.set $moved_left
    end
  )

  (func 
    (export "SetRightKeyState")
    (param $pressed i32)
    local.get $pressed
    global.set $pressing_right
    local.get $pressed
    if
      i32.const 0
      global.set $moved_right
    end
  )

  (func 
    (export "SetDownKeyState")
    (param $pressed i32)
    local.get $pressed
    global.set $pressing_down
    local.get $pressed
    if
      i32.const 0
      global.set $moved_down
    end
  )

  (func 
    (export "SetUpKeyState")
    (param $pressed i32)
    local.get $pressed
    global.set $pressing_up
    local.get $pressed
    if
      i32.const 0
      global.set $moved_up
    end
  )

  (func 
    (export "SetSpaceKeyState")
    (param $pressed i32)
    local.get $pressed
    global.set $pressing_space
    local.get $pressed
    if
      i32.const 0
      global.set $moved_space
    end
  )

  (func $GetPos
    (param $x i32) (param $y i32)
    (result i32)
    local.get $y
    global.get $grid_width
    i32.mul

    local.get $x
    i32.add
  )

  (func $GetPieceMatrixValue
    (param $piece i32) (param $piece_rot i32) (param $x i32) (param $y i32)
    (result i32)
    local.get $piece
    i32.const 6
    i32.shl

    local.get $piece_rot
    i32.const 4
    i32.shl

    i32.add

    global.get $pieces_ptr
    i32.add

    local.get $y
    i32.const 2
    i32.shl
    i32.add

    local.get $x
    i32.add

    i32.load8_u
  )

  (func $CheckCollision
    (param $piece i32) (param $piece_rot i32)
    (param $piece_x i32) (param $piece_y i32)
    (param $grid_ptr i32)
    (result i32)
    (local $x i32) (local $y i32)
    loop $y_loop
      i32.const 0
      local.set $x
      loop $x_loop
        local.get $piece
        local.get $piece_rot
        local.get $x
        local.get $y
        call $GetPieceMatrixValue

        if
          local.get $x
          local.get $piece_x
          i32.add
          local.get $y
          local.get $piece_y
          i32.add
          call $GetPos
          local.get $grid_ptr
          i32.add
          i32.load8_u

          if
            i32.const 1
            return
          end
        end

        local.get $x
        i32.const 1
        i32.add
        local.tee $x
        i32.const 4
        i32.ne
        br_if $x_loop
      end

      local.get $y
      i32.const 1
      i32.add
      local.tee $y
      i32.const 4
      i32.ne
      br_if $y_loop
    end

    i32.const 0
  )

  (func $CheckDefaultCollision
    (result i32)
    global.get $piece
    global.get $piece_rot
    global.get $piece_x
    global.get $piece_y
    global.get $grid_ptr
    call $CheckCollision
  )

  (func $ClearGrid
    (local $x i32) (local $y i32) (local $x_end i32) (local $y_end i32)
    global.get $grid_width
    i32.const 1
    i32.sub
    local.set $x_end

    global.get $grid_height
    i32.const 1
    i32.sub
    local.set $y_end

    i32.const 1
    local.set $y
    loop $y_loop
      i32.const 1
      local.set $x
      loop $x_loop
        local.get $x
        local.get $y
        call $GetPos

        global.get $grid_ptr
        i32.add

        i32.const 0
        i32.store8

        local.get $x
        i32.const 1
        i32.add
        local.tee $x

        local.get $x_end
        i32.ne
        br_if $x_loop
      end

      local.get $y
      i32.const 1
      i32.add
      local.tee $y

      local.get $y_end
      i32.ne
      br_if $y_loop
    end
  )

  (func $RenderPiece
    (param $dest_ptr i32) (param $piece i32)
    (param $piece_x i32) (param $piece_y i32)
    (param $piece_rot i32)
    (local $x i32) (local $y i32) (local $tmp i32)
    ;; render the piece
    loop $y_loop
      i32.const 0
      local.set $x
      loop $x_loop
        ;; get grid pos
        local.get $x
        local.get $piece_x
        i32.add
        local.get $y
        local.get $piece_y
        i32.add
        call $GetPos
        local.get $dest_ptr
        i32.add
        local.set $tmp

        local.get $piece
        local.get $piece_rot
        local.get $x
        local.get $y
        call $GetPieceMatrixValue
        if
          local.get $tmp
          i32.const 1
          i32.store8
        end

        local.get $x
        i32.const 1
        i32.add
        local.tee $x

        i32.const 4
        i32.ne
        br_if $x_loop
      end

      local.get $y
      i32.const 1
      i32.add
      local.tee $y

      i32.const 4
      i32.ne
      br_if $y_loop
    end


  )

  (func $Render
    (export "Render")
    (param $dest_ptr i32)
    ;; copy static blocks
    local.get $dest_ptr
    global.get $grid_ptr
    i32.const 264
    memory.copy

    local.get $dest_ptr
    global.get $piece
    global.get $piece_x
    global.get $piece_y
    global.get $piece_rot
    call $RenderPiece

    ;; do the rendering to the screen
    local.get $dest_ptr
    call $JsRender
  )

  (func $MoveLinesDown
    (param $grid_ptr i32) (param $y i32)
    (local $tmp i32)
    local.get $y
    i32.const 1
    i32.eq
    if
      i32.const 1
      i32.const 1
      call $GetPos
      local.get $grid_ptr
      i32.add

      i32.const 0

      i32.const 10

      memory.fill
    else
      i32.const 0
      local.get $y
      call $GetPos
      local.get $grid_ptr
      i32.add
      local.tee $tmp

      local.get $tmp
      i32.const 12
      i32.sub

      i32.const 12
      memory.copy

      local.get $grid_ptr
      local.get $y
      i32.const 1
      i32.sub
      call $MoveLinesDown
    end
  )

  (func $ClearLines
    (param $grid_ptr i32) (param $piece_y i32)
    (result i32)
    (local $x i32) (local $y i32) (local $x_end i32) (local $y_end i32)
    (local $line_cleared_count i32) (local $base_ptr i32)
    local.get $piece_y
    i32.const 4
    i32.add
    local.set $y_end

    global.get $grid_height
    i32.const 2
    i32.sub
    local.set $y

    local.get $y_end
    local.get $y
    i32.lt_u
    if
      local.get $y_end
      local.set $y
    end

    global.get $grid_width
    i32.const 1
    i32.sub
    local.set $x_end

    local.get $piece_y
    i32.const 1
    i32.sub
    local.set $y_end

    loop $y_loop
      block $line_filled_block
        i32.const 1
        local.tee $x
        local.get $y
        call $GetPos
        local.get $grid_ptr
        i32.add
        local.set $base_ptr

        loop $x_loop
          ;; check if the block is filled
          local.get $base_ptr
          local.get $x
          i32.add
          i32.load8_u

          ;; if the block is not filled skip this line
          if
          else
            br $line_filled_block
          end

          local.get $x
          i32.const 1
          i32.add
          local.tee $x
          local.get $x_end
          i32.ne
          br_if $x_loop
        end
        ;; the line is filled
        ;; move the lines down
        local.get $grid_ptr
        local.get $y
        call $MoveLinesDown

        local.get $line_cleared_count
        i32.const 1
        i32.add
        local.set $line_cleared_count

        br $y_loop
      end

      local.get $y
      i32.const 1
      i32.sub
      local.tee $y
      local.get $y_end
      i32.ne
      br_if $y_loop
    end

    local.get $line_cleared_count
  )

  (func $SpawnPiece
    call $Random
    i32.const 7
    i32.rem_u
    global.set $piece
 
    i32.const 4
    global.set $piece_x

    i32.const 1
    global.set $piece_y

    i32.const 0
    global.set $piece_rot
  )

  (func 
    (export "StartGame")
    (param $t0 i64)
    local.get $t0
    global.set $last_update
    local.get $t0
    global.set $last_fall_update

    i32.const 1
    global.set $moved_left
    i32.const 1
    global.set $moved_right
    i32.const 1
    global.set $moved_down
    i32.const 1
    global.set $moved_up
    i32.const 1
    global.set $moved_space

    i32.const 0
    global.set $score
    global.get $score
    call $JsUpdateScore

    call $ClearGrid
    call $SpawnPiece
    call $RunAi
  )

  (func $UpdateScore
    (param $lines_cleared i32)
    ;; 40	100	300	1200
    block $switch
      block $a
        block $b
          block $c
            block $d
              local.get $lines_cleared
              br_table $switch $a $b $c $d
            end
            i32.const 1200
            global.get $score
            i32.add
            global.set $score
            br $switch
          end
          i32.const 300
          global.get $score
          i32.add
          global.set $score
          br $switch
        end
        i32.const 100
        global.get $score
        i32.add
        global.set $score
        br $switch
      end
      i32.const 40
      global.get $score
      i32.add
      global.set $score
    end

    global.get $score
    call $JsUpdateScore
  )

  (func $IsGameOver
    (result i32)
    call $CheckDefaultCollision
  )

  (func $FallInstantly
    loop $fall_loop
      global.get $piece_y
      i32.const 1
      i32.add
      global.set $piece_y

      call $CheckDefaultCollision
      i32.const 1
      i32.xor
      br_if $fall_loop
    end
    global.get $piece_y
    i32.const 1
    i32.sub
    global.set $piece_y
  )

  (func $IntegratePiece
    global.get $grid_ptr
    global.get $piece
    global.get $piece_x
    global.get $piece_y
    global.get $piece_rot
    call $RenderPiece

    global.get $grid_ptr
    global.get $piece_y
    call $ClearLines
    call $UpdateScore
    call $SpawnPiece
  )

  (func $MovePiece
    (param $x i32)
    global.get $piece_x
    local.get $x
    i32.add
    global.set $piece_x

    call $CheckDefaultCollision
    if
      global.get $piece_x
      local.get $x
      i32.sub
      global.set $piece_x
    end
  )

  (func 
    (export "SetAiEnabled")
    (param $enabled i32)
    local.get $enabled
    global.set $ai_enabled
  )

  (func
    (export "UpdateGameState")
    (param $t1 i64)
    (result i32)
    (local $tick_count i64) (local $fall_count i64)
    local.get $t1
    global.get $last_update
    i64.sub

    global.get $tick_time
    i64.div_u
    local.tee $tick_count

    i64.const 0
    i64.ne
    if
      local.get $tick_count
      global.get $tick_time
      i64.mul
      global.get $last_update
      i64.add
      global.set $last_update

      loop $main_loop
        global.get $ai_enabled
        if
          global.get $piece_rot
          global.get $ai_piece_rot
          i32.ne
          if
            global.get $piece_rot
            i32.const 1
            i32.add
            i32.const 3
            i32.and
            global.set $piece_rot

            call $CheckDefaultCollision
            if
              global.get $piece_rot
              i32.const 1
              i32.sub
              i32.const 3
              i32.and
              global.set $piece_rot
            end
          else
            global.get $ai_piece_x
            global.get $piece_x
            i32.lt_s
            if
              i32.const -1
              call $MovePiece
            else
              global.get $ai_piece_x
              global.get $piece_x
              i32.gt_u
              if
                i32.const 1
                call $MovePiece
              end
            end
          end

          global.get $piece_rot
          global.get $ai_piece_rot
          i32.eq
          global.get $piece_x
          global.get $ai_piece_x
          i32.eq
          i32.and
          if
            call $FallInstantly
            call $IntegratePiece
            call $IsGameOver
            if
              i32.const 0
              return
            end
            call $RunAi
          end
          
        else
          ;; execute player actions
          ;; move left
          global.get $pressing_left
          global.get $moved_left
          i32.const 1
          i32.xor
          i32.or
          if
            i32.const 1
            global.set $moved_left
            i32.const -1
            call $MovePiece
          end

          ;; move right
          global.get $pressing_right
          global.get $moved_right
          i32.const 1
          i32.xor
          i32.or
          if
            i32.const 1
            global.set $moved_right
            i32.const 1
            call $MovePiece
          end

          ;; move down
          global.get $pressing_down
          global.get $moved_down
          i32.const 1
          i32.xor
          i32.or
          if
            i32.const 1
            global.set $moved_down
            global.get $piece_y
            i32.const 1
            i32.add
            global.set $piece_y

            call $CheckDefaultCollision
            if
              global.get $piece_y
              i32.const 1
              i32.sub
              global.set $piece_y

              call $IntegratePiece
              call $IsGameOver
              if
                i32.const 0
                return
              end
              call $RunAi
            end
          end

          ;; rotate
          global.get $pressing_up
          global.get $moved_up
          i32.const 1
          i32.xor
          i32.or
          if
            i32.const 1
            global.set $moved_up
            global.get $piece_rot
            i32.const 1
            i32.add
            i32.const 3
            i32.and
            global.set $piece_rot

            call $CheckDefaultCollision
            if
              global.get $piece_rot
              i32.const 1
              i32.sub
              i32.const 3
              i32.and
              global.set $piece_rot
            end
          end

          ;; fall
          global.get $pressing_space
          global.get $moved_space
          i32.const 1
          i32.xor
          i32.or
          if
            i32.const 1
            global.set $moved_space
            call $FallInstantly

            call $IntegratePiece
            call $IsGameOver
            if
              i32.const 0
              return
            end
            call $RunAi
          end
        end

        local.get $tick_count
        i64.const 1
        i64.sub
        local.tee $tick_count
        i64.const 0
        i64.ne
        br_if $main_loop
      end
    end

    local.get $t1
    global.get $last_fall_update
    i64.sub

    global.get $fall_time
    i64.div_u
    local.tee $fall_count

    i64.const 0
    i64.ne
    if
      local.get $fall_count
      global.get $fall_time
      i64.mul
      global.get $last_fall_update
      i64.add
      global.set $last_fall_update

      ;; move the piece if there are enough ticks
      loop $fall_loop
        global.get $piece_y
        i32.const 1
        i32.add
        global.set $piece_y

        call $CheckDefaultCollision
        if
          global.get $piece_y
          i32.const 1
          i32.sub
          global.set $piece_y

          global.get $grid_ptr
          global.get $piece
          global.get $piece_x
          global.get $piece_y
          global.get $piece_rot
          call $RenderPiece

          global.get $grid_ptr
          global.get $piece_y
          call $ClearLines

          call $UpdateScore

          call $SpawnPiece
          call $IsGameOver
          if
            i32.const 0
            return
          end
          call $RunAi
        end

        local.get $fall_count
        i64.const 1
        i64.sub
        local.tee $fall_count
        i64.const 0
        i64.ne
        br_if $fall_loop
      end

    end

    i32.const 1
  )

  (func $ComputeGridStats
    (param $grid_ptr i32)
    (result i32 i32 i32 i32)
    (local $holes i32) (local $aggregate_height i32)
    (local $bumpiness i32) (local $wells_depth i32)
    (local $x i32) (local $y i32) (local $h i32)
    (local $x_end i32) (local $y_end i32) (local $base_ptr i32)
    ;; heights = [self.h - 2] + [0 for _ in range(self.w - 2)] + [self.h - 2]
    global.get $grid_height
    i32.const 2
    i32.sub
    local.set $h

    global.get $available_ptr
    i32.const 0
    i32.const 48
    memory.fill

    global.get $available_ptr
    local.get $h
    i32.store
    
    global.get $available_ptr
    local.get $h
    i32.store offset=44

    ;;for y in range(1, self.h - 1):
    i32.const 1
    local.set $y

    global.get $grid_height
    i32.const 1
    i32.sub
    local.set $y_end

    global.get $grid_width
    i32.const 1
    i32.sub
    local.set $x_end

    loop $y_loop
      ;;  for x in range(1, self.w - 1):
      i32.const 1
      local.set $x

      i32.const 0
      local.get $y
      call $GetPos
      local.get $grid_ptr
      i32.add
      local.set $base_ptr

      loop $x_loop
        local.get $base_ptr
        local.get $x
        i32.add
        i32.load8_u
        ;;    if self.cells[y][x] != Color.BLACK:
        if
        ;;      if heights[x] == 0:
          global.get $available_ptr
          local.get $x
          i32.const 2
          i32.shl
          i32.add
          i32.load
          i32.eqz
          if
            ;;        h = self.h - 1 - y
            global.get $available_ptr
            local.get $x
            i32.const 2
            i32.shl
            i32.add

            global.get $grid_height
            i32.const 1
            i32.sub
            local.get $y
            i32.sub
            local.tee $h

            ;;        heights[x] = h
            i32.store

            ;;        self.aggregate_height += h
            local.get $h
            local.get $aggregate_height
            i32.add
            local.set $aggregate_height
          end
        else
        ;;    elif heights[x] != 0:
        ;;      self.holes += 1
          global.get $available_ptr
          local.get $x
          i32.const 2
          i32.shl
          i32.add
          i32.load
          i32.eqz
          if
          else
            i32.const 1
            local.get $holes
            i32.add
            local.set $holes
          end
        end

        local.get $x
        i32.const 1
        i32.add
        local.tee $x
        local.get $x_end
        i32.ne
        br_if $x_loop
      end
      
      local.get $y
      i32.const 1
      i32.add
      local.tee $y
      local.get $y_end
      i32.ne
      br_if $y_loop
    end

    ;;for x in range(2, self.w - 1):
    i32.const 2
    local.set $x
    loop $x_loop
      ;;  self.bumpiness += abs(heights[x] - heights[x - 1])
      global.get $available_ptr
      local.get $x
      i32.const 2
      i32.shl
      i32.add
      i32.load

      global.get $available_ptr
      local.get $x
      i32.const 1
      i32.sub
      i32.const 2
      i32.shl
      i32.add
      i32.load

      i32.sub
      local.tee $y

      i32.const 0
      i32.lt_s

      if
        local.get $y
        i32.const 0xffffffff
        i32.xor
        i32.const 1
        i32.add
        local.set $y
      end

      local.get $bumpiness
      local.get $y
      i32.add
      local.set $bumpiness

      local.get $x
      i32.const 1
      i32.add
      local.tee $x
      local.get $x_end
      i32.ne
      br_if $x_loop
    end
    
    ;;for x in range(1, self.w - 1):
    i32.const 1
    local.set $x
    loop $x_loop
      ;;  minh = min(heights[x - 1], heights[x + 1])
      global.get $available_ptr
      local.get $x
      i32.const 1
      i32.sub
      i32.const 2
      i32.shl
      i32.add
      i32.load
      local.tee $y ;; heights[x - 1]

      global.get $available_ptr
      local.get $x
      i32.const 1
      i32.add
      i32.const 2
      i32.shl
      i32.add
      i32.load
      local.tee $y_end ;; heights[x + 1]

      i32.gt_s
      if
        local.get $y_end
        local.set $y
      end

      ;; minh is in y
      ;;  dh = minh - heights[x]
      local.get $y

      global.get $available_ptr
      local.get $x
      i32.const 2
      i32.shl
      i32.add
      i32.load

      i32.sub

      ;; dh is in y
      local.tee $y
      i32.const 3
      i32.ge_s

      ;;  if dh >= 3:
      if
        ;;    self.wells_depth += dh
        local.get $y
        local.get $wells_depth
        i32.add
        local.set $wells_depth
      end

      local.get $x
      i32.const 1
      i32.add
      local.tee $x
      local.get $x_end
      i32.ne
      br_if $x_loop
    end

    local.get $holes
    local.get $aggregate_height
    local.get $bumpiness
    local.get $wells_depth
  )

  (func $FindMinMaxX
    (param $grid_ptr i32) (param $piece i32) (param $piece_rot i32)
    (param $piece_starting_x i32) (param $piece_y i32)
    (result i32 i32)
    (local $min_x i32) (local $max_x i32)

    local.get $piece_starting_x
    local.tee $min_x
    local.set $max_x

    loop $min_loop
      local.get $piece
      local.get $piece_rot
      local.get $min_x
      local.get $piece_y
      local.get $grid_ptr
      call $CheckCollision
      if
        local.get $min_x
        i32.const 1
        i32.add
        local.set $min_x
      else
        local.get $min_x
        i32.const 1
        i32.sub
        local.set $min_x
        br $min_loop
      end
    end

    loop $max_loop
      local.get $piece
      local.get $piece_rot
      local.get $max_x
      local.get $piece_y
      local.get $grid_ptr
      call $CheckCollision
      if
      else
        local.get $max_x
        i32.const 1
        i32.add
        local.set $max_x
        br $max_loop
      end
    end
   
    local.get $min_x
    local.get $max_x
  )

  (func $ComputeFitness
    (param $grid_ptr i32) (param $filled_rows i32)
    (result f32)
    (local $holes f32) (local $aggregate_height f32) (local $bumpiness f32)
    (local $wells_depth f32) (local $vtmp v128)
      local.get $filled_rows
      f32.convert_i32_u
      f32.const 0.103831
      f32.mul

      local.get $grid_ptr
      call $ComputeGridStats

      f32.convert_i32_u
      local.set $wells_depth
      f32.convert_i32_u
      local.set $bumpiness
      f32.convert_i32_u
      local.set $aggregate_height
      f32.convert_i32_u
      local.set $holes

      v128.const f32x4 0.0 0.0 0.0 0.0

      local.get $bumpiness
      f32x4.replace_lane 0

      local.get $aggregate_height
      f32x4.replace_lane 1

      local.get $holes
      f32x4.replace_lane 2

      local.get $wells_depth
      f32x4.replace_lane 3

      v128.const f32x4 0.164168 0.012872 0.962466 0.206230

      f32x4.mul

      local.tee $vtmp
      f32x4.extract_lane 0
      f32.sub

      local.get $vtmp
      f32x4.extract_lane 1
      f32.sub

      local.get $vtmp
      f32x4.extract_lane 2
      f32.sub

      local.get $vtmp
      f32x4.extract_lane 3
      f32.sub
  )

  (func $RunAi
    (local $rot i32) (local $min_x i32) (local $max_x i32) (local $piece_y i32)
    (local $best_fitness f32) (local $tmp f32) (local $rot_count i32)
    global.get $piece_x
    global.set $ai_piece_x

    global.get $piece_rot
    global.set $ai_piece_rot

    f32.const -1000000000000.00
    local.set $best_fitness

    global.get $rot_ptr
    global.get $piece
    i32.const 2
    i32.shl
    i32.add
    i32.load
    local.set $rot_count

    loop $rot_loop
      global.get $ai_grid_ptr
      global.get $grid_ptr
      i32.const 264
      memory.copy

      global.get $piece
      local.get $rot
      global.get $piece_x
      global.get $piece_y
      global.get $ai_grid_ptr
      call $CheckCollision

      if
        global.get $ai_grid_ptr
        global.get $piece
        local.get $rot
        global.get $piece_x
        global.get $piece_y
        call $FindMinMaxX
        local.set $max_x
        local.set $min_x

        loop $x_loop
          global.get $ai_grid_ptr
          global.get $grid_ptr
          i32.const 264
          memory.copy

          global.get $piece_y
          local.set $piece_y

          loop $y_loop
            local.get $piece_y
            i32.const 1
            i32.add
            local.set $piece_y

            global.get $piece
            local.get $rot
            local.get $min_x
            local.get $piece_y
            global.get $ai_grid_ptr
            call $CheckCollision
            if
              local.get $piece_y
              i32.const 1
              i32.sub
              local.set $piece_y

              global.get $ai_grid_ptr
              global.get $piece
              local.get $min_x
              local.get $piece_y
              local.get $rot
              call $RenderPiece

              global.get $ai_grid_ptr

              global.get $ai_grid_ptr
              local.get $piece_y
              call $ClearLines

              call $ComputeFitness
              local.tee $tmp

              local.get $best_fitness
              f32.gt
              if
                local.get $rot
                global.set $ai_piece_rot

                local.get $min_x
                global.set $ai_piece_x

                local.get $tmp
                local.set $best_fitness
              end
            else
              br $y_loop
            end

          end

          local.get $min_x
          i32.const 1
          i32.add
          local.tee $min_x
          local.get $max_x
          i32.ne
          br_if $x_loop
        end
      end

      local.get $rot
      i32.const 1
      i32.add
      local.tee $rot
      local.get $rot_count
      i32.ne
      br_if $rot_loop
    end
  )
)