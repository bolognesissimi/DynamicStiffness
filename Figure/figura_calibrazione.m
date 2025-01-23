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

function [fig1,cal2]=figura_calibrazione(PSD,freq_range_plot,font_size,nomemis,...
    nomemisura,colore,massa_sospesa)

%FIGURA_CALIBRAZIONE plotta la FRF per controllare che la massa dinamica
% di risonanza coincida con la massa sospesa del sistema.

N = length(PSD);
I=cell(1,N);

% reperisco valori calibrazione precedenti
[cal_f,cal_a] = parametri_calibrazione();
non_cal = zeros(1,N);
for i=1:N
    % identifico gli elementi corrispondenti al range di frequenze di
    % calibrazione
    [I{i}]=find(PSD(i).f >= freq_range_plot(1) &...
        PSD(i).f <= freq_range_plot(end));
    % calcolo nuovo noeff calibrazione forza
    non_cal(i) = mean( 1/cal_f*(1./mean(abs(PSD(i).txy(I{i})),2)) ) ;
end
cal2 = massa_sospesa / mean(non_cal);


% preparo oggetti grafici
fig1 = figure; % figura
leg = gobjects(3); % vettore legende
ax1 = gobjects(3); % vettore assi

Titoli={'Coerence','Dynamic Mass (force/acceleration)','Phase'};
for i=1:3
    % creo subplot
    ax1(i) = subplot(3,1,i,'Parent',fig1);
    hold (ax1(i), 'on')
    box (ax1(i), 'on')
    % legenda
    leg(i,1)=legend(ax1(i),'FontName','Arial','FontSize',font_size.fs_legend,...
        'Location','best');
    % titolo
    title(Titoli{i},'FontSize',14,'FontName','Arial');
end
for i=1:N
    
    % plot coerenza
    plot1(1) = plot(ax1(1),PSD(i).f, PSD(i).coh,'LineWidth',2,...
        'Color',string(colore(i,:)),'DisplayName','Uncalibrated');
    [~,c]=size(PSD(i).txy);
    
    % plot masse singoli colpi
    for j=1:c
        plot1(2) = plot(ax1(2),PSD(i).f',...
            1/cal_f*(1./(abs(PSD(i).txy(:,j)))),...
            'LineWidth',0.5,'HandleVisibility','off',...
            'Color',[0.8 0.8 0.8]);
    end
    % plot massa media
    plot1(2) = plot(ax1(2),PSD(i).f,...
        1/cal_f*(1./mean(abs(PSD(i).txy),2)),...
        'LineWidth',2,'DisplayName','Uncalibrated',...
        'Color',string(colore(i,:)));
    
    % Massa piastra
    yline(ax1(2),massa_sospesa,'-',...
        'Reference Mass [kg]',...
        'LineWidth',1,'HandleVisibility','off')
    yline(ax1(2),massa_sospesa*1.05,'--',...
        '+5%',...
        'LineWidth',0.5,'HandleVisibility','off')
    yline(ax1(2),massa_sospesa*0.95,'--',...
        '-5%',...
        'LineWidth',0.5,'HandleVisibility','off')
    
    % fase
    plot1(3) = plot(ax1(3),PSD(i).f, 180/pi*(angle(mean(PSD(i).txy,2))),...
        'LineWidth',2,'DisplayName','Uncalibrated',...
        'Color',string(colore(i,:)));
    
    %     plot1(3) = plot(ax1(3),PSD(i).f, imag(PSD(i).K_tfest),...
    %         'LineWidth',1,'DisplayName',nomemis{i},...
    %     'Color',string(colore(i,:)));
end

% plot massa media calibrata
% calcolo valore medio
massa_media = zeros(length(PSD(1).txy(:,1)), N);
for i=1:N
    massa_media (:,i) = mean(abs(PSD(i).txy), 2);
end
    plot1(2) = plot(ax1(2),PSD(i).f,...
        cal2/cal_f*(1./mean (massa_media, 2)),...
        'LineWidth',2,'DisplayName','Calibrated',...
        'Color','Red');

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
set(ax1(1),'Ylim',[0.5 1.1])
yticks (ax1(1),[ 0.5 0.8 0.9 1 1.1])
% imposto parametri grafico massa
set(ax1(2),'Ylim',[0.8*massa_sospesa massa_sospesa*1.3])
% imposto parametre grafico fase
set(ax1(3),'Ylim',[-200 200])
yticks (ax1(3),[-180 -90 0 90 180])
% imposto parametri comuni ai tre subplot
for i=1:3
    set(ax1(i), 'XLim',freq_range_plot, 'XGrid','on','YGrid','on','Xscale',...
        'lin')
    xlabel(ax1(i),'Frequency [Hz]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
end

ylabel(ax1(2),'Dynamic Mass [kg]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');
ylabel(ax1(3),'Angle [°]','FontWeight','bold','FontSize',...
        font_size.fs_label,'FontName','Arial');

% tifolo figura
sgt=sgtitle(['FRF ',nomemisura]);
set(sgt,'FontName','Arial','FontSize',font_size.fs_sgtitle)
end
