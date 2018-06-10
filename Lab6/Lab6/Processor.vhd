--------------------------------------------------------------------------------
--
-- LAB #6 - Processor 
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Processor is
    Port ( reset : in  std_logic;
	   clock : in  std_logic);
end Processor;

architecture holistic of Processor is
	component ImmGen is
	     Port (Instruction : in std_logic_vector(31 downto 0);
		   Input : in std_logic_vector(1 downto 0);
                   Immediate: out std_logic_vector(31 downto 0));
	end component;

	component Control
   	     Port( clk : in  STD_LOGIC;
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
	end component;

	component ALU
		Port(DataIn1: in std_logic_vector(31 downto 0);
		     DataIn2: in std_logic_vector(31 downto 0);
		     ALUCtrl: in std_logic_vector(4 downto 0);
		     Zero: out std_logic;
		     ALUResult: out std_logic_vector(31 downto 0) );
	end component;
	
	component Registers
	    Port(ReadReg1: in std_logic_vector(4 downto 0); 
                 ReadReg2: in std_logic_vector(4 downto 0); 
                 WriteReg: in std_logic_vector(4 downto 0);
		 WriteData: in std_logic_vector(31 downto 0);
		 WriteCmd: in std_logic;
		 ReadData1: out std_logic_vector(31 downto 0);
		 ReadData2: out std_logic_vector(31 downto 0));
	end component;

	component InstructionRAM
    	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;

	component RAM 
	    Port(Reset:	  in std_logic;
		 Clock:	  in std_logic;	 
		 OE:      in std_logic;
		 WE:      in std_logic;
		 Address: in std_logic_vector(29 downto 0);
		 DataIn:  in std_logic_vector(31 downto 0);
		 DataOut: out std_logic_vector(31 downto 0));
	end component;
	
	component BusMux2to1
		Port(selector: in std_logic;
		     In0, In1: in std_logic_vector(31 downto 0);
		     Result: out std_logic_vector(31 downto 0) );
	end component;
	
	component ProgramCounter
	    Port(Reset: in std_logic;
		 Clock: in std_logic;
		 PCin: in std_logic_vector(31 downto 0);
		 PCout: out std_logic_vector(31 downto 0));
	end component;

	component adder_subtracter
		port(	datain_a: in std_logic_vector(31 downto 0);
			datain_b: in std_logic_vector(31 downto 0);
			add_sub: in std_logic;
			dataout: out std_logic_vector(31 downto 0);
			co: out std_logic);
	end component adder_subtracter;
signal PCin, PCout, four, PCaddOutput, ImmAddOutput, ImmGenOut, PCaddOutput, ImmAddOutput : std_logic_vector(31 downto 0);
signal Instruction, WriteData , ReadData1 , ReadData2 std_logic_vector(31 downto 0);
signal carryout , carryout2 , BranchSelect , RegWrite , Zero , MemRead , MemWrite , MemtoReg : std_logic;
signal ImmgenSelect , Branch , std_logic_vector(1 downto 0);
begin
	-- Add your code here
	Programcounter : ProgramCounter port map(reset, clock, PCin, PCout);
	PCadder : adder_subtacter port map(PCout, four, '0', PCaddOutput, carryout);
	ImmAdder : adder_subtracter port map(PCout, ImmGenOut, '0', ImmAddOutput, carryout2);
	AdderMUX : BusMux2to1 port map(BranchSelect, PCaddOutput, ImmAddOutput, PCMuxOutput);
	InstructionMemory : InstructionRAM port map(reset, clock, PCout, Instruction);
	RegisterModule : Registers port map(Instruction(19 downto 15), Instruction(24 downto 20), Instruction(11 downto 7), WriteData, RegWrite, ReadData1, ReadData2);
	ImmediateGenerator : Immgen port map(Instruction, ImmGenSelect, ImmGenOut);
	RegisterMUX : BusMux2to1 port map(ALUSrc, ReadData1, ImmGenOutput, RegisterMuxOutput);
	ProcessorALU : ALU(ReadData1, RegisterMuxOutput, ALUCtrl, Zero, ALUResult);
	DataMemory : RAM port map(reset, clock, MemRead, MemWrite,ALUResult(29 downto 0), ReadData2, DataReadOutput);
	DataMemoryMUX : BusMux2to1 port map(MemtoReg, ALUResult, ReadDataOutput, WriteData);
	
end holistic;

