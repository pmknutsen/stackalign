function mImg = saImgTransform(mImg, nRotate, vTranslate)
% Rotate/translate image
%
% Example:
%   mImg = saImgTransform(mImg, nRotate, vTranslate)
%

% Rotate
mImg = imrotate(mImg, nRotate, 'nearest', 'crop');

% Translate
T = maketform('affine', [1 0 0; 0 1 0; vTranslate 1]);
mImg = imtransform(mImg, T, 'XData',[1 size(mImg, 2)], 'YData',[1 size(mImg, 1)]);

return
