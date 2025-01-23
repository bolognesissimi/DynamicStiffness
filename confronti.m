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

set(0,'DefaultFigureWindowStyle','docked')
clear variables % cancello le variabili
close all % chiudo le figure aperte
clc % chiudo command wondow

fs_label=14; % Etichette assi
fs_legend=12; % legenda
fs_title=18; % titolo subplot
fs_sgtitle=18; % titolo figura
fs_xyline=12; % etichette xline o yline

font_size=table(fs_label,fs_legend, fs_title, fs_sgtitle, fs_xyline);

colore = [
    '.000, .447, .741';    '.850, .325, .098';    '.929, .694, .125';
    '.494, .184, .556';    '.466, .674, .188';    '.301, .745, .933';
    '.635, .078, .184';    '.762, .762, .762';    '.999, .682, .788';
    '.000, .502, .502';    '.000, .000, .627';    '.430, .135, .078';
    '.559, .354, .075';    '.424, .124, .526';    '.446, .644, .148';
    '.301, .705, .903';    '.615, .018, .114'];


elab_folder = pwd;

% acquisisto i file presenti in cartella 1 e cartella 2
cartella_1 = dir([elab_folder,'/1/*.mat']);
cartella_2 = dir([elab_folder,'/2/*.mat']);

%comparo i nomi dei file in 1

PSD1=struct();

% import cartella 1
N=length(cartella_1);

for i=1:N
    
    stringa  = ['1/' ,cartella_1(i).name];
    temp = load (stringa);
    
    % se non ho ancora importato nulla in psd
    if isempty( fieldnames(PSD1))
        PSD1 = temp.PSD;
        ris = temp.ris;
        conf = temp.conf(1).conf;
        % altrimenti concateno le strutture
    else
        PSD1 = [PSD1,temp.PSD];
        ris.k = [ris.k; temp.ris.k];
        ris.dk = [ris.dk; temp.ris.dk];
        ris.c = [ris.c; temp.ris.c];
    end
    
end

ris_1 = ris;
PSD_1 = PSD1;
conf_1 = conf;

% import cartella 2
N=length(cartella_2);
PSD2=struct();


for i=1:N
    
    stringa  = ['2/' ,cartella_2(i).name];
    temp = load (stringa);
    
    % se non ho ancora importato nulla in psd
    if isempty( fieldnames( PSD2))
        PSD2 = temp.PSD;
        ris = temp.ris;
        conf = temp.conf(1).conf;
        % altrimenti concateno le strutture
    else
        PSD2 = [PSD2,temp.PSD];
        ris.k = [ris.k; temp.ris.k];
        ris.dk = [ris.dk; temp.ris.dk];
        ris.c = [ris.c; temp.ris.c];
    end
    
end

ris_2 = ris;
PSD_2 = PSD1;

% sostituisco lo spazio prima della data in con un '-'
space1 = find(cartella_1.name == ' ');
space2 = find(cartella_2.name == ' ');

cartella_1.name(space1(end)) = '-';
cartella_2.name(space2(end)) = '-';

n1 = length (cartella_1);
n2 = length (cartella_2);



if n1==1 && n2==1
    
    I1 = find (cartella_1.name == '-');
    I2 = find (cartella_2.name == '-');
    
    I1 = [0 I1];
    I2 = [0 I2];
    
    nome_1 = cartella_1.name(1:I1(end-2)-1);
    data_1 = cartella_1.name(I1(end-2)+1:end-4);
    nome_2 = cartella_2.name(1:I2(end-2)-1);
    data_2 = cartella_2.name(I2(end-2)+1:end-4);
    
    mis_1 = [];
    mis_2 = [];
    nome_conf = [];
    
    if strcmp (nome_1,nome_2)
        
        mis_1 = data_1;
        mis_2 = data_2;
        
        nome_conf = [nome_1,' ',data_1, '_vs_',data_2];
        
    else
        
        for i = 1:(length(I1)-3)
            
            value1 = cartella_1.name(I1(i)+1:I1(i+1)-1);
            value2 = cartella_2.name(I1(i)+1:I1(i+1)-1);
            %confronto i rispettivi parametri delle due misure
            check = strcmp(value1, value2);
            
            % se sono diversi
            if check==0
                
                if isempty(mis_1)
                    if i>1
                        mis_1 =  dizionario_conf(value1) ;
                        mis_2 =  dizionario_conf(value2) ;
                    else
                        
                        switch value1
                            case '0'
                                mis_1 = 'non risonante';
                                mis_2 = 'risonante' ;
                            case '1'
                                mis_1 = 'risonante';
                                mis_2 = 'non risonante' ;
                        end
                    end
                else
                    mis_1 = [mis_1 '-', dizionario_conf(value1)];
                    mis_2 = [mis_2 '-', dizionario_conf(value2) ];
                end
                
                if isempty (nome_conf)
                    nome_conf = [value1, '_vs_', value2];
                else
                    nome_conf = [nome_conf '-', value1, '_vs_', value2];
                end
                
            else
                
                if isempty (nome_conf)
                    nome_conf = value1;
                else
                    nome_conf = [nome_conf '-', value1]; %#ok<*AGROW>
                end
                
            end
            
        end
        
        if isempty(mis_1)==0
            nome_conf = [nome_conf,' ',data_1];
        end
    end
else
    
    mis_1 = 'mis1';
    mis_2 = 'mis2';
    
end
k_av_1 = mean (ris_1.k, 1);
k_av_2 = mean (ris_2.k,1);
dk_av_1 = mean (ris_1.dk,1);
dk_av_2 = mean (ris_2.dk,1);

% inizializzo figura
figura1 = figure;
asse = axes('Parent', figura1);

% Definisco altezza e larghezza in cm e i ppi della figura
L=18.5; % larghezza in centimetri
H=8; % altezza in centimetri
ppi=150; %pizel per pollice
% Imposto posizione e dimenzioni della figura
set(figura1,'WindowStyle','normal') % Insert the figure to dock
% determino dimensioni grafico
figura1.OuterPosition = ([100,0,L/2.54*ppi,H/2.54*ppi]);


legenda = legend(asse,'FontName','Arial','FontSize',font_size.fs_legend,...
    'Location','best','Interpreter','none');
valori = [k_av_1; k_av_2]';
errori = [dk_av_1; dk_av_2]';
coh_1 = mean(ris_1.c,1);
coh_2 = mean(ris_2.c,1);

hold(asse,'on')

y=(1:length(ris_1.f_centrale));

bar1 = bar(asse, y-0.2,k_av_1,'BarWidth',0.35,'HandleVisibility','off');
bar2 = bar(asse, y+0.2,k_av_2,'BarWidth',0.35,'HandleVisibility','off');

% [ errore eccessivo ; normale; coerenza bassa]

mycolor_1 = [156/255 196/255 222/255  ;.000 .447 .741; 0 79/255 128/255];
mycolor_2 = [224/255 196/255 184/255 ;.850 .325 .098; 122/255 50/255 19/255];

% plotto grafici vuoti per assegnargli nomi della legenda
bar_blu = bar (asse, nan,nan,'FaceColor',string(colore(1,:)),...
    'DisplayName',mis_1);
bar_red = bar (asse, nan,nan,'FaceColor',string(colore(2,:)),...
    'DisplayName',mis_2);

bar_error = bar (asse, nan,nan,'FaceColor',mycolor_1(1,:),...
    'DisplayName','err > 10% o 20% < coher < 90%');
bar_error2 = bar (asse, nan,nan,'FaceColor',mycolor_2(1,:),...
    'DisplayName','err > 10% o 20% < coher < 90%');

%bar_coh = bar (asse, nan,nan,'FaceColor',mycolor_1(1,:))%,...
%'DisplayName','Coerenza < 90% e >20%');
%bar_coh2 = bar (asse, nan,nan,'FaceColor',mycolor_2(1,:))%,...
%'DisplayName', %'Coerenza < 90% e >20%');

set(bar1,'CDataMapping','direct');

index_1 = zeros(size(y));
index_2 = index_1;

for iCount=1:length(y)
    if ( dk_av_1(iCount)/k_av_1(iCount) > .1 )
        index_1(iCount)=1;
    elseif (coh_1(iCount)<.2)
        index_1(iCount)=2;
    elseif(coh_1(iCount)>=.9)
        index_1(iCount)=2;
    else
        index_1(iCount)=3;
    end
end

for iCount=1:length(y)
    if ( dk_av_2(iCount)/k_av_2(iCount) >= .1 )
        index_2(iCount)=1;
    elseif (coh_2(iCount)<.2)
        index_2(iCount)=2;
    elseif(coh_2(iCount)>=.9)
        index_2(iCount)=2;
    else
        index_2(iCount)=3;
    end
end

bar1.FaceColor='flat';
bar2.FaceColor='flat';

for i=y
    bar1.CData(i,:) = mycolor_1(index_1(i),:);
    bar2.CData(i,:) = mycolor_2(index_2(i),:);
    
end

err = errorbar(asse,[y'-0.2,y'+0.2],valori,errori,errori,...
    'HandleVisibility','off');

set(err,'Color',[0 0 0],'LineStyle','none')

% scrivo le frequenze su asse x
asse.XTick = (1:length(ris_1.f_centrale));
asse.XTickLabel = (ris_1.f_centrale);

% Set the remaining axes properties
set(asse,'FontName','Arial','XGrid','on','YGrid','on',...
    'YLim',[0 150]); %[0 1.2*max(max(valori))]);
% Create ylabel
ylabel(asse,'Dynamic Stiffness [MN/m]','FontWeight','bold','FontSize',...
    font_size.fs_label,'FontName','Arial');
% Create xlabel
xlabel(asse,'1/3 ottave bands [Hz]','FontWeight','bold','FontSize',...
    font_size.fs_label,'FontName','Arial');

box(asse,'on');

% Create Title
ttl = title('Dinamic stiffness comparison','Interpreter','none');
set(ttl,'FontName','Arial','FontSize',font_size.fs_sgtitle)
%%
exportgraphics(figura1, [nome_conf,'.pdf']); %,'ContentType','vector')
%%

%gaussEqn = 'a*exp(-((x-b)/c)^2)+d'


x = ris_1.f_centrale;
y = mean(ris_1.k);
err_y = mean (ris_1.dk,1);

if length(y)==1
    y=ris_1.k;
end

i=0;
SE = [];
K = [];
while i==0
    
    %modelfun = @(b,x)b(1)*x./x;
    %mdl = fitnlm(x, y, modelfun, max(y)); % Modello dei primi picchi
    %[fit,R] = nlinfit(x', y', modelfun, max(y));
    
    w = 1./err_y.*2;
    mdl = fitlm(x,y,'constant','Weights',w);
    
    SE = [SE mdl.Coefficients.SE];
    K = [K mdl.Coefficients.Estimate];
    x = x(2:end);
    y = y(2:end);
    err_y = err_y(2:end);
    
    if length(x)<5
        i=1;
    end
end

[~,I] = find(SE==min(SE));
yline(asse,K(I),'b',K(I),'DisplayName','K mag si sil');
yline(asse,K(I)-SE(I),'b--','HandleVisibility','off');
yline(asse,K(I)+SE(I),'b--','HandleVisibility','off');

figure
hold on
plot (SE)
plot(K)
xline(I);
yline(K(I));


x = ris_2.f_centrale;
y = mean(ris_2.k);
err_y = mean (ris_1.dk,1);

if length(y)==1
    y=ris_2.k;
end

i=0;
SE = [];
K = [];
while i==0
    
    % modelfun = @(b,x)b(1)*x./x;
    % mdl = fitnlm(x, y, modelfun, max(y)); % Modello dei primi picchi
    % [fit,R] = nlinfit(x', y', modelfun, max(y));
    
    w = 1./err_y.*2;
    mdl = fitlm(x,y,'constant','Weights',w);
    
    SE = [SE mdl.Coefficients.SE];
    K = [K mdl.Coefficients.Estimate];
    
    x=x(2:end);
    y=y(2:end);
    err_y = err_y(2:end);
    if length(x)<5
        i=1;
    end
end

[~,I] = find(SE==min(SE));
yline(asse,K(I),'r',K(I),'DisplayName','K mag no sil');
yline(asse,K(I)-SE(I),'r--','HandleVisibility','off');
yline(asse,K(I)+SE(I),'r--','HandleVisibility','off');

figure
hold on
plot (SE)
plot(K)
xline(I);
yline(K(I));