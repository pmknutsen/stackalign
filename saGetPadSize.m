function nPadSize = saGetPadSize(tStack)
% Get size of image pad
%
%

if isfield(tStack, 'tTransform')
    if ~isfield(tStack(1).tTransform, 'nCumRotate')
        tStack = saGetCumulativeTransform(tStack);
    end
    mCumTranslate = [];
    for i = 1:length(tStack)
        mCumTranslate = [mCumTranslate; tStack(i).tTransform(1).vCumTranslate];
    end
    nPadSize = max(mCumTranslate(:));
else
    nPadSize = round(max(size(mImg)) / 2);
end

return