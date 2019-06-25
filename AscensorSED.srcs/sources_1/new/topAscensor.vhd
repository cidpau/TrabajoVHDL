library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity topAscensor is
    port(
        PISO           : in  std_logic_vector(15 downto 0);    --Combinacion de entrada (piso deseado) OK
        CLK            : in  std_logic;                       --Oscilador externo OK 
        RESET_N        : in  std_logic;                       --Pulsador Reset, activo a nivel bajo OK
        SENSOR_PUERTA  : in std_logic;                        --Sensor de seguridad, a 1 si la puerta esta abierta OK 
        MOTOR          : out std_logic_vector(1 downto 0);    --Señales para el motor OK
        DISPLAY        : out std_logic_vector(6 downto 0);   
        AN             : out std_logic_vector(7 downto 0);    --Vector de anodos
        PUERTAEXT      : out std_logic;                       --Apertura de puerta
        PUERTAINT      : out std_logic);                       --Apertura de puerta

end topAscensor;

architecture ESTRUCTURAL of topAscensor is

component fdivider
    port(CLKIN   : in  std_logic;
         RESET_N : in  std_logic;
         CLKOUT  : out std_logic);
  end component;
  
 component encoder is
    port(SELECCION : in  std_logic_vector(15 downto 0);
         P_DES : out std_logic_vector(3 downto 0);
         PULSADO : out std_logic);
  end component;
  
  component decoder
    port(CLK: 	    in STD_LOGIC;
       MOTOR: in STD_LOGIC_VECTOR(1 downto 0);
       CODE : in  std_logic_vector(3 downto 0);
       DISPLAY : out std_logic_vector(6 downto 0);
       CUR_DISPLAY: out STD_LOGIC_VECTOR(7 downto 0));
  end component;

component fsm 
    port(
      PISODES       : in  std_logic_vector(3 downto 0);   
      PULSADO       : in std_logic;                       
      CLK           : in  std_logic;                      
      RESET_N       : in  std_logic;                      
      SENSOR_PUERTA : in std_logic;                       
      MOTOR         : out std_logic_vector(1 downto 0);   
      PISOACT       : out std_logic_vector(3 downto 0);   
      PUERTAEXT : out std_logic;                          
      PUERTAINT : out std_logic);                         
  end component; 

  signal CodeBin  : std_logic_vector(3 downto 0);
  signal pdeseado  : std_logic_vector(3 downto 0);
  signal ppulsado  : std_logic;
  signal clkdiv   : std_logic;
  signal puerta1 : std_logic;
  signal puerta2 : std_logic;  
  signal motor_signal:  std_logic_vector(1 downto 0); 
begin

  PUERTAEXT <= puerta1;
  PUERTAINT <= puerta2;
  MOTOR<=motor_signal;
  
  CLKDIVIDER : fdivider port map(CLKIN => CLK, RESET_N => RESET_N, CLKOUT => clkdiv);
  ENCOD  : encoder port map(SELECCION => piso, P_DES => pdeseado, PULSADO => ppulsado);
  DECO  : decoder port map(CLK=>clk,MOTOR=>motor_signal,CODE => CodeBin, DISPLAY => display,CUR_DISPLAY=>an);
  FSM1    : fsm port map(PISODES => pdeseado, PULSADO => ppulsado, clk => clkdiv, RESET_N => reset_n, SENSOR_PUERTA => sensor_puerta,motor => motor_signal, puertaext => puerta1, puertaint => puerta2 );
 
end ESTRUCTURAL;
