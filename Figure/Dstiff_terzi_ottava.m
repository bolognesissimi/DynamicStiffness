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

function [figure1,figure2,ris ] = Dstiff_terzi_ottava(PSD,...
    freq_range,nomemis,font_size)
%DSTIFF_TERZI_OTTAVA  crea il grafico della rigidità dinamica in bande di
%   terzi d'ottava con relative barre d'errore.
%
%   Input
%   - PSD È una struttura lunga N che contiene le trasformate dei segnali,
%   viene generata dalle funzioni coerenza e rigidita_dinamica.
%
%   Output
%   - figure1 restituisce un array di figure contenente i risultati delle N
%   misure singole composte da n singoli impatti;
%   - figure2 restituisce la figura con i valori medi sulle N misure non
%   affette da errore
%   - mis restituisce i valori di rigidità per le bande comprese in 
%   freq_range delle sole misure non affette da errore
%   - mis_err restituisce i valori di errore di rigidità per le bande
%   comprese in freq_range delle sole misure non affette da errore.

N=length(PSD);

% Centrobanda preferiti da visualizzare a schermo
fcentro_pref = [ 16 20 ...
    25   31.5 40   50   63   80   100   125   160   200 ...
    250  315  400  500  630  800  1000  1250  1600  2000 ...
    2500 3150 4000 5000 6300 8000 10000 12500 16000 20000 ]';

% frequenze su base 10 per la ridistribuzione in bande
% https://en.wikipedia.org/wiki/Octave_band
fcentre = 10.^(0.1.*[12:43]');
fd = 10^0.05;
fupper = fcentre * fd;
flower = fcentre / fd;
% per vederle in un unica tabella
%X_wiki_10 = round([flower fcentre fupper]);

bandrange = find(fcentro_pref >= freq_range(1) & ...
    fcentro_pref <= freq_range(2));
mis = zeros(N,length(bandrange));
mis_err = zeros(N,length(bandrange));
coh = zeros(N,length(bandrange));

ris = struct('f_centrale',fcentro_pref(bandrange)');

% prealloco l'array di figure
figure1 = gobjects(N,1);
axes1 = gobjects(N,1);
bande_trasparenti = cell(1,N);
for i=1:N
    for j=1:length(bandrange)
        I = PSD(i).f >= flower(bandrange(j)) & PSD(i).f < fupper(bandrange(j));
        temp = abs(PSD(i).K_tfest(I,:));
        temp_err = abs(PSD(i).dK_tfest(I,:));
        mis(i,j)= mean (temp)/10^6;
        mis_err(i,j) = mean(temp_err)/10^6;
        
        temp_coh_av = mean(PSD(i).coh(I));
        coh(i,j) = temp_coh_av;
        
        if temp_coh_av<0.9 || mis_err(i,j)/mis(i,j)> 0.1
            bande_trasparenti{i} = [bande_trasparenti{i},j];
        end
        
        % imposto valori negativi a 0
        if mis(i,j)<0
            mis(i,j)=0;
        end
    end
    
    % Creo la figura
    figure1(i)= figure;
    % Creo gli assi
    axes1(i)=axes('Parent', figure1(i));
    hold on
    % Definisco altezza e larghezza in cm e i ppi della figura
    L=18.5; % larghezza in centimetri
    H=8; % altezza in centimetri
    ppi=150; %pizel per pollice
    % Imposto posizione e dimenzioni della figura
    set(figure1(i),'WindowStyle','normal') % Insert the figure to dock
    figure1(i).OuterPosition = ([100,0,L/2.54*ppi,H/2.54*ppi]); %determino dimensioni grafico
    
    % colore trasparente
    trasp = [127 184 222]/255;
    
    % Stampo le barre della rigidità
    bars1 = bar(bandrange,mis(i,:));
    bars1.FaceColor = 'flat';
    for j=1:length(bande_trasparenti{i})
        bars1.CData(bande_trasparenti{i}(j),:) = trasp;
    end
    % Stampo le barre d'errore
    er = errorbar(bandrange,mis(i,:),mis_err(i,:),mis_err(i,:));
    % Impostazioni delle barre di errore
    set(er,'Color',[0 0 0],'LineStyle','none')
    % Setto nomi etichette asse x
    %figure1.Children.XTick = (bandrange);
    axes1(i).XTick = (bandrange);
    axes1(i).XTickLabel = (fcentro_pref(bandrange));
    
    
    % Set the remaining axes properties
    set(axes1(i),'FontName','Arial','XGrid','on','YGrid','on',...
        'YLim',[0 200]);%1.2*max(mis(i,:))]);
    % Create ylabel
    ylabel('Rigidità Dinamica [MN/m]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
    % Create xlabel
    xlabel('Bande di 1/3 d''ottava [Hz]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
    % Create title
    if PSD(i).alert
        title(['Rigidità Dinamica - ',nomemis{i},'*'],'FontSize',font_size.fs_title,'FontName','Arial');
    else
        title(['Rigidità Dinamica - ',nomemis{i}],'FontSize',font_size.fs_title,'FontName','Arial');
    end
    % Creo il box intorno alla figura
    box(axes1(i),'on');
    
    hold off
    % Esporto la figura
%     exportgraphics(figure1(i), [nomemis{i},' bande_terzi_ottava.pdf'],...
%        'ContentType','vector')
end

% Salvo misura e errore in risultati
ris.k = mis;
ris.dk = mis_err;
ris.c = coh;

%figura con media

% inizializzo figura
figure2= figure;

% elimino le misure con problemi
I=[]; % conterrà le righe da cancellare
for i=1:N
    if PSD(i).alert %se la misura non è buona
        I=[I,i];
    end
end
mis(I,:)=[];
mis_err(I,:)=[];
% calcolo valori medi
[r,~]=size(mis);
if r>0
    mis_av=mis;
    mis_err_av = mis_err;

    if r>1
        mis_av = mean(mis);
        mis_err_av = (sum(mis_err.^2)).^(1/2);
    end
 
    % Creo gli assi
    axes2=axes('Parent', figure2);
    hold on
    % Definisco altezza e larghezza in cm e i ppi della figura
    L=18.5; % larghezza in centimetri
    H=8; % altezza in centimetri
    ppi=150; %pizel per pollice
    % Imposto posizione e dimenzioni della figura
    set(figure2,'WindowStyle','normal') % Insert the figure to dock
    figure2.OuterPosition = ([100,0,L/2.54*ppi,H/2.54*ppi]); %determino dimensioni grafico
    % Stampo le barre dell'assorbimento
    bar(bandrange,mis_av);
    % Stampo le barre d'errore
    er2 = errorbar(bandrange,mis_av,mis_err_av,mis_err_av);
    % Impostazioni delle barre di errore
    set(er2,'Color',[0 0 0],'LineStyle','none')
    % Setto nomi etichette asse x
    %figure1.Children.XTick = (bandrange);
    axes2.XTick = (bandrange);
    axes2.XTickLabel = (fcentro_pref(bandrange));
    
    % Set the remaining axes properties
    set(axes2,'FontName','Arial','XGrid','on','YGrid','on',...
        'YLim',[0 200]);%1.2*max(mis_av)]);
    % Create ylabel
    ylabel('Rigidità Dinamica [MN/m]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
    % Create xlabel
    xlabel('Bande di 1/3 d''ottava [Hz]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
    % Create title
    flag=1;
    for i=1:N
        flag=flag+PSD(i).alert;
    end
    if flag>0
        title(['Rigidità Dinamica - Media*'],'FontSize',font_size.fs_title,'FontName','Arial');
    else
        title(['Rigidità Dinamica - Media'],'FontSize',font_size.fs_title,'FontName','Arial');
    end
    % Creo il box intorno alla figura
    box(axes2,'on');
    hold off
end
end