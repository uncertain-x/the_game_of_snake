library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity food_control is
  port (
    clk    : in  std_logic;
    reset  : in  std_logic;
    eat    : in  std_logic;
    food_x : out std_logic_vector(4 downto 0);
    food_y : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of food_control is
  signal lfsr  : unsigned(7 downto 0) := x"A5";
  signal x_reg : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal y_reg : unsigned(3 downto 0) := to_unsigned(7, 4);

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
    variable idx : integer range 0 to 233;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        lfsr  <= x"A5";
        x_reg <= to_unsigned(10, x_reg'length);
        y_reg <= to_unsigned(7, y_reg'length);
      else
        -- The LFSR free-runs at clk speed instead of stepping once per eat.
        -- Stepping only on eat replays the exact same position sequence every
        -- game; sampling a free-running LFSR ties each spawn to *when* the
        -- player eats (millions of cycles apart), which is unpredictable.
        lfsr <= next_lfsr(lfsr);
        if eat = '1' then
          idx := to_integer(lfsr) mod 234;
          x_reg <= to_unsigned(1 + (idx mod 18), x_reg'length);
          y_reg <= to_unsigned(1 + (idx / 18), y_reg'length);
        end if;
      end if;
    end if;
  end process;

  food_x <= std_logic_vector(x_reg);
  food_y <= std_logic_vector(y_reg);
end architecture;
