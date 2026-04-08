%% Single-subject analysis. 

%% 1. Data preparation 

% A. Load in POS mat to get channel labels 

input = load('C:\Users\emre.yavuz\Desktop\DataGLM\P01\Digitizer\POS.mat');
labels = input.R.ch.label;
positions = input.R.ch.xyzH; 
labels_column = labels(:);

%% 2. Individual regressor analysis 

% Prepare dataframe for analysis in python 

parentDirectory = 'C:\Users\emre.yavuz\Desktop\DataGLM\';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
participantFolders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
Excludedindividual = {'P07', 'P08', 'P14', 'P15', 'P19', 'P22', 'P26', 'P31'};
participantFolders = participantFolders(~ismember({participantFolders.name}, Excludedindividual));
betavalues = [];
for p = 1:numel(participantFolders)
    participantname = participantFolders(p).name; 
    filePath = fullfile(parentDirectory, participantname, 'Results', 'SPM_Analysis', 'HbO', 'SPM.mat');
    data = load(filePath); 
    participant = data.SPM.beta; 
    names = data.SPM.xX.name; 
    index = names'; 
    dataPOS = load('C:\Users\emre.yavuz\Desktop\DataGLM\P01\Digitizer\POS.mat'); 
    labels = dataPOS.R.ch.label;
    positions = dataPOS.R.ch.xyzC; 
    labels_column = labels(:);
    labels_column = num2str(labels_column); 
    labels_column = cellstr(labels_column); 
    betavalues_with_participant = array2table(participant, 'VariableNames', labels_column');
    participantNumber = str2double(regexp(participantname, '\d+', 'match'));
    dyadNumber = ceil(participantNumber / 2);
    betavalues_with_participant.('Dyad') = repmat(dyadNumber, size(betavalues_with_participant, 1), 1);
    betavalues_with_participant.('Participant Number') = repmat(participantNumber, size(betavalues_with_participant, 1), 1);
    betavalues_with_participant.('Index') = index; 
    betavalues = [betavalues; betavalues_with_participant];
end 
BETAVALUESFRAME = 'C:\Users\emre.yavuz\Desktop\DataGLM\BETAVALUES.csv';
writetable(betavalues, BETAVALUESFRAME);

%% Extract data from first Hunt as an example

input = load('C:\Users\emre.yavuz\Desktop\DataGLM\P01\Digitizer\POS.mat');
labels = input.R.ch.label;
positions = input.R.ch.xyzH; 
labels_column = labels(:);
parentDirectory = 'C:\Users\emre.yavuz\Desktop\DataGLM\';
folders = dir(fullfile(parentDirectory, 'P*'));
pattern = '^P\d+$';
participantFolders = folders(arrayfun(@(x) ~isempty(regexp(x.name, pattern, 'once')), folders));
Excludedindividual = {'P07', 'P08', 'P14', 'P15', 'P19', 'P22', 'P26', 'P31'};
participantFolders = participantFolders(~ismember({participantFolders.name}, Excludedindividual));
betavalues = [];
targetParticipant = 'P01';
for p = 1:numel(participantFolders)
    participantname = participantFolders(p).name; 
    if strcmp(participantname, targetParticipant)
        filePath = fullfile(parentDirectory, participantname, 'Results', 'SPM_Analysis', 'HbO', 'SPM.mat');
        data = load(filePath); 
        participant = data.SPM.beta; % Beta values
        names = data.SPM.xX.name; % Names of regressors
        participantData = data.SPM.xX.X(136:176, 3); 
        time = (1:length(participantData))';
        resultsTable = table(time, participantData, 'VariableNames', {'Time', 'Values'});
        disp(resultsTable);
        outputFilePath = 'C:\Users\emre.yavuz\Desktop\DataGLM\P01_RESULTS.csv';
        writetable(resultsTable, outputFilePath);
    end
end
