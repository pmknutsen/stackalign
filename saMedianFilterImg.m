function tStack = saMedianFilterImg(tStack, nMedFiltSize)
% Compute median filtered all images
%
% Examples:
%   tStack = saMedianFilterImg(tStack, 201);
%
% Filtering is generally faster when nMedFiltSize is an odd number
%
%

hWait = waitbar(0, 'saMedianFilterImg: Computing median filtered images...');
for i = 1:numel(tStack)
    mImg = tStack(i).mImg;
    mImgMedFilt = double(medfilt2(uint16(mImg), [nMedFiltSize nMedFiltSize], 'symmetric'));
    tStack(i).mImgMedFilt = mImgMedFilt;
    tStack(i).nMedFiltSize = nMedFiltSize;
    waitbar(i/numel(tStack), hWait)
end

close(hWait)
fprintf('saMedianFilterImg: Median filtered %d images.\n', i)

return