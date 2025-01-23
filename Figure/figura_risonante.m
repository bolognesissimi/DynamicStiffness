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

function [fig1,fig2]=figura_risonante(PSD,freq_range_plot,font_size,nomemis,...
    nomemisura,colore,conf,xscale,yscale)

%FIGURA_RISONANTE plotta la FRF per individuare la frequenza di risonanza
%   del sistema.

N = length(PSD);

% figura di sintesi -------------------------------------------------------
fig1 = figure;
leg = gobjects(3);
ax1 = gobjects(3);
Titoli={'Coerenza','Acceleranza (accelerazione/forza)','Fase'};
for i=1:3
    % creo subplot
    ax1(i) = subplot(3,1,i,'Parent',fig1);
    hold (ax1(i), 'on')
    % legenda
    leg(i,1)=legend(ax1(i),'FontName','Arial','FontSize',font_size.fs_legend,...
        'Location','best');
    % titolo
    title(Titoli{i},'FontSize',20,'FontName','Arial');
end

[piastre] = tabella_piastre ();
% Creo il vettore di tabelle 'compioni'. ciascuna delle quale contiene le
% specifiche dei campioni in funzione della piastra utilizzata nella
% specifica misura:
% - per i campioni non cambia nulla
% - per le pavimentazioni stradali la superficie è pari alla superficie
%   dela piastra utilizzata
campioni = cell(1,N);
for i=1:N
    [campioni{i}] = tabella_campioni (conf(i).conf,piastre);
end

for i=1:N
    % coerenza
    plot1(1) = plot(ax1(1),PSD(i).f, PSD(i).coh,'LineWidth',2,...
        'Color',string(colore(i,:)));
    % modulo
    txx_av = mean(PSD(i).txy,2);
    txx_std = std(PSD(i).txy,[],2);
    switch yscale
        case 'log'
            plot1(2) = plot(ax1(2),PSD(i).f, 20*log10(abs(txx_av)),...
                'LineWidth',2,'DisplayName',[nomemis{i},' tfestimate'],...
                'Color',string(colore(i,:)));
            % std+
            plot(ax1(2),PSD(i).f, 20*log10(abs(txx_av)) + 20*log10(1+...
                abs(txx_std)./abs(txx_av)),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'DisplayName','Deviazione standard');
            % std-
            plot(ax1(2),PSD(i).f, 20*log10(abs(txx_av)) - 20*log10(1+...
                abs(txx_std)./abs(txx_av)),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'HandleVisibility','off')
        case 'lin'
            plot1(2) = plot(ax1(2),PSD(i).f, (abs(txx_av)),...
                'LineWidth',2,'DisplayName',[nomemis{i},' tfestimate'],...
                'Color',string(colore(i,:)));
            % std+
            plot(ax1(2),PSD(i).f, (abs(txx_av)) + (txx_std),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'DisplayName','Deviazione standard');
            % std-
            plot(ax1(2),PSD(i).f, (abs(txx_av)) - (txx_std),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'HandleVisibility','off')
    end
    
    massa_campione = campioni{i}.massa(conf(i).conf.campione);
    massa_piastra = piastre.massa(conf(i).conf.piastra);
%     switch yscale
%         case 'log'
%             % Massa piastra
%             yline(ax1(2),20*log10(1/massa_piastra),'-',...
%                 ['Massa piastra ',mat2str(massa_piastra),' kg'],...
%                 'LabelHorizontalAlignment','left',...
%                 'LineWidth',0.5,...
%                 'HandleVisibility','off','FontSize',font_size.fs_xyline)
%             yline(ax1(2),20*log10(1/massa_campione),'--',...
%                 ['Massa campione ',mat2str(massa_campione),' kg'],...
%                 'LabelHorizontalAlignment','left',...
%                 'LineWidth',0.5,...
%                 'HandleVisibility','off','FontSize',font_size.fs_xyline)
%         case 'lin'
%             % Massa piastra
%             yline(ax1(2),(1/massa_piastra),'-',...
%                 ['Massa piastra ',mat2str(massa_piastra),' kg'],...
%                 'LabelHorizontalAlignment','left',...
%                 'LineWidth',0.5,...
%                 'HandleVisibility','off','FontSize',font_size.fs_xyline)
%             yline(ax1(2),(1/massa_campione),'--',...
%                 ['Massa campione ',mat2str(massa_campione),' kg'],...
%                 'LabelHorizontalAlignment','left',...
%                 'LineWidth',0.5,...
%                 'HandleVisibility','off','FontSize',font_size.fs_xyline)
%     end
    
    % fase
    plot1(3) = plot(ax1(3),PSD(i).f, 180/pi*(angle(mean(PSD(i).txy,2))),...
        'LineWidth',2,'DisplayName',[nomemis{i},' tfestimate'],...
        'Color',string(colore(i,:)));
    
    %     plot1(3) = plot(ax1(3),PSD(i).f, imag(PSD(i).K_tfest),...
    %         'LineWidth',1,'DisplayName',nomemis{i},...
    %     'Color',string(colore(i,:)));
end

% imposto manualmente i massimi e minimi dei grafici
temp_real=zeros(1,N);
temp_imag=zeros(1,N);
% % cerco massimi di parte reale e immaginaria nel range di plot
% for i=1:N
%     temp_real(i)=max(real(PSD(i).K(I{i})));
%     temp_imag(i)=max(imag(PSD(i).K(I{i})));
% end
% % imposto limiti
% set(ax1(2), 'YLim',[0 1.2*min(temp_real)],'XGrid','on','YGrid','on')
% set(ax1(3), 'YLim',[-1.2*min(temp_imag) 1.2*min(temp_imag)],'XGrid','on','YGrid','on')

% imposto parametri grafico coerenza
set(ax1(1),'Ylim',[0 1])
yticks (ax1(1),[0 0.2 0.5 0.8 0.9 0.95 1])
% imposto parametre grafico modulo
ylabel(ax1(2),'[dB @ 1 g^{-1}]')
% imposto parametre grafico fase
set(ax1(3),'Ylim',[-200 200])
yticks (ax1(3),[-180 -90 0 90 180])
% imposto parametri comuni ai tre subplot
for i=1:3
    set(ax1(i), 'XLim',freq_range_plot, 'XGrid','on','YGrid','on',...
        'Xscale', xscale)
    xlabel(ax1(i),'Frequenza [Hz]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
end
% tifolo figura
sgt=sgtitle(['FRF ',nomemisura],'Interpreter','none');
set(sgt,'FontName','Arial','FontSize',font_size.fs_sgtitle)

% figure singole misure ---------------------------------------------------
fig2=gobjects(N,1);
ax2=gobjects(N,3);
leg = gobjects(N,3);

for i=1:N
    fig2(i)=figure;
    for j=1:3
        % creo subplot
        ax2(i,j) = subplot(3,1,j,'Parent',fig2(i));
        hold (ax2(i,j), 'on')
        % legenda
        leg(i,j)=legend(ax2(i,j),'FontName','Arial','FontSize',...
            font_size.fs_legend,'Location','best');
        % titolo
        title(Titoli{j},'FontSize',20,'FontName','Arial');
    end
    
    % coerenza
    plot(ax2(i,1),PSD(i).f, PSD(i).coh,...
        'LineWidth',2,'Color',string(colore(i,:)),...
        'DisplayName',[nomemis{i}]);
    txx_av = mean(PSD(i).txy,2);
    txx_std = std(PSD(i).txy,[],2);
    switch yscale
        case 'log'
            % modulo
            plot(ax2(i,2),PSD(i).f, 20*log10(abs(txx_av)),...
                'LineWidth',2,'LineStyle','-','Color',string(colore(i,:)),...
                'DisplayName',[nomemis{i}]);
            % std+
            plot(ax2(i,2),PSD(i).f, 20*log10(abs(txx_av)) + 20*log10(1+...
                abs(txx_std)./abs(txx_av)),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'DisplayName','Deviazione standard');
            % std-
            plot(ax2(i,2),PSD(i).f, 20*log10(abs(txx_av)) - 20*log10(1+...
                abs(txx_std)./abs(txx_av)),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'HandleVisibility','off')
        case 'lin'
            % modulo
            plot(ax2(i,2),PSD(i).f, (abs(txx_av)),...
                'LineWidth',2,'LineStyle','-','Color',string(colore(i,:)),...
                'DisplayName',[nomemis{i}]);
            % std+
            plot(ax2(i,2),PSD(i).f, (abs(txx_av)) + abs(txx_std),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'DisplayName','Deviazione standard');
            % std-
            plot(ax2(i,2),PSD(i).f, (abs(txx_av)) - abs(txx_std),...
                'LineWidth',0.5,'LineStyle','--','Color',string(colore(i,:)),...
                'HandleVisibility','off')
    end
    
    massa_campione = campioni{i}.massa(conf(i).conf.campione);
    massa_piastra = piastre.massa(conf(i).conf.piastra);
    
    switch yscale
        case 'log'
            % Massa piastra
            yline(ax2(i,2),20*log10(1/massa_piastra),'-',...
                'LineWidth',0.5,'FontSize',font_size.fs_xyline,...
                'LabelHorizontalAlignment','left',...
                'DisplayName',['Massa piastra ',mat2str(massa_piastra),' kg'])
            yline(ax2(i,2),20*log10(1/massa_campione),'--',...
                'LineWidth',0.5,'FontSize',font_size.fs_xyline,...
                'LabelHorizontalAlignment','left',...
                'DisplayName',['Massa campione ',mat2str(massa_campione),' kg'])
        case 'lin'
            yline(ax2(i,2),(1/massa_piastra),'-',...
                'LineWidth',0.5,'FontSize',font_size.fs_xyline,...
                'LabelHorizontalAlignment','left',...
                'DisplayName',['Massa piastra ',mat2str(massa_piastra),' kg'])
            yline(ax2(i,2),(1/massa_campione),'--',...
                'LineWidth',0.5,'FontSize',font_size.fs_xyline,...
                'LabelHorizontalAlignment','left',...
                'DisplayName',['Massa campione ',mat2str(massa_campione),' kg'])
    end
    % fase
    plot1(3) = plot(ax2(i,3),PSD(i).f, 180/pi*(angle(mean(PSD(i).txy,2))),...
        'LineWidth',2,'Color',string(colore(i,:)),...
        'DisplayName',[nomemis{i}]);
    
    % imposto parametri grafico coerenza
    set(ax2(i,1),'Ylim',[0 1])
    yticks (ax2(i,1),[0 0.2 0.5 0.8 0.9 0.95 1])
    % imposto parametri grafico acceleranza
    switch yscale
        case 'log'
            ylabel(ax2(i,2),'[dB @ 1 g^{-1}]')
        case 'lin'
            ylabel(ax2(i,2),'[g^{-1}]')
    end
                        
    % imposto parametre grafico fase
    set(ax2(i,3),'Ylim',[-200 200])
    yticks (ax2(i,3),[-180 -90 0 90 180])
    % imposto parametri comuni ai tre subplot
    for j=1:3
        set(ax2(i,j), 'XLim',freq_range_plot, 'XGrid','on','YGrid','on',...
            'Xscale',xscale);
        xlabel(ax2(i,j),'Frequenza [Hz]','FontWeight','bold','FontSize',...
            font_size.fs_label,'FontName','Arial');
    end
    % tifolo figura
    sgt(i)=sgtitle(['FRF ',nomemisura,'-',nomemis{i}],'Interpreter','none');
    set(sgt(i),'FontName','Arial','FontSize',font_size.fs_sgtitle)
end
end
