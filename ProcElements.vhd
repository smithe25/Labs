--------------------------------------------------------------------------------
--
-- LAB #6 - Processor Elements
--
--------------------------------------------------------------------------------
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
-- Add your code here
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

signal Math, Mathi, LW, SW, Branch, LUI: std_logic;
architecture Boss of Control is
begin
-- Add your code here
with opcode select
Math <= '1' when "0110011",
	'0' when others;

with opcode select
Mathi <= '1' when "0010011",
	 '0' when others;

with opcode select
LW <= '1' when "0000011",
      '0' when others;

with opcode select
SW <= '1' when "0100011",
      '0' when others;

with opcode select
Branch <= '1' when "1100011",
	  '0' when others;

with opcode select
LUI <= '1' when "0110111",
       '0' when others;

with opcode & funct7  & funct3 select
ALUCtrl <= "00000" when "01100110000000000", -- Add
	   "00001" when "01100110100000000", -- Sub
	   "00010" when "01100110000000111", -- And
	   "00011" when "01100110000000110", -- Or
	   "01000" when                      -- Sll
					     -- Slli
					     -- Srl
					     -- Srli


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
