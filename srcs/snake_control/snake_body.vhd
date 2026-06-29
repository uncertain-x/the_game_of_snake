----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.06.2026 00:13:30
-- Design Name: 
-- Module Name: snake_body - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package snake_body is
    -- maximum length of snake
    -- 18 x 13 = 234
    constant MAX_SNAKE_LENGTH : integer := 234;

    -- define x and y coordinate
    type snake_x_array is array (0 to MAX_SNAKE_LENGTH - 1) of integer range 1 to 18;
    type snake_y_array is array (0 to MAX_SNAKE_LENGTH - 1) of integer range 1 to 13;
end package snake_body;