clear
clc
close all

%loads parameters from data folder
run('data/param.m')

%Simplified parameters, used to make the coede less long
M = m + 2*J_m/r_m^2; %kg, total mass of tool head and 2 motors
bx = mu_lx + 8*mu_r/r_m^2; %N*s/m, total friction x direction
by = mu_ly + 4*mu_r/r_m^2; %N*s/m, total friction y direction
g = 2*K_m/r_m; %N*m/A, used to get force instead of torque

%ellipsoid parameters
x_c = d_x/2; %m, x center of ellipsoid
y_c = d_y/2; %m, y center of ellipsoid
a = 7e-2; %m, x radius of ellipsoid
b = 5e-2; %m, y radius of ellipsoid
T = 10; %s, total print time

