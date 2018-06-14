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

-- Program Counter signals
signal PCout : std_logic_vector(31 downto 0);

--PC Adder signals
signal PCaddOutput, four : std_logic_vector(31 downto 0);
signal carryout : std_logic;

-- Immediate Adder signals
signal ImmAddOutput, ImmGenOut : std_logic_vector(31 downto 0);
signal carryout2 : std_logic;

-- Adder MUX signals
signal BranchSelect : std_logic;
signal PCMuxOutput : std_logic_vector(31 downto 0);
-- Instruction Memory signals
signal Instruction : std_logic_vector(31 downto 0);

-- Control signals
signal Branch, ImmGenSelect : std_logic_vector(1 downto 0);
signal ALUCtrl : std_logic_vector(4 downto 0);
signal MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite : std_logic;

-- Register Module signals
signal WriteData : std_logic_vector(31 downto 0);
signal ReadData1, ReadData2 : std_logic_vector(31 downto 0);

-- Immediate Generator signals
	-- All signals are already created. ImmGenSelect, Instruction, ImmGenOutput.

-- Register MUX signals
signal RegisterMuxOutput : std_logic_vector(31 downto 0);

-- ALU signals
signal ALUResult : std_logic_vector(31 downto 0);
signal Zero : std_logic;

-- Data Memory Signals
signal DataReadOutput : std_logic_vector(31 downto 0);

-- Data Memory Mux

signal writeRegister : std_logic_vector(4 downto 0);
signal Register1 : std_logic_vector(4 downto 0);
signal Register2 : std_logic_vector(4 downto 0);
begin
	-- Add your code here
	with Branch & Zero select
	BranchSelect <= '1' when "011", -- BEQ and equal
			'1' when "100", -- BNE and not equal
			'0' when others;

	four <= "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0000" & "0100";
	writeRegister <= Instruction(11 downto 7);
	Register1 <= Instruction(19 downto 15);
	Register2 <= Instruction(24 downto 20);
	Programcount : ProgramCounter port map(reset, clock, PCMuxOutput, PCout);
	
	PCadder : adder_subtracter port map(PCout, four, '0', PCaddOutput, carryout);
	
	ImmAdder : adder_subtracter port map(PCout, ImmGenOut, '0', ImmAddOutput, carryout2);
	
	AdderMUX : BusMux2to1 port map(BranchSelect, PCaddOutput, ImmAddOutput, PCMuxOutput);
	
	InstructionMemory : InstructionRAM port map(reset, clock, PCout(31 downto 2), Instruction);

	ControlModule : Control port map(clock, Instruction(6 downto 0), Instruction(14 downto 12), Instruction(31 downto 25), Branch, MemRead, MemtoReg, ALUCtrl, MemWrite, ALUSrc, RegWrite, ImmGenSelect);
	
	RegisterModule : Registers port map(Register1, Register2, writeRegister, WriteData, RegWrite, ReadData1, ReadData2);
	
	ImmediateGenerator : Immgen port map(Instruction, ImmGenSelect, ImmGenOut);
	
	RegisterMUX : BusMux2to1 port map(ALUSrc, ReadData1, ImmGenOut, RegisterMuxOutput);
	
	ProcessorALU : ALU port map (ReadData1, RegisterMuxOutput, ALUCtrl, Zero, ALUResult);
	
	DataMemory : RAM port map(reset, clock, MemRead, MemWrite, ALUResult(31 downto 2), ReadData2, DataReadOutput);
	
	DataMemoryMUX : BusMux2to1 port map(MemtoReg, ALUResult, DataReadOutput, WriteData);
	
end holistic;

