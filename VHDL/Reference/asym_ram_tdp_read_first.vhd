-- asymmetric port RAM
-- adapted from the Xilinx template in UG901 Vivado Synthesis Examples
-- THIS VERSION IS THE ORIGINAL XILINX TEMPLATE WHICH LACKS COL_WIDTH IN BYTES AND BYTE-BY-BYTE WRITE ENABLE

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity asym_ram_tdp_read_first is
 generic(
  WIDTHA     : integer := 4;
  SIZEA      : integer := 1024;
  ADDRWIDTHA : integer := 10;
  WIDTHB     : integer := 16;
  SIZEB      : integer := 256;
  ADDRWIDTHB : integer := 8
 );

 port(
  clkA  : in  std_logic;
  clkB  : in  std_logic;
  enA   : in  std_logic;
  enB   : in  std_logic;
  weA   : in  std_logic;
  weB   : in  std_logic;
  addrA : in  std_logic_vector(ADDRWIDTHA - 1 downto 0);
  addrB : in  std_logic_vector(ADDRWIDTHB - 1 downto 0);
  diA   : in  std_logic_vector(WIDTHA - 1 downto 0);
  diB   : in  std_logic_vector(WIDTHB - 1 downto 0);
  doA   : out std_logic_vector(WIDTHA - 1 downto 0);
  doB   : out std_logic_vector(WIDTHB - 1 downto 0)
 );

end asym_ram_tdp_read_first;

architecture behavioral of asym_ram_tdp_read_first is
 function max(L, R : INTEGER) return INTEGER is
 begin
  if L > R then
   return L;
  else
   return R;
  end if;
 end;

 function min(L, R : INTEGER) return INTEGER is
 begin
  if L < R then
   return L;
  else
   return R;
  end if;
 end;

 function log2(val : INTEGER) return natural is
  variable res : natural;
 begin
  for i in 0 to 31 loop
   if (val <= (2 ** i)) then
    res := i;
    exit;
   end if;
  end loop;
  return res;
 end function Log2;

 constant minWIDTH : integer := min(WIDTHA, WIDTHB);
 constant maxWIDTH : integer := max(WIDTHA, WIDTHB);
 constant maxSIZE  : integer := max(SIZEA, SIZEB);
 constant RATIO    : integer := maxWIDTH / minWIDTH;

 -- An asymmetric RAM is modeled in a similar way as a symmetric RAM, with an
 -- array of array object. Its aspect ratio corresponds to the port with the
 -- lower data width (larger depth)
 type ramType is array (0 to maxSIZE - 1) of std_logic_vector(minWIDTH - 1 downto 0);

 signal my_ram : ramType := (others => (others => '0'));

 signal readA : std_logic_vector(WIDTHA - 1 downto 0) := (others => '0');
 signal readB : std_logic_vector(WIDTHB - 1 downto 0) := (others => '0');
 signal regA  : std_logic_vector(WIDTHA - 1 downto 0) := (others => '0');
 signal regB  : std_logic_vector(WIDTHB - 1 downto 0) := (others => '0');

begin
 process(clkA)
 begin
  if rising_edge(clkA) then
   if enA = '1' then
    readA <= my_ram(conv_integer(addrA));
    if weA = '1' then
     my_ram(conv_integer(addrA)) <= diA;
    end if;
   end if;
   regA <= readA;
  end if;
 end process;

 process(clkB)
 begin
  if rising_edge(clkB) then
   for i in 0 to RATIO - 1 loop
    if enB = '1' then
     readB((i + 1) * minWIDTH - 1 downto i * minWIDTH) <= my_ram(conv_integer(addrB & conv_std_logic_vector(i, log2(RATIO))));
     if weB = '1' then
      my_ram(conv_integer(addrB & conv_std_logic_vector(i, log2(RATIO)))) <= diB((i + 1) * minWIDTH - 1 downto i * minWIDTH);
     end if;
    end if;
   end loop;
   regB <= readB;
  end if;
 end process;

 doA <= regA;
 doB <= regB;

end behavioral;
