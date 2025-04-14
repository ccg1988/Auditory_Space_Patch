function dF = F_to_dF (F, base_range, base_type, dF_type, peak_range, sumF_range)

% 3rd dimension is always raw traces
% Created by CCG @ 2021-05-17
% Modified by CCG @

if length(size(F))==3
    F_base_all = F(:, :, base_range);
    F_base = mean(F_base_all, 3); % Not use squeeze
    dF = ( F - F_base ) ./ F_base; % From F to dF/F
    if strcmp(dF_type, 'peak')
        dF = squeeze(max(dF(:, :, peak_range), [], 3)); % chose the largest value
    elseif strcmp(dF_type, 'sum')
        dF = squeeze(sum(dF(:, :, sumF_range), 3));
    end
elseif length(size(F))==4
    F_base_all = F(:, :, base_range, :);
    if strcmp(base_type, 'indi')
        F_base = mean(F_base_all, 3); % 4D, Not use squeeze---stimulus specific mean
    elseif strcmp(base_type, 'toge')
        F_base = mean(F_base_all, 3:4); % X-Y 2D matrix---stimulus averaged mean
    end
    dF = ( F - F_base ) ./ F_base; % From F to dF/F
    if strcmp(dF_type, 'peak')
        dF = squeeze(max(dF(:, :, peak_range, :), [], 3)); % chose the largest value
    elseif strcmp(dF_type, 'sum')
        dF = squeeze(sum(dF(:, :, sumF_range, :), 3));
    end
elseif length(size(F))==5
    F_base_all = F(:, :, base_range, :, :);
    F_base = mean(F_base_all, 3); 
    dF = ( F - F_base ) ./ F_base; 
    if strcmp(dF_type, 'peak')
        dF = squeeze(max(dF(:, :, peak_range, :, :), [], 3)); 
    elseif strcmp(dF_type, 'sum')
        dF = squeeze(sum(dF(:, :, sumF_range, :, :), 3));
    end
elseif length(size(F))==6
    F_base_all = F(:, :, base_range, :, :, :);
    F_base = mean(F_base_all, 3); 
    dF = ( F - F_base ) ./ F_base; 
    if strcmp(dF_type, 'peak')
        dF = squeeze(max(dF(:, :, peak_range, :, :, :), [], 3)); 
    elseif strcmp(dF_type, 'sum')
        dF = squeeze(sum(dF(:, :, sumF_range, :, :, :), 3));
    end
 elseif length(size(F))==7
    F_base_all = F(:, :, base_range, :, :, :, :);
    F_base = mean(F_base_all, 3); 
    dF = ( F - F_base ) ./ F_base; 
    if strcmp(dF_type, 'peak')
        dF = squeeze(max(dF(:, :, peak_range, :, :, :, :), [], 3)); 
    elseif strcmp(dF_type, 'sum')
        dF = squeeze(sum(dF(:, :, sumF_range, :, :, :, :), 3));
    end   
end