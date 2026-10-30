clear
clc
close all

run('data/param.m') %load parameters

%below we put every parameter into a single variable p (to use in functions)
p.r_m = r_m; p.L_m = L_m; p.R_m = R_m; p.J_m = J_m; p.K_m = K_m; %motor constants added to p
p.m = m; p.C_n = C_n; p.C_tn = C_tn; p.R_tn = R_tn; p.R_n = R_n; %tool/nozzle constants added to p
p.T_e = T_e; p.mu_r = mu_r; p.mu_lx = mu_lx; p.mu_ly = mu_ly; p.T_b = T_b; p.d_x = d_x; p.d_y = d_y; %other constants added to p
p.M = M; p.bx = bx; p.by = by; p.g = g; %simplified parameters added to p

