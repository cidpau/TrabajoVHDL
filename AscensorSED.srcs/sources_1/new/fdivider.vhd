library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity fdivider is
  generic (
        PREESC : integer := 100000000);
  port(
       CLKIN  : in  std_logic := '0';
       RESET_N  : in  std_logic := '1';
       CLKOUT : out std_logic := '0');
end fdivider;

architecture FUNCIONAL of fdivider is
  signal aux : std_logic := '0';
begin
  CLKOUT <= aux;
  CLKDIV : process (CLKIN, RESET_N)
    variable cont : integer := 0;
  begin
    if(RESET_N = '0') then
      cont := 0;
      aux  <= '0';
    elsif (CLKIN'event and CLKIN = '1') then
      cont := cont+1;
      if (cont = (PREESC/2+1)) then
        cont := 1;
        aux  <= not aux;
      end if;
    end if;
  end process CLKDIV;
end FUNCIONAL;