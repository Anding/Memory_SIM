-- UG901 Vivado Synthesis Guide
-- Dual port, byte-selectable read-write, read-first RAM, port B is read-only
-- suitable for asymmetric port widths

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library seed;
use seed.config.all;

entity asym_ram_tdp_read_first_2 is
 generic(
  COL_WIDTH 	: integer := byte_width;
  NB_COL_A		: integer := 1;
  SIZEA			: integer := 1024;
  ADDRWIDTHA	: integer := 32;	-- address width needs to be wide enough for SIZE but may be wider
  NB_COL_B		: integer := 4;		-- no constraint on which port A, B is wider
  SIZEB			: integer := 256;	-- requires that NB_COL_A * SIZEA = NB_COL_B * SIZEB
  ADDRWIDTHB	: integer := 32
 );

 port(
  clkA  : in  std_logic;
  clkB  : in  std_logic;
  enA   : in  std_logic;
  enB   : in  std_logic;
  weA   : in  std_logic_vector(NB_COL_A - 1 downto 0);					-- byte-by-byte write-enable on port A
--web	: in  std_logic_vector(NB_COL_B - 1 downto 0);					-- port B is read-only as explained in the architecture
  addrA : in  std_logic_vector(ADDRWIDTHA - 1 downto 0);				-- addr in units of the COL_WIDTH (not bytes)
  addrB : in  std_logic_vector(ADDRWIDTHB - 1 downto 0);
  diA   : in  std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
--diB   : in  std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0);
  doA   : out std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
  doB   : out std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0)
 );

end asym_ram_tdp_read_first_2;
