function mImg = saImgTransform(mImg, nRotate, vTranslate, varargin)
% Rotate/translate image
%
% Usage:
% Rotate and then transform:
%       mImg = saImgTransform(mImg, nRotate, vTranslate)
%
% Transform first, then rotate (e.g. if undoing previous transform)
%       mImg = saImgTransform(mImg, nRotate, vTranslate, 'reverse')
%
%

if isempty(varargin)
    % Rotate
    mImg = imrotate(mImg, nRotate, 'nearest', 'crop');
end

% Translate
T = maketform('affine', [1 0 0; 0 1 0; vTranslate 1]);
mImg = imtransform(mImg, T, 'XData',[1 size(mImg, 2)], 'YData',[1 size(mImg, 1)]);

if ~isempty(varargin)
    % Rotate
    mImgO = imrotate(mImg, nRotate, 'nearest', 'crop');
end

return
