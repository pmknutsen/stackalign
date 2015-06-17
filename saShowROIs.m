function [hAx, hPatches] = saShowROIs(tStack, csName, varargin)
% Display ROIs in a 3D plot
%
% Usage:
%   [hFig, hPatches] = saShowROIs(tStack, csName)
%   [hFig, hPatches] = saShowROIs(tStack, csName, tParams)
%   
%   csName is the name of the ROI to display.
%
%   tParams is an optional structure with parameters:
%       tParams.hAx             Use existing axis (optional)
%       tParams.nIsoThresh      Isosurface threshold
%       tParams.nVoxelRes       Voxel resolution
%       tParams.v3DSmooth       Box smoothing filter
%       tParms.bPlot            Plot contours (true/false)
%       tParms.vBgCol           Figure background color
%       tParms.vAxCol           Axis line color
%       tParms.nPadFact         Padding factor, percent
%       tParms.nFaceAlpha       Transparance (0 to 1)
%       tParms.mROICols         Matrix of object colors
%

% Get analysis parameters
hAx = [];
if nargin == 3, tUserParms = varargin{1};
else            tUserParms = struct([]); end

% Default parameters (any can be passed as fields of tUserParms
tParms.nIsoThresh = 0.4; % isosurface threshold
tParms.nVoxelRes = 40; % voxel resolution, um
tParms.v3DSmooth = [150 150 150]; % size of 3D box filter, um
tParms.bPlot = 0; % plot contours
tParms.vBgCol = [.2 .2 .2]; % figure background color
tParms.vAxCol = [.6 .6 .6]; % axis line color
tParms.nPadFact = 25; % padding factor, percent
tParms.nFaceAlpha = .4;
tParms.hAx = 9990;
tParms.mROICols = [1 0 0; 0 1 0; 0 0 1; 1 0 1; 1 1 0; 0 1 1; 1 1 1]; % volume colors

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
    sName = csName{iROI};
    sROIName = sprintf('v%sBoundary', sName);
    if ~isfield(tStack, sROIName)
        sROIName = sprintf('%s', sName);
    end
    
    if iROI > size(mROICols, 1)
        vCol = mROICols(1, :);
    else
        vCol = mROICols(iROI, :);
    end
    
    mXYZa = [];
    if isfield(tStack, sROIName)
        for i = 1:length(tStack)-1
            % Get ROIs in original image coordinates
            mXYZ = tStack(i).(sROIName);
            if isempty(mXYZ), continue; end
            
            % Transform ROI coordinates
            nRotate = tStack(i).tTransform.nCumRotate;
            vTranslate = tStack(i).tTransform.vCumTranslate;
            vImgSize = size(tStack(i).mImg);
            mXYZ = saROITransform(mXYZ, vImgSize, nRotate, vTranslate);
            
            % Convert mXY to micrometers
            if isfield(tStack, 'nPixelsMM')
                mXYZ = (mXYZ ./ tStack(i).nPixelsMM) .* 1000; % um
            end
            
            mXYZ(:, 3) = ones(size(mXYZ,1), 1) .* tStack(i).nSectionDepth; % Z
            mXYZa = [mXYZa; mXYZ];
            
            % Plot points
            if bPlot
                plot3(hAx, mXYZ(:,1), mXYZ(:,2), mXYZ(:,3), ':', 'linewidth', .5, 'color', vCol)
                hold on
            end
        end
    else
        warning(sprintf('ROI %s not found', sROIName))
    end
    
    % Round depth (Z)
    mXYZa(:,3) = round(mXYZa(:,3) ./ nVoxelRes) .* nVoxelRes;
    
    % Compute resize factor from voxel resolution
    nPixRes = (1 / tStack(i).nPixelsMM) * 1000; % pixel resolution, um
    nResizeFact = 1 / (nVoxelRes / nPixRes); % volume resize factor

    % Find [X Y] dimensions ROI
    mImgSize = round(([max(mXYZa(:,2)) max(mXYZa(:,1))]) .* (nPadFact / 100 + 1)); % pad by 25%
    mRefImg = ones(mImgSize);
    mRefImg = imresize(mRefImg, nResizeFact);
    
    % Construct volume
    mStack = [];
    vZu = unique(mXYZa(:, 3));
    i = 0;
    for z = vZu'
        i = i + 1;
        iZ = mXYZa(:, 3) == z;
        vXt = mXYZa(iZ, 1) .* nResizeFact;
        vYt = mXYZa(iZ, 2) .* nResizeFact;
        vZt = mXYZa(iZ, 3) .* nResizeFact;
        mBW = roipoly(mRefImg, round(vXt), round(vYt));
        mStack(:,:,i) = mBW;
    end

    % Pad volume below and above
    nPadHeight = ceil(size(mStack, 3) * (nPadFact / 100)); % extra empty sections
    mPad = zeros(size(mStack, 1), size(mStack, 2), nPadHeight);
    mStack = cat(3, mPad, mStack, mPad);
    
    % Extrapolate vZu in both directions to same length as thickness of mStack
    vZui = interp1((nPadHeight+1):(nPadHeight+length(vZu)), vZu, 1:size(mStack, 3), 'linear', 'extrap');
    
    % Smooth in 3D
    vSmoothPix = v3DSmooth * nResizeFact;
    vSmoothPix = 2 .* round((vSmoothPix + 1) / 2) - 1; % round to nearest odd
    mStack = smooth3(mStack, 'box', vSmoothPix);

    % Compute isosurface
    tIso = isosurface(mStack, nIsoThresh);
    
    % Substitute Z coordicate of vertices with real values (by interpolation)
    tIso.vertices(:, 3) = interp1(1:size(mStack, 3), vZui, tIso.vertices(:, 3));
    
    % Rescale isosurface to original size
    tIso(1).vertices(:,[1 2]) = tIso(1).vertices(:,[1 2]) .* (1 / nResizeFact);
    
    % Display
    hPatches(iROI) = patch(tIso);
    
    % Caps
    %tCaps = isocaps(mStack, nIsoThresh);
    %tCaps(1).vertices = tCaps(1).vertices .* (1 / nResizeFact);
    %hCaps = patch(tCaps);
    
    % Set object properties
    set(hPatches(iROI), 'FaceColor', vCol, 'EdgeColor', 'none', 'facealpha', nFaceAlpha)

    drawnow
end

xlabel('um')
ylabel('um')
zlabel('um')

% Set 3D viewing properties
view(3)
axis vis3d tight

% Set lighting from both directions (front and behind)
if isempty(findobj(hFig, 'type', 'light'))
    camlight(0, 0)
    camlight(-180, 0)
    lighting phong
end
daspect([1 1 1])


return