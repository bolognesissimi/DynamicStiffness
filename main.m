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

%% File di configurazione
conf = []; %#ok<NASGU>

% In configuration mettiamo degli indici che ci dicono il campione
% utilizzato, la piastra di carico, la superficie d'appoggio l'adesivo e
% la punta del martello. Il file conf serve per far girare main.m e per
% scrivere il nome del file dei risultati con i parametri della misura.
% Campione:
%     'cemento','M1I10','M1II','M2I','M2II','M3I','M3II7','M4I10','M4II',
%     'M5I','M5II', 'M6I','M6II','resina','sughero2',
%     'sughero1','8_2','10_2','11_2','13_0','15_0','16_0','slab2',
%     'calibrazione','c0','c1', 'c2', 'c2b', 'c3','c4','polipropilene',
%     'teflon','PVC','slab','viabattelli','viacocchi','legno','arezzo1',
%     'massarosa1','massarosa_b','parcheggio','nantes_gomma','nantes',
%     'reggio','EVia_FI_rubber','EVia_FI_rif','pavimento',
%     'via_lamarmora_FI_ante', 'resiliente'
% Piastra:
%     'testaimp','mini','piastrina','quadrata_piccola','quadrata1',
%     'quadrata2','pesante1','pesante2','blocco','quadrata_2mm','tonda_2mm','top'
% Adesivo:
%     'x' = supercolla x60
%     'a' = attack o simili;
%     'c' = cemento lampocem;
%     's' = gesso
% Punta:
%     'g' = gomma
%     'p' = plastica
%     'm' = metallo
% Martellatore;
%      1 = martello a mano
%      2 = martello con martellatore
%      3 = shaker
% Risonante: 0 = non risonante, 1 = risonante;
% Configurazione:
%      'd' = down (testa impedenziometrica capovolta)
%      'u' = up (testa impedenziometrica dritta)
% Top: presenza o meno del disco piatto in testa alla testa impedenziometrica
%      'on' = disco presente
%      'off' = disco non presente
% Peso martello: presenza del peso supplementare del martello
%      'w' = peso installato;
%      '' = nessun peso installato

campione = {'paparelli'};
piastra={'top'};
appoggio={''};
adesivo={'x'};
punta={'g'};
martellatore = 2;
accelerometro = 0;
risonante = 0;
configurazione = {'d'};
top = {'on'};
peso_martello = {''};

% testo nuovo tipo variabile per esportare in xml
% campione = "paparelli";
% piastra = "top";
% appoggio = "";
% adesivo = "x";
% punta = "g";
% martellatore = 2;
% accelerometro = 0;
% risonante = 0;
% configurazione = "d";
% top = "on";
% peso_martello = "none";


conf = table(campione, piastra, appoggio, adesivo, punta, martellatore,...
    accelerometro,risonante,configurazione,top,peso_martello) %#ok<NOPTS>
%%
save('dati1.mat','conf')
%writetable(conf,'conf.xml')

%% Main

set(0,'DefaultFigureWindowStyle','docked')
clear variables % cancello le variabili
close all % chiudo le figure aperte
clc % chiudo command wondow

%Selezione dei segnali da usare
% hammer per martello
% head per testa impedenziometrica
% acc per accelerometro
sens_forza = 'head';
sens_acc = 'head';

% Analisi da fare
accelerazione = false;
acceleranza = false;
calibrazione = false;
stiffness_terzi = true;
UNIISO10570 = false;
SNR = false;


% Rangge di frequenza
freq_range = [0 1000]; % range in requenza per l'analisi
freq_range_plot = [10 4000]; % range in frequenza per il plot dei risultati

% Dimensioni font
fs_label=12; % Etichette assi
fs_legend=12; % legenda
fs_title=16; % titolo subplot
fs_sgtitle=20; % titolo figura
fs_xyline=10; % etichette xline o yline

font_size=table(fs_label, fs_legend, fs_title, fs_sgtitle, fs_xyline);

colore = [
    '.000, .447, .741';    '.850, .325, .098';    '.929, .694, .125';
    '.494, .184, .556';    '.466, .674, .188';    '.301, .745, .933';
    '.635, .078, .184';    '.762, .762, .762';    '.999, .682, .788';
    '.000, .502, .502';    '.000, .000, .627';    '.430, .135, .078';
    '.559, .354, .075';    '.424, .124, .526';    '.446, .644, .148';
    '.301, .705, .903';    '.615, .018, .114'];

% path of the current script
filePath = matlab.desktop.editor.getActiveFilename;
fprintf('%s\n',filePath);

[fileFolder, filename, ext] = fileparts(filePath);

% mfilePath = mfilename('fullpath');
% if contains(mfilePath,'LiveEditorEvaluationHelper')
%     mfilePath = matlab.desktop.editor.getActiveFilename;
% end
% disp(mfilePath);


% generazione nome della misura del nome della cartella
currentFolder = pwd;

% creo cartella dove salvare i grafici
elab_date = datetime('now','TimeZone','local','Format','uuuu-MM-dd HH:mm');
elab_date = datestr(elab_date); %#ok

I=find(elab_date==':');
elab_date(I)='_';
ElabFolder = ...
    fullfile(currentFolder,[elab_date,' Elab ',sens_forza,'-',sens_acc]);
mkdir(ElabFolder);

separatori=find (currentFolder == '\');
if isempty(separatori)
    separatori=find (currentFolder == '/');
end
nomemisura=currentFolder(separatori(end)+1:end);

% importazione segnali ----------------------------------------------------
[sng,fs,conf] = import_segnali(sens_forza,sens_acc);
N=length(sng);

% Creo la tabella 'piastre' che contiene le specifiche delle pianste di
%   carico e dei sensori
[piastre] = tabella_piastre();

% Creo il vettore di tabelle 'compioni'. ciascuna delle quale contiene le
%   specifiche dei campioni in funzione della piastra utilizzata nella
%   specifica misura:
%    - per i campioni non cambia nulla
%    - per le pavimentazioni stradali la superficie è pari alla superficie
%      dela piastra utilizzata
campioni = cell(1,N);
for i=1:N
    [campioni{i}] = tabella_campioni (conf(i).conf,piastre);
end


% Import tabella campioni e piastre da file
piastre = readtable([fileFolder filesep 'piastre.xlsx'], "UseExcel", false, ReadRowNames=true,ReadVariableNames=true);
campioni = readtable([fileFolder filesep 'campioni.xlsx'], "UseExcel", false, ReadRowNames=true,ReadVariableNames=true);


filtro = 0;
% Se "filtro" = 0 si procede con la ricerca dei picchi sul segnale orignale
% altrimenti si applica un filtro passa alto a 35 Hz e si cercano i picchi
% con "findpeaks"

% estrazione segnali e salvataggio in matrici------------------------------
% va scritta una funzione "prep_sng_shaker" per le misure con shaker
[sng,L_sample,L_pre,L_coda] = prep_sng_martello(sng,fs,filtro);

% Zeropad -----------------------------------------------------------------
% zeropaddo ulteriormente prima di fare i calcoli
L_padded = 2^14;
if L_padded > length(sng(1).F(:,1))
    for i=1:N
        [r,c] = size(sng(i).F);
        L_pad = L_padded - r;
        sng(i).F = [sng(i).F; zeros(L_pad,c)];
        sng(i).A = [sng(i).A; zeros(L_pad,c)];
    end
end

% caratteristiche fisiche campioni 
m = zeros(N,1); % masse piastre
h = zeros(N,1); % spessore campioni
s = zeros(N,1); % superfici campioni
for i=1:N
    piastra = conf(i).conf.piastra;
    campione = conf(i).conf.campione;
    m(i) = piastre.massa(piastra); %massa della piastra in uso
    h(i) = campioni.h(campione);
    if isequal(campioni.type(campione), {'sample'})
        s(i) = pi*(campioni.d(campione)/2)^2;
    end
    % se il campione è una pavimentazione o una slab uso la superficie dell
    % sensore
    if ismember(campioni.type(campione), [{'road'} {'slab'}])
        s(i) = pi*(piastre.d(piastra)/2)^2;
    end
    % h(i) = campioni{i}.h(conf(i).conf.campione);
    % s(i) = pi*(campioni{i}.d(conf(i).conf.campione)/2)^2;
end
% Genero nome misura
nomemis=cell(1,N);
for i=1:N
    nomemis{i}=['Misura ',num2str(i)];
end

% Finestratura dei segnali ------------------------------------------------
% Tipologia di finestratura
wintype = 'hann';

% Determina il tipo di finestratura da utilizzare per i segnali di
%   accelerazione:
%   hann = utilizza la finestra di hann;
%   rect = utilizza una finestratura rettangolare;
%   none = non applica nessuna finestratura.
L_win = L_pre;
[sng, fig_finestratura] = finestratura(sng, wintype, L_win, fs, font_size);
%
% Calcolo quantità trasformate --------------------------------------------

win_1 = chebwin(4*1024, 80);%#ok
win_1 = ones(1,L_sample);
% win_1=[]; %divide in 8 pezzi con sovrapposizione 50% 1 pezzo è 1/4,5 Lsample (~3640)

% Calcolo e test coerenza
[PSD,fig_cohe] = coerenza(sng, win_1, freq_range, freq_range_plot, fs, font_size);

% Calcolo dynamic stiffness
[PSD,fig_rigidita_dinamica] = rigidita_dinamica(PSD, freq_range,...
    freq_range_plot, font_size, colore);
exportgraphics(fig_rigidita_dinamica, fullfile(ElabFolder, 'DS_av.pdf'))
%% Figura rapporto segnale rumore
if SNR
    for i=1:N %#ok
        sng(i).F_noise = sng(i).F -sng(i).F_filt;
        sng(i).A_noise = sng(i).A -sng(i).A_filt;
        [Lsample,~] = size(sng(i).F);
        [pxx, f] = cpsd(sng(i).F_noise, sng(i).F_filt, win_1, [], Lsample, fs(i));
        [pxy, f] = cpsd(sng(i).A_noise, sng(i).A_filt, win_1,[], Lsample, fs(i));


        figure
        hold on
        %plot (f, 10*log10 (mean(abs(PSD.F),2)./mean(abs(pxx),2)))
        plot (f, smooth(10*log10 (mean(abs(PSD(i).F)./abs(pxx),2)),50),'DisplayName','Forza')
        plot (f, smooth(10*log10 (mean(abs(PSD(i).F)./abs(pxy),2)),50),'DisplayName','Accelerazione')
        set(gca,'XLim',freq_range_plot*2+100,'XScale','log','YScale','lin')
        grid on
        ylim ([0 50])
        legend;
        title ('Rapporto segnale rumore')
        ylabel('SNR [dB]')
        xlabel('Frequenza [Hz]')
    end
end
%% accelerazione
if accelerazione
    figure %#ok
    hold on
    for i=1:N
        plot (f, 10*log10(abs(PSD(i).A)),'Color',string(colore(i,:)),...
            'HandleVisibility','off','LineWidth',0.5)
        plot (f, 10*log10(mean(abs(PSD(i).A),2)),'Color',string(colore(i,:)),...
            'LineWidth',2)
    end
    grid on
    xlabel('Frequenza [Hz]','FontSize',font_size.fs_label)
    ylabel('Accelerazione [m/s^2]','FontSize',font_size.fs_label)
    set(gca,'XLim',freq_range_plot*2+100,'XScale','log','YScale','lin')
    legend('FontSize',font_size.fs_legend)
end
%%
% figura da inserire in scheda -------------------------------------------
%[fig_scheda] = figura_scheda(PSD,freq_range_plot,font_size,nomemis,colore,'lin');

%for i=1:N
%    T=fullfile(ElabFolder,cell2mat(['Figura scheda ',nomemis(i),'.pdf']));
%    exportgraphics( fig_scheda(i),T)
%end
%% Figura terzi ottava ----------------------------------------------------
if stiffness_terzi
    % Imposto il range in frequenza per il plot in terzi d'ottava
    octave_band_range = [100 4000];

    % Plot rigidità in terzi d'ottava
    [fig_terzi,fig_terzi_av,ris] = ...
        Dstiff_terzi_ottava(PSD,octave_band_range,nomemis,font_size);

    T = conf(1).conf;
    nomefile = cell2mat ([num2str(T.risonante),'-',T.campione,'-',T.piastra,'-',...
        T.punta,'-',T.configurazione,'-',T.top,'-',num2str(T.martellatore),'-',T.adesivo,'-',...
        T.peso_martello,' ',T.date]);

    save(fullfile(ElabFolder,[nomefile,'.mat']),"ris",'PSD','conf')

    for i=1:N
        exportgraphics(fig_terzi(i), fullfile(ElabFolder,[nomemis{i},...
            ' bande_terzi_ottava.pdf']),'ContentType','vector')
    end
    % copia dei risultati sulla clipboard
    %num2clip([mean(mis,1); mean(mis_err,1)])
    % Esporto la figura
    exportgraphics(fig_terzi_av, fullfile(ElabFolder,...
        'DS_bande_terzi_ottava_av.pdf'),...
        'ContentType','vector')
end
%% Figura secondo UNI ISO 10570:1997 --------------------------------------
if UNIISO10570
    [fig_UNI] = figura_UNI_10570(PSD,freq_range_plot,font_size,nomemis,colore);%#ok
    %exportgraphics(fig_UNI,['figura_UNI_10570_win_',num2str(win_1),'.pdf']);
end
%% Figura acceleranza -----------------------------------------------------
if acceleranza
    currentFolder = pwd;%#ok
    separatori=find (currentFolder=='/');
    nomemisura=currentFolder(separatori(end)+1:end);
    xscale='lin';
    yscale='log';
    [fig_risonanza_av,fig_ris] = ...
        figura_risonante(PSD,[1 500],font_size,nomemis,...
        nomemisura,colore,conf,xscale,yscale);

    T=fullfile(ElabFolder,['AccFRF_',sens_forza,'-',sens_acc,'.pdf']);
    exportgraphics(fig_risonanza_av, T,...
        'ContentType','vector')
    for i=1:N
        T=fullfile(ElabFolder,['AccFRF_',sens_forza,'-',sens_acc,'-',...
            nomemis{i},'.pdf']);
        exportgraphics(fig_ris(i), T,...
            'ContentType','image')
    end

    s_star=zeros(N,1);

    for i=1:N
        txx_av = mean(PSD(1).txy,2);
        I=find(PSD(1).f<500);
        [M,II]=max(txx_av(I));

        f_ris=PSD(1).f(II)

        s_star(i)=(2*pi*f_ris)^2*189;
        s_star/10^6
    end
    frequenze = (f_ris-10):0.1:(f_ris+10);

    [txy,fzoom] = tfestimate(sng(i).F_filt, sng(i).A_filt,win_1,[],frequenze,fs(i));
    ch=fig_risonanza_av.get( 'Children');

    plot(ch(5),fzoom,20*log10(mean(abs(txy),2)),'LineWidth',3,...
        'HandleVisibility','off','Color',string(colore(2,:)))
    legend(ch(5));
    for i=1:N
        txx_av = mean(abs(txy),2);
        %I=find(PSD(1).f<500);
        [M,II]=max(txx_av);

        f_ris=fzoom(II)

        s_star(i)=(2*pi*f_ris)^2*198;
        s_star/10^6
    end

    s_star_av= mean(s_star)
end
%% Calibrazione
if calibrazione
    % Considerando che questa parte di codice va eseguita per ottenere
    % valori di calibrazione, vengono rimoltiplicati
    massa_sospesa=0.130;%#ok %1.45;
    massa_sospesa=1.45; %Misurata con la bilancia
    %massa_sospesa=campioni{1}.massa(conf(1).conf.campione);
    [fig_calibrazione,cal2]=figura_calibrazione(PSD,[0 1000],font_size,nomemis,...
        nomemisura,colore,massa_sospesa);

    T=fullfile(ElabFolder,['Calibrazione_',sens_forza,'-',sens_acc,'.pdf']);
    exportgraphics(fig_calibrazione, T,...
        'ContentType','vector')
end