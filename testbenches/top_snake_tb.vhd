-- Integration testbench for top_snake.
-- Scenario (fully deterministic):
--   reset -> press start -> snake starts at (5,7) heading right, food at (10,7)
--   -> after 5 game ticks the snake eats -> food respawns somewhere else
--      (position comes from a free-running LFSR, so no exact value is pinned)
--   -> score becomes 1 and the seven-segment ones digit shows "1"
--   -> snake keeps going right and hits the wall -> collision -> running stops.
-- Uses VHDL-2008 external names to observe internal top signals.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity top_snake_tb is
end entity;

architecture sim of top_snake_tb is
  constant CLK_PERIOD : time := 10 ns;

  -- scaled-down timing: tick every 100 clocks, debounce 100 clocks, scan every 2
  constant TB_CLK_FREQ : integer := 100_000;
  constant TB_TICK_MS  : integer := 1;
  constant TB_DEB_MS   : integer := 1;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '1';
  signal btn_up, btn_down, btn_left, btn_right, btn_start : std_logic := '0';
  signal seg : std_logic_vector(6 downto 0);
  signal an  : std_logic_vector(3 downto 0);
  signal dp  : std_logic;
  signal vga_r, vga_g, vga_b : std_logic_vector(3 downto 0);
  signal vga_hs, vga_vs : std_logic;
begin
  clk <= not clk after CLK_PERIOD / 2;

  dut : entity work.top_snake
    generic map (
      CLK_FREQ_HZ => TB_CLK_FREQ,
      TICK_MS     => TB_TICK_MS,
      DEBOUNCE_MS => TB_DEB_MS,
      SCAN_DIV    => 2
    )
    port map (
      clk => clk,
      reset => reset,
      btn_up => btn_up,
      btn_down => btn_down,
      btn_left => btn_left,
      btn_right => btn_right,
      btn_start => btn_start,
      seg => seg,
      an => an,
      dp => dp,
      VGA_R => vga_r,
      VGA_G => vga_g,
      VGA_B => vga_b,
      VGA_H_SYNC => vga_hs,
      VGA_V_SYNC => vga_vs
    );

  stim : process
    alias food_x_i    is << signal dut.food_x     : integer range 1 to 18 >>;
    alias food_y_i    is << signal dut.food_y     : integer range 1 to 13 >>;
    alias eat_food_i  is << signal dut.eat_food   : std_logic >>;
    alias score_i     is << signal dut.score      : std_logic_vector(9 downto 0) >>;
    alias running_i   is << signal dut.running_en : std_logic >>;
    alias collision_i is << signal dut.collision  : std_logic >>;
    variable saw_eat : boolean := false;
  begin
    -- 1) reset
    wait for 10 * CLK_PERIOD;
    reset <= '0';
    wait for 10 * CLK_PERIOD;

    assert food_x_i = 10 and food_y_i = 7
      report "initial food position should be (10,7), got (" &
             integer'image(food_x_i) & "," & integer'image(food_y_i) & ")"
      severity failure;
    assert unsigned(score_i) = 0
      report "score should be 0 after reset" severity failure;
    assert running_i = '0'
      report "game should not run before start button" severity failure;

    -- 2) press start (hold long enough for the debouncer, then release)
    btn_start <= '1';
    wait for 150 * CLK_PERIOD;
    btn_start <= '0';
    wait for 150 * CLK_PERIOD;

    assert running_i = '1'
      report "running_en should be 1 after start press" severity failure;

    -- 3) snake head (5,7) moves right once per tick (100 clocks); food at (10,7)
    --    -> eat_food pulse on the 5th tick. Watch up to 8 ticks.
    for i in 1 to 800 loop
      wait until rising_edge(clk);
      if eat_food_i = '1' then
        saw_eat := true;
        exit;
      end if;
    end loop;
    assert saw_eat
      report "snake never ate the food at (10,7)" severity failure;

    -- 4) two clocks later the food register has updated. The spawn position
    --    is sampled from a free-running LFSR, so no exact value is asserted --
    --    only that the food left its old cell and stayed on the board.
    wait for 2 * CLK_PERIOD;
    assert food_x_i /= 10 or food_y_i /= 7
      report "food did not respawn after first eat, still (10,7)"
      severity failure;
    assert food_x_i >= 1 and food_x_i <= 18 and food_y_i >= 1 and food_y_i <= 13
      report "respawned food outside playable area: (" &
             integer'image(food_x_i) & "," & integer'image(food_y_i) & ")"
      severity failure;
    assert unsigned(score_i) = 1
      report "score should be 1 after first eat" severity failure;

    -- 5) seven-segment: ones digit must show "1" (active-low gfedcba = 1111001)
    wait until an = "1110";
    wait for 1 ns;
    assert seg = "1111001"
      report "ones digit should show 1 after first eat" severity failure;
    assert dp = '1'
      report "decimal point should stay off" severity failure;

    -- 6) snake keeps heading right from (10,7): reaches x=18 then hits the wall.
    --    Wait up to 12 more ticks for the collision.
    for i in 1 to 1400 loop
      wait until rising_edge(clk);
      if collision_i = '1' then
        exit;
      end if;
    end loop;
    assert collision_i = '1'
      report "snake should collide with the right wall" severity failure;
    wait for 2 * CLK_PERIOD;
    assert running_i = '0'
      report "game_state should leave RUNNING after collision" severity failure;

    report "TB PASS: top_snake integration (start, eat, score display, wall collision)"
      severity note;
    stop;
  end process;
end architecture;
