%% Run the spm fnirs analysis for all the participants included in the Data folder %%
% up until the computation of the design matrix %

clear all 
clc 
close all

%% !!!! INPUT VARIABLES !!!! TO !!!! CHANGE !!!!

datadir='C:\Users\emre.yavuz\Desktop\DataGLM'; %Folder with data in
AnalysisDir='C:\Users\emre.yavuz\Desktop\DataGLM'; % Analysis Script folder directory
procfold = 'Processed Data'; %folder with preprocessed snirf data
resfold = 'Results'; %where results from glm will be stored
AnalysisFolder='SPM_Analysis'; %spm results stored in resfold/Analysisfolder
allFolders = getfolders(datadir);
pairs = {};
ToExclude={['P07';'P08';'P14';'P15';'P19';'P22';'P26';'P31']};
for i = 1:length(allFolders)
    folderName = allFolders(i).name;
    if startsWith(folderName, 'P') && ~isnan(str2double(folderName(2:end))) % Check if it starts with 'P' and is followed by a number
        if ~any(strcmp(folderName, ToExclude))
            pairs = [pairs; fullfile(datadir, folderName)];
        end
    end
end

DownSam=1; % 1 to downsample the data, 0 to not downsample the data
NewFs=1; % New sampling frequency (Hz). If downsampling is not applied, NewFs=[];

% Digitizer files
DigitFolder='Digitizer'; % Digitizing Folder
addpath(AnalysisDir) % Add SPM scripts to the path

for n_pair = 1:length(pairs)
    number = regexp(pairs{n_pair}, 'P\d+', 'match');
    number = number{1};
    ptppath = [datadir filesep number];
    procpath = [ptppath filesep procfold];
    respath = [ptppath filesep resfold];
    digpath = [ptppath  filesep DigitFolder];

    snirfpattern = fullfile(procpath,'preprocessed.snirf');
    snirf_files = dir(snirfpattern);
    matpattern = fullfile(procpath,'preprocessed.mat');
    mat_file = dir(matpattern);

    onsfile =[ptppath filesep 'Logs' filesep 'Onsets' filesep sprintf('%sU_onsets',number)];
    SuffixCoord=sprintf('%s_MotCorr_coord.csv',number);
    SuffixOrig=sprintf('%s_MotCorr_orig.csv',number);
    ChConfig='ch_config.txt'; 
    
    ChExclusionFile=[datadir filesep 'Channels2Exclude.mat'];
    Channels2Excludeorig = load(ChExclusionFile);
    Channels2Exclude = Channels2Excludeorig.Excludechannels;

    % Digitizer filenames
    F{1,1}= [SuffixCoord];
    F{1,2}= [SuffixOrig];
    F{1,3}= ChConfig;

    % Create NIRS.mat file
    filename=snirfpattern;
    snirf_data = SnirfLoad(filename);
    matdata = load([procpath filesep mat_file(1).name]);

    Y.hbo=matdata.Data.HbO;
    Y.hbr=matdata.Data.HbR;
    Y.hbt=matdata.Data.HbT;
    Y.od=matdata.Data.OD;
    P.ns=size(Y.hbo,1); % Number of samples
    P.nch=size(Y.hbo,2); % Number of channels
    P.fs=25; % SAMPLING FREQUENCY ---- CHECK HERE!!!!!
    sprintf('fs= %f', 25)
    wavelengths = [753, 844];
    P.wav=wavelengths; % Wavelengths
    P.mask=ones(1,P.nch);
    P.fname.pos=[digpath filesep 'POS.mat']; % Directory where POS.mat will be saved
    P.fname.nirs=[respath filesep 'NIRS.mat'];
    F{2,1}=P.fname.nirs;
    save(P.fname.nirs,'Y','P');
    clear Data snirf_data t SD Y P
    %------------------------------------------------------------------------%

    % Additional regressors file
    if exist([ptppath filesep number '_Regressors.mat'],'file') % If we want to add Additional Regressors to the design matrix
        regrfile=[datadir filesep number filesep number '_Regressors.mat'];
    else regrfile=[]; % No Additional Regressors
    end

    %% Spatial Registration %%
    if ~isfile([digpath filesep 'POS.mat'])
        cd([datadir filesep number filesep DigitFolder])
        spm_fnirs_spatialpreproc_ui(F) % Run Spatial Registration
    end

    % Update directory inside the NIRS.mat file
    load(F{2,1})
    P.fname.pos=[digpath filesep 'POS.mat']; % Directory where POS.mat will be saved
    P.fname.nirs=[respath filesep  'NIRS.mat'];
    save(F{2,1},'Y','P');

    ppidx=find(strcmp(Channels2Exclude(:,1),number)==1);

    ctype='HBO'; %Cromophore type ctype='HBO' or ctype='HBR'

    % Run Analysis for HbO

    spmfnirsflow(F{2,1},onsfile,AnalysisFolder,ctype,regrfile,DownSam,NewFs,Channels2Exclude{ppidx,2},ptppath)

    cd([ptppath]) % PP's folder

    ctype='HBR'; %Cromophore type ctype='HBO' or ctype='HBR'

    % Run Analysis for HbR
    spmfnirsflow(F{2,1},onsfile,AnalysisFolder,ctype,regrfile,DownSam,NewFs,Channels2Exclude{ppidx,2},ptppath)
    disp('Analysis Completed')
    close all;
    
end


