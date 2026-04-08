%% script notes

% this script is written to organise everything into relevant folders
% make the inputsnirffiles that is read in contains the original data (downloaded from outlook drive) if
% you want it read-in fresh 

%1. Creating new folders within each folder

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
folders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
folderNames = {'Behaviour', 'Digitizer', 'Logs', 'Processed Data', 'rawdata', 'Results','inputdata'};
for i = 1:length(folders)
    currentFolder = fullfile(parentDirectory, folders(i).name);
     for j = 1:length(folderNames)
        newFolderName = folderNames{j};
        if ~exist(fullfile(currentFolder, newFolderName), 'dir')
            mkdir(currentFolder, newFolderName);
            disp(['Created new folder "', newFolderName, '" in ', currentFolder]);
        else
            disp(['Folder "', newFolderName, '" already exists in ', currentFolder]);
        end
    end
end 

%2. Putting snirf files in their relevant folder

initialDirectory = 'C:\Users\emre.yavuz\Desktop\Data\inputsnirffiles';
inputsnirfFiles = dir(fullfile(initialDirectory, '*.snirf'));
for i = 1:length(inputsnirfFiles)
    oldFileName = inputsnirfFiles(i).name;
    [~, baseFileName, ext] = fileparts(oldFileName);
    oldfileNumber = str2double(baseFileName);
    if numel(baseFileName) > 3 && ~contains(baseFileName, 'NaN')
        if oldfileNumber >= 1021
            newnumber = oldfileNumber - 1010;
        else
            newnumber = oldfileNumber - 1008;
        end
        newfileNumber = sprintf('P%02d', newnumber);
        newParticipantFileName = [newfileNumber '.snirf'];
        oldFilePath = fullfile(initialDirectory, oldFileName);
        newFilePath = fullfile(initialDirectory, newParticipantFileName);
        movefile(oldFilePath, newFilePath);
        copyParticipantFileName = sprintf('P%02d.snirf', newnumber + 1);
        copyfile(newFilePath, fullfile(initialDirectory,copyParticipantFileName));
        disp(['Renamed ' oldFileName ' to ' newParticipantFileName]);      
        parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data';
        folders = dir(fullfile(parentDirectory, 'P*'));
        pattern = '^P\d+$';
        folders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
        for j = 1:length(folders)
            participant = folders(j).name;
            snirfFileName = [participant '.snirf'];
            inputsnirfPath = fullfile(parentDirectory, 'inputsnirffiles', snirfFileName);
            inputdataPath = fullfile(parentDirectory, participant, 'inputdata', snirfFileName);
            if exist(inputsnirfPath, 'file') == 2
                copyfile(inputsnirfPath, inputdataPath);
                disp(['Copied ' snirfFileName ' to ' fullfile(parentDirectory, participant, 'inputdata')]);
            else
                disp(['Could not find ' snirfFileName ' in ' fullfile(parentDirectory, 'inputsnirffiles')]);
            end
        end
    end
end

%3. Removing duplicates of the digitisation folders

newDirectory = 'C:\Users\emre.yavuz\Desktop\Data\Digitization Data New';
if ~exist(newDirectory, 'dir')
    mkdir(newDirectory);
end
parentDirectory = newDirectory;
files = dir(fullfile(parentDirectory, '*.csv'));
latestRotatedFiles = struct();
latestRawFiles = struct();
for i = 1:length(files)
    fileName = files(i).name;
    [~, baseFileName, ~] = fileparts(fileName);
    splitName = split(baseFileName, '_');
    if numel(splitName) > 3
        originalID = ['re' splitName{1}];
        fileType = splitName{end};
        timestamp = splitName{2};
        timestamp = strrep(timestamp, '-', ''); % Remove hyphens
        timestamp = str2double(timestamp);
        if strcmp(fileType, 'rotatedProbes') || strcmp(fileType, 'rawProbes')
            if strcmp(fileType, 'rotatedProbes')
                if ~isfield(latestRotatedFiles, originalID) || timestamp > latestRotatedFiles.(originalID)
                    latestRotatedFiles.(originalID) = timestamp;
                end
            elseif strcmp(fileType, 'rawProbes')
                if ~isfield(latestRawFiles, originalID) || timestamp > latestRawFiles.(originalID)
                    latestRawFiles.(originalID) = timestamp;
                end
            end
        end
    end
end

for i = 1:length(files)
    fileName = files(i).name;
    [~, baseFileName, ~] = fileparts(fileName);
    splitName = split(baseFileName, '_');
    if numel(splitName) > 3
        originalID = ['re' splitName{1}];
        fileType = splitName{end};
        timestamp = splitName{2};
        timestamp = strrep(timestamp, '-', ''); % Remove hyphens
        timestamp = str2double(timestamp);
        if (strcmp(fileType, 'rotatedProbes') && timestamp ~= latestRotatedFiles.(originalID)) || ...
                (strcmp(fileType, 'rawProbes') && timestamp ~= latestRawFiles.(originalID)) || ...
                (strcmp(fileType, 'rotatedRef') && timestamp ~= latestRotatedFiles.(originalID)) || ...
                (strcmp(fileType, 'rawRef') && timestamp ~= latestRawFiles.(originalID))
            delete(fullfile(parentDirectory, fileName));
        end
    end
end 

%4. Renaming digitisation files based on participant number and then saving these in the initial folder

newDirectory = 'C:\Users\emre.yavuz\Desktop\Data\Digitization Data New';
if ~exist(newDirectory, 'dir')
    mkdir(newDirectory);
end
parentDirectory = newDirectory; 
files = dir(fullfile(parentDirectory, '*.csv'));
for i = 1:length(files)
    oldFileName = files(i).name;
    [~, baseFileName, ext] = fileparts(oldFileName);
    splitName = split(baseFileName, '_');
    if numel(splitName) > 1
        originalNumber = splitName{1};
        newNumber = str2double(originalNumber);
        if newNumber >= 1021
            newFormattedNumber = sprintf('P%02d_', newNumber - 1010);
        else
            newFormattedNumber = sprintf('P%02d_', newNumber - 1008);
        end
        newBaseFileName = [newFormattedNumber, baseFileName];
        newFileName = [newBaseFileName, ext];
        oldFilePath = fullfile(parentDirectory, oldFileName);
        newFilePath = fullfile(parentDirectory, newFileName);
        movefile(oldFilePath, newFilePath);
        disp(['Renamed: ', oldFileName, ' to ', newFileName]);
        delete(oldFilePath);
        disp(['Deleted original file: ', oldFileName]);
    end
end

%5. Rename digitisation files for matlab GLM reading

secondDirectory = 'C:\Users\emre.yavuz\Desktop\Data\Digitization FINAL';
if ~exist(secondDirectory, 'dir')
    mkdir(secondDirectory);
end 
parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\Digitization Data New';
files = dir(fullfile(parentDirectory, '*.csv'));
for i = 1:length(files)
    oldFileName = files(i).name;
    oldFilePath = fullfile(parentDirectory, oldFileName);
    if contains(oldFileName, 'rotated')
        newFilePath = fullfile(secondDirectory, oldFileName);
        copyfile(oldFilePath, newFilePath);
        disp(['Copied: ', oldFileName, ' to ', newFilePath]);
    end
    if contains(oldFileName, 'rotatedProbes')
        new = strtok(oldFileName, '_');
        newFileName = [new, '_Position.csv'];
        data = readtable(oldFilePath);
        criteria = {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7', 'S8', 'S9', 'S10', ...
            'D1', 'D2', 'D3', 'D4', 'D5', 'D6', 'D7', 'D8', ...
            'CH01', 'CH02', 'CH03', 'CH04', 'CH05', 'CH06', 'CH07', 'CH08', 'CH09', 'CH10', ...
            'CH11', 'CH12', 'CH13', 'CH14', 'CH15', 'CH16', 'CH17', 'CH18', 'CH19', 'CH20', ...
            'CH21', 'CH22', 'CH23', 'CH24', 'CH25'};
        matchingRows = ismember(data{:, 1}, criteria);
        data = data(matchingRows, :);
        writetable(data, oldFilePath);
    elseif contains(oldFileName, 'rotatedRef')
        new = strtok(oldFileName, '_');
        newFileName = [new, '_Reference.csv'];
    end
    newFilePath = fullfile(secondDirectory, newFileName);
    movefile(oldFilePath, newFilePath);
    disp(['Renamed: ', oldFileName, ' to ', newFileName]);
    if contains(oldFileName, 'raw')
        delete(oldFilePath);
        disp(['Deleted: ', oldFileName]);
    end
end

probeFiles = dir(fullfile(secondDirectory, '*_rotated*.csv'));
for i = 1:length(probeFiles)
    oldProbeFilePath = fullfile(secondDirectory, probeFiles(i).name);
    newProbeFileName = probeFiles(i).name(5:end); 
    newProbeFilePath = fullfile(parentDirectory, newProbeFileName);
    movefile(oldProbeFilePath, newProbeFilePath);
    disp(['Moved: ', probeFiles(i).name, ' back to ', parentDirectory]);
end

%6. Place these digitisation files in the correct folder for the run_GLM script

datapath = 'C:\Users\emre.yavuz\Desktop\Data';
parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\Digitization FINAL';
files = dir(fullfile(parentDirectory, '*.csv'));
for i = 1:length(files)
    participantID = files(i).name;
    splitID = split(participantID, '_');
    participantID = splitID{1};
    display(participantID);
    currentFile = files(i).name;
    copyfile(fullfile(parentDirectory, currentFile), fullfile(datapath,participantID,'Digitizer'));
    disp(['Moved file: ', currentFile, ' to ', fullfile(datapath, participantID, 'Digitizer', currentFile)]);
    fileToCopy = 'Ch_config.txt';
    copyfile(fullfile(datapath, fileToCopy), fullfile(datapath,participantID,'Digitizer'));
end

% 7. Fill empty digitiser folders with average across participants

% reference 

sourceDirectory = 'C:\Users\emre.yavuz\Desktop\Data'; 
targetDirectory = fullfile(sourceDirectory, 'Reference digitizer');
if ~exist(targetDirectory, 'dir')
    mkdir(targetDirectory);
end
participantFolders = dir(fullfile(sourceDirectory, 'P*\'));
for folderIdx = 1:numel(participantFolders)
    participantFolder = participantFolders(folderIdx).name;
    participantFolderPath = participantFolders(folderIdx).folder;
    parts = strsplit(participantFolderPath, filesep);
    participantNumber = parts{end};
    if strcmp(participantFolder, 'Digitizer')
       participantFiles = dir(fullfile(sourceDirectory,participantNumber,participantFolder,'*_Reference.csv'));
       for fileIdx = 1:numel(participantFiles)
        sourceFile = fullfile(sourceDirectory, participantNumber,participantFolder, participantFiles(fileIdx).name);
        destinationFile = fullfile(targetDirectory, participantFiles(fileIdx).name);
        copyfile(sourceFile, destinationFile);
       end
    end
end

participantFiles = dir(fullfile(targetDirectory, '*.csv'));
allData = cell(numel(participantFiles), 1);

for idx = 1:numel(participantFiles)
    filename = fullfile(targetDirectory, participantFiles(idx).name);
    participantData = readtable(filename);
    allData{idx} = table2array(participantData(:, 2:4));
end

combinedData = cat(3, allData{:});
meanData = mean(combinedData, 3);

sampleDataFile = readtable('C:\Users\emre.yavuz\Desktop\Data\P01\Digitizer\P01_Reference.csv');
rowLabels = sampleDataFile(:,1);
columnLabels = sampleDataFile.Properties.VariableNames(1:end);
meanDataWithLabels = cell(size(meanData, 1) + 1, size(meanData, 2) + 1);
meanDataWithLabels(1, 1:end) = columnLabels;
meanDataWithLabels(2:end, 1) = table2cell(rowLabels);
meanData(isnan(meanData)) = 0;
meanDataWithLabels(2:end, 2:end) = num2cell(meanData);
meanDataWithLabels(2:end, 2:end) = cellfun(@num2str, num2cell(meanData), 'UniformOutput', false);
meanDataTable = cell2table(meanDataWithLabels(2:end, :), 'VariableNames', meanDataWithLabels(1, :));
csvFileName = fullfile(sourceDirectory, 'Reference.csv');
writetable(meanDataTable, csvFileName);

% origin 

sourceDirectory = 'C:\Users\emre.yavuz\Desktop\Data'; 
targetDirectory = fullfile(sourceDirectory, 'Position digitizer');
if ~exist(targetDirectory, 'dir')
    mkdir(targetDirectory);
end
participantFolders = dir(fullfile(sourceDirectory, 'P*\'));
for folderIdx = 1:numel(participantFolders)
    participantFolder = participantFolders(folderIdx).name;
    participantFolderPath = participantFolders(folderIdx).folder;
    parts = strsplit(participantFolderPath, filesep);
    participantNumber = parts{end};
    if strcmp(participantFolder, 'Digitizer')
       participantFiles = dir(fullfile(sourceDirectory,participantNumber,participantFolder,'*_Position.csv'));
       for fileIdx = 1:numel(participantFiles)
        sourceFile = fullfile(sourceDirectory, participantNumber,participantFolder, participantFiles(fileIdx).name);
        destinationFile = fullfile(targetDirectory, participantFiles(fileIdx).name);
        copyfile(sourceFile, destinationFile);
    end
    end
end 

participantFiles = dir(fullfile(targetDirectory, '*.csv'));
allData = cell(numel(participantFiles), 1);

for idx = 1:numel(participantFiles)
    filename = fullfile(targetDirectory, participantFiles(idx).name);
    participantData = readtable(filename);
    allData{idx} = table2array(participantData(:, 2:4));
end

combinedData = cat(3, allData{:});
meanData = mean(combinedData, 3);

sampleDataFile = readtable('C:\Users\emre.yavuz\Desktop\Data\P01\Digitizer\P01_Position.csv');
rowLabels = sampleDataFile(:,1);
columnLabels = sampleDataFile.Properties.VariableNames(1:end);
meanDataWithLabels = cell(size(meanData, 1) + 1, size(meanData, 2) + 1);
meanDataWithLabels(1, 1:end) = columnLabels;
meanDataWithLabels(2:end, 1) = table2cell(rowLabels);
meanData(isnan(meanData)) = 0;
meanDataWithLabels(2:end, 2:end) = num2cell(meanData);
meanDataWithLabels(2:end, 2:end) = cellfun(@num2str, num2cell(meanData), 'UniformOutput', false);
meanDataTable = cell2table(meanDataWithLabels(2:end, :), 'VariableNames', meanDataWithLabels(1, :));
csvFileName = fullfile(sourceDirectory, 'Position.csv');
writetable(meanDataTable, csvFileName);

%8. Fill empty folders with averaged origin and reference files

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
participantFolders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
for folderIdx = 1:numel(participantFolders)
    participantFolder = participantFolders(folderIdx).name;
    participantNumber = participantFolder;
    digitizerFolderPath = fullfile(parentDirectory, participantNumber, 'Digitizer');
    if exist(digitizerFolderPath, 'dir')
        filesInDigitizer = dir(fullfile(digitizerFolderPath, '*.csv')); % Check for CSV files
        csvFilesPresent = ~isempty(filesInDigitizer);
        filesInDigitizerTxt = dir(fullfile(digitizerFolderPath, '*.txt')); % Check for TXT files
        txtFilesPresent = ~isempty(filesInDigitizerTxt);
        if ~csvFilesPresent && ~txtFilesPresent
            referenceFileNamePattern = 'Reference.csv';
            referenceFilePath = fullfile(parentDirectory, referenceFileNamePattern);
            if exist(referenceFilePath, 'file')
                copyfile(referenceFilePath, digitizerFolderPath);
                [~, fileName, fileExt] = fileparts(referenceFileNamePattern);
                newFileName = strcat(participantNumber, '_', fileName, fileExt);
                newFilePath = fullfile(digitizerFolderPath, newFileName);
                movefile(fullfile(digitizerFolderPath, [fileName, '.csv']), newFilePath);
            end
            positionFileNamePattern = 'Position.csv';
            positionFilePath = fullfile(parentDirectory, positionFileNamePattern);
            if exist(positionFilePath, 'file')
                copyfile(positionFilePath, digitizerFolderPath);
                [~, fileName, fileExt] = fileparts(positionFileNamePattern);
                newFileName = strcat(participantNumber, '_', fileName, fileExt);
                newFilePath = fullfile(digitizerFolderPath, newFileName);
                movefile(fullfile(digitizerFolderPath, [fileName, '.csv']), newFilePath);
            end
        end
    end
end

%9. Arrange digitisation data to be in right format for runGLM

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\';
desktopPath = 'C:\Users\emre.yavuz\Desktop\'; 
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
folders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
for i = 1:numel(folders)
    folderPath = fullfile(parentDirectory, folders(i).name, 'Digitizer');
    files = dir(fullfile(folderPath, '*Reference.csv'));
    for j = 1:numel(files)
        filePath = fullfile(folderPath, files(j).name);
        data = readtable(filePath);
        data.Properties.VariableNames = {'Reference', 'X', 'Y', 'Z'};
        if endsWith(filePath, 'Reference.csv')
         filePath = strrep(filePath, '_Reference.csv', '_MotCorr_orig.csv');
        end 
        writetable(data, filePath);
    end
    files = dir(fullfile(folderPath, '*Position.csv'));
    for j = 1:numel(files)
        filePath = fullfile(folderPath, files(j).name);
        data = readtable(filePath);
        data.Properties.VariableNames = {'Optode', 'X', 'Y', 'Z'};
        if endsWith(filePath, 'Position.csv')
         filePath = strrep(filePath, '_Position.csv', '_MotCorr_coord.csv');
        end
        writetable(data, filePath);
    end
end

%10. Remove unnecessary files in the digitizer folder 

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\';
desktopPath = 'C:\Users\emre.yavuz\Desktop\Data\'; 
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
folders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
keywords = {'MotCorr_coord', 'MotCorr_orig', 'POS', 'Ch_config', 'ChConfig'};
for i = 1:numel(folders)
    folderPath = fullfile(parentDirectory, folders(i).name, 'Digitizer');
    files = dir(folderPath);
    for j = 1:numel(files)
        [~, fileName, fileExt] = fileparts(files(j).name);
        containsKeyword = any(contains(lower(fileName), lower(keywords)));
        containsPosition = contains(lower(fileName), lower('Position'));
        containsReference = contains(lower(fileName), lower('Reference'));
        containsdoublehyphen = contains(lower(fileName), lower('__'));
        if (~containsKeyword || containsPosition || containsReference || containsdoublehyphen) && ~files(j).isdir
            filePath = fullfile(folderPath, files(j).name);
            delete(filePath); 
            disp(['Deleted: ', filePath]); 
        end
    end
end

%11. Ensure each folder has config.txt file

datapath = 'C:\Users\emre.yavuz\Desktop\Data';
folders = dir(fullfile(datapath, 'P*'));
pattern = '^P\d+$';
files = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
for i = 1:length(files)
    participantID = files(i).name;
    splitID = split(participantID, '_');
    participantID = splitID{1};
    fileToCopy = 'Ch_config.txt';
    copyfile(fullfile(datapath, fileToCopy), fullfile(datapath,participantID,'Digitizer'));
end

% 12. Relabel the source and detector labels (rows) for each coordinate digitiser file 

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\';
desktopPath = 'C:\Users\emre.yavuz\Desktop\Data\'; 
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
folders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
for i = 1:numel(folders)
    if str2double(folders(i).name(2:end)) < 9
    labelMapping = {'D8', 'S5'; 'S9', 'D3'; 'D7', 'S2'; 'S8', 'D8'; 'D6', 'S9'; 'S7', 'D5'; ...
        'D5', 'D4'; 'S10', 'S4'; 'S6', 'S3'; 'S5', 'D1'; 'D4', 'S10'; 'S4', 'S8'; 'D3', 'D6'; ...
        'S1', 'S6'; 'S3', 'D2'; 'D2', 'S1'; 'S2', 'D7'; 'D1', 'S7'};
    else
    labelMapping = {'D3', 'S5'; 'S3', 'D3'; 'D2', 'S2'; 'S2', 'D8'; 'D1', 'S9'; 'S1', 'D5'; ...
        'S6', 'D4'; 'D6', 'S4'; 'S10', 'S3'; 'S5', 'D1'; 'D5', 'S10'; 'S4', 'D6'; 'D4', 'S6'; ...
        'S9', 'S8'; 'S8', 'D2'; 'D8', 'S1'; 'S7', 'D7'; 'D7', 'S7'};
    end
    participantID = folders(i).name;
    splitID = split(participantID, '_');
    participantID = splitID{1};
    folderPath = fullfile(parentDirectory, folders(i).name, 'Digitizer');
    files = dir(folderPath); 
    for j = 1:numel(files)
        [~, fileName, fileExt] = fileparts(files(j).name);
        containsPosition = contains(lower(fileName), lower('MotCorr_coord'));
        if (containsPosition) && ~files(j).isdir
            filePath = fullfile(folderPath, files(j).name);
            data = readtable(filePath);
            oldLabels = labelMapping(:, 1);
            newLabels = labelMapping(:, 2);
            modifiedRows = false(size(data.Optode)); % Track modified rows
            for k = 1:numel(oldLabels)
                indices = strcmp(data.Optode, oldLabels{k})  & ~modifiedRows; 
                data.Optode(indices) = {newLabels{k}};
                modifiedRows = modifiedRows | indices;
            end
            writetable(data, filePath);
        end
    end
end
          
% 13. Trigger times

sourceDirectoryBehaviour = 'C:\Users\emre.yavuz\Desktop\Data\';
participantFolders = dir(fullfile(sourceDirectoryBehaviour, '**', '*.xlsx'));
for folderIdx = 1:numel(participantFolders)
        participantFolder = participantFolders(folderIdx).name;
        participantName = participantFolder(1:3);
        participantFolderPath = fullfile(sourceDirectoryBehaviour,'ParticipantFiles');
        destinationDirectory = fullfile(sourceDirectoryBehaviour, participantName, 'Behaviour');
        files = dir(fullfile(participantFolderPath, '**', '*.xlsx'));
        for fileIdx = 1:numel(files)
            participantFolder = files(fileIdx).name;
            participantName = participantFolder(1:3);
            path = fullfile(sourceDirectoryBehaviour, 'ParticipantFiles');
            sourceFilePath = fullfile(path, files(fileIdx).name);
            destinationDirectory = fullfile(sourceDirectoryBehaviour, participantName, 'Behaviour');
            destinationFilePath = fullfile(destinationDirectory);
            copyfile(sourceFilePath, destinationFilePath);
        end
end

% 14. Trigger times shifted 

sourceDirectoryBehaviour = 'C:\Users\emre.yavuz\Desktop\Data\';
participantFolders = dir(fullfile(sourceDirectoryBehaviour, '**', '*.xlsx'));
for folderIdx = 1:numel(participantFolders)
        participantFolder = participantFolders(folderIdx).name;
        participantName = participantFolder(1:3);
        participantFolderPath = fullfile(sourceDirectoryBehaviour,'ParticipantFilesSHIFT');
        destinationDirectory = fullfile(sourceDirectoryBehaviour, participantName, 'Behaviour');
        files = dir(fullfile(participantFolderPath, '**', '*.xlsx'));
        for fileIdx = 1:numel(files)
            participantFolder = files(fileIdx).name;
            participantName = participantFolder(1:3);
            path = fullfile(sourceDirectoryBehaviour, 'ParticipantFilesSHIFT');
            sourceFilePath = fullfile(path, files(fileIdx).name);
            destinationDirectory = fullfile(sourceDirectoryBehaviour, participantName, 'Behaviour');
            destinationFilePath = fullfile(destinationDirectory);
            copyfile(sourceFilePath, destinationFilePath);
        end
end

% 15. Behavioural data

sourceDirectoryBehaviour = 'C:\Users\emre.yavuz\Desktop\Data\';
participantFolders = dir(fullfile(sourceDirectoryBehaviour, '**', '*.xlsx'));
for folderIdx = 1:numel(participantFolders)
        participantFolder = participantFolders(folderIdx).name;
        participantName = participantFolder(1:3);
        participantFolderPath = fullfile(sourceDirectoryBehaviour,'BehaviourMATLAB');
        destinationDirectory = fullfile(sourceDirectoryBehaviour, participantName, 'Behaviour');
        files = dir(fullfile(participantFolderPath, '**', '*.xlsx'));
        for fileIdx = 1:numel(files)
            participantFolder = files(fileIdx).name;
            participantName = participantFolder(1:3);
            path = fullfile(sourceDirectoryBehaviour, 'BehaviourMATLAB');
            sourceFilePath = fullfile(path, files(fileIdx).name);
            destinationDirectory = fullfile(sourceDirectoryBehaviour, participantName, 'Behaviour');
            destinationFilePath = fullfile(destinationDirectory);
            copyfile(sourceFilePath, destinationFilePath);
        end
end

% 16. Create script to create onsets script

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
participantFolders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
model = 'bothpredators';
for p = 1:numel(participantFolders)
    participant = participantFolders(p).name; 
    triggers_file_path = fullfile('C:\Users\emre.yavuz\Desktop\Data', participant, 'Behaviour', [participant '_triggers_shift.xlsx']);
    triggers_data = readcell(triggers_file_path);
    triggers_df = cell2table(triggers_data(2:end, :), 'VariableNames', triggers_data(1, :));
    Fonsets = triggers_df.('FNIRS time')(contains(triggers_df.Event, 'Follow'));
    Consets = triggers_df.('FNIRS time')(contains(triggers_df.Event, 'Chase'));
    Fdurations = triggers_df.('Event duration')(contains(triggers_df.Event, 'Follow'));
    Cdurations = triggers_df.('Event duration')(contains(triggers_df.Event, 'Chase'));
    FLag = triggers_df.('Lag Score')(contains(triggers_df.Event, 'Follow'));
    CLag = triggers_df.('Lag Score')(contains(triggers_df.Event, 'Chase'));
    logs_folder_path = fullfile('C:\Users\emre.yavuz\Desktop\Data', participant, 'Logs');
    onsets_folder_path = fullfile(logs_folder_path, 'Onsets');
    if ~exist(onsets_folder_path, 'dir')
        mkdir(onsets_folder_path);
    end
    names = cell(1, 2); 
    onsets = cell(1, 2); 
    durations = cell(1, 2);
    names{1, 1} = "Follow";
    names{1, 2} = "Chase";
    onsets{1, 1} = Fonsets;
    onsets{1, 2} = Consets;
    durations{1, 1} = Fdurations;
    durations{1, 2} = Cdurations;
    if strcmp(model, 'individualpredators')
        Params = struct('Pname', {}, 'h', {}, 'P', {});  % Empty struct
        Params(1).Pname = 'none';
        Params(1).h = 1;
        Params(1).P = []; 
        Params(2).Pname = 'none';
        Params(2).h = 1;
        Params(2).P = []; 
    else
        Params = struct('Pname', {}, 'h', {}, 'P', {}); 
        Params(1).Pname = 'parametric';
        Params(1).h = 1;
        Params(1).P = FLag; 
        Params(2).Pname = 'parametric';
        Params(2).h = 1;
        Params(2).P = CLag; 
    end 
    onsets_file_path = fullfile('C:\Users\emre.yavuz\Desktop\Data', participant, 'Logs', 'Onsets', [participant 'U_onsets.mat']);
    save(onsets_file_path, 'names', 'onsets', 'durations', 'Params');
end

% 17. Place regressors.mat file in each participants data folder

parentDirectory = 'C:\Users\emre.yavuz\Desktop\Data\';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
participantFolders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
parentDirectoryRegressors = 'C:\Users\emre.yavuz\Desktop\Data\RegressorsbothpredatorsFINALFORFNIRS\';
Regressorsfiles = dir(fullfile(parentDirectoryRegressors, '*FINALFRAME_*.xlsx')); 
for p = 1:numel(participantFolders)
    participant = participantFolders(p).name; 
    for i = 1:numel(Regressorsfiles)
        filename = Regressorsfiles(i).name;
        parts = split(filename, '.');
        ext = parts{end};
        if strcmpi(ext, 'xlsx')
          artIndex = strfind(filename, 'FINALFRAME_');
          endIndex = strfind(filename, '.xlsx');
          substring = filename(artIndex+length('FINALFRAME_'):endIndex-1);
          participantreg = substring;
          if strcmp(participantreg, participant)
            disp(filename);
            regressors_save = fullfile(parentDirectory, participant, [participant '_Regressors.mat']);
            FINALDATA = readtable(fullfile(parentDirectoryRegressors, filename)); 
            Regressors = FINALDATA(:, 6:end);
            all_column_names = Regressors.Properties.VariableNames;
            Regressor_names = cellstr(all_column_names);
            assignin('base', 'Regressors', Regressors);
            save(regressors_save, 'Regressors','Regressor_names');
          end
        end
    end
end

%18. Move participant folders from Data folder to DataGLM folder

input = 'C:\Users\emre.yavuz\Desktop\Data\';
output = 'C:\Users\emre.yavuz\Desktop\DataGLM\';
outputFolderList = dir(output);
for j = 1:length(outputFolderList)
    outputFolderName = outputFolderList(j).name;
    if startsWith(outputFolderName, 'P') && length(outputFolderName) >= 3 && ...
        all(isstrprop(outputFolderName(2:3), 'digit'))
        rmdir(fullfile(output, outputFolderName), 's');
    end
end
folderList = dir(input);
for i = 1:length(folderList)
    folderName = folderList(i).name;
    if startsWith(folderName, 'P') && length(folderName) >= 3 && ...
        all(isstrprop(folderName(2:3), 'digit'))
        folderNumber = str2double(folderName(2:3));
        copyfile(fullfile(input, folderName), fullfile(output, folderName));
    end
end

%19. Remove regressors.mat files if necessary

parentDirectory = 'C:\Users\emre.yavuz\Desktop\DataGLM\';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
participantFolders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
for p = 1:numel(participantFolders)
    participant = participantFolders(p).name;
    regressorsFile = fullfile(parentDirectory, participant, [participant '_Regressors.mat']);
    if exist(regressorsFile, 'file') == 2
        delete(regressorsFile);
        disp(['Deleted ', regressorsFile]);
    else
        disp(['Regressors file does not exist for participant ', participant]);
    end
end

%20. Average coordinates across participants 

dataDir = 'C:\Users\emre.yavuz\Desktop\DataGLM';
allFolders = dir(fullfile(dataDir, 'P*'));
pattern = '^P\d+$';
participantFolders = allFolders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), allFolders));
coordData = [];
origData = [];
for i = 1:numel(participantFolders)
    pName = participantFolders(i).name;
    if strcmp(pName, 'P11')
        continue
    end
    digitizerFolder = fullfile(dataDir, pName, 'Digitizer');
    if ~exist(digitizerFolder, 'dir')
        warning('No Digitizer folder for %s, skipping...', pName);
        continue
    end
    coordFile = fullfile(digitizerFolder, [pName '_MotCorr_coord.csv']);
    origFile = fullfile(digitizerFolder, [pName '_MotCorr_orig.csv']);
    if exist(coordFile, 'file') && exist(origFile, 'file')
        coordTbl = readtable(coordFile);
        origTbl = readtable(origFile);
        if isempty(coordData)
            coordLabels = coordTbl.Optode;
            origLabels = origTbl.Reference;  
            coordData = zeros(height(coordTbl), 3, 0); % X,Y,Z, empty 3rd dim
            origData = zeros(height(origTbl), 3, 0);
        end
        coordData(:,:,end+1) = table2array(coordTbl(:, 2:4));
        origData(:,:,end+1) = table2array(origTbl(:, 2:4));
    else
        warning('Missing coord or orig file for %s, skipping...', pName);
    end
end
meanCoord = mean(coordData, 3, 'omitnan');
meanOrig = mean(origData, 3, 'omitnan');
meanCoord(isnan(meanCoord)) = 0;
meanOrig(isnan(meanOrig)) = 0;
meanCoordTbl = table(coordLabels, meanCoord(:,1), meanCoord(:,2), meanCoord(:,3), ...
    'VariableNames', {'Optode', 'X', 'Y', 'Z'});
meanOrigTbl = table(origLabels, meanOrig(:,1), meanOrig(:,2), meanOrig(:,3), ...
    'VariableNames', {'Reference', 'X', 'Y', 'Z'});
writetable(meanCoordTbl, fullfile(dataDir, 'Average_MotCorr_coord.csv'));
writetable(meanOrigTbl, fullfile(dataDir, 'Average_MotCorr_orig.csv'));
