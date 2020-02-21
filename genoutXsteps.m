function [Xout, SPE_X, T2_X, spesteps, t2steps] = genoutXsteps(Matref, pcaref, T2_target, SPE_target, nsteps)
if strcmp(pcaref.prepro, 'cent')
    Xaux = Matref - pcaref.m;
elseif strcmp(praref.prepro, 'autosc')
    Xaux = (Matref - pcaref.m) ./ repmat(pcaref.s, size(Matref, 1), 1);
end
p = size(Xaux, 2);
Xout = [];
P = pcaref.P;
I = eye(p);
T1 = Xaux * P;
E = Xaux - T1 * P';
SPE_X = sum(E .^ 2);
T2_X = sum(T1 .^ 2 ./ pcaref.lambda);
spesteps = linspace(SPE_X, SPE_target, nsteps);
t2steps = linspace(T2_X, T2_target, nsteps);

for k = 1:nsteps
    b = sqrt(spesteps(k) ./ SPE_X) - 1;
    a = sqrt(t2steps(k) ./ T2_X) - 1;
    for ni = 1:size(Xaux, 1)
        x1 = Xaux(ni, :);
        x2 = (x1 * (I + b * (I - (P * P'))) * (I + a * (P * P')));
        Xout = [Xout; x2];
    end
end

if strcmp(pcaref.prepro, 'cent')
    Xout = Xout + pcaref.m;
elseif strcmp(praref.prepro, 'autosc')
    Xout = (Xout .* repmat(pcaref.s, size(Xout, 1), 1)) + pcaref.m;
end
end