library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.snake_body.all;

entity snake_control is
    port (
        clk: in std_logic;
        reset: in std_logic;

        game_tick: in std_logic;  --from game_tick
        running_en : in std_logic;  --from game_state
        direction : in std_logic_vector(1 downto 0); --from direction_control

        food_x : in integer range 1 to 18; --from food_control
        food_y : in integer range 1 to 13; 
        snake_x : out snake_x_array; -- to display
        snake_y : out snake_y_array; 
        snake_len : out integer range 1 to MAX_SNAKE_LENGTH; --to display

        eat_food : out std_logic; --to food_control, request new food
        collision : out std_logic  --to game_state, game over signal
    );
end snake_control;

architecture Behavioral of snake_control is

    constant dir_up : std_logic_vector(1 downto 0) := "00";
    constant dir_down : std_logic_vector(1 downto 0) := "01";
    constant dir_left : std_logic_vector(1 downto 0) := "10";
    constant dir_right : std_logic_vector(1 downto 0) := "11";

    signal snake_x_reg : snake_x_array;
    signal snake_y_reg : snake_y_array;
    signal len_reg : integer range 1 to MAX_SNAKE_LENGTH := 3;

begin

    snake_x  <= snake_x_reg;
    snake_y  <= snake_y_reg;
    snake_len <= len_reg;

    process(clk)
        variable next_x : integer;
        variable next_y : integer;
        variable hit_self : std_logic;
        variable ate_food : std_logic;
    begin
        if rising_edge(clk) then

            eat_food <= '0';
            collision<= '0';

            if reset = '1' then
                len_reg <= 3;

                --initial snake position, moving right
                snake_x_reg(0)<= 5;
                snake_y_reg(0)<= 7;

                snake_x_reg(1)<= 4;
                snake_y_reg(1)<= 7;

                snake_x_reg(2)<= 3;
                snake_y_reg(2)<= 7;

                eat_food <= '0';
                collision <= '0';

            elsif game_tick = '1' and running_en = '1' then

                next_x := snake_x_reg(0);
                next_y := snake_y_reg(0);

                -- calculate next head position
                case direction is
                    when dir_up =>
                        next_y := snake_y_reg(0)-1;
                    when dir_down =>
                        next_y := snake_y_reg(0)+1;
                    when dir_left =>
                        next_x := snake_x_reg(0)-1;
                    when dir_right =>
                        next_x := snake_x_reg(0)+1;
                    when others =>
                        next_x := snake_x_reg(0);
                        next_y := snake_y_reg(0);
                end case;

                --wall collision
                if next_x < 1 or next_x > 18 or next_y < 1 or next_y > 13 then
                    collision <= '1';

                else
                    --self collision
                    hit_self := '0';

                    for i in 1 to MAX_SNAKE_LENGTH - 1 loop
                        if i < len_reg then
                            if snake_x_reg(i) = next_x and snake_y_reg(i) = next_y then
                                hit_self := '1';
                            end if;
                        end if;
                    end loop;

                    if hit_self = '1' then
                        collision <= '1';

                    else
                        --food eat
                        if next_x = food_x and next_y = food_y then
                            ate_food := '1';
                        else
                            ate_food := '0';
                        end if;

                        --move body from tail to head
                        for i in MAX_SNAKE_LENGTH - 1 downto 1 loop
                            if i < len_reg then
                                snake_x_reg(i) <= snake_x_reg(i - 1);
                                snake_y_reg(i) <= snake_y_reg(i - 1);
                            end if;
                        end loop;

                        -- update head
                        snake_x_reg(0) <= next_x;
                        snake_y_reg(0) <= next_y;

                        -- grow if food is eaten
                        if ate_food = '1' then
                            eat_food <= '1';

                            if len_reg < MAX_SNAKE_LENGTH then
                                len_reg <= len_reg + 1;
                            end if;
                        end if;

                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;