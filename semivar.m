function [dists,var_semi]=semivar(dis_matrix,SD,delta)
% Calculates the semivariance of inputted data

% Creates Distance Matrix between every point
sn_matrix=(squareform(pdist(SD,@(x,y) x-y)));

%Creates matrixes without repeated values
var_dis = triu(dis_matrix,1);
var_sd  = triu(sn_matrix,1);

%Makes vectors that store triangle matrix
var_dis = var_dis(:);
var_sd  = var_sd(:);
i=1;

for d = delta:2*delta:5000
    
lag = var_dis(var_dis < d+delta & var_dis >= d-delta);%Vector of Distances in lag range
lag_sd = var_sd(var_dis < d+delta & var_dis >= d-delta);% Vector of Variances in lag range
var_semi(i) = 1/(2*length(lag)) * nansum(lag_sd.^2);%calculates variance for lag
ll(i) = length(lag);
i=i+1;
end

%creates vector of lags
dists = delta:2*delta:5000;
end