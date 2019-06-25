 -- Un controlador a la entrada coge el valor de pisoDes en pisoNue si cumple
  -- las limitaciones del rango (CON)
  -- Si hay cambio en pisoNue y el estado es PARAR, se compara pisoNue con
  -- pisoAct y se decide si hay que subir o bajar. Si no estábamos en parar, no
  -- se hace caso, y se sigue con el funcionamiento normal (EST)
  -- Un registro cambia el valor del estado cada segundo (REG)
  -- La lógica de salida pone el valor de las salidas según el estado (SAL)
  -- CON, EST y SAL son lógicas asíncronas. REG es síncrono.
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fsm is
  port(
    PISODES          : in  std_logic_vector(3 downto 0);   --Piso deseado en código binario
    PULSADO       : in std_logic;                       --Se ha seleccionado un piso cuando su valor lógico es 1
    CLK           : in  std_logic;                      
    RESET_N       : in  std_logic;                      --Pulsador Reset, activo a nivel bajo
    SENSOR_PUERTA : in std_logic;                       --a 1 si la puerta está abierta
    MOTOR         : out std_logic_vector(1 downto 0);   --Indica el estado del motor
    PISOACT       : out std_logic_vector(3 downto 0);   --Piso actual en código binario
    PUERTAEXT : out std_logic;                          --Puerta manual
    PUERTAINT : out std_logic);                         --Puerta automática
end fsm;

architecture ESTRUCTURAL of fsm is

  type ESTADOS is (INICIO,PARAR, SUBIR, BAJAR,ABIERTO);
  signal estado    : ESTADOS := INICIO;                                 --Estado actual
  signal sigEstado : ESTADOS := PARAR;                                  --Estado siguiente
  signal p_deseado : std_logic_vector(3 downto 0) := (others => '0');   --Piso deseado
  signal p_actual  : std_logic_vector(3 downto 0) := (others => '0');   --Piso actual
  signal memopiso  : unsigned(3 downto 0) := (others => '0');           --Memoria estado (actual). Se corresponde con la salida a Displays
  signal memosigpiso: unsigned(3 downto 0) := (others => '0');           --Memoria siguiente estado
  
begin

  pisoact <= std_logic_vector(memopiso);
  p_actual <= std_logic_vector(memopiso); 
  
SYNC_PROC: process(PISODES, RESET_N) 
  begin
  if (RESET_N = '0') then
        p_deseado <= (others => '0');
    elsif(estado = PARAR) then
        if (pulsado = '0') then
            p_deseado <= std_logic_vector(memopiso); 
        else
           p_deseado <= pisodes;
        end if;
    end if;
 end process SYNC_PROC;


  NEXT_STATE_DECODE: process(p_deseado, p_actual, estado, SENSOR_PUERTA) -- Lógica del cálculo del siguiente estado
  begin
      sigEstado <= estado;
      memosigpiso <= memopiso; 
    
    if(estado = INICIO) then            --A inicio solo se accede a traves de RESET y no se vuelve en procesjamás
        sigEstado <= PARAR;             --Automáticamente vuelve a parada neutral después de Inicio, es decir, de ser reseteado
        
    elsif(estado = PARAR) then
        if(sensor_puerta = '1') then       -- Estando parados, se abre la puerta
            sigEstado <= ABIERTO;          -- La puerta del ascensor se encuentra abierta
        else
            if(p_deseado < p_actual) then
                sigEstado <= BAJAR;
            elsif(p_deseado > p_actual) then
                sigEstado <= SUBIR;
            end if;
        end if;
        
    elsif(estado = SUBIR) then
        if(p_deseado /= p_actual) then
            SigEstado <= SUBIR;
            memosigpiso <= memopiso + 1;
	   else
            sigEstado <= PARAR;
        end if;
      
    elsif(estado = BAJAR) then
        if(p_deseado /= p_actual) then
             sigEstado <= BAJAR;
             memosigpiso <= memopiso - 1;
	    else
            sigEstado <= PARAR;
        end if;

    elsif(estado = ABIERTO) then
        if(sensor_puerta = '0') then
            sigEstado <= PARAR;
        end if;
        
   end if;
   
  end process NEXT_STATE_DECODE;

  REG_EST : process(CLK, RESET_N) -- Actualización del estado
  begin
    if(RESET_N = '0') then
        estado <= INICIO;
        memopiso <= (others => '0');
    elsif(clk = '1' and clk'event) then --flanco de subida en el reloj
      estado <= sigEstado;
      memopiso <= memosigpiso;
    end if;
  end process REG_EST;

SALIDAS : process(estado) -- Lógica del cálculo de salida
  begin    
    if(estado = INICIO) then
         motor   <= "00";      --motor parado
         puertaext <= '0'; --puerta desbloqueada
         puertaint  <= '0'; --puerta desbloqueada
    elsif(estado = PARAR) then
          motor   <= "00";      --motor parado
          puertaext  <= '0'; --puerta desbloqueada
          puertaint  <= '0'; --puerta desbloqueada
    elsif(estado = SUBIR) then
          motor   <= "01";      --motor subiendo
          puertaext  <= '1'; --puerta bloqueada
          puertaint  <= '1'; --puerta bloqueada
    elsif(estado = BAJAR) then
         motor   <= "10";      --motor bajando
         puertaext   <= '1'; --puerta bloqueada
         puertaint  <= '1'; --puerta bloqueada
    else --puerta exterior abierta
        motor   <= "00";      --motor parado
        puertaext   <= '1'; --puerta desbloqueada
        puertaint  <= '1'; --puerta desbloqueada
    end if;
  end process SALIDAS;
  
end ESTRUCTURAL;
