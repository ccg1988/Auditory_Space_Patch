% For 500ms stimuli, we usually include 12 frames (sumF_range) after sound onsets
% Created by CCG @ 2021-06-04
% Modified by CCG @ 2021-0X
clear;clc;close all
load('M102D_0606_att20_ITD_R_mean.mat')
[X_pix, Y_pix, ~] = size(R_mean); 
Bin_type = 'ITD' ; %SpectralCues------ILD------ITD
attL = '20' ;          
ss = -300: 30: 300 ; % later on ITD stimuli             
S1 = length(ss) ;               % number of XX stimuli
all_S= num2str(ss') ;
ITI = 2 ;               % Data acquisition time in "second"
fps = 10 ;
trace_length = ITI*fps;
pre_stim = 0.3 ;
base_range = 1 : pre_stim*fps ;  base_type = 'indi'; % 'indi' or 'toge'
dF_type = 'peak' ; % 'peak' or 'sum'
peak_range = (pre_stim+1/fps)*fps : (ITI-0.5)*fps ; 
sumF_range = (pre_stim+1/fps)*fps : (ITI-0.0)*fps ; %stop point could be determined by plotting raw F traces
F = reshape(R_mean, X_pix, Y_pix, trace_length, S1); % X--Y--mean trace--S
dF = F_to_dF (F, base_range, base_type, dF_type, peak_range, sumF_range) ;
%%
best_S_weighted = nan (X_pix, Y_pix) ;
for x = 1 : X_pix
    for y = 1 : Y_pix
        dF_temp = squeeze(dF(x, y, :)) ;
        dF_temp(dF_temp<0)=0;
        best_S_weighted(x, y) = ss*dF_temp/sum(dF_temp);
    end
end    
%%
colorbar_max = 75 ;
colorbar_min = -75 ;
if strcmp(dF_type, 'peak')
    deltaF_threshold = 0.02 ; 
elseif strcmp(dF_type, 'sum')
    deltaF_threshold = 0.03 ;
end
figure('Position',[20 100 1600 850]);
[dF_mask, best_S] = max(dF,[],3);
disp_mask = nan(X_pix, Y_pix) ;
disp_mask( dF_mask >= deltaF_threshold )=1;

% subplot(1, 3, 1)
% imagesc(dF_mask, 'AlphaData',double(disp_mask)); axis off; axis('equal'); 
% caxis([0 0.01]);
% title(['Sound induced \DeltaF/F   thres: ', num2str(deltaF_threshold*100)])
%
aa=subplot(1, 2, 1);
imagesc(best_S, 'AlphaData',double(disp_mask)); axis off; axis('equal'); %colormap('turbo');
c=parula(S1); colormap(aa, c); 
cb = colorbar; %colormap('turbo');
cb.Position(1)=cb.Position(1)+0.02;
cb.Position(2)=cb.Position(2)+0.11; 
cb.Position(4)=0.5;
cb.XTickLabel=all_S;
cb.XTick=1.5:(S1-1)/S1:S1+0.5;
title( ['Best ', Bin_type, ' (Winner take all)  dF thres=',...
    num2str(deltaF_threshold*100),'%' ] )

aa=subplot(1, 2, 2);
imagesc(best_S_weighted, 'AlphaData',double(disp_mask)); axis off; axis('equal'); 
cb = colorbar; %colormap('turbo');
cb.Position(1)=cb.Position(1)+0.02;
cb.Position(2)=cb.Position(2)+0.11; 
cb.Position(4)=0.5;
% set(cb,'position',[.15 .1 .1 .3]) % [xposition yposition width height].
caxis([colorbar_min colorbar_max]);
title( ['Weighted ', Bin_type] )
saveas( gcf, strcat('M102D_0606_', Bin_type, '_',dF_type, '_dF',' base_type_', base_type,'_Att_', attL, ...
    '_Cmin_', num2str(colorbar_min),'_Cmax_', num2str(colorbar_max), ...
    '_dB_', num2str(deltaF_threshold*100), '%.png') ) ;