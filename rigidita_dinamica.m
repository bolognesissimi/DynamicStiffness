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

function [PSD,fig1] = rigidita_dinamica(PSD,freq_range,...
    freq_range_plot,font_size,colore)
%RIGIDITA_DDINAMICA  Calcolo della rigidità secondo ISO 7626-5
%   Frequency-domain averaging of data from several impacts at a fixed 
%   point may be performed in order to improve the estimate of the
%   frequency-response function. This estimate can be obtained as the
%   averaged cross-spectrum of the response and the force, divided by the 
%   averaged auto-spectrum of the force. Averaging also permits calculation
%   of the coherence function (see 9.1).
%   In a low-noise environment, averaging three to five impacts is usually 
%   sufficient to verify data quality. A larger number of impacts may be 
%   used to reduce the effect of uncorrelated noise on the response 
%   signals. However, the impact method loses its speed advantage if a very
%   large number of impacts need to be averaged, and so other excitation 
%   methods should be considered if the background noise cannot be reduced.
%
%   Make sure that the response of the structure has decayed below the 
%   limit of detection before applying the next impact for averaging; any 
%   residual “ringing” can interfere with the measurement of the subsequent
%   response signals. For small or lightly damped structures, it is useful 
%   to damp out the structural response manually.

N = length(PSD);

% Calcolo rigidità
for i=1:N
    PSD(i).K = 1./(mean(PSD(i).pxy,2)./mean(PSD(i).pxx,2))...
        .*(1i*2*pi*PSD(i).f).^2;
    
    PSD(i).K_tfest = conj(mean(1./PSD(i).txy,2)).*(1i*2*pi*PSD(i).f).^2;
end

% Calcolo deviazione standard per cpsd
for i=1:N
    PSD(i).dF = std (PSD(i).F, 0, 2);
    PSD(i).dA = std (PSD(i).A, 0, 2);
 
    dF = PSD(i).dF;
    dA = PSD(i).dA;
    F = mean(PSD(i).F,2);
    A = mean(PSD(i).A,2);
    b  = (1i*2*pi*PSD(i).f).^2;
    K = b .* F./A;
    
    [r,~]=size(F);
    dFA =zeros(size(F)).*dF.*dA;
    for j=1:r
        temp = cov (PSD(i).F(j,:),PSD(i).A(j,:));
        dFA(j)=  temp(1,2);
    end  
    % from https://en.wikipedia.org/wiki/Propagation_of_uncertainty
    dk = b .*( abs(dF./A).^2 + abs(F./A.^2.*dA).^2 +...
        2*(1./A).*(F./A.^2).*dFA ).^(1/2);
    PSD(i).dK = dk;
end
% Calcolo deviazione standard per tfestimate
for i=1:N
    [r,c]=size(PSD(i).txy);
    k_tf=zeros(r,c);
    for j=1:c
        k_tf(:,j)= conj(1./PSD(i).txy(:,j)).*(1i*2*pi*PSD(i).f).^2;
    end
    PSD(i).dK_tfest = std(k_tf,[],2);
end

% figura rigidità

fig1=figure;

% Definisco altezza e larghezza in cm e i ppi della figura
    L=14; % larghezza in centimetri
    H=14; % altezza in centimetri
    ppi=150; %pixel per pollice
    % Imposto posizione e dimenzioni della figura
    set(fig1,'WindowStyle','normal') % Insert the figure to dock
    % determino dimensioni grafico
    figura1.OuterPosition = ([100,0,L/2.54*ppi,H/2.54*ppi]);



    ax1(1)=subplot(3,1,1,'Parent',fig1);
    ax1(2)=subplot(3,1,2,'Parent',fig1);
    ax1(3)=subplot(3,1,3,'Parent',fig1);
% imposto parametri iniziali grafico
for i=1:3
    hold(ax1(i),'on');
end
% imposto nome delle misure
for i=1:N
    if PSD(i).alert
        % se la misura ha un alert metto un asterisco
        nome{i} = [ 'Misura ',num2str(i),'*'];
    else
        nome{i} = [ 'Misura ',num2str(i)];
    end
end
% coerenza
for i=1:N
    % Plot coerenza
    plot(ax1(1),PSD(i).f, PSD(i).coh,'LineWidth',2,'DisplayName',nome{i}...
        ,'Color',string(colore(i,:)))
    % legenda
    legend (ax1(1),'FontSize',font_size.fs_legend, 'Location','best');
end

% modulo
for i=1:N
    % Plot modulo di K
%     plot(ax1(2),PSD(i).f, 20*log10(abs(PSD(i).K)),...
%         'LineWidth',2,'DisplayName',nome{i},'Color',string(colore(i,:)))   
    plot(ax1(2),PSD(i).f, 20*log10(abs(PSD(i).K_tfest)),...
        'LineWidth',2,'DisplayName',[nome{i},' tfestimate'],...
        'LineStyle','-','Color',string(colore(i,:)))
    % plot errori
    plot(ax1(2),PSD(i).f,20*log10(abs(PSD(i).K_tfest)) + 20*log10(1+...
        abs(PSD(i).dK_tfest)./abs(PSD(i).K)),...
        'LineWidth',0.5,'LineStyle','-.','Color',string(colore(i,:)),...
        'HandleVisibility','off')
    plot(ax1(2),PSD(i).f,20*log10(abs(PSD(i).K_tfest)) - 20*log10(1+...
        abs(PSD(i).dK_tfest)./abs(PSD(i).K)),...
        'LineWidth',0.5,'LineStyle','-.','Color',string(colore(i,:)),...
        'HandleVisibility','off')
    % legenda
    legend (ax1(2),'FontSize',font_size.fs_legend, 'Location','best');
end

% fase
for i=1:N
    % Plot fase di K
    plot(ax1(3),PSD(i).f, 180/pi*(angle(PSD(i).K)),...
        'LineWidth',1,'DisplayName',nome{i},'Color',string(colore(i,:)))
    plot(ax1(3),PSD(i).f, 180/pi*unwrap(angle(PSD(i).K_tfest)),...
        'LineWidth',1,'DisplayName',[nome{i},' tfestimate'],...
        'LineStyle','--','Color',string(colore(i,:)))
    % legenda
    legend (ax1(3),'FontSize',font_size.fs_legend, 'Location','best');
end
% Plotto limite in frequenza
for i=1:N
    for j=1:3
        % Limite in frequenza
        xline(ax1(j),PSD(i).fmax,'-',...
            ['f_{max} (@ -10dB): ',num2str(round(PSD(i).fmax)),...
            'Hz'],'LineWidth',1,'HandleVisibility','off',...
            'Color',string(colore(i,:)));
    end
end
% imposto tacche asse y
yticks (ax1(1),[0 0.2 0.5 0.8 0.9 1])
yticks (ax1(3),[-180 -90 0 90 180])
% imposto etichette asse y
ylabel(ax1(2),'Rigidità dinamica [dB @ 1 N/m]','FontWeight','bold',...
    'FontSize',font_size.fs_label,'FontName','Arial');
ylabel(ax1(3),'Angolo [°]','FontWeight','bold',...
    'FontSize',font_size.fs_label,'FontName','Arial');
% settaggio parametri finali
set(ax1(3),'YLim',[-180 180]);
set(ax1(1),'YLim',[0 1]);
titoli={'Coerenza','Modulo','Fase'};
for i=1:3
    set(ax1(i),'XScale','log','XLim',freq_range_plot,'XGrid','on','YGrid','on')
    xlabel(ax1(i),'Frequenza [Hz]','FontWeight','bold',...
        'FontSize',font_size.fs_label,'FontName','Arial');
    title(ax1(i),titoli{i},'FontSize',font_size.fs_title,...
        'FontName','Arial');
    box(ax1(i),'on');
end
end