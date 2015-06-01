function iStainIndices = saGetIndicesByStain(tStack, sStain, varargin)
% Get indices by Stain name
%
% Examples:
%   Get region by stain only:
%       iNissl = saGetIndicesByStain(STAIN)
%
%   Get region by stain and region:
%       iNissl = saGetIndicesByStain(STAIN, REGION)
%

iStainIndices = find(strcmpi({tStack.sStain}, sStain));
if nargin == 3
    sRegion = varargin{1};
    iRegionIndices = find(strcmpi({tStack.sRegion}, sRegion));
    iStainIndices = intersect(iStainIndices, iRegionIndices);
end

return
