library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity encoder is
  port(
       SELECCION : in  std_logic_vector(15 downto 0);
       P_DES : out std_logic_vector(3 downto 0);
       PULSADO : out std_logic); --Bit que confirma que se ha hecho una selección en los botones del ascensor
end encoder;

architecture FUNCIONAL of encoder is
begin
  PISOSEL : process(SELECCION)
  begin
    case SELECCION is
      when "0000000000000000" => p_des <= "0000"; pulsado <= '0';
      when "0000000000000001" => p_des <= "0000"; pulsado <= '1';
      when "0000000000000010" => p_des <= "0001"; pulsado <= '1';
      when "0000000000000100" => p_des <= "0010"; pulsado <= '1';
      when "0000000000001000" => p_des <= "0011"; pulsado <= '1';
      when "0000000000010000" => p_des <= "0100"; pulsado <= '1';
      when "0000000000100000" => p_des <= "0101"; pulsado <= '1';
      when "0000000001000000" => p_des <= "0110"; pulsado <= '1';
      when "0000000010000000" => p_des <= "0111"; pulsado <= '1';
      when "0000000100000000" => p_des <= "1000"; pulsado <= '1';
      when "0000001000000000" => p_des <= "1001"; pulsado <= '1';
      when "0000010000000000" => p_des <= "1010"; pulsado <= '1';
      when "0000100000000000" => p_des <= "1011"; pulsado <= '1';
      when "0001000000000000" => p_des <= "1100"; pulsado <= '1';
      when "0010000000000000" => p_des <= "1101"; pulsado <= '1';
      when "0100000000000000" => p_des <= "1110"; pulsado <= '1';
      when "1000000000000000" => p_des <= "1111"; pulsado <= '1';
      when others => p_des <= "0000"; pulsado <= '0';
    end case;
  end process PISOSEL;
end FUNCIONAL;