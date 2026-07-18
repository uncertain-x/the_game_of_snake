library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.snake_body.all;

entity food_control is
  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    eat       : in  std_logic;
    snake_x   : in  snake_x_array;
    snake_y   : in  snake_y_array;
    snake_len : in  integer range 1 to MAX_SNAKE_LENGTH;
    food_x    : out std_logic_vector(4 downto 0);
    food_y    : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of food_control is
  -- 9-bit maximal-length LFSR (x^9 + x^5 + 1). It free-runs at clk speed:
  -- stepping only on eat would replay the same position sequence every game,
  -- while sampling a free-running LFSR ties each spawn to *when* the player
  -- eats, which is unpredictable.
  signal lfsr : unsigned(8 downto 0) := "101100111";

  type state_t is (idle, draw, scan);
  signal state : state_t := idle;

  signal cand_x : integer range 1 to 18 := 10;
  signal cand_y : integer range 1 to 13 := 7;
  signal j      : integer range 0 to MAX_SNAKE_LENGTH - 1 := 0;

  signal x_reg : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal y_reg : unsigned(3 downto 0) := to_unsigned(7, 4);

  function next_lfsr(value : unsigned(8 downto 0)) return unsigned is
    variable shifted : unsigned(8 downto 0);
  begin
    shifted := value(7 downto 0) & (value(8) xor value(4));
    if shifted = to_unsigned(0, shifted'length) then
      return "101100111";
    end if;
    return shifted;
  end function;
begin
  -- The candidate cell is checked against the snake ONE SEGMENT PER CLOCK
  -- CYCLE. A fully parallel check (234 comparators at once) costs ~6k LUTs
  -- and pushed the Basys-3 past 100% utilisation -- the device is already
  -- ~94% full because of the menu image ROM. Serial costs one comparator
  -- plus one indexed array read and needs at most snake_len cycles per
  -- candidate: worst case 234 probes x 234 cycles = 0.55 ms at 100 MHz,
  -- invisible next to the 150 ms game tick.
  process(clk)
    variable xc : integer range 0 to 31;
    variable yc : integer range 0 to 15;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        lfsr   <= "101100111";
        state  <= idle;
        x_reg  <= to_unsigned(10, x_reg'length);
        y_reg  <= to_unsigned(7, y_reg'length);
      else
        lfsr <= next_lfsr(lfsr);

        case state is
          when idle =>
            if eat = '1' then
              state <= draw;
            end if;

          -- Sample x and y directly from the LFSR bits and reject values
          -- outside the 18 x 13 playfield. This replaces the old
          -- "mod 234 + divide by 18" mapping, which cost a divider.
          when draw =>
            xc := to_integer(lfsr(4 downto 0));
            yc := to_integer(lfsr(8 downto 5));
            if xc >= 1 and xc <= 18 and yc >= 1 and yc <= 13 then
              cand_x <= xc;
              cand_y <= yc;
              j      <= 0;
              state  <= scan;
            end if;

          when scan =>
            if snake_x(j) = cand_x and snake_y(j) = cand_y then
              -- Occupied: step to the next cell (linear probe) and rescan.
              -- The deterministic walk visits every cell, so a free cell is
              -- always found while one exists. The just-eaten cell is held
              -- by the head, so food can never respawn where it was eaten.
              if cand_x < 18 then
                cand_x <= cand_x + 1;
              else
                cand_x <= 1;
                if cand_y < 13 then
                  cand_y <= cand_y + 1;
                else
                  cand_y <= 1;
                end if;
              end if;
              j <= 0;
            elsif j >= snake_len - 1 then
              -- scanned the whole body without a hit: accept
              x_reg <= to_unsigned(cand_x, x_reg'length);
              y_reg <= to_unsigned(cand_y, y_reg'length);
              state <= idle;
            else
              j <= j + 1;
            end if;
        end case;
      end if;
    end if;
  end process;

  food_x <= std_logic_vector(x_reg);
  food_y <= std_logic_vector(y_reg);
end architecture;
