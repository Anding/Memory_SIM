library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


architecture sim of blk_mem_sim is
constant depth_A : integer := (2 ** ADDRWIDTH_A) * NB_COL_A;
constant depth_B : integer := (2 ** ADDRWIDTH_B) * NB_COL_B;
-- 
type RAM_type is array (0 to depth_A - 1) of std_logic_vector(COL_WIDTH - 1 downto 0);

-- https://vhdlwhiz.com/initialize-ram-from-file
-- https://vhdlwhiz.com/stimulus-file/
impure function init_RAM return RAM_type is
 	variable RAM_initialized : RAM_type;
 	variable i : integer := 0; 	
	file text_file : text open read_mode is "C:test\RAM.txt";
	variable text_line : line;
 	variable RAM_value : std_ulogic_vector(COL_WIDTH - 1 downto 0);	
	variable ok : boolean;
	
begin
	while not endfile(text_file) loop		-- process each line of the file in turn
    	readline(text_file, text_line);			
    	within_each_line: loop				-- process each value on each line
    		hread(text_line, RAM_value, ok);
    		exit within_each_line when ok = false;
    		RAM_initialize(i) := RAM_value;
    		i := i + 1;
    		assert (i = depth_A)
    			report "Initialization file is deeper than the RAM"
    			severity failure;
    	end loop;
    	
	end loop;
  	return RAM_initialized;
  	
end function;	

signal RAM : RAM_type := init_RAM;			-- init_RAM called at this point
	
begin
	
assert (depth_A = depth_B)
	report "Different memory depths on A and B ports"
	severity failure;

end architecture;

