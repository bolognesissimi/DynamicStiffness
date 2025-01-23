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

function [sng,fs,conf] = import_segnali(sens_forza,sens_acc)
% IMPORT_SEGNALI
%Imporing data from folder

%files = dir(fullfile(currentFolder));
files = dir ('*.wav'); % cerco file .wav nella directory attuale
for i = 1 :length(files)
    [dati(i).data, dati(i).fs] = audioread(files(i).name); % importo i file
end
% cerco il pattern di salvataggio della scheda Apollo
for i = 1:length(files)
    % la scheda apollo scrive i moltiplicatori nel filename dentro due
    % parentesi tonde e separati da virgole
    par1 = find(files(i).name == '(');
    par2 = find(files(i).name == ')');
    dot1 = find(files(i).name == ',');

    pos = [par1 dot1 par2];

    if ~isempty(par1) % Se trovo pattern applico moltiplicatori
        disp('Trovati moltiplicatori nel nome file.')
        molt = zeros(length(pos)-1,1);
        for j = 1:(length(molt))
            molt(j) = str2double(files(i).name(pos(j)+1: pos(j+1)-1));
        end
    else % se non lo trovo applico moltiplicatori scheda NI
        disp('Applico moltiplicatori di default: 2000 500 500 500')
        molt = [2000 500 500 500];
        % assumo sempre che il martello venga acquisito
        % se ho meno segnali taglio molt di conseguenza
        [~,c] = size (dati(i).data);
        molt = molt(1:c);
    end
    dati(i).molt = molt; % salvo moltiplicatori in dati
    %sound(data(:,1),fs); %To hear sound
    dati(i).date = files(i).date; % salvo le date di creazione dei file
end
% carico le tabelle di configurazione, in futuro comincerò ad avere solo il
% file conf.mat
files2 = dir ('dati*');
if ~isempty(files2)
    disp('"dati" file found:')
    disp(length(files2))
    if length(files2) == length(dati)
        for i=1:length(files2)
            temp = load(files2(i).name,'conf');
            dati(i).conf = temp.conf;
        end
    else
        % 2024 12 17 sovrascrivo il file conf a tutti i dati in
        temp = load(files2(1).name,'conf');
        for i = 1:length(dati)
            dati(i).conf = temp.conf
        end

    end
end

N = length (dati); % numero misure analizzate contemporaneamente
% in caso di registrazione con Apollo moltiplico i dati per il fattore
% moltiplicativo
for i=1:N
    dati(i).data = dati(i).data .* dati(i).molt';
end
% Costruisco la struttura delle configurazioni
% contiene le configurazini delle misure
conf = struct('conf',cell(1,N));
%conf.conf = dati(1).conf;
for i = 1:N
    conf(i).conf = dati(i).conf;

    % inserisco in conf le date di acquisizione delle misure
    conf(i).conf.date = files(i).date(1:end-9);
end

fs = vertcat (dati.fs); % vettore delle frequenze di compionamento
misure = cell(N,1); % serve per generare le struct della giusta dimensione

% Creo la tabella 'piastre' che contiene le specifiche delle pianste di
% carico e dei sensori
[piastre] = tabella_piastre();

% Creo il vettore di tabelle 'campioni'. Ciascuna delle quale contiene le
% specifiche dei campioni in funzione della piastra utilizzata nella
% specifica misura:
% - per i campioni non cambia nulla
% - per le pavimentazioni stradali la superficie è pari alla superficie
%   dela piastra utilizzata
campioni = cell(1,N);
for i=1:N
    [campioni{i}] = tabella_campioni (conf(i).conf, piastre);
end

disp('Importo forza e accelerazione')
tic
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
% Importazione di forza e accelerazione
%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
% Parametri fisici
% div_f e div_a non servono con la Apollo perchè si usa la variabile 'molt'
%[g,div_F,div_A,~] = parametri_fisici();
g=9.81;
% i parametri di calibrazione sono un po' vecchi
[cal_f, cal_a] = parametri_calibrazione();
% Calibrazione di forza e accelerazione
% Definisco sng struttura con i segnali nel dominio del tempo
sng = struct('x',misure,'y',[]);
% per testaimp con National con segnali tagliati
for i = 1:N
    [r,c]=size(dati(i).data);
    if c==4 % misure con 4 segnali (di solito con lab view)
        switch sens_forza
            case 'hammer'
                sng(i).x = dati(i).data(:,1);

            case 'head'
                sng(i).x = dati(i).data(:,3);
        end
        %il canale dell'accelerazione è il n° conf(i).conf.accelerometro+2
        switch sens_acc
            case 'acc'
                sng(i).y = dati(i).data(:,conf(i).conf.accelerometro+2);

            case 'head'
                sng(i).y = dati(i).data(:,conf(i).conf.accelerometro+4);
        end
        % 2024 12 17 Per le registrazioni con 3 segnali, fatte ora con iPools
    elseif c==3 % misure con 3 segnali (di solito con lab view)
        switch sens_forza
            case 'hammer'
                sng(i).x = dati(i).data(:,1);

            case 'head'
                sng(i).x = dati(i).data(:,2);
        end
        %il canale dell'accelerazione è il n° conf(i).conf.accelerometro+2
        switch sens_acc
            case 'acc'
                sng(i).y = dati(i).data(:,3);

            case 'head'
                sng(i).y = dati(i).data(:,3);
        end
    else % misure con 2 segnali (di solito con apollo)
        sng(i).x = dati(i).data(:,1);
        %il canale dell'accelerazione è il n° conf(i).conf.accelerometro+2
        sng(i).y = dati(i).data(:,conf(i).conf.accelerometro+2);
    end
end

for i = 1:N
    sng(i).x = cal_f * sng(i).x;
    sng(i).y = cal_a * g * sng(i).y; %inverto il segno per rendere forza e accelerazione coerenti
end
% Plot dei segnali
for i=1:N
    L = length(sng(i).x);
    dt=1/fs(i); time=(0:dt:L/fs-dt);
    figure (i);
    subplot(2,1,1), hold on, plot (time, sng(i).x);
    xlabel('Tempo [s]','FontSize',14);
    ylabel('Forza [N]','FontSize',14);
    box('on');
    grid('on');

    subplot(2,1,2), hold on, plot (time, sng(i).y);
    ylabel('Accelerazione [m/s^2]','FontSize',14);
    xlabel('Tempo [s]','FontSize',14);
    box('on');
    grid('on');
    hold off
end

toc

end