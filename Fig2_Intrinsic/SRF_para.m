function [tuning_area, tuning_vector, tuning_vector_magnitude, azimuth, elevation] = ...
    SRF_para (rates, spont_rate, thres, speakers)

% Simplified from "analyze_srf_beta"; Only output parameters of SRF, without plotting
% rates is 1*24 or 32, spont_rate is single value (e.g. 2.2 or 0), s
% peakers is 32*2 (Spherical: azimuth & elevation) for computing "distance"
% Do NOT call other functions nor load other values
% by CCG 2020-04-11
% modified by CCG 2020-12-06---include "tuning area"

rates=rates-spont_rate;% this is critical!
if size(rates,2) == 1
        rates = rates';
end
if length(rates)<size(speakers,1) 
    speakers(25:end,:)=[]; %remove extra 8 speakers
end

speaker_locations = speakers;
speaker_number=size(speaker_locations,1);
spatial_resolution = 5;
longitude_limit = 180-spatial_resolution/2;
latitude_limit = 90-spatial_resolution/2;
nlongitude_cells = 360/spatial_resolution;
nlatitude_cells = 180/spatial_resolution;

longitude = repmat(-1*longitude_limit:spatial_resolution:longitude_limit,nlatitude_cells,1);
latitude = repmat(-1*latitude_limit:spatial_resolution:latitude_limit,nlongitude_cells,1)';
latitude_up = latitude(:,1) + spatial_resolution/2;
latitude_down = latitude(:,1) - spatial_resolution/2;
longitude_left = longitude(:,1) + spatial_resolution/2;
longitude_right = longitude(:,1) - spatial_resolution/2;
interp_cell_areas = areaquad(latitude_down,longitude_right,latitude_up,longitude_left);
interp_cell_areas = repmat(interp_cell_areas,1,nlongitude_cells);
    
distances = zeros(speaker_number, nlatitude_cells, nlongitude_cells);
    for i = 1:speaker_number %faster to do it this way instead of element by element. Takes .01 - .3 seconds
        distances(i,:,:) = reshape(distance(speaker_locations(i,[2 1]), [latitude(:) longitude(:)]),nlatitude_cells,nlongitude_cells);
    end
      
rate_interpolation = zeros(nlatitude_cells,nlongitude_cells);
    for i = 1:nlatitude_cells
        for j = 1:nlongitude_cells
            [dist, index] = sort(distances(:,i,j));
            weights = (1./dist(1:2)).^2./(sum(1./dist(1:2).^2));
            rate_interpolation(i,j) = sum(weights'.*rates(index(1:2)));
        end
    end

threshold = max(rates)*thres; %Evan used 0.5 for SU recording
tuning_area = sum(interp_cell_areas(rate_interpolation > threshold));    
    
rate_interpolation_thres=rate_interpolation; %added 20201206
rate_interpolation_thres(rate_interpolation_thres< max(rates)*thres)=0; %0.999 equal to winner take all=best speaker
    
interp_vectors = zeros(nlatitude_cells*nlongitude_cells,3);
[interp_vectors(:,2), interp_vectors(:,1), interp_vectors(:,3)] = sph2cart(pi*longitude(:)/180,pi*latitude(:)/180, ...
        (rate_interpolation_thres(:)+spont_rate).*interp_cell_areas(:));
tuning_vector = 1.066 * sum(interp_vectors) / sum( (rate_interpolation_thres(:)+spont_rate).*interp_cell_areas(:) );
[~,~,tuning_vector_magnitude] = cart2sph(tuning_vector(2),tuning_vector(1),tuning_vector(3));
tuning_vector_magnitude = min(tuning_vector_magnitude,1);
[THETA,PHI,~] = cart2sph(tuning_vector(2),tuning_vector(1),tuning_vector(3));
azimuth=rad2deg(THETA);
elevation=rad2deg(PHI);