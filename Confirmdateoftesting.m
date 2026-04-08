newDirectory = 'C:\Users\emre.yavuz\Desktop\Data\Digitization Data New';
if ~exist(newDirectory, 'dir')
    mkdir(newDirectory);
end
parentDirectory = newDirectory;
files = dir(fullfile(parentDirectory, '*.csv'));
fileTable = table('Size', [length(files), 2], 'VariableTypes', {'string', 'string'}, 'VariableNames', {'NewNumber', 'Date'});
for i = 1:length(files)
    oldFileName = files(i).name;
    [~, baseFileName, ~] = fileparts(oldFileName);
    splitName = split(baseFileName, '_');
    if numel(splitName) > 1
        originalNumber = splitName{1};
        newNumber = str2double(originalNumber);
        if newNumber >= 1021
            newFormattedNumber = sprintf('P%02d_', newNumber - 1010);
        else
            newFormattedNumber = sprintf('P%02d_', newNumber - 1008);
        end
        dateStr = splitName{3};
        fileTable.NewNumber{i} = newFormattedNumber;
        fileTable.Date{i} = dateStr;
    end
end
[~, uniqueIdx] = unique(fileTable.NewNumber, 'stable');
fileTable = fileTable(uniqueIdx, :);
disp(fileTable);
SAVEDirectory = 'C:\Users\emre.yavuz\Desktop\DataGLM';
saveFileName = fullfile(SAVEDirectory, 'Dateoftestingtable.csv');
writetable(fileTable, saveFileName);