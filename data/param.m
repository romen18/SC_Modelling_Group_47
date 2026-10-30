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
C_tn = 3; %J/K, Nozzle thermal capacity 
R_tn = 6; %K/W, Nozzle thermal resistance 
R_n = 14.4; %Ohm, Nozzle resistor (gotten from 24V, 40W heater)

%other constants
T_e = 25; %deg C, Environment temperature
mu_r = 0.003; %N*m*s/rad, Bearing friction rolling
mu_lx = 0.03; %N*s/m,Bearing friction linear x-direction
mu_ly = 0.03; %N*s/m, Bearing friction linear y-direction
T_b = 50; %deg C, Print bed temperature
d_x = 0.3; %m, Print area dimension x
d_y = 0.3; %m, Print area dimension y

%Simplified parameters, used to make the code less long
M = m + 2*J_m/r_m^2; %kg, equivalent mass includijng motor inertia
bx = mu_lx + 8*mu_r/r_m^2; %N*s/m, total friction x direction
by = mu_ly + 4*mu_r/r_m^2; %N*s/m, total friction y direction
g = 2*K_m/r_m; %N*m/A, used to get force instead of torque
