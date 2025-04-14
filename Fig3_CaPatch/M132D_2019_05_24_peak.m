% Compute the best stimulus (spatial and tonotopy) and SRF only for 132D monkey
% Compared to 102D, there is no pre_stim (1st frame is not baseline) and
%   images were continuously acquired, so last frame could be used as baseline
% modified from "P4_tuning_map_1dB.m" @ 2021-04-19

clear;clc;close all
load('M132D_2019_05_24_Att30_WB_Noise_R_mean.mat')
ID = 'All' ;   
att_level = 30 ;
theta = -30 ; %window rotation angle (after rostral-caudal fliping)
[X_pix, Y_pix, ~] = size(R_mean); 
ITI = 10 ;          %Data acquisition time in "second"
fps = 10 ;
df_window = 1.0 ;
trace_length = ITI*fps;
peak_range = 1 : df_window*fps; %Definately not search among all 10s 
deltaF_threshold = 0.03 ; % 0.03 for dF max peak, 0.2 for dF summed area
S1 = 24 ;      %8, 16, 24 or 32 speakers or sound frequency or SNR
R_F = reshape(R_mean, X_pix, Y_pix, trace_length, S1); % X--Y--mean trace--S
R_base_all = R_F(:, :, (end-2*fps+1):end, :); %********************last 2s as baseline********************
R_base = mean(R_base_all, 3); %mean value of last 2 second; Not use squeeze 
R_dF = ( R_F - R_base ) ./ R_base; % From F to dF/F
R_dF_peak = squeeze(max(R_dF(:, :, peak_range, :), [], 3)); % largest value among  range
%%% R_dF_peak = squeeze(sum(R_dF(:, :, peak_range, :), 3)); %summed value among  range
R_dF_peak = flip(R_dF_peak ,2); %left window mirror to right
[R_dF_seg_peak_value, peak_value_deltaF]=max(R_dF_peak, [], 3);
disp_mask=ones(X_pix, Y_pix); 
disp_mask(R_dF_seg_peak_value<deltaF_threshold)=0;
disp_mask(37:57, 108:168) = 0;
disp_mask(58:64, 114:168) = 0;
%
figure('Position',[100 100 1500 850]);
deltaF_peak_disp = 0.25 ;
ax1=subplot(1, 2, 1);
imagesc(R_dF_seg_peak_value); caxis([deltaF_threshold deltaF_peak_disp]); colormap(ax1, 'parula')
axis('equal'); axis off; 
title(['\DeltaF/F display peak is: ', num2str(deltaF_peak_disp*100), '%']);

ax2=subplot(1, 2, 2);
bg = {'w','r'};c = distinguishable_colors(S1, bg);
imagesc(peak_value_deltaF, 'AlphaData',double(disp_mask)); 
axis('equal'); axis off
colormap(ax2, c); caxis([1 S1]); %---for spatial tuning curve under single level with all reps
title(['Attenuation: ', num2str(att_level), ' dB   threshold with sum \DeltaF/F >',num2str(100*deltaF_threshold), '%']);
saveas(gcf, strcat('M132D_2019_05_24_winner_take_all_thres_', num2str(deltaF_threshold*100),...
    '%_',ID, '_att_', num2str(att_level), 'dB_peak.png'));
%%
% compute the azimuth and elevation---SLOW!
spont_rate = 0;
load('Speakers_32_LH_BD.mat') %speaker info, for 132D, left hemisphere and back door
speakers(16,1) = 180 ; % assign top as back
SRF_thres = 0.75 ; % 0 (all pixel) to 0.5 (within circled line) to 0.99 (best speaker)
tuning_area_2D=nan(X_pix,Y_pix);
tuning_vector_magnitude_2D=nan(X_pix,Y_pix);
azimuth_map=nan(X_pix,Y_pix);
elevation_map=nan(X_pix,Y_pix);
parfor x = 1 : X_pix
        for y = 1 : Y_pix
        rates=squeeze(R_dF_peak(x,y,:));
        if disp_mask(x,y)==1
            [tuning_area_2D(x, y), ~, tuning_vector_magnitude_2D(x, y),... 
                azimuth_map(x, y), elevation_map(x, y)] ...
                = SRF_para(rates, spont_rate, SRF_thres, speakers);
        end
        end
 end
delete(gcp('nocreate'))
%%
load('HSV_diagram.mat') %181(elevation)*360(azimuth)*3(rgb)
rotate_YN = 'N' ;
ele_cor=91;azi_cor=180;
full_field_map=nan(X_pix, Y_pix, 3);
TV_thres = 0 ; % 0 mean NO threshold (show all regions)
area_thres = 2 ; % >1 mean NO threshold
for x=1 : X_pix
    for y=1 : Y_pix
        Ele=round(elevation_map(x, y));
        Azi=round(1*azimuth_map(x, y)); %use -1 to shift the SRF of 132 to match 102D data
        TV=squeeze(tuning_vector_magnitude_2D(x, y));
        SRF_area=squeeze(tuning_area_2D(x, y));
        if Azi==-180
            Azi=Azi+1;
        end
        if ~isnan(Ele)  &&  ~isnan(Azi)
            full_field_map(x, y,  :)=squeeze(HSV_diagram(Ele+ele_cor, Azi+azi_cor, :));
        end
        if isnan(Ele)  ||  isnan(Azi) || TV<=TV_thres || SRF_area>=area_thres
            full_field_map(x, y,  :)=[0.5; 0.5; 0.5];
        end    
    end
end
azimuth_map = 1*azimuth_map ; %use -1 to shift the SRF of 132 to match 102D data
% disp_mask =  flip(disp_mask ,2); %left window mirror to right
% azimuth_map = flip(azimuth_map ,2); 
% elevation_map = flip(elevation_map ,2); 
% full_field_map = flip(full_field_map ,2); 
%
figure('Position', [200 200 750 700]);
% full_field_map_change1 = flip(full_field_map ,2); 

if strcmp(rotate_YN, 'Y')
    % full_field_map_change2 = imrotate_white(full_field_map_change1, -theta); %useless
    % padding the background with gray color; default color of "imrotate" is black
    full_field_map_change2 = imrotate(full_field_map, theta);
    Mrot = ~imrotate(true(size(full_field_map)), theta);
    back_id = Mrot&~imclearborder(Mrot) ; back_id(:,:, 1:2)=[];
    for x = 1 : size (back_id ,1)
        for y = 1 : size (back_id ,2)
            if back_id(x, y)
                full_field_map_change2(x, y, :) = [0.5 0.5 0.5];
            end
        end
    end
    % to decrease window size: xmin/ymin++ and width/height--
    % full_field_map_change2 = imcrop(full_field_map_change2, [90 70 279 259]) ; % [xmin ymin width height]
elseif strcmp(rotate_YN, 'N')
    full_field_map_change2 = full_field_map;
end

image(full_field_map_change2); 
axis('equal'); axis off; 
title(['Atten: ', num2str(att_level), 'dB        |TV| >',num2str(TV_thres), ...
    '        area <',num2str(area_thres),...
    '    summed df/f range 1to', num2str(df_window*fps), ' frames']);
saveas(gcf, strcat('M132D_2019_05_24_Att_', num2str(att_level), 'dB_SRF_thres', num2str(SRF_thres), ...
    '%_TV thre_', num2str(TV_thres),...
    '_Area thre_', num2str(area_thres), '_df_range_', num2str(df_window), 's_peak.png'));
%%
% figure('Position', [100 200 1550 700]);
% ax1=subplot(1, 2, 1);
% imagesc(azimuth_map, 'AlphaData',double(disp_mask));
% axis('equal'); axis off; colormap(gca, hsv); set(ax1,'color','w'); caxis([-180 180]); colorbar
% 
% ax2=subplot(1, 2, 2);
% % elevation_map_new = elevation_map;
% % for x = 1 : size (elevation_map ,1)
% %         for y = 1 : size (elevation_map ,2)
% %             if isnan (elevation_map(x, y))
% %                 elevation_map_new(x, y) = [0 1 0] ;
% %             end    
% %         end    
% % end
% % imagesc(elevation_map_new);
% imagesc(elevation_map, 'AlphaData',double(disp_mask));
% axis('equal'); axis off; colormap(gca, gray); set(ax2,'color','g'); caxis([-90 90]); colorbar
% 
% saveas(gcf, strcat('Tuning area and Tuning vector magnitude', '.png')); 
