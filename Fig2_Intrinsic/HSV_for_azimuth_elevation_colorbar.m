%Display the HSV using changes of Value and Saturation
%Created 2020-02-04
%Modified 2020-02-05
%Coarse resolution
hsv=[0.1 1 0;0.1 1 0.3;0.1 1 0.5;0.1 1 0.7;0.1 1 1;0.1 0.7 1;0.1 0.5 1;0.1 0.3 1;0.1 0 1];
%Finner resolution
steps=181;steps_half=(steps-1)/2;%100 for V,100 for S
range=360;
% HSV_steps=((1:100)/100)';
HSV_steps=((0:steps_half-1)/(steps_half))';
HSV_saturation=[ones(steps_half,1);1;flip(HSV_steps)];
HSV_value=[HSV_steps;1;ones(steps_half,1)];
%Only display the specified, single color
HSV_hue=0.1*ones(steps,1);
HSV_combine=cat(2,HSV_hue,HSV_saturation,HSV_value);%H--S--V
% rgb = hsv2rgb(hsv);
rgb = hsv2rgb(HSV_combine);
figure;s=surf(peaks);colormap(rgb);s.EdgeColor='none';
%%
%Display all the colors within full circle
HSV_diagram=zeros(steps,range,3);
Shift_angle=0;
for i=1:range
   HSV_hue=(i/range)*ones(steps,1);
   HSV_combine=cat(2,HSV_hue,HSV_saturation,HSV_value);
   rgb = hsv2rgb(HSV_combine);
   HSV_diagram(:,i,:)=rgb;
end
HSV_diagram=circshift(HSV_diagram,Shift_angle,2);%Shifting angle we need at 2nd dimenson
figure;image(flipud(HSV_diagram));colormap(rgb)%Flip array up to down
%%
%generate a random 'spatial map'--256*256*2
X_pix=32;Y_pix=32;
ele_cor=91;azi_cor=181;
map_random=zeros(X_pix,Y_pix,2);map_random_disp=zeros(X_pix,Y_pix,3);
map_random(:,:,1)=randi([-90 90],X_pix,Y_pix);%elevation [-90 to 90]    [1 181]
map_random(:,:,2)=randi([-180 179],X_pix,Y_pix);%azimuth [-180 to 179]  [1 360]
% map_random(:,:,2)=randi([0 179],X_pix,Y_pix);%contra-lateral
% map_random(:,:,2)=randi([-180 -1],X_pix,Y_pix);%ipsi-lateral
for x=1:X_pix
   for y=1:Y_pix
       ele=map_random(x,y,1);azi=map_random(x,y,2);
       map_random_disp(x,y,:)=HSV_diagram(ele+ele_cor,azi+azi_cor,:);
   end
end
figure;image((map_random_disp));colormap(rgb);axis square
