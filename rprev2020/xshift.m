function [Xnew] = xshift(X, P, a, b)
% Statistically Controlled OUTliERs
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
% DESCRIPTION
%
% Performs a shift to each row in X, increasing by factors a and b the
% distance of the observations according to the PCA model expressed in P.
%
% INPUTS
%
% X: data matrix with observations to be shifted.
% P: loading matrix of the PCA model according to which the observations in
%   X will change their distance.
% a: column vector with the factor which tunes the increment of the 
%   Hotelling's T^2 for its corresponding row in X.
% b: column vector with the factor which tunes the increment of the SPE for
%   its corresponding row in X.

% OUTPUTS
%
% Xnew: data matrix with the same dimensions as X, with each observation 
% shifted.
%
narginchk(4,4)
LengthMatchSize(a,X,1);
LengthMatchSize(b,X,1);

I = eye(size(P, 1));
Xnew = nan(size(X));

for ni = 1:size(X, 1)
    Xnew(ni, :) = (X(ni, :) * (I + b(ni) * (I - (P * P'))) * (I + a(ni)...
        * (P * P')));
end

end
%
function LengthMatchSize(arg,B,dimB)
    if (length(arg) ~= size(B,dimB))
        error(['Factor - Num.obs dimension mismatch: ',...
            'numel(factor) is' num2str(length(arg)),'and X has',...
            num2str(size(B,dimB)), 'elements'])
    end
end