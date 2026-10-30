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
t_path = linspace(0,T_p,10001); %t vector


%calculate path length of ellipse
vx_d = -a*Omega*sin(Omega*t_path); %desired x velocity
vy_d = b*Omega*cos(Omega*t_path); %desired y velocity
v_d = sqrt(vx_d.^2+ vy_d.^2); %speed of printhead
l_path = cumtrapz(t_path, v_d); %trapezoidal integration of speed over time
L = l_path(end); %m, last value of l_path gives total length of ellipse

ds = L/N; %length of a cell
s = (1:N)*ds; %creates vector including the position for each cell index

C_cell = rho*cp*A*ds; %thermal capacity of one cell
G = k*A/ds; %thermal conductance between cells

beta_a = 3*h_air/(rho*cp*d); %heat loss coefficient to air
beta_b = h_bed/(rho*cp*d); %heat loss coefficient to bed


%% INITIALIZATION
delta_t = 0.001; %time step
k_f = floor(t_f/delta_t) + 1; %final simulation index
k_off = floor(T_p/delta_t) +1; %index when printing finishes
t = (0:k_f-1)*delta_t; %time vector

T = NaN(N, k_f); %matrix to store solutions
n_a_old = 0; %tracks number of cells printed

%% TIME MARCHING
for k = 1:(k_f-1)
    if k<k_off %domain grows during printing
        n_a = floor(l_path(k)/ds); %number of active cells at step k
        T((n_a_old+1):n_a, k) = T_dep; %all new cells start at temperate T_dep
        n_a_old = n_a;

        if n_a == 0
            continue
        end

        Phi = zeros(n_a+1, 1); %work vector for flows
        Phi(2:end-1) = (T(1:n_a-1, k) - T(2:n_a, k))*G; %update internal flows
        Phi(1) = 0; %boundary condition
        Phi(end) = 2*G*(T(n_a,k) - T_dep); %boundary condition at nozzle

        Q=3*h_air*d*ds*(T_e - T(1:n_a, k)) + h_bed*d*ds*(T_b - T(1:n_a,k)); %heat exchange with air and bed
        T(1:n_a, k+1) = T(1:n_a, k) + (delta_t/C_cell)*(Phi(1:end-1) - Phi(2:end) + Q); %update cell temperatures

    else %after printing finishes
        T((n_a_old+1):N,k) = T_dep; %updates cells printed during final timestep
        n_a_old = N;

        Phi = zeros(N+1,1); %matrix to store solutions
        Phi(2:end-1) = (T(1:end-1, k) - T(2:end, k))*G; %update internal flows
        Phi(end) = (T(end,k)-T(1,k))*G; %boundary condition when loop is complete
        Phi(1) = Phi(end); %boundaries touching

        Q=3*h_air*d*ds*(T_e - T(:, k)) + h_bed*d*ds*(T_b - T(:,k)); %heat exchange with air and bed
        T(:, k+1) = T(:, k) + (delta_t/C_cell)*(Phi(1:end-1) - Phi(2:end) + Q); %update cell temperatures
    end
end

%% PLOTTING

T_min = min(T);
T_max = max(T);
T_mean = mean(T);

delta_T = T_max - T_min;
idx_uni = find(delta_T < epsilon_T, 1);
t_uniform = t(idx_uni);

%filament profiles
figure;
hold on;
t_plot = [2, 5, 10, 20, 40, 60]; %total time elapsed at plot end
for i = 1:length(t_plot)
    k_plot = round(t_plot(i)/delta_t)+1;
    plot(s, T(:, k_plot), 'LineWidth', 1.5);
end
hold off;
xlabel('distance along filament s (m)');
ylabel('Temperature (deg C)');
title('temperature along the filament during and after printing');
legend('t = 2 s', 't = 5 s', 't = 10 s', 't = 20 s', 't = 40 s','t = 60 s','Location','best');
grid on;

