clear
clc
close all

%loads parameters from data folder
run('data/param.m')

%heating up
t = 0:0.01:500; %time vector
T_n0 = 25; %deg C, initial temperature
T_set = 265; %deg C, the temperature we want to reach
tau_n = R_tn*C_tn; %s, time constant of nozzle
U_n_hold = sqrt(R_n/R_tn*(T_set-T_e)); %V, nozzle voltage needed to hold the temperature at T_set
T_n_eq = T_e + R_tn*U_n_hold^2/R_n; %deg C, the eventual temperature we want to reach
T_n = T_n_eq + (T_n0 - T_n_eq)*exp(-t/tau_n); %deg C, temperature of nozzle T_n(t)

figure;
plot(t, T_n, 'lineWidth', 1.5);
xlabel('t (s)');
ylabel('T_n (deg C)');
title('Temperature during heating up of nozzle 25 deg C to 265 deg C');
grid on;

%cooling down
t = 0:0.01:500; %time vector
U_n_hold = 0; %V, nozzle voltage turned off to cool down the nozzle
T_n0 = 265; %deg C, initial temperature
tau_n = R_tn*C_tn; %s, time constant of nozzle
T_n_eq = T_e + R_tn*U_n_hold^2/R_n; %deg C, the eventual temperature we want to reach
T_n = T_n_eq + (T_n0 - T_n_eq)*exp(-t/tau_n); %deg C, temperature of nozzle T_n(t)

figure;
plot(t, T_n, 'lineWidth', 1.5);
xlabel('t (s)');
ylabel('T_n (deg C)');
title('Temperature during cooling down of nozzle 265 deg C to 25 deg C');
grid on;