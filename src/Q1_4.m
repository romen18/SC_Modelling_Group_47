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

%initial values and A,B,C,D 
% with x = [x, vx, i_x, y, vy, i_y]^T
% and u = [u_x, u_y]^T
x0 = [x_c+a, 0, 0, y_c, 0, 0]; %initial state, starting at right side of ellipsoid
A = [0, 1, 0,                    0, 0, 0;
    0, -bx/M, g/M,               0, 0, 0;
    0, -K_m/(r_m*L_m), -R_m/L_m, 0, 0, 0;
    0, 0, 0,                     0, 1, 0;
    0, 0, 0,               0, -by/M, g/M;
    0, 0, 0, 0, -K_m/(r_m*L_m), -R_m/L_m]; %A matrix
B = [0, 0;
    0, 0;
    1/L_m, 0;
    0, 0;
    0, 0;
    0, 1/L_m]; %B matrix
C = [1, 0, 0, 0, 0, 0;
    0, 0, 0, 1, 0, 0]; %C matrix that only outputs x and y position
D = [0, 0;
    0, 0]; %D matrix

