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
	     SignExtend & Instruction(31)  & Instruction(30 downto 25) & Instruction(12 downto 9) & Instruction(7) & Instruction(30 downto 25) & Instruction(11 downto 8) when "11",
	     "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" when others; 

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
            '1' when "0000011", -- LW
	    'Z' when others; -- SW
	    
with opcode & funct3 select
Branch <= "01" when "1100011000", -- BEQ
	  "10" when "1100011001", -- BNE
	  "00" when others;


with opcode & funct7  & funct3 select
ALUCtrl <= "00000" when "01100110000000000", -- Add
	   "00000" when "00100110000000000", -- Addi
	   "00001" when "01100110100000000", -- Sub
	   "00010" when "01100110000000111", -- And
	   "00010" when "0010011111XXXXXXX", -- Andi
	   "00011" when "01100110000000110", -- Or
	   "00011" when "0010011XXXXXXX110", -- Ori
	   "01000" when "01100110000000001", --Sll
	   "01000" when "00100110000000001", -- Slli
	   "01100" when "01100110000000101", -- Srl
	   "01100" when "00100110000000101", -- Srli
	    "ZZZZZ" when others;

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
begin
-- Add your code here

end executive;
--------------------------------------------------------------------------------
