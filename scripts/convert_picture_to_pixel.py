from PIL import Image
import os
import re

WIDTH = 640
HEIGHT = 480

images = [
    "game_start.jpg",
    "game_over.jpg"
]

COE_FILE = "snake_menu_rom_compressed.coe"
VHD_FILE = "snake_menu_rom_compressed.vhd"

# ==========================
# RGB888 -> RGB444
# ==========================
def rgb888_to_rgb444(r, g, b):
    r4 = r >> 4
    g4 = g >> 4
    b4 = b >> 4
    return (r4 << 8) | (g4 << 4) | b4

# ==========================
# Convert image
# ==========================
def convert_image(filename):
    print("Processing:", filename)
    img = Image.open(filename)
    img = img.convert("RGB")
    img = img.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
    
    pixels = []
    for y in range(HEIGHT):
        for x in range(WIDTH):
            r, g, b = img.getpixel((x, y))
            pixel = rgb888_to_rgb444(r, g, b)
            pixels.append(pixel)
    
    return pixels

print("=" * 60)
print("Convert 2 pictures - (game_start + game_over)")
print("=" * 60)

rom = []
for img in images:
    data = convert_image(img)
    rom.extend(data)

total_pixels = len(rom)
print(f"\nTotal pixels: {total_pixels}")
print(f"Number of pictures: {len(images)}")
print(f"Each picture: {WIDTH} x {HEIGHT} = {WIDTH*HEIGHT} pixels")

ADDR_BITS = (total_pixels - 1).bit_length()
print(f"Address width: {ADDR_BITS} bits (0 ~ {total_pixels-1})")

print("\ngenerate COE...")
with open(COE_FILE, "w") as f:
    f.write("memory_initialization_radix=16;\n")
    f.write("memory_initialization_vector=\n")
    
    for i, p in enumerate(rom):
        f.write(f"{p:03X}")
        if i != len(rom) - 1:
            f.write(",\n")
        else:
            f.write(";\n")

print(f"  ✓ {COE_FILE}")

print("\ngenerate VHD...")

with open(VHD_FILE, "w") as f:
    f.write(f"""library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake_menu_rom is
Port(
    clk  : in std_logic;
    addr : in std_logic_vector({ADDR_BITS-1} downto 0);
    data : out std_logic_vector(11 downto 0)
);
end snake_menu_rom;

architecture Behavioral of snake_menu_rom is

type rom_type is array(0 to {total_pixels-1}) of std_logic_vector(11 downto 0);

constant ROM : rom_type := (
""")

    # write data - use index to avoid mismatch
    for i, p in enumerate(rom):
        if i == 0:
            f.write(f"    0 => x\"{p:03X}\"")
        else:
            f.write(f",\n    {i} => x\"{p:03X}\"")

    
    f.write("""
);

begin

process(clk)
begin
    if rising_edge(clk) then
        data <= ROM(to_integer(unsigned(addr)));
    end if;
end process;

end Behavioral;
""")

print(f"  ✓ {VHD_FILE}")

print("\n" + "=" * 60)
print("Verify generated VHD file...")

with open(VHD_FILE, "r") as f:
    content = f.read()
    count = len(re.findall(r'x"[0-9A-Fa-f]{3}"', content))
    
print(f"  Number of data elements in VHD: {count}")
print(f"  Expected number of elements: {total_pixels}")

if count == total_pixels:
    print("  ✅ Number matches! VHD file is correct")
else:
    print(f"  ❌ Error: Expected {total_pixels} elements, actual {count} elements")
    print("  Please check the VHD file generation logic")


total_bits = total_pixels * 12
total_kb = total_bits / 1024
bram_blocks_18k = total_bits / 18432  # each BRAM 18Kb

print(f"\nresource evaluation:")
print(f"  total data: {total_bits:,} bits = {total_kb:.1f} Kb")
print(f"  number of BRAM blocks (18Kb): {bram_blocks_18k:.1f} blocks")
print(f"  Basys3 available BRAM: 90 blocks (1800 Kb)")

if total_kb <= 1800:
    print(f"  ✅ BRAM enough! Usage: {total_kb/1800*100:.1f}%")
else:
    print(f"  ❌ BRAM not enough! Exceeded: {total_kb-1800:.1f} Kb")

print("\n" + "=" * 60)
print("Conversion completed!")