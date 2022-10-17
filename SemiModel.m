function [x_sph,x_exp,x_lin,rms_sph,rms_exp,rms_lin]=SemiModel(d,var_semi,d2,var_semi2,Month_label)

% Creates semivariogram Models

max_point=4500;%Stores length of data

d2_i=d';
var_semi2_i=var_semi';

%Removes Data with distance or variance is NAN
d2_i(isnan(d) | isnan(var_semi)) = [];
var_semi2_i(isnan(d) | isnan(var_semi)) = [];

%Creates System of Equations to be solved
fun_sph = @(x)(x(1)+x(2).*(1.5.*(d2_i./x(3))-0.5.*(d2_i./x(3)).^3)).*(d2_i<x(3))+(x(1)+x(2)).*(d2_i>=x(3))-var_semi2_i;
fun_exp = @(x)x(1)+x(2).*(1-exp(-1*d2_i/x(3)))-var_semi2_i;
fun_lin = @(x)(x(1)+x(2).*(d2_i./x(3)).*(d2_i<x(3)))+(x(1)+x(2)).*(d2_i>=x(3))-var_semi2_i;

%Sets Limits on Selection
%[Nugget, Sill, Range]
x0 = [0,80,3000];%Initial Guess
lb = [0, 0, 0];%Lower limit
ub = [0, 1000, 10000];%Upper limit

%Sloves for [Nugget, Sill, Range]
x_sph = lsqnonlin(fun_sph,x0,lb,ub);
x_exp = lsqnonlin(fun_exp,x0,lb,ub);
x_lin = lsqnonlin(fun_lin,x0,lb,ub);

%Creates Models from chosen [Nugget, Sill, Range]
fun2_sph = @(x)(x(1)+x(2).*(1.5.*((0:max_point)./x(3))-0.5.*((0:max_point)./x(3)).^3)).*((0:max_point)<x(3))+(x(1)+x(2))*((0:max_point)>=x(3));
fun2_exp = @(x)x(1)+x(2).*(1-exp(-1*(0:max_point)/x(3)));
fun2_lin = @(x)(x(1)+x(2).*((0:max_point)./x(3)).*((0:max_point)<x(3)))+(x(1)+x(2)).*((0:max_point)>=x(3));

%Calaculates RMSD
rms_sph= sqrt((1/length(d2_i))*sum((var_semi2_i-fun_sph(x_sph)).^2));
rms_exp= sqrt((1/length(d2_i))*sum((var_semi2_i-fun_exp(x_exp)).^2));
rms_lin= sqrt((1/length(d2_i))*sum((var_semi2_i-fun_lin(x_lin)).^2));

%Plots semivariogram
figure()
plot(d2_i,var_semi2_i,'*')
hold on
plot(0:max_point,fun2_sph(x_sph),'LineWidth',2);
plot(0:max_point,fun2_exp(x_exp),'LineWidth',2);
plot(0:max_point,fun2_lin(x_lin),'LineWidth',2);

ylabel('Semivariance [cm]')
legend('Observations','Spherical Model','Exponential Model','Linear Model')
xlabel('Distance [km]')

end