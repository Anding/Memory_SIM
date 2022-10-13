library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


architecture sim of blk_mem_sim is
constant depth_A : integer := (2 ** ADDRWIDTH_A) * NB_COL_A;
constant depth_B : integer := (2 ** ADDRWIDTH_B) * NB_COL_B;
constant zero : std_logic_vector(COL_WIDTH - 1 downto 0) := (others=>'0');
-- 
type RAM_type is array (0 to depth_A - 1) of std_logic_vector(COL_WIDTH - 1 downto 0);

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

signal RAM : RAM_type := init_RAM;			-- init_RAM is called during setup
											-- an incorrect filename will fail at the elaborate stage
begin
	
assert (depth_A = depth_B)
	report "Different memory depths on A and B ports"
	severity failure;

end architecture;

