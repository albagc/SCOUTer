function [pcamodel] = pcamb_classic(X, ncomp, alpha, prepro)
% Statistically Controlled OUTliers 
% A. Gonzalez Cebrian, A. Folch-Fortuny, F. Arteaga and A. Ferrer
% Copyright (C) 2020 A. Gonzalez Cebrian, A. Folch-Fortuny and F. Arteaga
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%% DESCRIPTION 
% Performs PCA Model Building using the data in X using the SVD approach.
%
%% INPUTS
% X: double matrix of dimensions _NxK_ with observations used for the 
%   PCA-MB.
% ncomp: integer indicating the number of Principal Components of the 
%   model.
% alpha (optional): value of the Type I risk assumed for the Upper 
%   Control Limits (UCL) calculation. Default value set to alpha = 0.05.
% prepro (optional): string indicating preprocessing applied to X, its 
%   possible values are 'cent', 'autosc' or 'none'. Default value set
%   to 'none'.
%
%% OUTPUTS
% pcamodel : struct returning the parameters of the PCA model fit with 
%   data in X. Fields:
%   - m: mean vector (1 x K).
%   - s: mean vector (1 x K).
%   - P: loading matrix (K x ncomp).
%   - Pfull: loading matrix (K x K).
%   - lambda: vector with variances of the scores (1 x ncomp).
%   - limspe: Upper Control Limit (for alpha value) for the SPE.
%   - limt2: Upper Control Limit (for alpha value) for the T^2.
%   - prepro: string indicating preprocessing applied to X.
%   - ncomp: integer indicating the number of PCs of the model.
%   - alpha: value of the Type I risk assumed for the UCL.
%   - n: number of observations used in the PCA-MB.
%   - S: covariance matrix of observations used in the PCA-MB.
%   - limits_t: Control Limits for the scores with a confidence
%       level (1- alpha)x100 % 
%% Matlab Code 
if nargin == 2
    alpha = 0.05;
    prepro = 'none';
elseif nargin == 3
    prepro = 'none';
end
% PCA Model Building
m = mean(X);
s = std(X);
n = size(X, 1);
if strcmp(prepro, 'cent')
    Xaux = X - m;
elseif strcmp(prepro, 'autosc')
    Xaux = (X - m) ./ repmat(s, n, 1);
elseif strcmp(prepro, 'none')
    Xaux = X;
end
[~, D, V] = svd(Xaux);
P = V(:, 1:ncomp);
Tfull = Xaux * V;
T = Xaux * P;
E = Xaux - T * P';
SPE = sum(E .^ 2, 2);
Lambda = var(T);
LambdaE = eig(cov(E));
lambda = Lambda(1 : ncomp);
T2 = sum(T .^2 ./ repmat(lambda, n, 1), 2);
if strcmp(prepro, 'cent')
    Xrec = T * P' + m;
elseif strcmp(prepro, 'autosc')
    Xrec = (T * P') .* repmat(s, n, 1) + m;
end
% SPE upper control limit
theta1 = sum(LambdaE(ncomp + 1 : end));
theta2 = sum(LambdaE(ncomp + 1 : end) .^ 2);
theta3 = sum(LambdaE(ncomp + 1 : end) .^ 3);
h0 = 1 - 2 * theta1 * theta3 / (3 * theta2 ^ 2);
z_alpha = norminv(1 - alpha);
spe1 = z_alpha * sqrt(2 * theta2 * h0 ^ 2) / theta1;
spe2 = theta2 * h0 * (h0 - 1) / (theta1 ^ 2);
cl_spe = theta1 * ((spe1 + 1 + spe2) ^ (1 / h0));
% T2 upper control limit
F_alpha = finv(1 - alpha, ncomp, n - ncomp);
cl_t2 = (n ^ 2 - 1) * ncomp / (n * (n - ncomp)) * F_alpha;
% Limits for scores
z = ((n - 1) * (n - 1) / n) * betainv(1 - alpha, 1, (n - 3) / 2);
limits_t = struct();
for i = 1:size(Tfull,2)
    limits_t.(strcat('pc',string(i))) = [-sqrt(var(Tfull(:, i)) * z), ...
        sqrt(var(Tfull(:, i)) * z)];
end

% Output struct with PCA model elements       
pcamodel.m = m;
pcamodel.s = s;
pcamodel.P = P;
pcamodel.Pfull = V;
pcamodel.lambda = lambda;
pcamodel.limspe = cl_spe;
pcamodel.limt2 = cl_t2;
pcamodel.prepro = prepro;
pcamodel.ncomp = ncomp;
pcamodel.alpha = alpha;
pcamodel.n = n;
pcamodel.S = cov(X);
pcamodel.limits_t = limits_t;
end

function mustBeInRange(arg,b)
    if (arg < b(1)) || (arg > b(2))
        error(['Value assigned to Data is not in range ',...
            num2str(b(1)),'...',num2str(b(2))])
    end
end
function mustBeInRangeSize(arg,B,dimB)
    if (arg < 2) || (arg > size(B,dimB))
        error(['Value assigned to Data is not in range ',...
            num2str(2),'...',num2str(size(B,dimB))])
    end
end