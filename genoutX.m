function [Xout, T2X, SPEX] = genoutX(X1, pcaref, T2target, SPEtarget)
if strcmp(pcaref.prepro, 'cent')
    Xaux = X1 - pcaref.m;
elseif strcmp(pcaref.prepro, 'autosc')
    Xaux = (X1 - pcaref.m) ./ repmat(pcaref.s, size(X1, 1), 1);
end
p = size(Xaux, 2);
Xout = [];
P = pcaref.P;
I = eye(p);
T1 = Xaux * P;
E = Xaux - T1 * P';
SPEX = sum(E .^ 2, 2);
T2X = sum(T1 .^ 2 ./ pcaref.lambda, 2);
a = sqrt(T2target ./ T2X) - 1;
b = sqrt(SPEtarget ./ SPEX) - 1;
for ni = 1:size(Xaux, 1)
    x1 = Xaux(ni, :);
    x2 = (x1 * (I + b(ni) * (I - (P * P'))) * (I + a(ni) * (P * P')));
    Xout = [Xout; x2];
end
if strcmp(pcaref.prepro, 'cent')
    Xout = Xout + pcaref.m;
elseif strcmp(pcaref.prepro, 'autosc')
    Xout = (Xout .* repmat(pcaref.s, size(Xout, 1), 1)) + pcaref.m;
end
end