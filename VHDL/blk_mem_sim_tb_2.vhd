library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;

-- instantiate the memory and test initialization with byte-by-byte read on channels A and B
entity blk_mem_sim_tb_2 is
end entity;

architecture testbench of blk_mem_sim_tb_2 is
	
constant COL_WIDTH : integer := 8;
constant NB_COL_A : integer := 1;
constant ADDRWIDTH_A : integer := 4;
constant NB_COL_B : integer := 1;
constant ADDRWIDTH_B : integer := 4;
constant depth_A : integer := 2 ** ADDRWIDTH_A;			-- cell depth not necessarily byte depth
constant clock_freq : natural := 100E6;
constant clock_period : time := 1 sec / clock_freq;
constant half_clock_period : time := clock_period / 2;

signal test_ok : boolean := false;	
signal clk	: std_logic := '1';
signal rst	: std_logic := '1';
signal enA	: std_logic := '1';
signal enB	: std_logic := '1';
signal weA	: std_logic_vector(NB_COL_A - 1 downto 0) := (others=>'0');
signal weB	: std_logic_vector(NB_COL_B - 1 downto 0) := (others=>'0');
signal addrA : std_logic_vector(ADDRWIDTH_A - 1 downto 0) := (others=>'0');
signal addrB : std_logic_vector(ADDRWIDTH_B - 1 downto 0) := (others=>'0');
signal dinA  : std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0) := (others=>'0');
signal dinB  : std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0) := (others=>'0');
signal doutA : std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
signal doutB : std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0);

type RAM_type is array (0 to depth_A - 1) of std_logic_vector(COL_WIDTH - 1 downto 0);	
constant RAM_expected : RAM_type := (
	x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07", 
	x"08", x"09", x"0A", x"0B", x"0C", x"0D", x"0E", x"0F", others => x"00");
  	
begin
	
DUT: entity xil_defaultlib.blk_mem_sim(sim) 
	generic map(
		COL_WIDTH => COL_WIDTH,
		NB_COL_A => NB_COL_A,
		ADDRWIDTH_A	=> ADDRWIDTH_A,
		NB_COL_B => NB_COL_B,
		ADDRWIDTH_B => ADDRWIDTH_B,
		INIT_FILE => "C:\Work\Memory_SIM\Resources\RAM_tb2.txt"
 )
 	port map(
		clkA => clk,
		clkB => clk,
		enA => enA,
		enB => enB,
		weA => weA,
		weB => weB,
		addrA => addrA,
		addrB => addrB,
		dinA => dinA,
		dinB => dinB,
		doutA => doutA,
		doutB => doutB
 );
 	
clk <= not clk after half_clock_period;

sequencer_process : process 
variable i : integer := 0;

-- procedues defined here with access to process variables

procedure verify_MEM_A ( 
	-- read the databus on channel A at a given memory address with the expected data
	data : in std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
	address : in std_logic_vector(ADDRWIDTH_A - 1 downto 0)
) is
begin
	addrA <= address;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	assert data = doutA
		report	"verify bus A failed at address " & to_hstring(address) &
				", expected " & to_hstring(data) & ", obtained " & to_hstring(doutA)
		severity failure;
	
end procedure;


procedure verify_MEM_B ( 
	-- read the databus on channel A at a given memory address with the expected data
	data : in std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0);
	address : in std_logic_vector(ADDRWIDTH_B - 1 downto 0)
) is
begin
	addrB <= address;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	assert data = doutB
		report	"verify bus B failed at address " & to_hstring(address) &
				", expected " & to_hstring(data) & ", obtained " & to_hstring(doutB)
		severity failure;
	
end procedure;

begin
	wait for 4 * clock_period;
	wait until rising_edge(clk);
	rst <= '0';
	wait until rising_edge(clk);
	
	-- verify memory contents through channel A	
	for i in RAM_expected'range loop
		verify_MEM_A(RAM_expected(i), std_logic_vector(to_unsigned(i, ADDRWIDTH_A)) );
	end loop;
	
	
	-- verify memory contents through channel B	
	for i in RAM_expected'range loop
		verify_MEM_B(RAM_expected(i), std_logic_vector(to_unsigned(i, ADDRWIDTH_B)) );
	end loop;
	
	wait until rising_edge(clk);
	report ("*** TEST COMPLETED OK ***");
	test_ok <= true; 
	wait for clock_period;
	std.env.finish;
	
end process;

end architecture;

