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

function [cal_f,cal_a] = parametri_calibrazione()
%parametri_calibrazione
% Fornisce i parametri di caibrazione per i segali di forza e accelerazione
% per ora utilizza valori fissi, ma a tendere dovrebbe usare valori in base
% alla calibrazione più recente sisponibile

cal_f = 0.976250497177942;
cal_a = mean ([0.9654 0.9659 0.9604]);
end