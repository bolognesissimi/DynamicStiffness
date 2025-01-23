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

function [fig1]=figura_scheda(PSD,freq_range_plot,font_size,nomemis,colore)

%FIGURA_SCHEDA Realizza una figura secondo

N = length(PSD);
I = cell(N,1);
for i=1:N
    I{i} = find(PSD(i).f>freq_range_plot(1)&PSD(i).f<freq_range_plot(end));
end
fig1 = gobjects(N,1);
sgt = gobjects(N,1);
sub1 = gobjects(N,4);
leg = gobjects(N,2);

Titoli={'Coerenza','Modulo','Parte reale e immaginaria','Fase'};

for i=1:N
    fig1(i) = figure;
    sgt(i) = sgtitle(['Rigidità Dinamica - Misura in sito non risonante - '...
        ,nomemis{i}]);
    set (sgt(i),'FontSize',font_size.fs_sgtitle,'FontName','Arial')
    % creo subplot
    for j=1:4
        sub1(i,j) = subplot(4,1,j,'Parent',fig1(i));
        hold(sub1(i,j),'on');
    end
    % Legende
    leg(i,1)=legend(sub1(i,2),'FontName','Arial','FontSize',font_size.fs_legend,...
        'Location','best');
    leg(i,2)=legend(sub1(i,3),'FontName','Arial','FontSize',font_size.fs_legend,...
        'Location','best');
    %coerenza
    plot(sub1(i,1),PSD(i).f, PSD(i).coh,'LineWidth',2,...
        'Color',string(colore(1,:)));
    
    % modulo
    plot(sub1(i,2),PSD(i).f, 20*log10(abs(PSD(i).K_tfest)),'LineWidth',2,...
        'Color',string(colore(1,:)),'DisplayName','Modulo');
    plot(sub1(i,2),PSD(i).f, 20*log10(abs(PSD(i).K_tfest)) + 20*log10(1+...
        abs(PSD(i).dK_tfest)./abs(PSD(i).K_tfest)),...
        'LineWidth',1,'LineStyle','--','Color',string(colore(1,:)),...
        'DisplayName','Deviazione standard');
    plot(sub1(i,2),PSD(i).f, 20*log10(abs(PSD(i).K_tfest)) - 20*log10(1+...
        abs(PSD(i).dK_tfest)./abs(PSD(i).K_tfest)),...
        'LineWidth',1,'LineStyle','--','Color',string(colore(1,:)),...
        'HandleVisibility','off');
    
    % reale e immaginaria
    plot(sub1(i,3),PSD(i).f, real(PSD(i).K_tfest),'LineWidth',2,...
        'Color',string(colore(1,:)),'DisplayName','Parte reale');
    plot(sub1(i,3),PSD(i).f, imag(PSD(i).K_tfest),'LineWidth',2,...
        'LineStyle','--','Color',string(colore(2,:))...
        ,'DisplayName','Parte immaginaria');
    % fase
    plot(sub1(i,4),PSD(i).f, 180/pi*(angle(PSD(i).K_tfest)),...
        'LineWidth',2,'Color',string(colore(1,:)));
    % imposto manualmente i massimi e minimi dei grafici
    %     set(sub1(i,2),'YLim',[0 1.2*max(abs(PSD(i).K_tfest(I{i})))],...
    %         'XGrid','on','YGrid','on')
    set(sub1(i,2),...
        'XGrid','on','YGrid','on')
    % etichetta asse y modulo
    ylabel(sub1(i,2),'Rigidità dinamica [dB @ 1N/m]',...
        'FontWeight','normal','FontSize', font_size.fs_label,...
        'FontName','Arial');
    % etichetta asse y parte reale e immaginaria
    ylabel(sub1(i,3),'Rigidità dinamica [N/m]',...
        'FontWeight','normal','FontSize', font_size.fs_label,...
        'FontName','Arial');
    
    
    % imposto parametri grafico coerenza
    set(sub1(i,1),'Ylim',[0 1])
    yticks (sub1(i,1),[0 0.2 0.5 0.8 0.9 1])
    % imposto parametri grafico fase
    set(sub1(i,4),'Ylim',[-190 190])
    yticks (sub1(i,4),[-180 -90 0 90 180])
    % imposto parametri comuni ai tre subplot
    for j=1:4
        set(sub1(i,j), 'XLim',freq_range_plot, 'XGrid','on','YGrid','on')
        % tichette asse x
        xlabel(sub1(i,j),'Frequenza [Hz]',...
            'FontWeight','normal','FontSize', font_size.fs_label,...
            'FontName','Arial');
        % titoli
        title(sub1(i,j),Titoli{j},...
            'FontSize',font_size.fs_title,'FontName','Arial');
        % Limite in frequenza
        xline(sub1(i,j),PSD(i).fmax,'-',...
            ['f_{max} (-10dB): ',num2str(round(PSD(i).fmax)),...
            'Hz'],'LineWidth',1,'HandleVisibility','off',...
            'Color',string(colore(1,:)));
        box(sub1(i,j),'on');
    end
end
drawnow;
for j=1:2
    set(leg(i,j),'Location','best');
end
% esporto la figura in pdf
% for i=1:N
%     exportgraphics( fig1(i),cell2mat(['Figura scheda ',nomemis(i),'.pdf']))
% end
end
