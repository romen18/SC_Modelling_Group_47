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
T_p = 10; %s, total print time

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

%calculation of u for ellipsoid
t = 0:0.01:T_p; %time vector

Omega = (2*pi)/T_p; %rad/s, angular velocity
x_d = x_c + a*cos(Omega*t); %desired x position
y_d = y_c + b*sin(Omega*t); %desired y position
vx_d = -a*Omega*sin(Omega*t); %desired x velocity
vy_d = b*Omega*cos(Omega*t); %desired y velocity
ax_d = -a*Omega^2*cos(Omega*t); %desired x acceleration
ay_d = -b*Omega^2*sin(Omega*t); %desired y acceleration
jx_d = a*Omega^3*sin(Omega*t); %desired x jerk
jy_d = -b*Omega^3*cos(Omega*t); %desired y jerk

ix_d = (M*ax_d + bx*vx_d)/g; %desired x current
iy_d = (M*ay_d + by*vy_d)/g; %desired y current 
ix_d_dot = (M*jx_d + bx*ax_d)/g; %desired x change in current
iy_d_dot = (M*jy_d + by*ay_d)/g; %desired y change in current

u_x = L_m*ix_d_dot + R_m*ix_d + K_m*vx_d/r_m;
u_y = L_m*iy_d_dot + R_m*iy_d + K_m*vy_d/r_m;

u = [u_x; u_y]; %control input vector

%state space simulation
sys = ss(A,B,C,D); 
[y, t_out, x] = lsim(sys, u, t, x0); %simulate system


figure;
plot(y(:,1), y(:,2), 'lineWidth', 1.5);
hold on;
plot(x_d, y_d, 'r--', 'lineWidth', 1.5);
hold off;
xlabel('x (m)');
ylabel('y (m)');
title('Nozzle paths ellipsoid');
legend('Actual path', 'Desired path');
grid on;

figure;
plot(t, u_x, 'lineWidth', 1.5);
hold on;
plot(t, u_y, 'lineWidth', 1.5);
hold off;
xlabel('Time (s)');
ylabel('Control input (V)');
title('Control inputs ellipsoid');
legend('u_x', 'u_y');
grid on;

%for 5 point flower:
x_c = d_x/2; %m, x center of ellipsoid
y_c = d_y/2; %m, y center of ellipsoid
a = 7e-2; %m, x average radius of flower
epsilon = 0.3; %m, flower petal size
T_p = 10; %s, total print time

x0 = [x_c+a, 0, 0, y_c, 0, 0]; %initial state, starting at right side of ellipsoid

%u calculation for flower
Omega = (2*pi)/T_p; %rad/s, angular velocity
x_d = x_c + a*cos(Omega*t) + a*epsilon/2*(cos(6*Omega*t)+cos(4*Omega*t)); %desired x position
y_d = y_c + a*sin(Omega*t) + a*epsilon/2*(sin(6*Omega*t)-sin(4*Omega*t)); %desired y position
vx_d = -a*Omega*sin(Omega*t) - a*epsilon*Omega/2*(sin(6*Omega*t)+sin(4*Omega*t)); %desired x velocity
vy_d = a*Omega*cos(Omega*t) + a*epsilon*Omega/2*(6*cos(6*Omega*t) - 4*cos(4*Omega*t)); %desired y velocity
ax_d = -a*Omega^2*cos(Omega*t) - a*epsilon*Omega^2/2*(36*cos(6*Omega*t) + 16*cos(4*Omega*t)); %desired x acceleration
ay_d = -a*Omega^2*sin(Omega*t) + a*epsilon*Omega^2/2*(-36*sin(6*Omega*t) + 16*sin(4*Omega*t)); %desired y acceleration
jx_d = a*Omega^3*sin(Omega*t) + a*epsilon*Omega^3/2*(216*sin(6*Omega*t) + 64*sin(4*Omega*t)); %desired x jerk
jy_d = -a*Omega^3*cos(Omega*t) + a*epsilon*Omega^3/2*(-216*cos(6*Omega*t) + 64*cos(4*Omega*t)); %desired y jerk

ix_d = (M*ax_d + bx*vx_d)/g; %desired x current
iy_d = (M*ay_d + by*vy_d)/g; %desired y current 
ix_d_dot = (M*jx_d + bx*ax_d)/g; %desired x change in current
iy_d_dot = (M*jy_d + by*ay_d)/g; %desired y change in current

u_x = L_m*ix_d_dot + R_m*ix_d + K_m*vx_d/r_m;
u_y = L_m*iy_d_dot + R_m*iy_d + K_m*vy_d/r_m;

u = [u_x; u_y]; %control input vector

%state space simulation
sys = ss(A,B,C,D); 
[y, t_out, x] = lsim(sys, u, t, x0); %simulate system

figure;
plot(y(:,1), y(:,2), 'lineWidth', 1.5);
hold on;
plot(x_d, y_d, 'r--', 'lineWidth', 1.5);
hold off;
xlabel('x (m)');
ylabel('y (m)');
title('Nozzle paths flower');
legend('Actual path', 'Desired path');
grid on;

figure;
plot(t, u_x, 'lineWidth', 1.5);
hold on;
plot(t, u_y, 'lineWidth', 1.5);
hold off;
xlabel('Time (s)');
ylabel('Control input (V)');
title('Control inputs flower');
legend('u_x', 'u_y');
grid on;