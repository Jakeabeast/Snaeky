require 'gosu'
require 'rubygems'

CELL_DIM = 20

class Snake
    attr_reader :alive, :pos_x, :pos_y, :points  #*** array?
    attr_writer :on_star

    def initialize(layer)
        @layer = layer
        @image_head = Gosu::Image.new("images/snakeHead.png")
        @image_head_star = Gosu::Image.new("images/snakeCollectStar.png")
        @image_head_dead = Gosu::Image.new("images/snakeHeadDied.png")
        @image_body = Gosu::Image.new("images/snakeBody.png")
        @sound_star = Gosu::Sample.new("sounds/collect_star.wav")
        @sound_died = Gosu::Sample.new("sounds/died.wav")
        @direction = Gosu::KB_DOWN
        @pos_x = 5
        @pos_y = 2
        @angle = 180 #change depending on move direction
        @points = 0  
        @on_star = false
        @alive = true

        @body = Array.new()
        extend_body()
        extend_body()
        
    end

    def add_point()
        @points += 1
        @sound_star.play()
    end
   
    def get_pos_x()
        return @pos_x 
    end
    def get_pos_y()
        return @pos_y 
    end

    def get_points()
        return @points
    end

    def draw(interface_gap, distance)
        #draw body
        idx = 0
        while(idx < @body.length)
            true_x = @body[idx][0] * distance + interface_gap
            true_y = @body[idx][1] * distance + interface_gap
            @image_body.draw_rot(true_x, true_y, @layer)
            idx += 1
        end

        #draw head
        true_x = @pos_x * distance + interface_gap
        true_y = @pos_y * distance + interface_gap

        if(@alive == true)
            if(@on_star == true)
                @image_head_star.draw_rot(true_x, true_y, @layer, @angle)
            else
                @image_head.draw_rot(true_x, true_y, @layer, @angle)
            end
        elsif(@alive == false)
            @image_head_dead.draw_rot(true_x, true_y, @layer, @angle)
        end
    end

    def face_direction(direction)
        if (direction == Gosu::KB_UP)
            @angle = 0
        elsif (direction == Gosu::KB_RIGHT)
            @angle = 90
        elsif (direction == Gosu::KB_DOWN)
            @angle = 180
        elsif (direction == Gosu::KB_LEFT)
            @angle = 270
        else 
            puts "ERROR: Invalid Direction"
        end
        @direction = direction
    end

    def move()
        shift_body(@pos_x, @pos_y)
        if    (@direction == Gosu::KB_LEFT) 
            @pos_x -= 1
        elsif (@direction == Gosu::KB_RIGHT)
            @pos_x += 1
        elsif (@direction == Gosu::KB_UP)
            @pos_y -= 1
        elsif (@direction == Gosu::KB_DOWN) 
            @pos_y += 1
        else 
            puts("Snake.move Error!") 
        end
    end

    #Push body to end of body array
    def extend_body()
        body_position = [-7, -7]
        @body.push(body_position)
    end

    def shift_body(pos_x, pos_y)
        @body.pop()
        shift_to_front = [pos_x, pos_y]
        @body.prepend(shift_to_front)
    end

    def print_position()
        puts("*****************")
        print_position_head()
        print_position_body()
        
    end

    def print_position_head()
        puts ("Snake Head Position: X = #{@pos_x.to_s}. Y = #{@pos_y.to_s}.\n")
    end

    def print_position_body()
        idx = 0
        while(idx < @body.length)
            puts ("Snake Body Position #{idx.to_s}: X = #{@body[idx][0].to_s}. Y = #{@body[idx][1].to_s}.\n")
            idx += 1
        end
    end

    def check_collision(start_of_grid, end_of_grid)
        if(check_collision_wall(start_of_grid, end_of_grid) == true || check_collision_self() == true)
            @alive = false
            @sound_died.play()
        end
    end

    def check_collision_wall(start_of_grid, end_of_grid)
        if (@pos_x < start_of_grid || @pos_x > end_of_grid || @pos_y < start_of_grid || @pos_y > end_of_grid)
            return true
        else
            return false
        end
    end

    def check_collision_self()
        idx = 0
        while(idx < @body.length)
            if(@pos_x == @body[idx][0] && @pos_y == @body[idx][1])
                return true
            end
            idx += 1
        end
        return false
    end
end