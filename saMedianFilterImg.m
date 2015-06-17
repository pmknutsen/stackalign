function tStack = saMedianFilterImg(tStack, nMedFiltSize)
% Compute median filtered all images
%
% Examples:
%   tStack = saMedianFilterImg(tStack, 201);
%
% Filtering is generally faster when nMedFiltSize is an odd number.
%
% For faster computing, convert all images to UINT16 with
% saConvertToUINT16() prior to running this function.
%

fprintf('saMedianFilterImg: Computing median filtered images...\n');

for i = 1:numel(tStack)
    fprintf ('Filtering image %d / %d \r', i, numel(tStack))
    mImg = tStack(i).mImg;
    mImgMedFilt = medfilt2(mImg, [nMedFiltSize nMedFiltSize], 'symmetric');
    tStack(i).mImgMedFilt = mImgMedFilt;
    tStack(i).nMedFiltSize = nMedFiltSize;
end

fprintf('\nsaMedianFilterImg: Median filtered %d images.\n', i)

return