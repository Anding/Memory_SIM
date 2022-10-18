library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


architecture sim of blk_mem_sim is
constant depth_A : integer := (2 ** ADDRWIDTH_A) * NB_COL_A;
constant depth_B : integer := (2 ** ADDRWIDTH_B) * NB_COL_B;
constant zero : std_logic_vector(COL_WIDTH - 1 downto 0) := (others=>'0');
type RAM_type is array (0 to depth_A - 1) of std_logic_vector(COL_WIDTH - 1 downto 0);

-- Initialize the RAM from a text file
-- https://vhdlwhiz.com/initialize-ram-from-file
-- https://vhdlwhiz.com/stimulus-file/
-- https://vhdlguide.com/2017/09/22/textio/
impure function init_RAM return RAM_type is	
 	variable RAM_initialized : RAM_type := (others => zero);   		-- this will be the return value
  	variable RAM_value : std_ulogic_vector(COL_WIDTH - 1 downto 0);	-- hread( ) works with std_ulogic_vector	
	file text_file : text;											-- textio utility type
	variable text_line : line;										-- textio utility type
 	variable i : integer := 0; 
	variable ok : boolean;
	
begin
	if init_file /= "" then							-- only initialize if a filename is given
		file_open(text_file, init_file, read_mode);
		while not endfile(text_file) loop			-- process each line of the file in turn
	    	readline(text_file, text_line);			
	    	within_each_line: loop					-- process each value on each line
	    		hread(text_line, RAM_value, ok);
	    		exit within_each_line when ok = false;
	    		RAM_initialized(i) := RAM_value;	-- std_ulogic may be assigned to std_logic
	    		i := i + 1;
	    		assert (i = depth_A)
	    			report "Initialization file is deeper than the RAM"
	    			severity failure;
	    	end loop;
	    	
		end loop;
		file_close(text_file);
	end if;
  	return RAM_initialized;
  	
end function;	

-- Log2() function
-- Xilinix template
function log2(depth : INTEGER) return natural is
	variable res : natural;
begin
	for i in 0 to 31 loop				
 		if (depth <= (2 ** i)) then
   			res := i;
   			exit;
  		end if;
	end loop;
	return res;
end function log2;

signal RAM : RAM_type := init_RAM;			-- init_RAM is called during setup
											-- an incorrect filename will fail at the elaborate stage
begin
	
assert (depth_A = depth_B)																	-- simulation only assert in a process statement
	report "Different memory depths on A and B ports"
	severity failure;
	
 port_A : process
 variable addrLo : unsigned(log2(NB_COL_A) - 1 downto 0);								-- the address on port addrA is a cell address
 variable addrFull : unsigned(ADDRWIDTH_A + log2(NB_COL_A) - 1 downto 0);					-- these variables will stepwise compute the byte address as an integer
 variable addrInt : integer;
 variable hiBitBus, loBitBus : integer;

 begin
  wait until rising_edge(clkA);
   if enA = '1' then
		for i in 0 to NB_COL_A - 1 loop														-- iterate over each byte of the databus
   			addrLo  := to_unsigned(i, log2(NB_COL_A));										-- the full address incorporates the databus address and the current byte number
   			addrFull := unsigned(addrA) & addrLo;												-- join unsigned types with & rather than integers with a + b * 2^n, which doesn't synthesize
   			addrInt := to_integer(addrFull);													-- now convert to integer type for array look-up
   			hiBitBus := (i + 1) * COL_WIDTH - 1;												-- bit positions on the bus
   			loBitBus := i * COL_WIDTH;
     		doutA(hiBitBus downto loBitBus) <= RAM(addrInt);

	    	if weA(i) = '1' then	     													-- byte write-enable on port A
     			RAM(addrInt) <= dinA(hiBitBus downto loBitBus);
     		end if;
		end loop;

   end if;
 end process;

end architecture;

