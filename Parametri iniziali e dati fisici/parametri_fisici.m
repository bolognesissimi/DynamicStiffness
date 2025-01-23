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

function [g,div_F,div_A,fs] = parametri_fisici()
% Parametri_fisici
% sensit_F=1/1000;      % Sensibilità Martello strumentato [V/N]
% sensit_A1=1/1000;%95.8/1000;    % Sensibilità Accelerometro1 [V/g]
% sensit_A2=1/1000;%0.03/1000;   % Sensibilità Accelerometro2 [V/g]
g=9.81;                 % Accelerazione di gravità [m/s^2]
div_F=2000;             % Divisione applicata alla Forza prima della scrittura sul file WAVE
div_A=500;              % Divisione applicata alla Accelerazione prima della scrittura sul file WAVE
fs=52100;               % Freq. di campionamento (Hz);
end

