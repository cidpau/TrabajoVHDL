library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity decoder is
  port(
       CLK: 	    in STD_LOGIC; --500MHz
       MOTOR: in STD_LOGIC_VECTOR(1 downto 0);
       CODE : in  std_logic_vector(3 downto 0);
       DISPLAY : out std_logic_vector(6 downto 0);
       CUR_DISPLAY: out STD_LOGIC_VECTOR(7 downto 0)--Ánodos de los displays
       );
end decoder;

architecture BEHAVIORAL of decoder is
    -- 500Mzh/1000000=500Hz
   constant max_refresh_count: INTEGER := 100000; --Para real
   --constant max_refresh_count: INTEGER := 10; --Para prueba simulacion
   signal refresh_count: INTEGER range 0 to max_refresh_count;
   signal refresh_state: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
   signal display_sel: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
   
begin

 cur_display <= display_sel;

   gen_clock: process(clk)
   begin
       if clk'event and clk='1' then
       -- contador 500Hz (para refresco del display)
       if refresh_count < max_refresh_count then
       refresh_count <= refresh_count + 1;
       else
       refresh_state <= refresh_state + 1;
       refresh_count <= 0; 
           end if; 
       end if; 
   end process; 
   
    show_display: process(refresh_state) 
         begin -- selección del display 
             case refresh_state is 
                 when "000" => 
                     display_sel <= "01111111"; -- display S|B|P 
                 when "001" => 
                     display_sel <= "10111111"; -- display U|A|A
                 when "010" => 
                     display_sel <= "11011111"; -- display B|J|R 
                 when "011" => 
                     display_sel <= "11101111"; -- display E|A|A 
                 when "100" =>
                    display_sel <= "11111110";
                 when "101" =>
                    display_sel <= "11111101";
                 when others => 
                     display_sel <= "11111111"; 
             end case; 
  
             -- mostrar digitos 
             case display_sel is 
                 when "01111111" =>
                  if (motor="00") then --Parado
                      display <= "0011000"; -- P
                  elsif (motor="01") then --Sube
                      display <= "0100100"; -- S
                  elsif (motor="10") then --Baja
                      display <= "0000000"; -- B
                  end if;
                 when "10111111" => 
                  if (motor="00" or motor="10") then 
                     display <= "0001000"; -- A
                  elsif (motor="01") then 
                     display <= "1000001"; -- U
                  end if;
                 when "11011111" => 
                       if (motor="00") then 
                          display <= "0001000"; -- R
                       elsif (motor="01") then 
                          display <= "0000000"; -- B
                       elsif (motor="10") then 
                           display <= "1000111"; -- J
                       end if;
                 when "11101111" => 
                  if (motor="00" or motor="10") then 
                     display <= "0001000"; -- A
                  elsif (motor="01") then 
                     display <= "0110000"; -- E
                  end if;
                  when "11111110"=> --Unidades del número de piso
                     case CODE is
                       when "0000" => display <= "0000001"; --Indica un 0
                       when "0001" => display <= "1001111"; --Indica un 1
                       when "0010" => display <= "0010010"; --Indica un 2
                       when "0011" => display <= "0000110"; --Indica un 3
                       when "0100" => display <= "1001100"; --Indica un 4
                       when "0101" => display <= "0100100"; --Indica un 5
                       when "0110" => display <= "0100000"; --Indica un 6
                       when "0111" => display <= "0001111"; --Indica un 7
                       when "1000" => display <= "0000000"; --Indica un 8
                       when "1001" => display <= "0000100"; --Indica un 9
                       when "1010" => display <= "0000001"; --Indica un 0
                       when "1011" => display <= "1001111"; --Indica un 1
                       when "1100" => display <= "0010010"; --Indica un 2
                       when "1101" => display <= "0000110"; --Indica un 3
                       when "1110" => display <= "1001100"; --Indica un 4
                       when "1111"=>  display <= "0100100"; --Indica un 5
                       when others => display <= "1111111"; --Vacío
                     end case;
                     when "11111101"=> --Decenas del número de piso
                        case CODE is
                             when "1010" => display <= "1001111"; --Indica un 1
                             when "1011" => display <= "1001111"; --Indica un 1
                             when "1100" => display <= "1001111"; --Indica un 1
                             when "1101" => display <= "1001111"; --Indica un 1
                             when "1110" => display <= "1001111"; --Indica un 1
                             when "1111"=>  display <= "1001111"; --Indica un 1
                             when others => display <= "1111111"; --Vacío
                        end case;
                 when others =>
             display <= "1111111"; --Vacío
         end case;
     end process;
     
end BEHAVIORAL;