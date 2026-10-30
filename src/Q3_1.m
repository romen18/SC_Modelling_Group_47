clear
clc
close all

run('data/param.m') %load parameters

%below we put every parameter into a single variable p (to use in functions)
p.r_m = r_m; p.L_m = L_m; p.R_m = R_m; p.J_m = J_m; p.K_m = K_m; %motor constants added to p
p.m = m; p.C_n = C_n; p.C_tn = C_tn; p.R_tn = R_tn; p.R_n = R_n; %tool/nozzle constants added to p
p.T_e = T_e; p.mu_r = mu_r; p.mu_lx = mu_lx; p.mu_ly = mu_ly; p.T_b = T_b; p.d_x = d_x; p.d_y = d_y; %other constants added to p
p.M = M; p.bx = bx; p.by = by; p.g = g; %simplified parameters added to p

%Heating variables from Q1.5
p.T_set = 265; %deg C, target nozzle temp
p.T_cool = 45; %deg C, target cooling temp
p.U_n_hold = sqrt (R_n/R_tn*(p.T_set-T_e));

%ellipse variables from Q1.4
p.x_c = d_x/2; %m, x center of ellipsoid
p.y_c = d_y/2; %m, y center of ellipsoid
p.a = 7e-2; %m, x radius of ellipsoid
p.b = 5e-2; %m, y radius of ellipsoid
p.T_p = 10; %s, total print time for 1 ellipse
p.Omega = (2*pi)/p.T_p; %rad/s, angular velocity for printing ellipse

%q states
%(0) q0: "printing", (1) q1: "stopping and saving location", (2) q2: "moving to wipe tower", (3) q3: "wiping"
%(4) q4: "Nozzle heat off", (5) q5: "loading new filament", (6) q6: "nozzle heat on", (7) q7: "returning to saved location"

%x vector = [x, vx, i_x, y, vy, i_y, T_n]

q0=0; %start in printing state
x0 = [p.x_c + p.a; 0; 0; p.y_c; 0; 0; p.T_set]; %starts at right side of ellipse with temperature on
%empty variables that will be updated in the state machine when the right state is reached
p.x_save = 0;
p.y_save = 0; 
p.t_jump = 0;
p.new_filament_required = true;

%simulation parameters for starting ode45
t=0;
t_end=500;
q = q0;
x = x0;

%empty lists for plotting
x_full = []; 
t_full = [];
q_full = [];


while t<t_end
    options = odeset('Events', @(t,x) guards(t, x, p, q)); %options for ode45 to change states with guard functions at curent time
    %runs ode45 until guard triggers
    [t_current, x_current, t_event, x_event, i_event] = ode45(@(t,x) sys(x, input(t,x,p,q),p), [t,t_end], x, options);

    t=t_current(end); %updates t to start next simulation from the end of this state
    x=x_current(end, :)'; %updates x to start next simulation from the end of this state
    p.t_jump = t; %saves time when the jump was made (to use for u values of the ellipse)

    %appends full lists for full plot during printing
    t_full = [t_full; t_current]; %appends t_current to t_full to match up plotting of x_full
    x_full = [x_full; x_current]; %appends full x state over every t timestep to t_full
    q_full = [q_full; q * ones(length(t_current),1)]; %appends q, t times to q_full

    %adds plot after state ended so you can see per state how it changed (excluding wiping, heating, cooling, and loading states)
    if ~(q == 3 | q == 4 | q == 5 | q == 6)
        figure;
        plot(x_current(:,1), x_current(:,4), 'LineWidth', 1.5);
        xlabel('x (m)');
        ylabel('y (m)');
        axis equal;
        title(['Nozzle path during state q', num2str(q)]);
        grid on;
    end
    %if state is cooling or heating plots the temperature
    if q == 4 || q==6
        figure;
        plot(t_current(:),x_current(:,7), 'LineWidth', 1.5);
        ylabel('T (deg C)');
        xlabel('t (s)');
        title(['Nozzle temperature during state q', num2str(q)]);
        grid on;
    end
    %if no event happened, skip over the state jumping of this loop
    if isempty(i_event)
        break
    end
    %as the state ended (guard was reached) we can jump to the next state
    if q == 0
        q = 1; %jumps to q1: stopping
    elseif q ==1
        p.x_save = x(1); %saves location
        p.y_save = x(4); %saves location
        q = 2;
    elseif q < 7
        q = q+1; %jumps to the next state
    elseif q == 7
        q = 0; %jumps to q0: printing
        p.new_filament_required = false; %filament is already replaced
    end
end

figure;
plot(x_full(:,1), x_full(:,4), 'LineWidth', 1.5);
xlabel('x (m)');
ylabel('y (m)');
axis equal;
title('Nozzle path during full simulation');
grid on;

figure;
plot(t_full(:), x_full(:,7), 'LineWidth', 1.5);
xlabel('t (s)');
ylabel('T (deg C)');
title('Nozzle temperature over time');
grid on;

figure;
plot(t_full(:), q_full(:), 'LineWidth', 1.5);
xlabel('t (s)');
ylabel('q (state)');
title('States over time');
grid on;

figure;
plot(t_full(:), x_full(:,1), 'LineWidth', 1.5);
xlabel('t (s)');
ylabel('x (m)');
title('x position over time');
grid on;

function [value, isterminal, direction] = guards(t,x,p,q) %guard function using ode45 syntax
    isterminal = 1; %this stops ode45 when the value reaches 0
    direction =  0; %switches states if 0 is crossed from either above or below
    switch q
        case 0 %printing (stops when ellipse is finished and new filament is required)
            if p.new_filament_required
                value = (t-p.t_jump) - p.T_p; %time_printing minus the time required to draw an ellipse
            else
                value = 1; %never switches when a new filament roll has been put on
            end
        case 1 %stopping and saving location (stops when the speed succesfully reached very close to 0)
            value = sqrt(x(2)^2 + x(5)^2)-0.0001; %total speed is less than 0.1mm/s
        case 2 %moving to wipe tower (stop when distance to (0,0) is <=1mm)
            value = sqrt(x(1)^2 + x(4)^2) -0.001; %position relative to (0,0) squared minus 1mm
        case 3 %wiping (stops when in state 3 for 10 seconds)
            value = (t-p.t_jump)-10; %10 seconds after wiping started
        case 4 %Nozzle heat off (stops when temp reaches below T_cool)
            value = x(7)-p.T_cool;
        case 5 %loading new filament (stops when 20 seconds have passed since started loading)
            value = (t-p.t_jump)-20;
        case 6 %nozzle heat on (stops when T_n is within 5 degrees of T_set)
            value = x(7)-(p.T_set-5);
        case 7 %returning to saved location (stop when distance to (x_save,y_save) is <=0.01mm)
            value = sqrt((x(1)-p.x_save)^2 + (x(4)-p.y_save)^2) - 0.00001;
    end
end

function u = input(t,x,p,q) %calculates u = [u_x, u_y, u_n]
    switch q
        case 0 %printing
            t_print = t-p.t_jump; %current time since printing state started
            vx_d = -p.a*p.Omega*sin(p.Omega*t_print); %desired x velocity
            vy_d = p.b*p.Omega*cos(p.Omega*t_print); %desired y velocity
            ax_d = -p.a*p.Omega^2*cos(p.Omega*t_print); %desired x acceleration
            ay_d = -p.b*p.Omega^2*sin(p.Omega*t_print); %desired y acceleration
            jx_d = p.a*p.Omega^3*sin(p.Omega*t_print); %desired x jerk
            jy_d = -p.b*p.Omega^3*cos(p.Omega*t_print); %desired y jerk

            ix_d = (p.M*ax_d + p.bx*vx_d)/p.g; %desired x current
            iy_d = (p.M*ay_d + p.by*vy_d)/p.g; %desired y current 
            ix_d_dot = (p.M*jx_d + p.bx*ax_d)/p.g; %desired x change in current
            iy_d_dot = (p.M*jy_d + p.by*ay_d)/p.g; %desired y change in current

            u_x = p.L_m*ix_d_dot + p.R_m*ix_d + p.K_m*vx_d/p.r_m;
            u_y = p.L_m*iy_d_dot + p.R_m*iy_d + p.K_m*vy_d/p.r_m;

            u_n = p.U_n_hold; %nozzle voltage to hold temperature at T_set
        case 1 %stopping and saving location
            u_x = 0;
            u_y = 0;
            u_n = p.U_n_hold;
        case 2 %moving to wipe tower
            u_x = -x(1); %if x>0 u_x pulls it to the left 
            u_y = -x(4); %if y>0 u_y pulls it down
            u_n = p.U_n_hold;
        case 3 %wiping
            u_x = 0; %stays still while wiping is being done 
            u_y = 0; %stays still while wiping is being done
            u_n = p.U_n_hold;
        case 4 %Nozzle heat off
            u_x = 0;
            u_y = 0;
            u_n = 0; %nozzle voltage turned off to cool down the nozzle
        case 5 %loading new filament
            u_x = 0;
            u_y = 0;
            u_n = 0;
        case 6 %nozzle heat on
            u_x = 0;
            u_y = 0;
            u_n = p.U_n_hold; %nozzle voltage to hold temperature at T_set
        case 7 %returning to saved location
            u_x = p.x_save - x(1); %makes u_x positive if x_save>x
            u_y = p.y_save - x(4); %makes u_y positive if y_save>y
            u_n = p.U_n_hold;
    end
    u = [u_x; u_y; u_n]; %output of function
end

function dx = sys(x,u,p)
    %the following equations are all derived in Q1.3 decoupled motion (using epsilon = {x, y})
    %x vector = [x, vx, i_x, y, vy, i_y, T_n]
    %u vector = [u_x, u_y, u_n]
    %even though we did add a new state T_n, we keep the original 6x6 A1 and add an 1x1 A2 (block diagonal) 
    %as T_n is not dependent on the first 6 states of x
    dx_pos = x(2); %dx_pos as dx is the function variable
    dvx = -p.bx/p.M*x(2) + p.g/p.M*x(3);
    dix = -p.K_m/(p.r_m*p.L_m)*x(2) - p.R_m/p.L_m*x(3) + 1/p.L_m*u(1);
    dy_pos = x(5);
    dvy = -p.by/p.M*x(5) + p.g/p.M*x(6);
    diy = -p.K_m/(p.r_m*p.L_m)*x(5) -p.R_m/p.L_m*x(6) + 1/p.L_m*u(2);
    
    %from Q1.5, assuming a constant voltage input and thus u_c=u_n
    dT_n = 1/p.C_tn * (u(3)^2/p.R_n - (x(7)-p.T_e)/p.R_tn);
    dx = [dx_pos; dvx; dix; dy_pos; dvy; diy; dT_n]; %output of function
end