%please note that these values are all
%made up (using the internet) since the assignment gave no values.

%Motor constants
r_m = 30e-3; %m, motor radius
L_m = 1e-3; %H, motor induction
R_m = 1; %ohm, motor resistor
J_m = 3.0e-5; %kg*m^2, motor inertia
K_m = 0.05; %N*m/A motor constant

%Tool/Nozzle constants
m = 0.4; %kg, Tool head mass
C_n = 1e-6; %F, Nozzle capacitor
C_tn = 25; %J/K, Nozzle thermal capacity (30g aluminium heater block)
R_tn = 15; %K/W, Nozzle therma resistance 
R_n = 14; %Ohm, Nozzle resistor (gotten from 24V, 40W heater)

%other constants
T_e = 298; %K, Environment temperature
mu_r = 0.003; , Bearing friction rolling
mu_lx = 0.03; , Bearing friction linear x-direction
mu_ly = 0.03; , Bearing friction linear y-direction
T_b = 323; %K, Print bed temperature
d_x = 0.3; %m, Print area dimension x
d_y = 0.3; %m, Print area dimension y