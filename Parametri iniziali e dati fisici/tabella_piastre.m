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

function [piastre] = tabella_piastre()
%UNTITLED genera una tabella con tutte le specifiche delle piastre
%utilizzate
%   Non richiede parametri di imput.
piastre_mass =  [0.03;0; 0.006;  0.1967; 0.6274; 0.6249; 1.4293; 2.8871; 15;...
    0.001;0.001;0.008];
piastre_h =     [0.02875;0; 0.0018; 0.008;  0.008;  0.008;  0.024;  0.0475;...
    0.16;0.002;0.002;0.005];
piastre_d =     [0.017;01; 0.026;  2*sqrt(0.056*0.057/pi); 2*sqrt(0.1*0.1/pi); ...
    2*sqrt(0.1*0.1/pi); 0.1; 0.1;2*sqrt(0.25*0.25/pi);0.02;0.02;0.02];
piastre = table(piastre_mass,piastre_h,piastre_d);
piastre.Properties.RowNames={'testaimp','mini','piastrina','quadrata_piccola',...
    'quadrata1','quadrata2','pesante1','pesante2','blocco','quadrata_2mm',...
    'tonda_2mm','top'};
piastre.Properties.VariableNames={'massa','h','d'}
end

