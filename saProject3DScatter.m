function saProject3DScatter(tStack, csName, varargin)
% Project 3D scatter onto all viewing planes w/histograms
%
% Usage:
%   [hFig, hPatches] = saProject3DScatter(tStack, csName)
%   [hFig, hPatches] = saProject3DScatter(tStack, csName, tParams)
%   
%   tParams is an optional structure with parameters:
%       tParams.nVoxelRes       Voxel resolution (micrometers)
%       tParms.vBgCol           Figure background color
%       tParms.vAxCol           Axis line color
%       tParms.mROICols         Matrix of object colors
%

% Get analysis parameters
hAx = [];
if nargin == 3, tUserParms = varargin{1};
else            tUserParms = struct([]); end

% Default parameters (any can be passed as fields of tUserParms
tParms.vBgCol = [.2 .2 .2];
tParms.vAxCol = [.6 .6 .6];
tParms.nVoxelRes = 10;
tParms.nMarkerSize = 0.5;
tParms.mROICols = [1 0 0; 0 1 0; 0 0 1; 1 0 1; 1 1 0; 0 1 1; 1 1 1]; % colors

% Replace defaults with user-set parameters
csParms = fieldnames(tUserParms);
for p = 1:length(csParms)
    tParms.(csParms{p}) = tUserParms.(csParms{p});
end

% Split parameters into variables
csParms = fieldnames(tParms);
for p = 1:length(csParms)
    eval(sprintf('%s = tParms.(csParms{p});', csParms{p}));
end

for iROI = 1:length(csName)
    sROIName = sprintf('%s', csName{iROI});
    
    % Scatter color
    if iROI > size(mROICols, 1) vCol = mROICols(1, :);
    else                        vCol = mROICols(iROI, :); end
    
    mXYZa = [];
    if isfield(tStack, sROIName)
        for i = 1:length(tStack)-1
            mXYZ = tStack(i).(sROIName);
            if isempty(mXYZ), continue; end
            mXYZ(:, 3) = ones(size(mXYZ,1), 1) .* tStack(i).nSectionDepth; % Z
            mXYZa = [mXYZa; mXYZ];
        end
    else
        warning(sprintf('ROI %s not found', sROIName))
    end

    mXYZa = round(mXYZa ./ nVoxelRes) .* nVoxelRes; % micrometers, rounded
    mXYZa = unique(mXYZa, 'rows'); % keep only unique values
    
    % Initialize new figure for this group
    hFig = figure;
    set(hFig, 'renderer', 'opengl', 'color', vBgCol)

    % Get typical separation between sections
    vD = diff([tStack.nSectionDepth]);
    nSectionSep = mode(vD(vD > 0));
    
    vRand1 = (rand(size(mXYZa, 1), 1) * nVoxelRes * 2) - nVoxelRes;
    vRand3 = (rand(size(mXYZa, 1), 1) * nSectionSep * 2) - nSectionSep;
    
    mXYZa = mXYZa + [repmat(vRand1, 1, 2) vRand3];
    
    % Scatter plot and histogram onto X plane
    hAx(1) = subplot(3, 1, 1);
    vEdges = min(mXYZa(:, 1)):nVoxelRes:max(mXYZa(:, 1));
    [hAxX, hScat, hHist] = plotyy(hAx(1), mXYZa(:, 1), mXYZa(:, 3), vEdges, histc(mXYZa(:, 1), vEdges));
    set(hScat, 'marker', '.', 'markersize', 0.5, 'color', vCol, ...
        'linestyle', 'none')
    set(hHist, 'linewidth', 2, 'color', 'k')
    set(hAxX(1), 'ycolor', vCol)
    set(hAxX(2), 'ycolor', 'k')
    set(hAxX, 'xtick', -5000:500:5000, 'xticklabel', -5:.5:5)
    set(hAxX(1), 'ytick', -5000:500:5000, 'yticklabel', -5:.5:5)
    xlabel('X (mm)')
    ylabel(hAxX(1), 'Z (mm)')
    axis(hAxX, 'tight')

    % Scatter plot and histogram onto Y plane
    hAx(2) = subplot(3, 1, 2);
    vEdges = min(mXYZa(:, 2)):nVoxelRes:max(mXYZa(:, 2));
    [hAxX, hScat, hHist] = plotyy(hAx(2), mXYZa(:, 2), mXYZa(:, 3), vEdges, histc(mXYZa(:, 2), vEdges));
    set(hScat, 'marker', '.', 'markersize', 0.5, 'color', vCol, ...
        'linestyle', 'none')
    set(hHist, 'linewidth', 2, 'color', 'k')
    set(hAxX(1), 'ycolor', vCol)
    set(hAxX(2), 'ycolor', 'k')
    set(hAxX, 'xtick', -5000:500:5000, 'xticklabel', -5:.5:5)
    set(hAxX(1), 'ytick', -5000:500:5000, 'yticklabel', -5:.5:5)
    xlabel('Y (mm)')
    ylabel(hAxX(1), 'Z (mm)')
    axis(hAxX, 'tight')
    
    % Scatter plot and histogram onto Z plane
    hAx(3) = subplot(3, 1, 3);
    vEdges = min(mXYZa(:, 3)):nVoxelRes:max(mXYZa(:, 3));
    [hAxX, hScat, hHist] = plotyy(hAx(3), mXYZa(:, 3), mXYZa(:, 1), vEdges, histc(mXYZa(:, 3), vEdges));
    set(hScat, 'marker', '.', 'markersize', 0.5, 'color', vCol, ...
        'linestyle', 'none')
    set(hHist, 'linewidth', 2, 'color', 'k')
    set(hAxX(1), 'ycolor', vCol)
    set(hAxX(2), 'ycolor', 'k')
    set(hAxX, 'xtick', -5000:500:5000, 'xticklabel', -5:.5:5)
    set(hAxX(1), 'ytick', -5000:500:5000, 'yticklabel', -5:.5:5)
    xlabel('Z (mm)')
    ylabel(hAxX(1), 'X (mm)')
    axis(hAxX, 'tight')

    set(hAx, 'color', vBgCol)
    
end

return