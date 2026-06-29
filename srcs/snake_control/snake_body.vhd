library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package snake_body is
    -- maximum length of snake
    -- 18 x 13 = 234
    constant MAX_SNAKE_LENGTH : integer := 234;

    -- define x and y coordinate
    type snake_x_array is array (0 to MAX_SNAKE_LENGTH - 1) of integer range 1 to 18;
    type snake_y_array is array (0 to MAX_SNAKE_LENGTH - 1) of integer range 1 to 13;
end package snake_body;