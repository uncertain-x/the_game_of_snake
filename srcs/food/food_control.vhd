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
  signal lfsr      : unsigned(7 downto 0) := x"A5";
  signal x_reg     : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal y_reg     : unsigned(3 downto 0) := to_unsigned(7, 4);
  signal searching : std_logic := '0';

  function next_lfsr(value : unsigned(7 downto 0)) return unsigned is
    variable feedback : std_logic;
    variable shifted  : unsigned(7 downto 0);
  begin
    feedback := value(7) xor value(5) xor value(4) xor value(3);
    shifted := value(6 downto 0) & feedback;
    if shifted = to_unsigned(0, shifted'length) then
      return x"A5";
    end if;
    return shifted;
  end function;
begin
  process(clk)
    variable idx      : integer range 0 to 233;
    variable cand_x   : integer range 1 to 18;
    variable cand_y   : integer range 1 to 13;
    variable on_snake : boolean;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        lfsr      <= x"A5";
        x_reg     <= to_unsigned(10, x_reg'length);
        y_reg     <= to_unsigned(7, y_reg'length);
        searching <= '0';
      else
        -- The LFSR free-runs at clk speed instead of stepping once per eat.
        -- Stepping only on eat replays the exact same position sequence every
        -- game; sampling a free-running LFSR ties each spawn to *when* the
        -- player eats (millions of cycles apart), which is unpredictable.
        lfsr <= next_lfsr(lfsr);

        -- A candidate position is only accepted if it does not overlap the
        -- snake. On a hit we keep searching, one candidate per clock cycle;
        -- the maximal-length LFSR walks all 255 states, so every one of the
        -- 234 board cells is tried within 255 cycles (2.55 us at 100 MHz),
        -- invisible at game speed. Until then the old position is held.
        if eat = '1' or searching = '1' then
          idx := to_integer(lfsr) mod 234;
          cand_x := 1 + (idx mod 18);
          cand_y := 1 + (idx / 18);

          on_snake := false;
          for i in 0 to MAX_SNAKE_LENGTH - 1 loop
            if i < snake_len then
              if snake_x(i) = cand_x and snake_y(i) = cand_y then
                on_snake := true;
              end if;
            end if;
          end loop;

          if on_snake then
            searching <= '1';
          else
            x_reg     <= to_unsigned(cand_x, x_reg'length);
            y_reg     <= to_unsigned(cand_y, y_reg'length);
            searching <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  food_x <= std_logic_vector(x_reg);
  food_y <= std_logic_vector(y_reg);
end architecture;
