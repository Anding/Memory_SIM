library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity blk_mem_sim is
 generic(
  COL_WIDTH 	: integer := 8;		-- always 8 bits for one byte
  NB_COL_A		: integer := 4;		-- width of the COL_A data_bus in BYTES
  ADDRWIDTH_A	: integer := 13;  	-- width of the COL_A address_bus in BITS
  									-- compute as log2(capacity_in_bytes / NB_COL), e.g. log2(32768 / 4) = 13
  NB_COL_B		: integer := 1;
  ADDRWIDTH_B	: integer := 15;  	-- e.g. log2(32768 / 1) = 15
  INIT_FILE		: string  := ""		-- e.g. "C:\Work\Memory_SIM\Resources\RAM.txt", or "" for no initialization file
 );

 port(
  clkA  : in  std_logic;
  clkB  : in  std_logic;
  enA   : in  std_logic;
  enB   : in  std_logic;
  weA   : in  std_logic_vector(NB_COL_A - 1 downto 0);					-- byte write-enable
  weB	: in  std_logic_vector(NB_COL_B - 1 downto 0);
  addrA : in  std_logic_vector(ADDRWIDTH_A - 1 downto 0);				-- cell address (not necessarily byte address)
  addrB : in  std_logic_vector(ADDRWIDTH_B - 1 downto 0);
  dinA   : in  std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
  dinB   : in  std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0);
  doutA   : out std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
  doutB   : out std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0)
 );

end entity;

