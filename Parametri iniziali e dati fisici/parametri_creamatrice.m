%
% Copyright (C) 2022 Matteo Bolognese
%
%    This file is part of DynamicStiffness.
%
%    DynamicStiffness is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    DynamicStiffness is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with DynamicStiffness.  If not, see <http://www.gnu.org/licenses/>.

function [Lsample,L_pre,L_coda] = parametri_creamatrice()
%parametri_creamatrice Dimensioni dei campioni e disposizione degli stessi
%nel take.
Lsample=2^14;
Lsample=2^14;
%Lsample=52100;

L_pre=round((Lsample/20)); % Lunghezza della parte prima del picco
L_coda=round(Lsample-L_pre); % Lunghezza della coda dei segnali
end

