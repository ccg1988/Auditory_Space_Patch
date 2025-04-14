%Calculte the tonotopy for all pixels---Spectrum method
%New stimulus from 1kHz to 32kHz
%by CCG @ 2019-05-11
%for 1 to 32kHz
% sound_duration=14.8;start_freq=1;end_freq=32;
%for A4 to A10

clear; clc; close all
load('M102D_2020_09_11_UP_DOWN.mat')

sound_duration=14.6;start_freq=0.44;end_freq=28.16;

oct=log2(end_freq/start_freq);
amp_UP=UP{1}';amp_DOWN=DOWN{1}';delay_UP=UP{2}';delay_DOWN=DOWN{2}';%transpose for Thorlabs
X_size=size(amp_UP,1);Y_size=size(amp_UP,2);
signal_mean=(delay_UP-delay_DOWN)/2+10;signal_vector=reshape(signal_mean,[],X_size*Y_size);
delay_mean=(delay_UP+delay_DOWN)/2-10;
jitter_start = 2 ; jitter_end = 6 ; %UP and DOWN signal delay's difference (seconds)
SD_num = 1.25 ; % key parameter to adjust the masking threshold
display_floor=1;display_ceil=90;
threshold=std(std(amp_UP+amp_DOWN));
mask=ones(X_size,Y_size);
for x=1:X_size
    for y=1:Y_size
        if (amp_UP(x,y)+amp_DOWN(x,y))<SD_num*threshold
           mask(x,y)=0;
        end
        if delay_mean(x,y)>jitter_end||delay_mean(x,y)<jitter_start
           mask(x,y)=0;
        end
    end
end

figure;ha=tight_subplot(2,3,[.1 .001],[.1 .05],[.03 .05]);
axes(ha(1));imagesc(amp_UP+amp_DOWN);colormap(jet);axis('equal');title('Signal Amplitude Map');grid off;set(gca,'XTick',[],'YTick',[]);colorbar
axes(ha(4));imagesc((amp_UP-amp_DOWN)/mean(mean(amp_DOWN)));colormap(jet);axis('equal');title('Amplitude: UP minus DOWN PreferenceMap');grid off;set(gca,'XTick',[],'YTick',[]);colorbar
axes(ha(2));imagesc(delay_mean);colormap(jet);axis('equal');title('Hemodynamics Delay Map');grid off;set(gca,'XTick',[],'YTick',[]);colorbar
axes(ha(3));histogram(delay_mean,'Normalization','probability');title('Distribution of DOWN plus UP: Hemodynamics Delay \Phid');
xlabel('time (second)');xlim([-10 10]);ylabel('Proportion');
axes(ha(6));histogram(signal_mean,'Normalization','probability');title('Distribution of DOWN minus UP: Signal Delay \Phis');
xlabel('time (second)');xlim([0 20]);ylabel('Proportion');
axes(ha(5));imagesc(signal_mean,'AlphaData',double(mask));colormap(jet);axis('equal');
title(['Signal Map    Threshold: <',num2str(jitter_end),'s&>',num2str(jitter_start),'s Delay and >',num2str(SD_num),'STD Amplitude'])
signal_bottom=prctile(signal_vector,display_floor);signal_top=prctile(signal_vector,display_ceil);
bar_bottom=start_freq*2^((signal_bottom/sound_duration)*oct);
bar_top=start_freq*2^((signal_top/sound_duration)*oct);
bar_bottom=round(bar_bottom,2);bar_top=round(bar_top,2);caxis([signal_bottom signal_top]);
colorbar('Ticks',[signal_bottom,signal_top],'TickLabels',{[num2str(bar_bottom),' kHz  '],[num2str(bar_top),' kHz']});
grid off;set(gca,'XTick',[],'YTick',[])
%%
figure;imagesc(signal_mean,'AlphaData',double(mask));colormap(jet);axis('equal')
title(['Signal Map    Threshold: <',num2str(jitter_end),'s&>', ...
    num2str(jitter_start),'s Delay and >',num2str(SD_num),'STD Amplitude'])
signal_bottom=prctile(signal_vector,display_floor);signal_top=prctile(signal_vector,display_ceil);
bar_bottom=start_freq*2^(((signal_bottom-(-sound_duration/2))/sound_duration)*oct);
bar_top=start_freq*2^(((signal_top-(-sound_duration/2))/sound_duration)*oct);
bar_bottom=round(bar_bottom,2);bar_top=round(bar_top,2);caxis([signal_bottom signal_top]);
colorbar('Ticks',[signal_bottom,signal_top],'TickLabels', ...
    {[num2str(bar_bottom),' kHz  '],[num2str(bar_top),' kHz']});
grid off;set(gca,'XTick',[],'YTick',[])
%%
% figure;histogram(reshape(signal_mean,X_size*Y_size,1))