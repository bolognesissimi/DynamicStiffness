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

function [soglia,delay,inizio,fine] = parametri_ricerca_picchi(fs,x)
%UNTITLED4 Parametri per la ricerca dei picchi
soglia=10;              % Soglia dei picchi;
delay=round(15*fs/1000);    % Sample da saltare una volta superata la soglia
inizio=1;            % Punto di inizio della ricerca dei picchi;
fine=round(0.98*length(x));           % Punto di fine della ricerca dei picchi

end

