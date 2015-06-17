function tStack = saGetSectionDepth(tStack)
% Calculate the section depth, relative to some zero, of each slide.
%
% Function asks for section thickness, and computes the relative 'depth' of
% each section based on section numbering.
%
% 'Depth' refers to the distance, in microns, of each section from the
% initial section (i.e. section number 1; even when one such does not
% exist, e.g. when numbering starts from a higher number).
%

% Ask for section thickness
nThickness = input('What is the tissue thickness (in microns)? ');

% Get section numbers if not already known
if ~isfield(tStack, 'nSectionNumber')
    tStack = saNumberSections(tStack);
end

% Compute 'depth'
for i = 1:length(tStack)
    tStack(i).nSectionDepth = tStack(i).nSectionNumber * nThickness;
end

disp('saGetSectionDepth: Done computing relative section depths.')

return
