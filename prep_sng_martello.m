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

function [sng,L_sample,L_pre,L_coda] = prep_sng_martello(sng,fs,filtro)
% PREP_SNG_MARTELLO estrae i segnali degli impatti dalle registrazioni in
% sng e costruisce delle matrici con forza e accelerazione 

%<<<<<<<<<<<<<<<<<<<<<<<<
% Parametri di controllo
%<<<<<<<<<<<<<<<<<<<<<<<<
% Parametri di ricerca
N=length(sng);
fine = cell(1,N);
for i = 1:N
    [soglia,delay,inizio,fine{i}] = parametri_ricerca_picchi(fs(i),sng(i).x);
end

% Parametri di creazione dei campioni
[L_sample,L_pre,L_coda] = parametri_creamatrice();

% Parametri di filtro
bandwidth = 0; % Se bandwidth =!0 e =c vengono tenuti sonolo i segnali con bandwidth >=c
filt_doppi = 0; % Se filt_doppi=1 i colpi vengono filtrati eliminando i doppi colpi


%<<<<<<<<<<<<<<<
% Ricerca Colpi
%>>>>>>>>>>>>>>>
picchi1 = cell(1,N); %posizioni dei picchi trovati inizialmente
n_picchi = cell(1,N); %numero dei picchi trovati inizialmente

if filtro == 0 % uso trovacolpi
    disp('Utilizzo trovacolpi');
    tic
    for i=1:N
        [picchi1{i}, n_picchi{i}] = trovacolpi(sng(i).x, soglia, delay, inizio, fine{i});
        %n_picchi{i} %#ok<NOPTS>
    end
    toc
else % Uso findpeaks
    disp('utilizzo findpeaks')
    tic
    %parametri per findpeaks
    prominanza = 10;%25;
    distanza = 0.7;
    larghezza = 15;
    fpass = 35 %#ok<NOPTS>
    
    picchi_t = cell(1,N);
    p = cell(1,N);
    w = cell(1,N);
    x_Hpass = cell(1,N);
    for i=1:N
        x_Hpass{i} = highpass(sng(i).x,fpass,fs(i));
    end
    
    for i=1:N
        [pks1,picchi_t{i},w{i},p{i}] = findpeaks(x_Hpass{i}(1:end),fs(i),...
            'MinPeakProminence',prominanza,'MinPeakDistance',...
            distanza,'Annotate','extents');
        picchi_t{i}=picchi_t{i}(w{i}<larghezza);
        
        pks1=pks1(w{i}<larghezza);
        picchi1{i} = picchi_t{i}*fs(i); % posizioni dei picchi = tempo * fs
        n_picchi{i} = length(picchi1{i}) %#ok<NOPTS>
        
        figure (i)
        subplot(2,1,1), hold on, plot(picchi_t{i},pks1,'*');
        findpeaks(x_Hpass{i},fs(i),'MinPeakProminence',prominanza,...
            'MinPeakDistance',distanza,'Annotate','extents');
        sng(i).x = x_Hpass{i};
    end
    toc
    % sostituisco la forza con la forza filtrata
    for i=1:N
        sng(i).x = x_Hpass{i};
    end
end

%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
% Definizione delle matrici (selezione dei segnali)
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
pos = cell(1:N);
picchi_sel1 = zeros(1,N);
for i = 1:N
    [sng(i).F, pos{i}] = creamatriceforza_noavg (sng(i).x, picchi1{i},...
        n_picchi{i}, L_pre, L_coda, filt_doppi, fs(i));
    
    [sng(i).A] = creamatriceaccelerazione (sng(i).y, pos{i}, L_pre,...
        L_coda, fs(i));
    % shift per misurare il rumore al posto del segnale
    [sng(i).A_noise] = creamatriceaccelerazione (sng(i).y, pos{i}+round(51200/1000*50), L_pre,...
        L_coda, fs(i));
    [sng(i).F_noise] = creamatriceaccelerazione (sng(i).x, pos{i}+round(51200/1000*50), L_pre,...
        L_coda, fs(i));
    picchi_sel1(i) = length(pos{i});
end
picchi_sel1 %#ok<NOPTS>
end