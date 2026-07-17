library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;
library work;
use work.snake_body.all;

entity food_control_tb is
end entity;

architecture sim of food_control_tb is
  constant CLK_PERIOD : time := 10 ns;
  -- worst-case search is one full walk of the 8-bit LFSR (255 states)
  constant SEARCH_CYCLES : natural := 300;
  constant EAT_ROUNDS    : natural := 20;

  -- fake snake: rows y=1..6 fully occupied (108 cells) + slot 108 holds the
  -- "head" that sits on the just-eaten food cell
  constant BLOCK_CELLS : natural := 108;
  constant HEAD_SLOT   : natural := BLOCK_CELLS;

  signal clk    : std_logic := '0';
  signal reset  : std_logic := '1';
  signal eat    : std_logic := '0';
  signal food_x : std_logic_vector(4 downto 0);
  signal food_y : std_logic_vector(3 downto 0);

  signal snake_x_sig   : snake_x_array := (others => 0);
  signal snake_y_sig   : snake_y_array := (others => 0);
  signal snake_len_sig : integer range 1 to MAX_SNAKE_LENGTH := 1;

  procedure assert_inside_play_area(
    constant x_value : in std_logic_vector(4 downto 0);
    constant y_value : in std_logic_vector(3 downto 0);
    constant tag     : in string
  ) is
    variable x_int : natural;
    variable y_int : natural;
  begin
    x_int := to_integer(unsigned(x_value));
    y_int := to_integer(unsigned(y_value));
    assert x_int >= 1 and x_int <= 18
      report tag & ": x outside playable area"
      severity failure;
    assert y_int >= 1 and y_int <= 13
      report tag & ": y outside playable area"
      severity failure;
  end procedure;
begin
  clk <= not clk after CLK_PERIOD / 2;

  dut : entity work.food_control
    port map (
      clk       => clk,
      reset     => reset,
      eat       => eat,
      snake_x   => snake_x_sig,
      snake_y   => snake_y_sig,
      snake_len => snake_len_sig,
      food_x    => food_x,
      food_y    => food_y
    );

  stim : process
    variable prev_x   : std_logic_vector(4 downto 0);
    variable prev_y   : std_logic_vector(3 downto 0);
    variable x_int    : natural;
    variable y_int    : natural;
    variable on_snake : boolean;
  begin
    -- occupy rows y=1..6 completely so roughly half the board is snake
    for i in 0 to BLOCK_CELLS - 1 loop
      snake_x_sig(i) <= 1 + (i mod 18);
      snake_y_sig(i) <= 1 + (i / 18);
    end loop;
    snake_len_sig <= BLOCK_CELLS + 1;

    wait for 5 * CLK_PERIOD;
    reset <= '0';
    wait until rising_edge(clk);

    prev_x := food_x;
    prev_y := food_y;
    assert_inside_play_area(food_x, food_y, "initial food");

    wait for 5 * CLK_PERIOD;
    assert food_x = prev_x and food_y = prev_y
      report "food changed without eat pulse"
      severity failure;

    for round in 1 to EAT_ROUNDS loop
      -- the head that just ate now occupies the old food cell
      snake_x_sig(HEAD_SLOT) <= to_integer(unsigned(food_x));
      snake_y_sig(HEAD_SLOT) <= to_integer(unsigned(food_y));
      prev_x := food_x;
      prev_y := food_y;

      eat <= '1';
      wait until rising_edge(clk);
      eat <= '0';

      -- allow the search to finish even in the worst case
      for c in 1 to SEARCH_CYCLES loop
        wait until rising_edge(clk);
      end loop;

      assert_inside_play_area(food_x, food_y,
        "food after eat " & integer'image(round));

      assert food_x /= prev_x or food_y /= prev_y
        report "food respawned on the just-eaten cell (round "
               & integer'image(round) & ")"
        severity failure;

      x_int := to_integer(unsigned(food_x));
      y_int := to_integer(unsigned(food_y));
      on_snake := false;
      for i in 0 to HEAD_SLOT loop
        if snake_x_sig(i) = x_int and snake_y_sig(i) = y_int then
          on_snake := true;
        end if;
      end loop;
      assert not on_snake
        report "food spawned on the snake body (round "
               & integer'image(round) & ")"
        severity failure;

      wait for 5 * CLK_PERIOD;
      assert food_x'stable(5 * CLK_PERIOD)
        report "food kept moving after the search settled (round "
               & integer'image(round) & ")"
        severity failure;
    end loop;

    assert false
      report "TB PASS: food stays playable, moves on eat, never lands on the snake"
      severity note;
    stop;
  end process;
end architecture;
