function [hAx, hScatter] = saShowScatter(tStack, csName, varargin)
% Display 3D scatter plot
%
% Usage:
%   [hFig, hPatches] = saShowScatter(tStack, csName)
%   [hFig, hPatches] = saShowScatter(tStack, csName, tParams)
%   
%   tParams is an optional structure with parameters:
%       tParams.hAx             Use existing axis (optional)
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
tParms.hAx = 9990;
tParms.nVoxelRes = 40;
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

    mXYZa = round(mXYZa ./ nVoxelRes) .* nVoxelRes; % micrometers, rounded
    mXYZa = unique(mXYZa, 'rows'); % remove non-unique values
    
    % Scatterplot
    hScatter(iROI) = plot3(mXYZa(:, 1), mXYZa(:, 2), mXYZa(:, 3), '.', ...
        'color', vCol, ...
        'markersize', nMarkerSize, ...
        'parent', hAx);
end

% Set 3D viewing properties
view(3)
axis vis3d tight
daspect([1 1 1])
set(hAx, 'color', vBgCol, 'xcolor', vAxCol, 'ycolor', vAxCol, 'zcolor', vAxCol)
xlabel('um'); ylabel('um'); zlabel('um')

return