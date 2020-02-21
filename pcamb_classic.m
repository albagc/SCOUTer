function [pcamodel] = pcamb_classic(X, ncomp, alpha, prepro)
m = mean(X);
s = std(X);
n = size(X, 1);
if strcmp(prepro, 'cent')
    Xaux = X - m;
elseif strcmp(prepro, 'autosc')
    Xaux = (X - m) ./ repmat(s, n, 1);
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

        
pcamodel.m = m;
pcamodel.s = s;
pcamodel.P = P;
pcamodel.Pfull = V;
pcamodel.T = T;
pcamodel.Xrec = Xrec;
pcamodel.E = E;
pcamodel.SPE = SPE;
pcamodel.lambda = lambda;
pcamodel.T2 = T2;
pcamodel.limspe = cl_spe;
pcamodel.limt2 = cl_t2;
pcamodel.prepro = prepro;
pcamodel.ncomp = ncomp;
pcamodel.alpha = alpha;
pcamodel.n = n;
pcamodel.S = cov(X);
pcamodel.limits_t = limits_t;
end