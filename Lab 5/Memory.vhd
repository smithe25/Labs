--------------------------------------------------------------------------------
--
-- LAB #5 - Memory and Register Bank
--
--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;
entity bitstorage is
	port(bitin: in std_logic;
		 enout: in std_logic;
		 writein: in std_logic;
		 bitout: out std_logic);
end entity bitstorage;

architecture memlike of bitstorage is
	signal q: std_logic := '0';
begin
	process(writein) is
	begin
		if (rising_edge(writein)) then
			q <= bitin;
		end if;
	end process;
	
	-- Note that data is output only when enout = 0	
	bitout <= q when enout = '0' else 'Z';
end architecture memlike;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity fulladder is
    port (a : in std_logic;
          b : in std_logic;
          cin : in std_logic;
          sum : out std_logic;
          carry : out std_logic
         );
end fulladder;

architecture addlike of fulladder is
begin
  sum   <= a xor b xor cin; 
  carry <= (a and b) or (a and cin) or (b and cin); 
end architecture addlike;


--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register8 is
	port(datain: in std_logic_vector(7 downto 0);
	     enout:  in std_logic;
	     writein: in std_logic;
	     dataout: out std_logic_vector(7 downto 0));
end entity register8;

architecture memmy of register8 is
	component bitstorage
		port(bitin: in std_logic;
		 	 enout: in std_logic;
		 	 writein: in std_logic;
		 	 bitout: out std_logic);
	end component;
begin
	inst : for i in 7 downto 0 generate
	A: bitstorage port map(datain(i), enout, writein, dataout(i));
	end generate;

end architecture memmy;

--------------------------------------------------------------------------------
Library ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity register32 is
	port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
end entity register32;

architecture biggermem of register32 is
	-- hint: you'll want to put register8 as a component here 
	-- so you can use it below
	component register8
		port(datain: in std_logic_vector(7 downto 0);
		     enout: in std_logic;
		     writein: in std_logic;
		     dataout: out std_logic_vector(7 downto 0));
end component;
	Signal write8, write16, enable8, enable16 : std_logic := '0';
begin
	-- insert code here.
	U1 : register8 port map (datain(7 downto 0), enable8, write8, dataout(7 downto 0));
	U2 : register8 port map (datain(15 downto 8), enable16, write16, dataout(15 downto 8));
	U3 : register8 port map (datain(23 downto 16), enout32, writein32, dataout(23 downto 16));
	U4 : register8 port map (datain(31 downto 24), enout32, writein32, dataout(31 downto 24));

	write8 <= writein32 OR writein16 OR writein8;
	write16 <= writein32 OR writein16;

	enable8 <= enout32 AND enout16 AND enout8;
	enable16 <= enout32 AND enout16;


	end architecture biggermem;
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity RAM is
    Port(Reset:	  in std_logic;
	 Clock:	  in std_logic;	 
	 OE:      in std_logic;
	 WE:      in std_logic;
	 Address: in std_logic_vector(29 downto 0);
	 DataIn:  in std_logic_vector(31 downto 0);
	 DataOut: out std_logic_vector(31 downto 0));
end entity RAM;

architecture staticRAM of RAM is

   type ram_type is array (0 to 127) of std_logic_vector(31 downto 0);
   signal i_ram : ram_type;
   signal addressInteger : integer;
   signal outOfBounds : std_logic_vector(31 downto 0);
begin
  outOfBounds <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
  addressInteger <= to_integer(unsigned(Address));
  RamProc: process(Clock, Reset, OE, WE, Address) is

  begin
    if Reset = '1' then
      for i in 0 to 127 loop   
          i_ram(i) <= X"00000000";
      end loop;
    end if;

    if(OE = '0') then
	if(addressInteger <= 127) then
	DataOut <= i_ram(addressInteger);
    	else
	DataOut <= outOfBounds;
	end if;
    end if;

    if falling_edge(Clock) then
	if(WE = '1' AND addressInteger <= 127) then
		i_ram(addressInteger) <= DataIn;
	-- Add code to write data to RAM
	-- Use to_integer(unsigned(Address)) to index the i_ram array
    end if;
    end if;

	-- Rest of the RAM implementation

  end process RamProc;

end staticRAM;	

--------------------------------------------------------------------------------
LIBRARY ieee;
Use ieee.std_logic_1164.all;
Use ieee.numeric_std.all;
Use ieee.std_logic_unsigned.all;

entity Registers is
    Port(ReadReg1: in std_logic_vector(4 downto 0); 
         ReadReg2: in std_logic_vector(4 downto 0); 
         WriteReg: in std_logic_vector(4 downto 0);
	 WriteData: in std_logic_vector(31 downto 0);
	 WriteCmd: in std_logic;
	 ReadData1: out std_logic_vector(31 downto 0);
	 ReadData2: out std_logic_vector(31 downto 0));
end entity Registers;
signal DataInput : std_logic_vector(31 downto 0);
architecture remember of Registers is
	component register32
  	    port(datain: in std_logic_vector(31 downto 0);
		 enout32,enout16,enout8: in std_logic;
		 writein32, writein16, writein8: in std_logic;
		 dataout: out std_logic_vector(31 downto 0));
	end component;
	
begin
    X0: register32: (DataInput, '1', '1', '1', WriteCmd, WriteCmd, WriteCmd, "0000000000000000000000000000000");
    A0: register32: (DataInput, '1', '1', '1', WriteCmd, WriteCmd, WriteCmd, ReadData0);
    A1: register32: 
    -- Add your code here for the Register Bank implementation

end remember;

----------------------------------------------------------------------------------------------------------------------------------------------------------------
