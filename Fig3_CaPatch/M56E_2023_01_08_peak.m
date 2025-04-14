% 
clear;clc;close all
load('M56E_2023_01_08_Aonly_WB_40dBDoor_Open_F_mean.mat')
ID = 'All' ;  
S_type = 'L' ; % T for tonotopy, L for locations, H for horizontal
att_level = 40 ;
S2_level = 50 ;
[X_pix_num, Y_pix_num, ~] = size(F_mean); 
pre_stim = 0.3 ;
ITI = 1.2 ;          %Data acquisition time in "second"
fps = 10 ;
trace_length = ITI*fps;
base_range = 1 : pre_stim*fps ; base_type = 'indi'; % 'indi' or 'toge'
peak_range = (pre_stim+1/fps)*fps : (ITI-0)*fps ; %-1.5 for 0.5s, 30frames stimuli
sumF_range = (pre_stim+1/fps)*fps : (ITI-0) * fps ; %stop point could be determined by plotting raw F traces
dF_type = 'peak' ; % 'peak' or 'sum'
if strcmp(dF_type, 'sum')
    deltaF_threshold = 0.1 ; %0.3 is common
elseif strcmp(dF_type, 'peak')
    deltaF_threshold = 0.015 ; 
end
bg = {'w','r'};
if strcmp (S_type, 'T')
    % x=M102D0005; tonotopy_Hz=round(x.stimulus_ch1(:,6)/1000, 2);
    load('tonotopy_Hz_31.mat')
    S1 = 31 ;      %8, 16, 24 or 32 spks or sound frequency or SNR
    c = jet(S1);
elseif strcmp (S_type, 'L')
    S1 = 32 ;
    c = distinguishable_colors(S1,bg);
elseif strcmp (S_type, 'H')
    S1 = 16 ;
    c = hsv(S1);    
end    

F = reshape(F_mean, X_pix_num, Y_pix_num, trace_length, S1); % X--Y--mean trace--S
dF = F_to_dF (F, base_range, base_type, dF_type, peak_range, sumF_range) ;

figure('Position',[100 100 1500 850]);
[dF_seg_peak_value, peak_value_deltaF]=max(dF, [], 3);
disp_mask=ones(X_pix_num, Y_pix_num); 
disp_mask(dF_seg_peak_value<deltaF_threshold)=0;
imagesc(peak_value_deltaF, 'AlphaData',double(disp_mask)); 
axis('equal'); axis off
colormap(c); caxis([1 S1]); 
if strcmp (S_type, 'T')
    colorbar('XTickLabel', num2str(tonotopy_Hz), 'XTick', 1.5:30/31:S1+0.5)
elseif strcmp (S_type, 'L')    
    colorbar('XTickLabel', num2str((1:S1)'), 'XTick', 1.5:30/31:S1+0.5)
elseif strcmp (S_type, 'H')    
    colorbar('XTickLabel', num2str((1:S1)'), 'XTick', 1.5:(S1-1)/S1:S1+0.5)    
end
title(['Attenuation: ', num2str(att_level), ' dB   threshold with ', dF_type, ...
    ' \DeltaF/F >',num2str(100*deltaF_threshold), '%']);
saveas(gcf, strcat('M56E_2023_01_08_winner_take_all_thres_', num2str(deltaF_threshold*100), '%_',ID,...
    '_att_', num2str(att_level), '_dB','_base_type_', base_type,'_dF_type_', dF_type, '.png'));

% saveas(gcf, strcat('M5E_0108_winner_take_all_thres_', num2str(deltaF_threshold*100), '%_',ID,...
%     '_att_', num2str(att_level), '_dB','_base_type_', base_type,'_dF_type_', dF_type, '.pdf'));
%% for 32 spkrs stimuli computation
% compute the azimuth and elevation---SLOW!
if strcmp (S_type, 'L')
spont_rate = 0;
load('Speakers_32_RH_FD.mat') %speaker info, for 102D, right hemisphere and face door
speakers(16,1) = 180 ; % assign top as back
SRF_thres = 0.75 ; % 0 (all pixel) to 0.5 (within circled line) to 0.99 (best speaker)
tuning_area_2D=nan(X_pix_num,Y_pix_num);
tuning_vector_magnitude_2D=nan(X_pix_num,Y_pix_num);
azimuth_map=nan(X_pix_num,Y_pix_num);
elevation_map=nan(X_pix_num,Y_pix_num);
parfor x = 1 : X_pix_num
        for y = 1 : Y_pix_num
        rates=squeeze(dF(x,y,:)); 
        if disp_mask(x,y)==1
            [tuning_area_2D(x, y), ~, tuning_vector_magnitude_2D(x, y), azimuth_map(x, y), elevation_map(x, y)] ...
                = SRF_para(rates, spont_rate, SRF_thres, speakers);
        end
        end
 end
delete(gcp('nocreate'))
end
%% for 32 spkrs stimuli display
if strcmp (S_type, 'L')
pos=get(0,'ScreenSize'); X_size=pos(3);Y_size=pos(4);
figure('position',[X_size*0.3 Y_size*0.1 X_size*0.65 Y_size*0.55]);
load('HSV_diagram.mat') %181(elevation)*360(azimuth)*3(rgb)
ele_cor=91;azi_cor=180;
full_field_map=nan(X_pix_num, Y_pix_num, 3);
TV_thres = 0 ; % 0 mean NO threshold (show all regions)
area_thres = 2 ; % >1 mean NO threshold
for x=1 : X_pix_num
    for y=1 : Y_pix_num
        Ele=round(elevation_map(x, y));
        Azi=round(azimuth_map(x, y)); 
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
image(full_field_map); axis('equal'); axis off; 
title(['Atten: ', num2str(att_level), 'dB        |TV| >',num2str(TV_thres), '        area <',num2str(area_thres)]);
saveas(gcf, strcat('M56E_2023_01_08_Tuning full  SRF thre_', num2str(SRF_thres), '%_TV thre_', num2str(TV_thres),...
    '_Area thre_', num2str(area_thres),' base_type_', base_type,' dF_type_', dF_type, '.png'));
end