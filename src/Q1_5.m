clear
clc
close all

%loads parameters from data folder
run('data/param.m')

%Simplified parameters, used to make the code less long
M = m + 2*J_m/r_m^2; %kg, total mass of tool head and 2 motors
bx = mu_lx + 8*mu_r/r_m^2; %N*s/m, total friction x direction
by = mu_ly + 4*mu_r/r_m^2; %N*s/m, total friction y direction
g = 2*K_m/r_m; %N*m/A, used to get force instead of torque


%heating up
t = 0:0.01:160; %time vector
T_n0 = 25; %deg C, initial temperature
tau_n = R_tn*C_tn; %s, time constant of nozzle
T_n_eq = 265; %deg C, the eventual temperature we want to reach
T_n = T_n_eq + (T_n0 - T_n_eq)*exp(-t/tau_n); %deg C, temperature of nozzle T_n(t)

figure;
plot(t, T_n, 'lineWidth', 1.5);
xlabel('t (s)');
ylabel('T_n (deg C)');
title('Temperature during heating up of nozzle 25 deg C to 265 deg C');
grid on;