function [hAx, hScatter] = saShowScatterDensity(tStack, csName, varargin)
% Show density of 3D as a color coded blubble plot.
%
% Density is color coded in units of px/mm^2.
% Bubble size are normalized such that the largest bubble has diameter
% equal to 2% of the largest axis dimension.
%
% Usage:
%   [hFig, hPatches] = saShowScatterDensity(tStack, csName)
%   [hFig, hPatches] = saShowScatterDensity(tStack, csName, tParams)
%   
%   tParams is an optional structure with parameters:
%       tParams.hAx             Use existing axis (optional)
%       tParams.nVoxelRes       Voxel resolution (micrometers)
%       tParms.vBgCol           Figure background color
%       tParms.vAxCol           Axis line color
%       tParms.mROICols         Matrix of object colors
%       tParms.nDensityThresh   Density threshold (show higher; px/mm^2)
%       tParms.sColMap          Colormap (e.g. 'hot')
%
% TODO:
%   Different between channels, eg. tdTom vs mCit
%

% Get analysis parameters
hAx = [];
if nargin == 3, tUserParms = varargin{1};
else            tUserParms = struct([]); end

% Default parameters (any can be passed as fields of tUserParms
tParms.vBgCol = [.2 .2 .2];
tParms.vAxCol = [.6 .6 .6];
tParms.hAx = 9990;
tParms.nVoxelRes = 40;
tParms.sColMap = 'hot';
tParms.nMarkerSize = 0.5;
tParms.nDensityThresh = 200;
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

% Initialize figure and axis
if ishandle(hAx)
    axes(hAx)
    hFig = get(hAx, 'parent');
    hold on
else
    hFig = figure;
    hAx = axes();
    set(hFig, 'renderer', 'opengl', 'color', vBgCol)
end
set(hAx, 'color', vBgCol, 'xcolor', vAxCol, 'ycolor', vAxCol, 'zcolor', vAxCol)

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

    % Compute density
    vEdgeMin = min(mXYZa, [], 1);
    vEdgeMax = max(mXYZa, [], 1);
    vXEdge = vEdgeMin(1):nVoxelRes:vEdgeMax(1);
    vYEdge = vEdgeMin(2):nVoxelRes:vEdgeMax(2);
    vZEdge = vEdgeMin(3):nVoxelRes:vEdgeMax(3);
    [mCount, cEdges, ~, ~] = histcn(mXYZa, vXEdge, vYEdge, vZEdge);
    
    % Extract coordinates of pixels with density > 1
    iI = find(mCount(:) > 1);
    [iX iY iZ] = ind2sub(size(mCount), iI);
    
    vX = cEdges{1}(iX) + (nVoxelRes / 2);
    vY = cEdges{2}(iY) + (nVoxelRes / 2);
    vZ = cEdges{3}(iZ) + (nVoxelRes / 2);
    vCount = mCount(iI);
    vCount = round(vCount ./ (nVoxelRes / 1000)); % px/mm^3
    
    % Sizes of circles (normalized to 2% of max axis length)
    vBubbleSize = vCount ./ max(vCount);
    vBubbleSize = vBubbleSize .* (max(mXYZa(:)) * .02);
    
    % Display only densities > N px/mm^3
    iShow = vCount > nDensityThresh;
    
    % Scatterplot
    mCol = eval(sprintf('%s(max(vCount(iShow)));', sColMap));
    hScatter(iROI) = scatter3(vX(iShow), vY(iShow), vZ(iShow), vBubbleSize(iShow), mCol(vCount(iShow), :), ...
        'filled', 'parent', hAx);
end

% Set 3D viewing properties
view(3)
axis vis3d tight
daspect([1 1 1])
set(hAx, 'color', vBgCol, 'xcolor', vAxCol, 'ycolor', vAxCol, 'zcolor', vAxCol)
xlabel('um'); ylabel('um'); zlabel('um')

return