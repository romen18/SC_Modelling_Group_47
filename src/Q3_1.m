clear
clc
close all

run('data/param.m') %load parameters

%below we put every parameter into a single variable p (to use in functions)
p.r_m = r_m; p.L_m = L_m; p.R_m = R_m; p.J_m = J_m; p.K_m = K_m; %motor constants added to p
p.m = m; p.C_n = C_n; p.C_tn = C_tn; p.R_tn = R_tn; p.R_n = R_n; %tool/nozzle constants added to p
p.T_e = T_e; p.mu_r = mu_r; p.mu_lx = mu_lx; p.mu_ly = mu_ly; p.T_b = T_b; p.d_x = d_x; p.d_y = d_y; %other constants added to p
p.M = M; p.bx = bx; p.by = by; p.g = g; %simplified parameters added to p

%q states
%(0) q0: "printing", (1) q1: "stopping and saving location", (2) q2: "moving to wipe tower", (3) q3: "wiping"
%(4) q4: "Nozzle heat off", (5) q5: "loading new filament", (6) q6: "nozzle heat on", (7) q7: "returning to saved location"

%x vector = [x, vx, i_x, y, vy, i_y, T_n]^T

q0=0 %start in printing state

function u = input(x,p,q) %calculates u = [u_x, u_y, u_n]^T
    switch q
        case 0 %printing
            u_x = 0 %will be filled later with ellipse input function
            u_y = 0 %will be filled later with ellipse input function
            u_n = p.U_n_hold %nozzle voltage to hold temperature at T_set
        case 1 %stopping and saving location
            u_x = 0
            u_y = 0
            u_n = p.U_n_hold
        case 2 %moving to wipe tower
            u_x = 0 %placeholder
            u_y = 0 %placeholder
            u_n = p.U_n_hold
        case 3 %wiping
            u_x = 0 %placeholder
            u_y = 0 %placeholder
            u_n = p.U_n_hold
        case 4 %Nozzle heat off
            u_x = 0
            u_y = 0 
            u_n = 0 %nozzle voltage turned off to cool down the nozzle
        case 5 %loading new filament
            u_x = 0
            u_y = 0
            u_n = 0
        case 6 %nozzle heat on
            u_x = 0
            u_y = 0
            u_n = p.U_n_hold %nozzle voltage to hold temperature at T_set
        case 7 %returning to saved location
            u_x = 0 %placeholder
            u_y = 0 %placeholder
            u_n = p.U_n_hold
    end
end

function dx = sys(x,u,p,q)
    switch q
        case 0 %printing
        case 1 %stopping and saving location
        case 2 %moving to wipe tower
        case 3 %wiping
        case 4 %Nozzle heat off
        case 5 %loading new filament
        case 6 %nozzle heat on
        case 7 %returning to saved location

    end

    dx = [dx_pos; dvx; dix; dy_pos; dvy; diy; dT_n]; %output of function (dx_pos because dx is the function name)
end