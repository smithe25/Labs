--------------------------------------------------------------------------------
--
-- LAB #4
--
--------------------------------------------------------------------------------

Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity ALU is
	Port(	DataIn1: in std_logic_vector(31 downto 0);
		DataIn2: in std_logic_vector(31 downto 0);
		ALUCtrl: in std_logic_vector(4 downto 0);
		Zero: out std_logic;
		ALUResult: out std_logic_vector(31 downto 0) );
end entity ALU;

architecture ALU_Arch of ALU is
	-- ALU components	
	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;

	component shift_register
		port(	datain: in std_logic_vector(31 downto 0);
		   	dir: in std_logic;
			shamt:	in std_logic_vector(4 downto 0);
			dataout: out std_logic_vector(31 downto 0));
	end component shift_register;

Signal addResult, shiftData, shiftResult, andResult, orResult : std_logic_vector(31 downto 0);
Signal bitComparison : std_logic_vector(1 downto 0);
Signal carryOut : std_logic;
begin
with ALUCtrl select
shiftData <= DataIn1 when "01XXX",
	     DataIn2 when others;

with ALUCtrl select
	ALUResult <= 	addResult when "0000X",
			andResult when "00010",
			orResult when "00011",
		       shiftResult when "X1XXX",
			DataIn2 when "10000",
			"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others;



Adder : adder_subtracter port map (DataIn1, DataIn2, ALUCtrl(0), addResult, carryOut);
Shift : shift_register port map (shiftData, ALUCtrl(2), ALUCtrl, shiftResult);
andResult <= DataIn1 AND DataIn2;
orResult <= DataIn1 AND DataIn2;

-- for i in 31 downto 0 loop
--bitComparison <= DataIn1(i) & DataIn2(i);
--with bitComparison select
	--andResult(i) <= '1' when "11",
		--        '0' when others;

--with bitComparison select
	--orResult(i) <= '1' when "01",
		--       '1' when "10",
		  --     '0' when others;
--end loop;
			
	-- Add ALU VHDL implementation here

end architecture ALU_Arch;


