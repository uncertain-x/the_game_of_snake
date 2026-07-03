library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.snake_body.all;

entity top_snake is
    generic (
        -- defaults match the board; testbenches override them to speed up simulation
        CLK_FREQ_HZ : integer := 100_000_000;
        TICK_MS     : integer := 150;
        DEBOUNCE_MS : integer := 5;
        SCAN_DIV    : positive := 100000
    );
    port (
        clk : in std_logic;
        reset : in std_logic;

        btn_up : in std_logic;
        btn_down : in std_logic;
        btn_left : in std_logic;
        btn_right : in std_logic;

        btn_start : in std_logic;

        -- seven-segment score display
        seg : out std_logic_vector(6 downto 0);
        an  : out std_logic_vector(3 downto 0);
        dp  : out std_logic;

        -- VGA
        VGA_R : out std_logic_vector(3 downto 0);
        VGA_G : out std_logic_vector(3 downto 0);
        VGA_B : out std_logic_vector(3 downto 0);
        VGA_H_SYNC : out std_logic;
        VGA_V_SYNC : out std_logic
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
    -- raw vectors from food_control, converted to the integers above
    signal food_x_slv : std_logic_vector(4 downto 0);
    signal food_y_slv : std_logic_vector(3 downto 0);

    signal snake_x : snake_x_array;
    signal snake_y : snake_y_array;
    signal snake_len : integer range 1 to MAX_SNAKE_LENGTH;
    signal eat_food : std_logic;

    signal score : std_logic_vector(9 downto 0);

    -- convert food_control's vector output to the bounded integers snake_control
    -- expects; clamps metavalues (simulation time zero) and out-of-range values
    function slv_to_coord(v : std_logic_vector; lo, hi, dflt : integer) return integer is
    begin
        if is_x(v) then
            return dflt;
        elsif to_integer(unsigned(v)) < lo then
            return lo;
        elsif to_integer(unsigned(v)) > hi then
            return hi;
        else
            return to_integer(unsigned(v));
        end if;
    end function;

begin

    --collision <= '0';
    food_x <= slv_to_coord(food_x_slv, 1, 18, 10);
    food_y <= slv_to_coord(food_y_slv, 1, 13, 7);

    -- score = food eaten = snake growth since the initial length of 3
    score <= std_logic_vector(to_unsigned(snake_len - 3, score'length)) when snake_len >= 3
             else (others => '0');

    deb_up: entity work.Debouncer
        generic map (
            clk_freq => CLK_FREQ_HZ,
            stable_time => DEBOUNCE_MS
        )
        port map (
            clk => clk,
            reset => reset,
            button => btn_up,
            result => up_db
        );

    deb_down: entity work.Debouncer
        generic map (
            clk_freq => CLK_FREQ_HZ,
            stable_time => DEBOUNCE_MS
        )
        port map (
            clk => clk,
            reset => reset,
            button => btn_down,
            result => down_db
        );

    deb_left: entity work.Debouncer
        generic map (
            clk_freq => CLK_FREQ_HZ,
            stable_time => DEBOUNCE_MS
        )
        port map (
            clk => clk,
            reset => reset,
            button => btn_left,
            result => left_db
        );

    deb_right: entity work.Debouncer
        generic map (
            clk_freq => CLK_FREQ_HZ,
            stable_time => DEBOUNCE_MS
        )
        port map (
            clk => clk,
            reset => reset,
            button => btn_right,
            result => right_db
        );

    deb_start: entity work.Debouncer
        generic map (
            clk_freq => CLK_FREQ_HZ,
            stable_time => DEBOUNCE_MS
        )
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
        generic map (
            clk_board => CLK_FREQ_HZ,
            tick_cycle => TICK_MS
        )
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

    u_food: entity work.food_control
        port map (
            clk => clk,
            reset => reset,
            eat => eat_food,
            food_x => food_x_slv,
            food_y => food_y_slv
        );

    u_score_display: entity work.seven_seg_controller
        generic map (
            SCAN_DIV => SCAN_DIV
        )
        port map (
            clk => clk,
            reset => reset,
            score => score,
            seg => seg,
            an => an,
            dp => dp
        );

    u_display: entity work.display_control
        port map (
            clk => clk,
            reset => reset,
            VGA_R => VGA_R,
            VGA_G => VGA_G,
            VGA_B => VGA_B,
            VGA_H_SYNC => VGA_H_SYNC,
            VGA_V_SYNC => VGA_V_SYNC
        );

end Behavioral;
