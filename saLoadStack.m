function tStack = saLoadStack()
% Load images from previously saved results file, if it exists.
% Otherwise, load images direcly from current directory.
%
% Usage:
%   tStack = saLoadStack()
%
% Image files must use the following naming convention:
%   Animal_Region_Slide_Section_Stain.tiff
%
%   Example:
%       CX34_BS_1_08_Nissl.tiff
%
% The imaged tissue should be in the same orientation across all images,
% i.e. anatomical axes relative to image axes should be the same.
%
%

sResultsFile = 'sa_image_stack.mat';

if exist(sResultsFile, 'file')
    disp('saLoadStack: Loading stack from disk...')
    load(sResultsFile)
    fprintf('saLoadStack: Loaded %s \n', [pwd filesep sResultsFile])
else
    % Get list of images
    tDir = dir('*.tiff');
    tStack = struct([]);
    fprintf('saLoadStack: Loading %d images...\n', numel(tDir));
    for f = 1:length(tDir)
        sName = tDir(f).name;
        fprintf ('Loading image %d / %d \r', f, numel(tDir))
        % Filename format
        % Mouse_Region_Slide_Section_Stain.tiff
        % Example:  CX34_BS_1_08_Nissl.tiff
        try
            cValues = textscan(sName(1:end-5), '%s%s%f%f%s', 'delimiter', '_');
            tStack(end+1).sAnimal = cell2mat(cValues{1});
            tStack(end).sRegion = cell2mat(cValues{2});
            tStack(end).nSlide = cValues{3};
            tStack(end).nSection = cValues{4};
            tStack(end).sStain = cell2mat(cValues{5});
        catch
            error('Failed parsing filename in saLoadStack(). Check that all filenames have the correct format.')
        end
        
        % Load images
        tStack(end).mImg = imread(sName);
    end
    fprintf('\nsaLoadStack: Done reading %d images.\n', f)
end

return
