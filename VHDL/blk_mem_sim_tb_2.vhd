library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;

entity blk_mem_sim_tb_2 is
end entity;
	
architecture testbench of blk_mem_sim_tb_2 is
	
constant COL_WIDTH : integer := 8;
constant NB_COL_A : integer := 4;
constant ADDRWIDTH_A : integer := 13;
constant NB_COL_B : integer := 1;
constant ADDRWIDTH_B : integer := 15;
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
	
constant MEMORY_A is array (0 to 7) of std_logic_vector(7 downto 0) := 
	x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07";
  	
begin
	
DUT: entity xil_defaultlib.blk_mem_sim(sim) 
	generic map(
		COL_WIDTH => COL_WIDTH,
		NB_COL_A => NB_COL_A,
		ADDRWIDTH_A	=> ADDRWIDTH_A,
		NB_COL_B => NB_COL_B,
		ADDRWIDTH_B => ADDRWIDTH_B,
		INIT_FILE => "C:\Work\Memory_SIM\Resources\RAM.txt"
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

procedure read_MEM_A ( 
	-- read the databus on channel A at a given memory address
	data : out std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
	address : in std_logic_vector(ADDRWIDTH_A - 1 downto 0)
) is
begin
	addr_A <= address;
	wait until rising_edge(clk);
	data <= doutA;
	
end proceduere;

procedure verify_MEM_A ( 
	-- read the databus on channel A at a given memory address with the expected data
	data : in std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
	address : in std_logic_vector(ADDRWIDTH_A - 1 downto 0)
) is
begin
	addr_A <= address;
	wait until rising_edge(clk);
	wait for 1 ps;
	assert data = doutA
		report	"verify bus A failed at address " & to_hstring(address) &
				", expected " & to_hstring(data) & ", obtained " & to_hstring(doutA)
		severity failure;
	
end proceduere;

begin
	wait for 4 * clock_period;
	wait until rising_edge(clk);
	rst <= '0';
	wait until rising_edge(clk);
	
	-- verify memory contents through channel A	
	for i in (0 to Memory_A.top) loop
		verify_MEM_A(Memory_A(i), i);
	end loop;
	
	wait for 1 * clock_period;
	report ("*** TEST COMPLETED OK ***");
	test_ok <= true; 
	wait for clock_period;
	std.env.finish;
	
end process;

end architecture;

