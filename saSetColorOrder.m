function tStack = saSetColorOrder(tStack, csChannelOrder)
% Set color order when displaying RGB images
%
% Usage:
%   tStack = saSetColorOrder(tStack, sChannelOrder)
%
% Example:
%   tStack = saSetColorOrder(tStack, {'Nissl' 'tdTom' 'mCit'})
%
% For instance, when calling saImageChannel() the order of color channels
% in the returned multi-channel image is generally arbitrary. This function
% associates the order vChannelOrder with each image in the stack.
%
% saImageChannel() uses this order (when available) when constructing the
% multi-channel image.
%

for i = 1:length(tStack)
    tStack(i).csColorOrder = csChannelOrder;
end

disp('saSetColorOrder: Done setting color/channel order.')

return
