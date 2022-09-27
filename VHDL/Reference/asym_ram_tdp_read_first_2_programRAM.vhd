-- UG901 Vivado Synthesis Guide
-- Dual port, byte-selectable read-write, read-first RAM, port B is read-only
-- suitable for asymmetric port widths
-- all-zero memory initialization

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library seed;
use seed.constants.all;
use seed.functions.all;
use seed.config.all;


architecture programRAM of asym_ram_tdp_read_first_2 is

 -- programRAM (dictionary space) is always byte-width internally
 type ramType is array (0 to program_memory_address_top) of std_logic_vector(byte_width - 1 downto 0); 
 	
 -- MEMORY INITIALIZATION HERE
 signal my_ram : ramType := (
 	oNOOP, oLITB, x"12", x"40", x"07", oHALT, oHALT, oHALT, 
	oHALT, oHALT, oHALT, oLITB, x"13", oLITW, x"ab", x"cd",
	x"40", oHALT, oHALT, oLITL, x"12", x"34", x"56", x"78",
	x"40", x"07", oHALT, oHALT, x"40", x"05", oHALT, oHALT,	
	x"7f", x"fb", oLITB, x"14", oNOOP, oNOOP, oNOOP, oNOOP,	-- end of unconditional branch and literal testing
	x"c0", x"01", oLITB, x"21", oNOOP, oNOOP, oNOOP, oNOOP,	-- nest into a nested subroutine
	x"e0", x"01", oLITB, x"22", oNOOP, oNOOP, oNOOP, oNOOP,	-- catch into a nested subroutine
	x"e0", x"03", oLITB, x"23", oNOOP, oNOOP, oNOOP, oNOOP, -- nest into a nested subroutine with throw 0
	x"e0", x"05", oLITB, x"24", oNOOP, oNOOP, oNOOP, oNOOP,	
	oLITB, x"ff", oLITB, oNOOP, x"80", x"03", oHALT, oNOOP,	-- conditional branch testing
	oLITB, x"07", oNOOP, oNOOP, oNOOP, oEXEC, oNOOP, oNOOP, -- execute testing
	oLITB, x"08", oNOOP, oSMUL, oLITB, x"09", oNOOP, oNOOP,	
	oHALT, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,	
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,	
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,	
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,		
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,	
	oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,	
	oLITB, x"a1", x"c0", x"02", oLITB, x"e1", oUNST, oHALT,	-- 160
	oLITB, x"a2", oNOOP, oNOOP, oLITB, x"e2", oUNST, oHALT, -- 168
	oLITB, x"a3", x"c0", x"04", oLITB, x"e3", oUNST, oHALT,	-- 176
	oLITB, x"00", oNOOP, oNOOP, oTHRW, oLITB, x"e4", oUNST,	-- 184
	oLITB, x"a5", x"c0", x"06", oLITB, x"e5", oUNST, oHALT,	-- 192
	oLITB, x"a6", oNOOP, oNOOP, oTHRW, oLITB, x"e6", oUNST,	-- 200
	oLITB, x"a7", oUNST, oNOOP, oNOOP, oNOOP, oNOOP, oNOOP,	-- 208
	others => oNOOP
 );		-- copy-paste initializaton from program_memory_A of control_unit_test_data.vhd
 
begin

 process
 variable addrLo : unsigned(log2(NB_COL_A, 0) - 1 downto 0);									-- these variables to compute the bus assignment in steps.  Commented below
 variable addrFull : unsigned(ADDRWIDTHA + log2(NB_COL_A, 0) - 1 downto 0);
 variable addrInt : integer;
 variable hiBitBus, loBitBus : integer;

 begin
  wait until rising_edge(clkA);
   if enA = '1' then
		for i in 0 to NB_COL_A - 1 loop														-- iterate over each byte of the databus
   			addrLo  := to_unsigned(i, log2(NB_COL_A, 0));										-- the full address incorporates the databus address and the current byte number
   			addrFull := unsigned(addrA) & addrLo;											-- join unsigned types with & rather than integers with a + b * 2^n, which doesn't synthesize
   			addrInt := to_integer(addrFull);												-- now convert to integer type for array look-up
   			hiBitBus := (i + 1) * COL_WIDTH - 1;											-- bit positions on the bus
   			loBitBus := i * COL_WIDTH;
     		doA(hiBitBus downto loBitBus) <= my_ram(addrInt);

	    	if weA(i) = '1' then	     													-- byte write-enable on port A
     			my_ram(addrInt) <= diA(hiBitBus downto loBitBus);
     		end if;
		end loop;

   end if;
 end process;

 process
 variable addrLo : unsigned(log2(NB_COL_B, 0) - 1 downto 0);
 variable addrFull : unsigned(ADDRWIDTHB + log2(NB_COL_B, 0) - 1 downto 0);
 variable addrInt : integer;
 variable hiBitBus, loBitBus : integer;
 begin
  wait until rising_edge(clkB);
   if enB = '1' then
		for i in 0 to NB_COL_B - 1 loop
   			addrLo  := to_unsigned(i, log2(NB_COL_B, 0));
   			addrFull := unsigned(addrB) & addrLo;
   			addrInt := to_integer(addrFull);
   			hiBitBus := (i + 1) * COL_WIDTH - 1;
   			loBitBus := i * COL_WIDTH;
     		doB(hiBitBus downto loBitBus) <= my_ram(addrInt);

     		-- byte-enable write on both ports cannot be synthesized
     		-- ERROR: [Synth 8-2913] Unsupported Dual Port Block-RAM template for my_ram_reg
     		-- if weB(i) = '1' then
     		--	my_ram(addrInt) <= diB(hiBitBus downto loBitBus);
     		-- end if;
		end loop;

	end if;
 end process;

end architecture;
