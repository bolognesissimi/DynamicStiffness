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

function [Matrice, pos] = creamatriceforza_noavg (Segnale, picchi,n_picchi, L_pre, L_coda, filt_doppi, fs)
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

x=Segnale;

%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
% Definizione delle matrici (selezione dei segnali)
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
Matrice=[];
pos=[];
for j = 1: n_picchi
    in  = round(picchi(j) - L_pre);
    out = round(picchi(j) + L_coda-1);
    
    pre_pad=[];
    post_pad=[];
    if in <= 1
        pre_pad=zeros(-in+1,1); %#ok<NASGU>
        in=1;
    end
    if out>length(x)
        post_pad=zeros(out-length(x),1);
        out=length(x);
    end
    x_temp = x(in:out)-x(in); % prendo il segnale fino alla fine
    x_temp = [pre_pad; x_temp; post_pad]; %#ok<AGROW>
    
    %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    % Filtraggio per doppio colpo
    %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if filt_doppi==1
        n_colpi = findpeaks(x_temp,fs,'MinPeakDistance',0.002,'Threshold',0,'MinPeakHeight',5);
    else
        n_colpi = 1;  % i colpi non vengono filtrati
    end

    %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    % Filtraggio per intensità del colpo
    %<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if  length(n_colpi) == 1 %&& max(x_temp)>= 80 && (max(x_temp) <=150)
        Matrice = [Matrice, x_temp];
        pos=[pos,picchi(j)];
    end

% j = j+1;
end

end