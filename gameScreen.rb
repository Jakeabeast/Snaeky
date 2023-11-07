require 'gosu'
require 'rubygems'
require './snake'
require './button'
require './stars'

module GameState
  MENU, START, FINAL_SCORE  = *0..2
end

module LayerOrder
  BACKGROUND, SCREEN, GAME_OBJECTS, CONTROLS, TOP = *0..4
end

module Palette
  BUG = 0, #Actually a bug... when you call first color (know clue why when BUG and GREEN are same value)
  BLUE =   [0xff_99FFFF, 0xff_1CFFFF], #Yet Printing BUG prints extra values for some reason
  ORANGE = [0xff_FFD79A, 0xff_FF871C],
  PURPLE = [0xff_D09AFF, 0xff_BC1CFF],
  YELLOW = [0xff_FFF69A, 0xff_FFFF1C],
  GREEN =  [0xff_9AFF9D, 0xff_1CFF24],
  GREY = [0xff_404040, Gosu::Color::GRAY]
end

class GameWindow < Gosu::Window

  WIDTH = 400
  HEIGHT = 600

  SPEED_FACTOR = 1.3
  STARTING_SPEED = 40


  GRID_DISTANCE = 30 #size of snake png
  INTERFACE_GAP = 50
  GAME_SCREEN_LENGTH = WIDTH - (INTERFACE_GAP * 2)
  MAX_GRID_CELL = (GAME_SCREEN_LENGTH) / GRID_DISTANCE - 1 #should be 9 as we can only move 9 spots within the screen

  CONTROLS_LENGTH = 70
  CONTROL_POSITION_LEFT = [INTERFACE_GAP + 30, GAME_SCREEN_LENGTH + INTERFACE_GAP * 2 + CONTROLS_LENGTH]
  CONTROL_POSITION_RIGHT = [INTERFACE_GAP + CONTROLS_LENGTH * 2 + 60, GAME_SCREEN_LENGTH + INTERFACE_GAP * 2 + CONTROLS_LENGTH]
  CONTROL_POSITION_UP = [INTERFACE_GAP + CONTROLS_LENGTH + 45, GAME_SCREEN_LENGTH + 15  + CONTROLS_LENGTH]
  CONTROL_POSITION_DOWN = [INTERFACE_GAP + CONTROLS_LENGTH + 45, GAME_SCREEN_LENGTH + INTERFACE_GAP * 2 + CONTROLS_LENGTH]

  STARS_TILL_SPEED_UP = 3 #lower difficulty = harder

  def initialize()
    super(WIDTH, HEIGHT, false)
    self.caption = "Snaeky"
    @image_menu = Gosu::Image.new("images/menu.png")
    @sound_beat = Gosu::Sample.new("sounds/beat.mp3")
    @sound_bop = Gosu::Sample.new("sounds/bop.wav")
    @color_palette
    change_color()
    @font = Gosu::Font.new(20)
    @timer = 0
    @difficulty_level = 1
    @frames_per_movement = STARTING_SPEED
    @player = Snake.new(LayerOrder::GAME_OBJECTS)
    @control_left = Button.new(Gosu::KB_LEFT)
    @control_right = Button.new(Gosu::KB_RIGHT)
    @control_up = Button.new(Gosu::KB_UP)
    @control_down = Button.new(Gosu::KB_DOWN)
    @action_prep = 0
    @state = GameState::MENU
    @star = Star.new(LayerOrder::GAME_OBJECTS, MAX_GRID_CELL, @player.pos_x, @player.pos_y)


    #puts "*****"
    #puts Palette::BUG #should be equal to 0???
    #puts "*****"
    #puts Palette::GREEN
    #puts "*****"
    #puts Palette::BLUE
  end

  def update
    case @state
    when GameState::MENU
      @timer += 1
      if (check_action() == true && @timer > 30)
        @sound_bop.play()
        sleep(1)
        @action_prep = Gosu::KB_DOWN
        @timer = 0
        @state = GameState::START
      end

    when GameState::START
      @timer += 1
      @player.face_direction(check_action())

      #game tick/move player
      if(@timer >= @frames_per_movement)
        game_tick()
      end
      if(@player.alive == false)
        @timer = 0
        @state = GameState::FINAL_SCORE
      end

    when GameState::FINAL_SCORE
      @timer += 1
      if (check_action() == true)
        reset_game()
        @timer = 0
        @state = GameState::MENU
      end

      if (@timer == 60 || @timer == 120)
        @sound_bop.play()
      end
    end
  end

  def draw()
    #draw background
    draw_quad(0, 0, Palette::GREY[0], WIDTH, 0, Palette::GREY[0], 0, HEIGHT, Palette::GREY[0], WIDTH, HEIGHT, Palette::GREY[0], LayerOrder::BACKGROUND)
    #draw interface (light up at start of timer)
    if(@timer < 2)
      draw_rect(INTERFACE_GAP, INTERFACE_GAP, GAME_SCREEN_LENGTH, GAME_SCREEN_LENGTH, @color_palette[1], LayerOrder::SCREEN)
    else
      draw_rect(INTERFACE_GAP, INTERFACE_GAP, GAME_SCREEN_LENGTH, GAME_SCREEN_LENGTH, @color_palette[0], LayerOrder::SCREEN)
    end

    #draw controls
    draw_controls()

    case @state
    when GameState::MENU
      draw_rect(INTERFACE_GAP + 15, INTERFACE_GAP + 15, GAME_SCREEN_LENGTH - 30, GAME_SCREEN_LENGTH - 30, Gosu::Color::BLACK, LayerOrder::SCREEN)
      @image_menu.draw(INTERFACE_GAP + 15, INTERFACE_GAP + 15, LayerOrder::SCREEN)
    when GameState::START
      #draw snake
      @player.draw(INTERFACE_GAP, GRID_DISTANCE)
      #draw star
      @star.draw(INTERFACE_GAP, GRID_DISTANCE)
      #draw points
      @font.draw_text("SCORE: #{@player.get_points()}", INTERFACE_GAP, INTERFACE_GAP/2, z = LayerOrder::TOP, 1, 1, Palette::GREY[1])
    when GameState::FINAL_SCORE
      #draw snake
      @player.draw(INTERFACE_GAP, GRID_DISTANCE)
      #after 1second display score
      if(@timer > 60)
        draw_quad(85, 155, @color_palette[1], 315, 155, @color_palette[0] , 85, 200, @color_palette[0], 315, 200, @color_palette[1], LayerOrder::TOP)
        @font.draw_text("SCORE: #{@player.get_points()}", 90, 160, z = LayerOrder::TOP, 2.0, 2.0, Gosu::Color::BLACK)
      end
      #after 2second "press play"
      if(@timer > 120)
        draw_quad(85, 215, @color_palette[1], 315, 215, @color_palette[1] , 85, 260, @color_palette[1], 315, 260, @color_palette[1], LayerOrder::TOP)
        @font.draw_text("Press Space", 100, 218, z = LayerOrder::TOP, 2.0, 2.0, Gosu::Color::BLACK)
      end
    end
  end

  def draw_controls()
    draw_rect(INTERFACE_GAP, GAME_SCREEN_LENGTH + INTERFACE_GAP + 15, GAME_SCREEN_LENGTH, GAME_SCREEN_LENGTH/1.5, Gosu::Color::GRAY, LayerOrder::CONTROLS)

    draw_rect(CONTROL_POSITION_UP[0], CONTROL_POSITION_UP[1], CONTROLS_LENGTH, CONTROLS_LENGTH, @color_palette[1], LayerOrder::CONTROLS)
    @control_up.draw(@action_prep, CONTROL_POSITION_UP[0], CONTROL_POSITION_UP[1], CONTROLS_LENGTH, LayerOrder::CONTROLS)

    draw_rect(CONTROL_POSITION_LEFT[0], CONTROL_POSITION_LEFT[1], CONTROLS_LENGTH, CONTROLS_LENGTH, @color_palette[1], LayerOrder::CONTROLS)
    @control_left.draw(@action_prep, CONTROL_POSITION_LEFT[0], CONTROL_POSITION_LEFT[1], CONTROLS_LENGTH, LayerOrder::CONTROLS)

    draw_rect(CONTROL_POSITION_DOWN[0], CONTROL_POSITION_DOWN[1], CONTROLS_LENGTH, CONTROLS_LENGTH, @color_palette[1], LayerOrder::CONTROLS)
    @control_down.draw(@action_prep, CONTROL_POSITION_DOWN[0], CONTROL_POSITION_DOWN[1], CONTROLS_LENGTH, LayerOrder::CONTROLS)

    draw_rect(CONTROL_POSITION_RIGHT[0], CONTROL_POSITION_RIGHT[1], CONTROLS_LENGTH, CONTROLS_LENGTH, @color_palette[1], LayerOrder::CONTROLS)
    @control_right.draw(@action_prep, CONTROL_POSITION_RIGHT[0], CONTROL_POSITION_RIGHT[1], CONTROLS_LENGTH, LayerOrder::CONTROLS)
  end

  #game ticks every 60 frames / every 1sec / every update_interval() * 60
  def game_tick()
    @timer = 0
    @sound_beat.play()
    @player.move()
    #@player.print_position()

    #check if player dies
    @player.check_collision(1, MAX_GRID_CELL)
    #check if player has collected a star
    if (@player.pos_x == @star.pos_x && @player.pos_y == @star.pos_y)
      @player.on_star = true
      collect_star()
    else
      @player.on_star = false
    end
  end

  #snake collects star and gains a point, speed up after every 5 stars
  def collect_star()
    @player.add_point()
    @player.extend_body()
    @star = Star.new(LayerOrder::GAME_OBJECTS, MAX_GRID_CELL, @player.pos_x, @player.pos_y)

    swap_controls()

    if (@player.points % STARS_TILL_SPEED_UP == 0 && @player.points > 0)
      speed_up()
      change_color()
    end
  end

  def check_action()
    case @state
    when GameState::MENU
      if Gosu.button_down? Gosu::KB_SPACE
        return true
      else
        return false
      end

    when GameState::START
      if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::KbA
        @action_prep = @control_left.direction
      elsif Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::KbD
        @action_prep = @control_right.direction
      elsif Gosu.button_down? Gosu::KB_UP or Gosu.button_down? Gosu::KbW
        @action_prep = @control_up.direction
      elsif Gosu.button_down? Gosu::KB_DOWN or Gosu.button_down? Gosu::KbS
        @action_prep = @control_down.direction
      else  end
      return @action_prep

    when GameState::FINAL_SCORE
      if Gosu.button_down? Gosu::KB_SPACE
        @sound_bop.play()
        return true
      else
        return false
      end
    end
  end

  def quit() #add to menu***
    sleep(1)
    close
  end

  def change_color()
    previous_color = @color_palette
    while(previous_color == @color_palette)
      selection = rand(1..5)
      case selection
      when 1
        @color_palette = Palette::GREEN
      when 2
        @color_palette = Palette::BLUE
      when 3
        @color_palette = Palette::ORANGE
      when 4
        @color_palette = Palette::PURPLE
      when 5
        @color_palette = Palette::YELLOW
      end
    end
  end

  def speed_up()
    @frames_per_movement = (@frames_per_movement / SPEED_FACTOR).round()
    @difficulty_level += 1
  end

  def swap_controls()
    @timer = -60 #Give time for players to see control swap
    selection = rand(1..6)
    case selection
    when 1
      temp = @control_down.get_direction()
      @control_down.rotate(@control_up.get_direction())
      @control_up.rotate(temp)
    when 2
      temp = @control_down.get_direction()
      @control_down.rotate(@control_left.get_direction())
      @control_left.rotate(temp)
    when 3
      temp = @control_down.get_direction()
      @control_down.rotate(@control_right.get_direction())
      @control_right.rotate(temp)
    when 4
      temp = @control_up.get_direction()
      @control_up.rotate(@control_left.get_direction())
      @control_left.rotate(temp)
    when 5
      temp = @control_up.get_direction()
      @control_up.rotate(@control_right.get_direction())
      @control_right.rotate(temp)
    when 6
      temp = @control_left.get_direction()
      @control_left.rotate(@control_right.get_direction())
      @control_right.rotate(temp)
    end
  end

  def reset_game()
    initialize()
  end
end

GameWindow.new.show
