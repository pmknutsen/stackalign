function mROIo = saROITransform(mROI, vImSize, nRotate, vTranslate, varargin)
% Rotate/translate pixels coordinates
%
% Usage:
% Rotate and then transform:
%       mROI = saImgTransform(mROI, vImSize, nRotate, vTranslate)
%
% Transform first, then rotate (e.g. if undoing previous transform)
%       mROI = saImgTransform(mROI, vImSize, nRotate, vTranslate, 'reverse')
%
% mROI is an N-by-2 matrix with X and Y coordinates.
% vImSize is the size of the origin image.
%

nTheta = deg2rad(nRotate);

% Transform first
if ~isempty(varargin)
    mROI = mROI + repmat(vTranslate, size(mROI, 1), 1);
end

% Image origin
vO = vImSize([2 1]) / 2;

% Bring vectors to rotation origin
vX = mROI(:, 1)' - vO(1);
vY = mROI(:, 2)' - vO(2);

% Define rotation matrix
R = [cos(nTheta) sin(nTheta); -sin(nTheta) cos(nTheta)];

% Define outputs
mXYr = R * [vX; vY];

mROIo(:, 1) = mXYr(1, :)' + vO(1);
mROIo(:, 2) = mXYr(2, :)' + vO(2);

% Transform last
if isempty(varargin)
    mROIo = mROIo + repmat(vTranslate, size(mROIo, 1), 1);    
end

return