function tStack = saSortStack(tStack)
% Sort stack by slide number, then by section number

vSort = [ [tStack.nSlide]' [tStack.nSection]' ];
[~, iSort] = sortrows(vSort);
tStack = tStack(iSort);

fprintf('aiSortStack: Sorted %d images.\n', length(iSort))

return
