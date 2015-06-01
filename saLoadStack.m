function tStack = saLoadStack()
% Load images from previously saved results file, if it exists.
% Otherwise, load images direcly from current directory.
%
% Image files must use the following naming convention:
%   Animal_Region_Slide_Section_Stain.tiff
%   Example:
%       CX34_BS_1_08_Nissl.tiff
%

sResultsFile = 'sa_image_stack.mat';

if exist(sResultsFile, 'file')
    load(sResultsFile)
    fprintf('saLoadStack: Loaded %s \n', [pwd filesep sResultsFile])
else
    % Get list of images
    tDir = dir('*.tiff');
    tStack = struct([]);
    for f = 1:length(tDir)
        sName = tDir(f).name;
        % Filename format
        % Mouse_Region_Slide_Section_Stain.tiff
        % Example:  CX34_BS_1_08_Nissl.tiff
        cValues = textscan(sName(1:end-5), '%s%s%f%f%s', 'delimiter', '_');
        tStack(end+1).sAnimal = cell2mat(cValues{1});
        tStack(end).sRegion = cell2mat(cValues{2});
        tStack(end).nSlide = cValues{3};
        tStack(end).nSection = cValues{4};
        tStack(end).sStain = cell2mat(cValues{5});
        
        % Load images
        tStack(end).mImg = imread(sName);
        
    end
    fprintf('saLoadStack: Done reading %d images.\n', f)
end

return
