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

function [ PSD, figure1] = coerenza( sng,win_1,freq_range,freq_range_plot,...
    fs,font_size)
%COERENZA  Calcolo della coerenza secondo ISO 7626-5
%   The coherence function is defined as the ratio of the square of the
%   magnitude of the averaged cross-spectrum between the force and the
%   response, to the product of the averaged auto-spectra of the force and
%   of the response. The coherence function expresses the degree of linear
%   relationship between the response and the force for each sampled
%   frequency.
%   The value of the coherence function is always between 1 and 0. If the FRF
%   of a linear system were measured without error, the coherence function
%   would equal 1. A coherence value less than 1 is an indication of possible
%   poor quality of data.
%   The accuracy of a coherence estimate depends on both the number of
%   data
%   records which were averaged to obtain it and the true value of the
%   coherence. If the true value is high (greater than 0,9), then only a
%   few records (five to ten) are needed to achieve high statistical
%   confidence in the accuracy of the estimate. Formulae for estimating
%   errors are given in Reference [5].
%   NOTE 1 Low coherence at “anti-resonance” frequencies is not generally
%   a cause for concern about data quality.

N = length(sng);
PSD = struct('F',cell(1,N),'A',[],'alert',[]);
[Lsample,~] = size(sng(1).F);

% inizializzo oggetti grafici
figure1 = gobjects(1,N);
subplot1 = gobjects(2,N);
for i=1:N
    tic
    % finestra unitaria per non far calcolare la normalizzazione a periodogram
    %win_1 = ones(size(sng(i).win_F(:,1)));
    %win_1=4*1024;
    
    % cross spectrum between F and A
    %[pxy, f] = cpsd(sng(i).F_filt, sng(i).A_filt,win_1,[],Lsample,fs(i));
    [pxy, f] = cpsd(sng(i).F_filt, sng(i).A_filt,win_1,[],Lsample,fs(i));
    PSD(i).A = pxy;% abs(pxy);%.^2;
    PSD(i).pxy = pxy;
    PSD(i).f = f;
    PSD(i).fs = fs(i);
    averaged_cross_spectrum_F_A = mean(PSD(i).pxy,2);
    
    % autospectrum of F
    %[pxx, ~] = cpsd(sng(i).F_filt, sng(i).F_filt,win_1,[],Lsample,fs(i));
    [pxx, ~] = cpsd(sng(i).F_filt, sng(i).F_filt,win_1,[],Lsample,fs(i));
    PSD(i).F = pxx;
    PSD(i).pxx = pxx;
    averaged_autospectrum_F=mean(pxx,2);
    
    % autospectrum A
    %[pyy, ~] = cpsd(sng(i).A_filt, sng(i).A_filt,win_1,[],Lsample,fs(i));
    [pyy, ~] = cpsd(sng(i).A_filt, sng(i).A_filt,win_1,[],Lsample,fs(i));
    averaged_autospectrum_A=mean(pyy,2);
    PSD(i).pyy = pyy;
    
    % coherence
    coh = (abs(averaged_cross_spectrum_F_A)).^2 ./ ...
        (averaged_autospectrum_F .* averaged_autospectrum_A);
    PSD(i).coh=coh;
    
    % tfestimate
    [txy]=tfestimate(sng(i).F_filt,sng(i).A_filt,win_1,[],Lsample,fs(i));
    PSD(i).txy =txy;
    
    % analisi larghezza di banda
    % cerco l'indice corrispondente alla frequenza più vicina a 50Hz
    f0 = find(PSD(i).f>50,1);
    % calcolo un vettore temporaneo con i livelli in dB
    PSD_Fav_dB = 20*log10(abs(PSD(i).F));
    % cerco l'indice del punto maggiore di 50Hz in cui la forza è 10dB meno
    % del valore a 50Hz
    fmax_10dB = find(PSD_Fav_dB(f0:end) < (PSD_Fav_dB(f0)-10),1);
    % memorizzo la frequenza corrispondente sommando all'indice di fo
    % l'indice trovato
    fmax = f(fmax_10dB+f0);
    PSD(i).fmax = fmax;
    fmax_20dB = find(PSD_Fav_dB(f0:end) < (PSD_Fav_dB(f0)-20),1);
    % memorizzo la frequenza corrispondente sommando all'indice di fo
    % l'indice trovato
    fmax = f(fmax_20dB+f0);
    PSD(i).fmax_20dB = fmax;
    
    disp('Fine dei calcoli');toc;
    
    % Plot figura coerenza
    figure1(i) = figure;
    Titoli={'Coerenza','Potenze spettrali'};
    
    for j=1:2
        subplot1(j,i) = subplot(2,1,j,'Parent',figure1(i));
        hold (subplot1(j,i), 'on')
        title(Titoli{j},'FontSize',font_size.fs_title,'FontName','Arial');
    end
    % plot coerenza
    plot(subplot1(1,i),PSD(i).f,PSD(i).coh,'DisplayName','coherence',...
        'LineWidth',2);
    xline(subplot1(1,i),PSD(i).fmax,'-',...
        ['Limite in frequenza (-10dB): ',num2str(round(PSD(i).fmax)),'Hz'],...
        'LineWidth',1,'HandleVisibility','off');
    xline(subplot1(1,i),PSD(i).fmax_20dB,'-',...
        ['Limite in frequenza (-20dB): ',num2str(round(PSD(i).fmax_20dB)),'Hz'],...
        'LineWidth',1,'HandleVisibility','off');
    set(subplot1(1,i),'XScale','lin','XLim',freq_range_plot)
    
    
    % plot potenze spettrali
    % plot PXY
    set(subplot1(2,i),'XLim',freq_range_plot,'XScale','lin','YScale','log')
    temp=mean(PSD(i).pxy,2);
    plot(subplot1(2,i),PSD(i).f,abs(temp/max(temp)),...
        'DisplayName','averaged cross spectrum F A','LineWidth',1);
    % plot PXX
    temp=mean(PSD(i).pxx,2);
    plot(subplot1(2,i),PSD(i).f,abs(temp/max(temp)),...
        'DisplayName','averaged autospectrum F','LineWidth',1);
    % plot PYY
    temp=mean(PSD(i).pyy,2);
    plot(subplot1(2,i),PSD(i).f,abs(temp/max(temp)),...
        'DisplayName','averaged autospectrum A','LineWidth',1);
    legend (subplot1(2,i),'FontSize',font_size.fs_legend, 'Location','best');
    %drawnow
    % imposto parametri comuni ai due subplot
    for j=1:2
        set(subplot1(j,i),'XLim',freq_range_plot,'XGrid','on','YGrid','on')
        xlabel(subplot1(j,i),'Frequenza [Hz]','FontWeight','bold',...
            'FontSize',font_size.fs_label,'FontName','Arial');
        box(subplot1(j,i),'on');
    end
    % imposto parametri grafico coerenza
    set(subplot1(1,i),'Ylim',[0 1])
    yticks (subplot1(1,i),[0 0.2 0.5 0.8 0.9 0.95 1])
end

% Cerco le frequenza comprese nell'intervallo di interesse
[I] = find (PSD(i).f>=freq_range(1) & PSD(i).f<=freq_range(end));
%Analizzo le coerenze delle misure
for i=1:N
    % Definisco un indicatore che mi valuta la bontà della coerenza
    II = find (PSD(i).coh(I,:)<0.95);
    %integr=cumtrapz((1-PSD(i).coh(I,:)));
    %incoerenza=integr(end);
    incoerenza=length(II)/length(I);
    disp(incoerenza)
    % se riscontro una anomalia comunico a schermo e eseguo analisi
    if incoerenza>0.1
        PSD(i).alert=1;
        disp (['Errore sulla coerenza in misura ',num2str(i),' tra ',...
            num2str(freq_range(1)),'Hz e ',num2str(freq_range(end)),'Hz:']);
        %disp(integr(end));
        disp(incoerenza);
        % calcolo coerenze singoli colpi
        coh=mscohere(sng(i).F_filt,sng(i).A_filt,win_1,[],PSD(i).f,fs(i));
        [~,c]=size(coh);
        inc=zeros(1,c);
        for j=1:c
            III = find(coh(I,j)<0.95);
            inc(j)=length(III)/length(I);
        end
        [min_inc, best_ind]=min(inc);
        [max_inc, worst_ind]=max(inc);
        % plotto la migliore e la peggiore delle coerenze
        fig2=figure;
        ax1 = axes('Parent',fig2);
        hold on
        set(ax1,'XLim',freq_range_plot,'Ylim',[0 1],'XScale','lin',...
            'XGrid','on','YGrid','on')
        yticks (ax1,[0 0.2 0.5 0.8 0.9 0.95 1])
        xlabel(ax1,'Frequenza [Hz]','FontWeight','bold',...
            'FontSize',font_size.fs_label,'FontName','Arial');
        plot(ax1,PSD(i).f,coh(:,worst_ind),'LineWidth',1,...
            'DisplayName',['Max incoerenza (',num2str(max_inc),...
            ') in colpo n°',num2str(worst_ind),'.'])
        plot(ax1,PSD(i).f,coh(:,best_ind),'LineWidth',1,...
            'DisplayName',['Min incoerenza (',num2str(min_inc),...
            ') in colpo n°',num2str(best_ind),'.'])
    legend (ax1,'FontSize',font_size.fs_legend, 'Location','best');
%     fig3=figure;
%     boxplot(inc);
    end
end

end