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

function [sng, figure1] = finestratura(sng, wintype, L_win, fs, font_size)
%FINESTRATURA  Finestratura dei segnali di forza e accelerazione

N = length(sng);
[Lsample,~] = size(sng(1).F);

% Finestratura Accelerazione

% M_win è l'ordine della finestratura:
% la lunghezza del fronte di salita + fronte di discesa
M_win = ones(N,1)*L_win; %min (ceil(10.*fs/1000), Lsample/4); % 10ms
% Inizializza win_a
sng(1).win_A=[];
taglio_forzato=0; %se =1 taglio la parte iniziale del segnale
if wintype == 'none' %#ok
    for i=1:N
        win_A = ones(Lsample,1);
        [~,c] = size(sng(i).F);
        for j=1:c
            sng(i).win_A(:,j)=win_A;
        end
    end
else
    for i=1:N
        switch wintype
            case 'hann'
                curve = hann(M_win(i));
            case 'rect'
                curve = ones(M_win(i),1);
        end
        [~,c] = size(sng(i).F);
        % per ciascun colpo trovo la dimensione di finestra giusta
        for j=1:c
            %decim_max_temp=[];
            max_temp=find(abs(sng(i).A(:,j))==max(abs(sng(i).A(:,j)))); % massomo dell'accelerazione
            % cerco tutti i punti per cui il segnale è maggiore di
            % max_temp/100
            decim_max_temp = find(abs(sng(i).A(:,j))> abs(sng(i).A(max_temp(1),j))/10);
            % cerco l'untimo punto in cui il segnale è maggiore del 90%del massimo
            ultimo90percent = find(abs(sng(i).A(:,j))> abs(sng(i).A(max_temp(1),j))*0.9);
            %plateau_1 = ones(round((r-M_win-1)*L_plateau), 1);
            %plateau_0 = zeros((r-M_win-1) - round((r-M_win-1)*L_plateau), 1);

            % La lunghezza del plateau sarà il valore minimo tra la
            % massima possibile pari a (Lsample-M_win-2) e la lunghezza
            % della sezione del segnale compresa tra il primo massimo
            % e l'ultimo punto maggiore di max/2 moltiplicata per un
            % fattore log(100)/log(2) perché si dovrebbe cercare il
            % punto dove il segnale diminuisce di 100 volte. a questa
            % lunghezza si somma la posizione del massimo rispetto al

            % fine del fronte di salita
            % L_plateau1 = min( round((decim_max_temp(end) - ...
            %     max_temp(1))*log(100)/log(2)+max_temp(1)-M_win(i)/2),...
            %     Lsample-M_win(i)-2 );

            % L plateau calcolato a partire dal massimo
            L_plateau1 = min(round(2*(decim_max_temp(end)-max_temp(1))+...
                max_temp(1)), Lsample-M_win(i));

            % Lplateau calcolato a partire dal 90%
            L_plateau1 = min(round(2*(decim_max_temp(end)-ultimo90percent(end))+...
                max_temp(1))-length(curve(1:ceil(end/2))), Lsample-M_win(i));

            %Finestratura molto larga
            %L_plateau1 =  Lsample-M_win(i);

            plateau_1 = ones(L_plateau1, 1);
            length(curve(1:ceil(end/2)))
            plateau_0 = zeros(Lsample-L_plateau1-M_win(i), 1);
            t = ones(size(curve(1:ceil(end/2))));
            % t = curve(1:ceil(end/2));
            win_A = [t; plateau_1; ...
                curve((end/2+1):end); plateau_0];
            win_A(1)=0;
            sng(i).win_A(:,j) = win_A;
            % taglio la prima parte del segnale che corrisponde
            % temporalmente all'impatto del martello
            if taglio_forzato
                precut = zeros(1,round(22/1000*fs))'; %#ok
                temp = [precut; sng(i).win_A(:,j)];
                L = length(sng(i).A(:,j));
                sng(i).win_A(:,j) = temp(1:L);
            end
            sng(i).E_win(j)=sum(sng(i).win_A(:,j).^2)/length(sng(i).win_A(:,j));
        end
    end
end

% Generazione finestra Forza
% cerco il massimo della forza e creo una finestra lunga il doppio della
% distanza tra l'inizio dei picco e il suo massimo.

M_win_F = ones(N,1)*L_win;% round(5.*fs/1000); % 5ms
for i=1:N
    curve = hann(M_win_F(i));
    [M,I]=max(sng(i).F); %#ok
    % Per ciascun segnale genero una finestra apposita
    for j=1:length(I)

        %L_win_F = L_pre+round(2.25*fs/1000)+M_win/2; % lunghezza plateau
        %iniziale
        %L_win_F = round(I(j)+1.5*(I(j)-L_win));
        L_win_F = round(1.2*L_win);
        %win_F = [ones(L_win_F-(M_win/2),1); curve(end/2:end-1); zeros(Lsample-L_win_F,1)];
        temp = [ones(L_win_F+1,1); curve(end/2:end-1); ...
            zeros(length(sng(i).F(:,1)),1)];
        sng(i).win_F(:,j)=temp(1:length(sng(i).F(:,1)));
        % imposto nuovamente il primo valore di f pari a 0, ma l'ho già fatto.
        sng(i).win_F(1,j) = 0;
    end
end

% Vettore tempo in ms
dt = 1./fs;
time1=zeros(Lsample,N);
for i=1:N
    time1(:,i) = 1000*(0:dt(i):Lsample/fs(i)-dt(i));
end

% Finestratura
for i = 1:N
    sng(i).F_filt = sng(i).F  .* sng(i).win_F;
    sng(i).A_filt = sng(i).A  .* sng(i).win_A;
end

% Figura finestratura segnali
% Rappresento la finestra e i segnali prima e dopo l'applicazione della
% finestra
for i=1:N
    figure1(i)= figure; %#ok<AGROW>

    % Definisco altezza e larghezza in cm e i ppi della figura
    L=14; % larghezza in centimetri
    H=12; % altezza in centimetri
    ppi=150; %pizel per pollice
    % Imposto posizione e dimenzioni della figura
    set(figure1(i),'WindowStyle','normal') % Insert the figure to dock
    % determino dimensioni grafico
    figure1(i).OuterPosition = ([100,0,L/2.54*ppi,H/2.54*ppi]);

    %titolo della figura intera
    sgtitle(figure1(i),'Finestratura','FontSize',font_size.fs_sgtitle);
    % Titoli dei subplot
    Titoli={'Forza','Accelerazione'};
    % Genero i subplot
    for j=1:2
        subplot1(j) = subplot(2,1,j,'Parent',figure1(i)); %#ok<AGROW>
        hold (subplot1(j), 'on')
        title(Titoli{j},'FontSize',font_size.fs_title,'FontName','Arial');
    end
    % plot forza
    plot(subplot1(1),time1(:,i),sng(i).F_filt(:,1)/max(sng(i).F(:,1)),...
        'DisplayName','Segnale filtrato','LineWidth',3,...
        'Color',[0.2 0.2 0.2]);
    plot(subplot1(1),time1(:,i),sng(i).F(:,1)/max(sng(i).F(:,1)),...
        'DisplayName','Segnale originale','LineWidth',2, 'LineStyle','--' ,...
        'Color',[1 0.5 0.5]);
    plot(subplot1(1),time1(:,i),sng(i).win_F(:,1),...
        'DisplayName','Finestra','LineWidth',2);
    legend (subplot1(1),'FontSize',font_size.fs_legend, 'Location','best');

    % plot accelerazione
    plot(subplot1(2),time1(:,i),sng(i).A_filt(:,1)/max(sng(i).A(:,1)),...
        'DisplayName','Segnale filtrato','LineWidth',3,...
        'Color',[0.2 0.2 0.2]);
    plot(subplot1(2),time1(:,i),sng(i).A(:,1)/max(sng(i).A(:,1)),...
        'DisplayName','Segnale originale','LineWidth',2, 'LineStyle','--',...
        'Color',[1 0.5 0.5]);
    plot(subplot1(2),time1(:,i),sng(i).win_A(:,1),...
        'DisplayName','Finestra','LineWidth',2);
    legend (subplot1(2),'FontSize',font_size.fs_legend, 'Location','best');

    % Impostazione parametri finali
    for j=1:2
        set(subplot1(j),'Ylim',[-0.05 1.05], ...
            'Xlim', [0 time1(end,i)], ...[1000*L_pre/fs(1)/2 1000*3*L_pre/fs(1)/2],...
            'XGrid','on','YGrid','on')
        xlabel(subplot1(j),'Tempo [ms]','FontWeight','bold',...
            'FontSize',font_size.fs_label,'FontName','Arial');
        box(subplot1(j),'on');
    end

end
end