function mImg = saImageChannels(tStack, iSection, varargin)
% Get image channels of selected section number
%
%   mImg = saImageChannels(tStack, iSection)
%   mImg = saImageChannels(tStack, iSection, 'lowres')
%
%

if ~isfield(tStack, 'nSectionNumber')
    tStack = saNumberSections(tStack);
end

iChannels = find([tStack.nSectionNumber] == iSection);
if isempty(iChannels)
    mImg = [];
    return
end

if isfield(tStack, 'csColorOrder')
    csColorOrder = tStack(iChannels(1)).csColorOrder;
    [~, vNewOrder] = ismember(csColorOrder, {tStack(iChannels).sStain});
    %{tStack(iChannels(vNewOrder)).sStain}
    iChannels = iChannels(vNewOrder(1:length(iChannels)));
end

mImg = [];
for i = 1:length(iChannels)
    if isempty(varargin)
        mImg(:,:,i) = tStack(iChannels(i)).mImg;
    else
        mImg(:,:,i) = tStack(iChannels(i)).mImgLoRes;        
    end
    mImg(:,:,i) = mImg(:,:,i) - min(min(mImg(:,:,i)));
    mImg(:,:,i) = mImg(:,:,i) ./ max(max(mImg(:,:,i)));
end

% Create 2nd and 3rd dimensions, if missing
if size(mImg, 3) < 2
    mImg(:,:,2) = zeros(size(mImg(:,:,1)));
end
if size(mImg, 3) < 3
    mImg(:,:,3) = zeros(size(mImg(:,:,1)));
end

return