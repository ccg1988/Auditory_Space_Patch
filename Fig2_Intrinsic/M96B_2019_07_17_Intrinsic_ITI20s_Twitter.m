% 
clear;clc
close all
load('M96B_2019_07_17_R_mean_ITI20s.mat')
ID = 'All' ;
att_level = 40 ;
[X_pix, Y_pix, ~] = size(R_mean); 
S1 = 32 ;         % 24 or 32 spks or sound frequency or SN
ITI = 10 ;          % Data acquisition time in "second"
fps = 5 ;
trace_length = ITI*fps;
peak_range = 2*fps : 6*fps ; %2s to 6s (from Xindong's manuscript)
deltaF_threshold = 0.2 ; % 0.03 for dF max peak, 0.2 for dF summed area
R_F = reshape(R_mean, X_pix, Y_pix, trace_length, S1); % X--Y--mean trace--S
R_base_all = R_F(:, :, 1:1*fps, :); %********************first 1s as baseline********************
R_base = mean(R_base_all, 3); %mean value of first 1second; Not use squeeze 
R_dF = -1*( R_F - R_base ) ./ R_base; % change negative dR/R to positive*****!!!!!!*****
R_dF_peak = squeeze(sum(R_dF(:, :, peak_range, :), 3)); % summed value among range
bg = {'w','r'};c = distinguishable_colors(S1, bg);

c_new = [c(5, :); c(6:8, :); c(1:4, :); c(30, :); c(13:15, :); c(10:12, :);
    c(16, :); c(21:23, :); c(25, :); c(17:19, :); c(24, :);
    c(20, :); c(32, :); c(31, :); c(29, :); c(28, :); c(9, :); c(27, :); c(26, :)] ;

figure('Position',[100 100 1500 850]);
[R_dF_seg_peak_value, peak_value_deltaF] = max (R_dF_peak, [], 3);
disp_mask=ones(X_pix, Y_pix); 
disp_mask(R_dF_seg_peak_value<deltaF_threshold)=0;
imagesc(peak_value_deltaF, 'AlphaData',double(disp_mask)); 
axis('equal'); axis off
colormap(c_new); caxis([1 S1]); %---for spatial tuning curve under single level with all reps
title(['Attenuation: ', num2str(att_level), ' dB   threshold with peak \DeltaF/F >',num2str(100*deltaF_threshold), '%']);
saveas(gcf, strcat('M96B_2019_07_17_winner_take_all_', num2str(deltaF_threshold*100), ...
    '%_',ID, '_att_', num2str(att_level), 'dB.png'));
% %%
% % compute the azimuth and elevation---SLOW!
% spont_rate = 0;
% load('Speakers_32_LH_BD.mat') %speaker info, for 96B, left hemisphere and back to the door
% speakers(16,1) = 180 ; % assign top as back
% SRF_thres = 0.8 ; % 0 (all pixel) to 0.5 (within circled line) to 0.99 (best speaker)
% tuning_area_2D=nan(X_pix,Y_pix);
% tuning_vector_magnitude_2D=nan(X_pix,Y_pix);
% azimuth_map=nan(X_pix,Y_pix);
% elevation_map=nan(X_pix,Y_pix);
% parfor x = 1 : X_pix
%         for y = 1 : Y_pix
%         rates=squeeze(R_dF_peak(x,y,:)); 
%         rates(rates<0)=0;
%         if disp_mask(x,y)==1
%             [tuning_area_2D(x, y), ~, tuning_vector_magnitude_2D(x, y), azimuth_map(x, y), elevation_map(x, y)] ...
%                 = SRF_para(rates, spont_rate, SRF_thres, speakers);
%         end
%         end
%  end
% delete(gcp('nocreate'))
% %%
% load('HSV_diagram.mat') %181(elevation)*360(azimuth)*3(rgb)
% ele_cor=91;azi_cor=180;
% full_field_map=nan(X_pix, Y_pix, 3);
% TV_thres = 0 ; % 0 mean NO threshold (show all regions)
% area_thres = 2 ; % >1 mean NO threshold
% for x=1 : X_pix
%     for y=1 : Y_pix
%         Ele=round(elevation_map(x, y));
%         Azi=round(azimuth_map(x, y)); 
%         TV=squeeze(tuning_vector_magnitude_2D(x, y));
%         SRF_area=squeeze(tuning_area_2D(x, y));
%         if Azi==-180
%             Azi=Azi+1;
%         end
%         if ~isnan(Ele)  &&  ~isnan(Azi)
%             full_field_map(x, y,  :)=squeeze(HSV_diagram(Ele+ele_cor, Azi+azi_cor, :));
%         end
%         if isnan(Ele)  ||  isnan(Azi) || TV<=TV_thres || SRF_area>=area_thres
%             full_field_map(x, y,  :)=[0.5; 0.5; 0.5];
%         end    
%     end
% end
% figure('Position', [200 200 750 700]);
% image(full_field_map); axis('equal'); axis off; 
% title(['Atten: ', num2str(att_level), 'dB        |TV| >',num2str(TV_thres), '        area <',num2str(area_thres)]);
% saveas(gcf, strcat('M96B_2019_07_02_Tuning full  SRF thre_', num2str(SRF_thres), '%_TV thre_', num2str(TV_thres),...
%     '_Area thre_', num2str(area_thres), '.png'));
% %%
% figure('Position', [100 200 1550 700]);
% subplot(1, 2, 1);
% imagesc(azimuth_map, 'AlphaData',double(disp_mask));
% axis('equal'); axis off; colormap(gca, hsv); set(gcf,'color','w'); caxis([-180 180]); colorbar
% subplot(1, 2, 2);
% imagesc(elevation_map, 'AlphaData',double(disp_mask));
% axis('equal'); axis off; colormap(gca, gray); set(gcf,'color','w'); caxis([-90 90]); colorbar
% saveas(gcf, strcat('M96B_2019_07_02_azimuth_elevation', '.png')); 