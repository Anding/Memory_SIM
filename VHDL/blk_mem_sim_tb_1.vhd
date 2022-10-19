library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;

-- instantiate the memory, including reading the memory file contents
entity blk_mem_sim_tb_1 is
end entity;

architecture testbench of blk_mem_sim_tb_1 is
	
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
  	
begin
	
DUT: entity xil_defaultlib.blk_mem_sim(sim) 
	generic map(
		COL_WIDTH => COL_WIDTH,
		NB_COL_A => NB_COL_A,
		ADDRWIDTH_A	=> ADDRWIDTH_A,
		NB_COL_B => NB_COL_B,
		ADDRWIDTH_B => ADDRWIDTH_B,
		INIT_FILE => "C:\Work\Memory_SIM\Resources\RAM_tb1.txt"
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
	
begin
	wait for 4 * clock_period;
	wait until rising_edge(clk);
	rst <= '0';
	wait for 4 * clock_period;
	report ("*** TEST COMPLETED OK ***");
	test_ok <= true; 
	wait for clock_period;
	std.env.finish;
	
end process;

end architecture;

