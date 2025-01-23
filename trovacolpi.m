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

function [picchi,n_picchi] = trovacolpi (Forze, soglia, delay, inizio, fine)
% trovacolpi trova i picchi del vettore Forze, usando come Input: 
%I1) il segnale Forze; 
%I2) soglia dei picchi (soglia);
%I3) sample da saltare una volta superata la soglia (delay);
%I4) punto di inizio della ricerca dei picchi (inizio);
%I5) punto di fine della ricerca dei picchi (fine);
%restituendo come Output: 
%O1) le posizioni dei picchi trovati
%O2) il numero di picchi selezionati (picchi_sel); 

x2=abs(Forze);
picchi=[];
ii=inizio;
while   ii < fine(1)
    if  x2(ii) > soglia
        picchi = [picchi; ii];
        ii=ii+delay;
    end
    ii=ii+1;
end
%Calcolo del numero di picchi
n_picchi = length(picchi);
end