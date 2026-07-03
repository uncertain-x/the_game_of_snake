library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.snake_body.all;

entity top_snake is
    port (
        clk : in std_logic;
        reset : in std_logic;

        btn_up : in std_logic;
        btn_down : in std_logic;
        btn_left : in std_logic;
        btn_right : in std_logic;
        
        btn_start : in std_logic
    );
end top_snake;

architecture Behavioral of top_snake is

    signal up_db, down_db, left_db, right_db, start_db : std_logic;
    signal direction  : std_logic_vector(1 downto 0);
    signal game_tick  : std_logic;
    signal running_en : std_logic;
    signal collision  : std_logic;
    signal state_out  : std_logic_vector(1 downto 0);
    
    
    signal food_x : integer range 1 to 18 := 7;
    signal food_y : integer range 1 to 13 := 7;
    
    signal snake_x : snake_x_array;
    signal snake_y : snake_y_array;
    signal snake_len : integer range 1 to MAX_SNAKE_LENGTH;
    signal eat_food : std_logic;

begin

    --collision <= '0';
    food_x <= 7;
    food_y <= 7;
    
    deb_up: entity work.Debouncer
        port map (
            clk => clk,
            reset => reset,
            button => btn_up,
            result => up_db
        );

    deb_down: entity work.Debouncer
        port map (
            clk => clk,
            reset => reset,
            button => btn_down,
            result => down_db
        );

    deb_left: entity work.Debouncer
        port map (
            clk => clk,
            reset => reset,
            button => btn_left,
            result => left_db
        );

    deb_right: entity work.Debouncer
        port map (
            clk => clk,
            reset => reset,
            button => btn_right,
            result => right_db
        );

    deb_start: entity work.Debouncer
        port map (
            clk => clk,
            reset => reset,
            button => btn_start,
            result => start_db
        );

    u_dir: entity work.direction_control
        port map (
            clk => clk,
            reset => reset,
            btn_up => up_db,
            btn_down => down_db,
            btn_left => left_db,
            btn_right => right_db,
            direction => direction
        );

    u_tick: entity work.game_tick
        port map (
            clk => clk,
            reset => reset,
            tick => game_tick
        );

    u_state: entity work.game_state
        port map (
            clk => clk,
            reset => reset,
            start_btn => start_db,
            collision => collision,
            state_out => state_out,
            running_en => running_en
        );
        
    u_snake: entity work.snake_control
    port map (
        clk => clk,
        reset => reset,
        game_tick => game_tick,
        running_en => running_en,
        direction=> direction,

        food_x => food_x,
        food_y => food_y,
        snake_x => snake_x,
        snake_y => snake_y,
        snake_len => snake_len,

        eat_food => eat_food,
        collision => collision
    );

end Behavioral;