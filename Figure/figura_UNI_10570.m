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

function [fig1]=figura_UNI_10570(PSD,freq_range_plot,font_size,nomemis,colore)

%FIGURA UNI 10570 Realizza una figura secondo la norma UNI 10570:1997.
%   "Prodotti per l’isolamento delle vibrazioni Determinazione delle
%   caratteristiche meccaniche di materassini e piastre.
%   Prova dinamica forzata - Modello di riferimento e di interpretazione
%   dei dati"
%   La funzione esegue un plot di coerenza, parte reale e parte immaginaria
%   della rigidità.

N = length(PSD);
I=cell(1,N);
for i=1:N
    [I{i}]=find(PSD(i).f>=freq_range_plot(1) &...
        PSD(i).f<=freq_range_plot(end));
end
fig1 = figure;
leg = gobjects(3);
ax1 = gobjects(3);
Titoli={'Coerenza','Parte Reale','Parte Immaginaria'};
for i=1:3
    % creo subplot
    ax1(i) = subplot(3,1,i,'Parent',fig1);
    hold (ax1(i), 'on')
    % legenda
    leg(i,1)=legend(ax1(i),'FontName','Arial','FontSize',font_size.fs_legend,...
        'Location','best');
    % titoloo
    title(Titoli{i},'FontSize',20,'FontName','Arial');
end
for i=1:N
    plot1(1) = plot(ax1(1),PSD(i).f, PSD(i).coh,'LineWidth',2,...
    'Color',string(colore(i,:)));
    
    plot1(2) = plot(ax1(2),PSD(i).f, real(PSD(i).K_tfest),...
        'LineWidth',2,'DisplayName',[nomemis{i},' tfestimate'],...
    'Color',string(colore(i,:)));
%     plot1(2) = plot(ax1(2),PSD(i).f, real(PSD(i).K),...
%         'LineWidth',1,'DisplayName',nomemis{i},...
%     'Color',string(colore(i,:)));
    
    plot1(3) = plot(ax1(3),PSD(i).f, imag(PSD(i).K_tfest),...
        'LineWidth',2,'DisplayName',[nomemis{i},' tfestimate'],...
    'Color',string(colore(i,:)));
%     plot1(3) = plot(ax1(3),PSD(i).f, imag(PSD(i).K_tfest),...
%         'LineWidth',1,'DisplayName',nomemis{i},...
%     'Color',string(colore(i,:)));
end

% imposto manualmente i massimi e minimi dei grafici
temp_real=zeros(1,N);
temp_imag=zeros(1,N);
% cerco massimi di parte reale e immaginaria nel range di plot
for i=1:N
    temp_real(i)=max(real(PSD(i).K(I{i})));
    temp_imag(i)=max(imag(PSD(i).K(I{i})));
end
% imposto limiti
set(ax1(2), 'YLim',[0 1.2*min(temp_real)],'XGrid','on','YGrid','on')
set(ax1(3), 'YLim',[-1.2*min(temp_imag) 1.2*min(temp_imag)],'XGrid','on','YGrid','on')
% imposto parametri grafico coerenza
set(ax1(1),'Ylim',[0 1])
yticks (ax1(1),[0 0.2 0.5 0.8 0.9 0.95 1])
% imposto parametri comuni ai tre subplot
for i=1:3
    set(ax1(i), 'XLim',freq_range_plot, 'XGrid','on','YGrid','on')
    xlabel(ax1(i),'Frequenza [Hz]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
end
% tifolo figura
sgt=sgtitle('Rigidità Dinamica UNI 10570:1997');
set(sgt,'FontName','Arial','FontSize',font_size.fs_sgtitle)
end
