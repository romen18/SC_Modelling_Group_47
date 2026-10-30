clear
clc
close all

run('data/param.m')
T_dep = 265; %C, deposit temperature of filament
epsilon_T = 20; %C, tolerance for filament T difference alongth length
a = 7e-2; %m, x radius of ellipsoid
b = 5e-2; %m, y radius of ellipsoid
T_p = 10; %s, printing time

t_f=120; %simulation end time
N=200; %amount of cells in the ellipse

Omega = 2*pi/T_p; %rad/s, angular speed ellipse
t_path = linspace(0,t_f,10001); %t vector


%calculate path length of ellipse
vx_d = -a*Omega*sin(Omega*t_path); %desired x velocity
vy_d = b*Omega*cos(Omega*t_path); %desired y velocity
v_d = sqrt(vx_d.^2+ vy_d.^2); %speed of printhead
l_path = cumtrapz(t_path, v_d); %trapezoidal integration of speed over time
L = l_path(end); %m, last value of l_path gives total length of ellipse

ds = L/N; %length of a cell
s = (1:N)*ds; %creates vector including the position for each cell index

G_cell = rho*cp*A*ds; %thermal capacity of one cell
G = k*A/ds; %thermal conductance between cells

beta_a = 3*h_air/(rho*cp*d); %heat loss coefficient to air
beta_b = h_bed/(rho*cp*d); %heat loss coefficient to bed

