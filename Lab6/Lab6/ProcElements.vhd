--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity ImmGen is
port (Instruction: in std_logic_vector(31 downto 0);
	 Input: in std_logic_vector(1 downto 0);
         Immediate: out std_logic_vector(31 downto 0));
end entity ImmGen;

architecture Generation of ImmGen is
signal SignExtend: std_logic_vector(19 downto 0); 
begin
SignExtend <= Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) &
	      Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) &
	      Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) &
	      Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31) & Instruction(31);

with Input select
Immediate <= SignExtend & Instruction(31 downto 20) when "00", -- Addi, Andi, Ori, BEQ, BNE, LW, Slli or Srli
	     SignExtend & Instruction(31 downto 25) & Instruction(11 downto 7) when "01", -- SW
	     Instruction(31 downto 12) & "000000000000" when "10", -- Lui
	     SignExtend  &Instruction(31) & Instruction(7) & Instruction(30 downto 25) & Instruction(12 downto 9) when "11",
	     "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" when others; 

end Generation;
	    

	 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BusMux2to1 is
	Port(	selector: in std_logic;
			In0, In1: in std_logic_vector(31 downto 0);
			Result: out std_logic_vector(31 downto 0) );
end entity BusMux2to1;

architecture selection of BusMux2to1 is
begin
with selector select
Result <= In0 when '0',
	  In1 when others;

end architecture selection;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
      Port(clk : in  STD_LOGIC;
           opcode : in  STD_LOGIC_VECTOR (6 downto 0);
           funct3  : in  STD_LOGIC_VECTOR (2 downto 0);
           funct7  : in  STD_LOGIC_VECTOR (6 downto 0);
           Branch : out  STD_LOGIC_VECTOR(1 downto 0);
           MemRead : out  STD_LOGIC;
           MemtoReg : out  STD_LOGIC;
           ALUCtrl : out  STD_LOGIC_VECTOR(4 downto 0);
           MemWrite : out  STD_LOGIC;
           ALUSrc : out  STD_LOGIC;
           RegWrite : out  STD_LOGIC;
           ImmGen : out STD_LOGIC_VECTOR(1 downto 0));
end Control;


architecture Boss of Control is
signal  LW, SW, Branching, LUI: std_logic;
begin
-- Add your code here
with opcode select
ALUSrc <= '0' when "0110011", -- Rtype
	  '1' when "0010011", -- Itype
          '1' when "0110111", -- LUI
          '1' when "1100011", -- Btype
          '0' when others;
with opcode select
MemtoReg <= '0' when "0010011", -- Itype
	    '0' when "0110011", -- Rtype
	    '0' when "0110111", -- LUI
            '1' when "0000011", -- LW
	    'Z' when others; -- SW
	    
with opcode & funct3 select
Branch <= "01" when "1100011000", -- BEQ
	  "10" when "1100011001", -- BNE
	  "00" when others;

ALUCtrl <= "00000" when opcode & funct7 & funct3 = "01100110000000000" else -- Add 
	   "00000" when opcode & funct3 = "0010011000" else 		    -- Addi
	   "00001" when opcode & funct7 & funct3 = "01100110100000000" else -- Sub
	   "00010" when opcode & funct7 & funct3 = "01100110000000111" else -- And
	   "00010" when opcode & funct7 & funct3 = "0010011111" else 	    -- Andi
	   "00011" when opcode & funct7 & funct3 = "01100110000000110" else -- Or
	   "00011" when opcode & funct3 = "0010011110" else 	            -- Ori
	   "01000" when opcode & funct7 & funct3 = "01100110000000001" else --Sll
	   "01000" when opcode & funct7 & funct3 = "00100110000000001" else -- Slli
	   "01100" when opcode & funct7 & funct3 = "01100110000000101" else -- Srl
	   "01100" when opcode & funct7 & funct3 = "00100110000000101" else -- Srli
	   "10000" when opcode = "0110111" else
	    "ZZZZZ";

with opcode select
ImmGen <= "00" when "0010011", -- Addi
	  "00" when "0000011", -- LW
	  "01" when "0100011", -- SW
	  "10" when "0110111", -- Lui
	  "11" when "1100011", -- Branching
	  "ZZ" when others;

with opcode select
MemRead <= '1' when "0000011", -- LW
	   '0' when others;

with opcode select
MemWrite <= '1' when "0100011", -- SW
	    '0' when others;

with opcode select
RegWrite <= '1' when "0010011", -- I Type
	    '1' when "0110011", -- R type
	    '1' when "0000011", -- LW
	    '1' when "0110111", -- Lui
	    '0' when others;

end Boss;

--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port(Reset: in std_logic;
	 Clock: in std_logic;
	 PCin: in std_logic_vector(31 downto 0);
	 PCout: out std_logic_vector(31 downto 0));
end entity ProgramCounter;

architecture executive of ProgramCounter is
signal PCNext : std_logic_vector(31 downto 0);
begin
-- Add your code here
	ClockSignal: process(Reset, Clock) is
		begin
		if(Reset = '1') then
			PCout <= "0000" & "0000" & "0100" & "0000" & "0000" & "0000" & "0000" & "0000";
		elsif (rising_edge(clock)) then
			PCout <= PCin;
		end if;
	end process;
end executive;
--------------------------------------------------------------------------------
