clear
clc
close all

run('data/param.m')
T_set = 265; %deg C, set nozzle temperature
T_dep = 265 + 273.15; %K, deposit temperature of filament
epsilon_T = 1; %K, tolerance for filament T difference
T_p = 10; %s, printing time

Omega = 2*pi/T_p; %rad/s, angular speed ellipse
t_path = linspace(0,T_p,10001); %t vector

vx_d = -a*Omega*sin(Omega*t); %desired x velocity
vy_d = b*Omega*cos(Omega*t); %desired y velocity

