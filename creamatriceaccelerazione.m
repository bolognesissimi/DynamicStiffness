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

function [Matrice] = creamatriceaccelerazione (Segnale, pos, L_pre, L_coda, fs)
% Function che trova i picchi del vettore Forze, usando come Input:
%I1) il segnale Forze;
%I2) il segnale Accelerazioni;
%I3) soglia dei picchi (soglia);
%I4) sample da saltare una volta superata la soglia (delay);
%I5) punto di inizio della ricerca dei picchi (inizio);
%I6) punto di fine della ricerca dei picchi (fine);
%I7) lunghezza della parte prima del picco (L_pre);
%I8) lunghezza della parte dopo del picco (L_coda);
%I9) se filt_doppi=1 i colpi vengono filtrati eliminando i doppi colpi (filt_doppi);
%I10) la frequenza di campionamento in Hz;
%restituendo come Output:
%O1) il numero di picchi selezionati (picchi_sel);
%O2) la matrice delle singole forze (F) sistemate in colonne;
%O3) la matrice delle singole accelerazioni (A) sistemate in colonne.

y=Segnale;

%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
% Definizione delle matrici (selezione dei segnali)
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Matrice=[];
%y_sel=[]; %y_sel contencono tutti i picchi selezionati in un unico vettore
n_picchi=length(pos);
for j = 1: n_picchi
    in  = round(pos(j) - L_pre);
    out = round(pos(j) + L_coda-1);
    
    pre_pad=[];
    post_pad=[];
    if in <= 1
        pre_pad=zeros(-in+1,1);
        in=1;
    end
    if out>length(y)
        post_pad=zeros(out-length(y),1);
        out=length(y);
    end
    
    y_temp = y(in:out)-mean(y(in:out));
    % y_temp = y_temp-mean(y_temp);
    y_temp = [pre_pad; y_temp; post_pad]; %#ok<AGROW>
    
    Matrice = [Matrice, y_temp];    %#ok<AGROW>
    
end

end