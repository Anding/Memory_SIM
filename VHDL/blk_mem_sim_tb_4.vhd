library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library xil_defaultlib;

-- test the memory simulation against Xilinx IP
entity blk_mem_sim_tb_4 is
end entity;

architecture testbench of blk_mem_sim_tb_4 is

constant COL_WIDTH : integer := 8;
constant NB_COL_A : integer := 2;
constant ADDRWIDTH_A : integer := 8;
constant NB_COL_B : integer := 4;
constant ADDRWIDTH_B : integer := 7;
constant depth_A : integer := 2 ** ADDRWIDTH_A;		-- cell depth not byte depth
constant depth_B : integer := 2 ** ADDRWIDTH_B;	
constant clock_freq : natural := 100E6;
constant clock_period : time := 1 sec / clock_freq;
constant half_clock_period : time := clock_period / 2;
constant NUM_WRITES : integer := 250;

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
signal doutA_IP : std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
signal doutB_IP : std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0);
signal doutA_SIM : std_logic_vector(COL_WIDTH * NB_COL_A - 1 downto 0);
signal doutB_SIM : std_logic_vector(COL_WIDTH * NB_COL_B - 1 downto 0);

-- Xilinx IP must be accessed via a COMPONENT		
COMPONENT blk_mem_IP
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(NB_COL_A - 1 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(ADDRWIDTH_A - 1 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(COL_WIDTH * NB_COL_A - 1 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(COL_WIDTH * NB_COL_A - 1 DOWNTO 0);
    clkb : IN STD_LOGIC;
    enb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(NB_COL_B - 1 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(ADDRWIDTH_B - 1  DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(COL_WIDTH * NB_COL_B - 1 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(COL_WIDTH * NB_COL_B - 1 DOWNTO 0)
  );
END COMPONENT;	

begin
	
DUT: entity xil_defaultlib.blk_mem_sim(sim) 
	generic map(
		COL_WIDTH => COL_WIDTH,
		NB_COL_A => NB_COL_A,
		ADDRWIDTH_A	=> ADDRWIDTH_A,
		NB_COL_B => NB_COL_B,
		ADDRWIDTH_B => ADDRWIDTH_B,
		INIT_FILE => ""
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
		doutA => doutA_SIM,
		doutB => doutB_SIM
 );
 	
IP: blk_mem_IP 
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
		doutA => doutA_IP,
		doutB => doutB_IP
 );
 
clk <= not clk after half_clock_period;

sequencer_process : process 
variable i : integer := 0;
variable seed1, seed2 : integer := 999;

-- procedues defined here with access to process variables

procedure verify_MEM_A ( 
	-- read the databus on channel A and match the IP with the simulation
	address : in std_logic_vector(ADDRWIDTH_A - 1 downto 0)
) is
begin
	addrA <= address;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	assert doutA_SIM = doutA_IP
		report	"match bus A failed at address " & to_hstring(address) &
				", IP " & to_hstring(doutA_IP) & ", simulation " & to_hstring(doutA_SIM)
		severity failure;
	
end procedure;


procedure verify_MEM_B ( 
	-- read the databus on channel A and match the IP with the simulation
	address : in std_logic_vector(ADDRWIDTH_B - 1 downto 0)
) is
begin
	addrB <= address;
	wait until rising_edge(clk);
	wait until rising_edge(clk);
	assert doutB_SIM = doutB_IP
		report	"match bus B failed at address " & to_hstring(address) &
				", IP " & to_hstring(doutB_IP) & ", simulation " & to_hstring(doutB_SIM)
		severity failure;
	
end procedure;

-- https://vhdlwhiz.com/random-numbers/
impure function rand_slv(len : integer) return std_logic_vector is
	variable r : real;
	variable slv : std_logic_vector(len - 1 downto 0);
begin
	for i in slv'range loop
    	uniform(seed1, seed2, r);
    	slv(i) := '1' when r > 0.5 else '0';
	end loop;
	return slv;
end function;


begin
	wait for 4 * clock_period;
	wait until rising_edge(clk);
	rst <= '0';
	wait until rising_edge(clk);
		
	-- write randomly on both channels
	for i in 1 to NUM_WRITES loop
		addrA <= rand_slv(ADDRWIDTH_A);
		dinA <= rand_slv(COL_WIDTH * NB_COL_A);
		weA <= rand_slv(NB_COL_A);
		wait until rising_edge(clk);
		weA <= (others =>'0');
		addrB <= rand_slv(ADDRWIDTH_B);
		dinB <= rand_slv(COL_WIDTH * NB_COL_B);
		weB <= rand_slv(NB_COL_B);
		wait until rising_edge(clk);
		weB <= (others =>'0');
	end loop;
	
	-- verify matching memory contents through channel A	
	for i in 0 to depth_A - 1 loop
		verify_MEM_A(std_logic_vector(to_unsigned(i, ADDRWIDTH_A)) );
	end loop;
	
	-- verify matching memory contents through channel B	
	for i in 0 to depth_B - 1 loop
		verify_MEM_B(std_logic_vector(to_unsigned(i, ADDRWIDTH_B)) );
	end loop;
	
	wait until rising_edge(clk);
	report ("*** TEST COMPLETED OK ***");
	test_ok <= true; 
	wait for clock_period;
	std.env.finish;
	
end process;

end architecture;

