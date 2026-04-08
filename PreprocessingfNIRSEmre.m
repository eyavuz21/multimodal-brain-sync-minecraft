 %% This script runs the fNIRS data pre-processing, and works on the .nirs file
% The preprocessing follows this steps:
% (1) Visual check  of raw voltage data
% (2) Conversion of raw voltage data (Intensity) into changes in Optical Density (OD)
% (3) Motion artifact correction (Wavelet)
% (4) Band-pass filter
% (5) Conversion from preprocessed changes in OD into concentration changes in oxy and deoxy
% (6) Conversion of oxy and deoxy into the activation signal using the CBSI method
%  INPUT = .nirs file;
%  OUTPUT = .nirs file with preprocessed data (overwritten)

clear 
close all

%% Input variables (change based on your data) 

save_arg = 1; %set to 0 if you dont want to save figures
iqr=1.5;
DPF=[6 6]; 
fc=[0.01 0.4];
FilterOrder=3;
mc = 1; %set to 0 to skip
bp = 1; %set to 0 to skip
cbsi=1; %set to 0 to skip

%% Preprocessing 
% select the snirf files to preprocess

[filename_nirs, pathname] = uigetfile('.snirf','Select the SNIRF data file');
filename=fullfile(pathname ,filename_nirs);
[~, snirf_name, ~] = fileparts(filename_nirs);
identifier = snirf_name;
thirdCharacter = identifier(2:3);
numericValue = str2double(thirdCharacter);
numericValue = numericValue+1;
identifier2 = ['P' sprintf('%02d',numericValue)];
if ~isempty(identifier)
    folder_path1 = fullfile('C:\Users\emre.yavuz\Desktop\Data', identifier, 'Processed Data\');
    folder_path2 = fullfile('C:\Users\emre.yavuz\Desktop\Data', identifier2, 'Processed Data\');
    figpath1 = fullfile('C:\Users\emre.yavuz\Desktop\Data', identifier, 'rawdata\');
    figpath2 = fullfile('C:\Users\emre.yavuz\Desktop\Data', identifier2, 'rawdata\');
    savename1 = 'preprocessed';
    savename2 = 'preprocessed';
    savename_snirf1 = 'preprocessed';
    savename_snirf2 = 'preprocessed';
end

% select the relevant timestamp that corresponds to the given snirf file in order to trim the data 

[xlsx_filename, xlsx_path] = uigetfile('*.xlsx', 'Select the XLSX data file');
[~, ~, data] = xlsread(fullfile(xlsx_path, xlsx_filename));
value1 = data{2, 1}; 
value = (value1-5) / 0.04;
index = round(value);

%process participant 1 and 2 separately

for i = 1:2
    validIdentifiersA = {'P09','P13','P15'};
    validIdentifiersB = {'P26','P32','P34'};
    validIdentifiersC = {'P11','P19','P29','P31','P33'};
    validIdentifiersD = {'P10','P14','P16','P18'};
    validIdentifiersE = {'P17','P25'};
    validIdentifiersF = {'P12','P20','P30'};
    if i == 1
        folderpath = folder_path1;
        figpath = figpath1;
        snirf_data = SnirfLoad(filename);
        measurementMatrix = snirf_data.data.cache.measurementListMatrix; 
        csvFilePath = fullfile('C:\Users\emre.yavuz\Desktop\Data', [identifier '_measurement_data.csv']);
        writematrix(measurementMatrix, csvFilePath);

        if identifier == 'P05'
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [1:25, 75:99]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [1:25, 75:99]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([1:25, 75:99],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(1:10,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(1:10,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(1:8,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(1:8,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif strcmp(identifier, 'P01') || strcmp(identifier, 'P03')
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [1:25, 99:123]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [1:25, 99:123]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([1:25, 99:123],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(1:10,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(1:10,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(1:8,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(1:8,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif identifier == 'P07'
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [1:25, 51:75]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [1:25, 51:75]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([1:25, 51:75],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);      
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(1:10,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(1:10,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(1:8,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(1:8,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif ismember(identifier, validIdentifiersA)
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [1:25, 76:100]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [1:25, 76:100]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([1:25, 76:100],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);      
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(1:10,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(1:10,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(1:8,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(1:8,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif ismember(identifier, validIdentifiersC)
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [51:75, 126:150]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [51:75, 126:150]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([51:75, 126:150],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);      
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 20;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 16;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(21:30,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(21:30,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(17:24,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(17:24,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif ismember(identifier, validIdentifiersE)
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [26:50, 101:125]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [26:50, 101:125]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([26:50, 101:125],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);      
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 10;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 8;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(11:20,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(11:20,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(9:16,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(9:16,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        else
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [1:25, 76:100]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [1:25, 76:100]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([1:25, 76:100],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(1:10,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(1:10,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(1:8,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(1:8,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        end 
        savename = savename1;
        savename_snirf = savename_snirf1;

    elseif i == 2
        folderpath = folder_path2;
        figpath = figpath2; 
        snirf_data = SnirfLoad(filename);

        if identifier2 == 'P06'
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [26:50, 100:124]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [26:50, 100:124]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([26:50, 100:124],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 10;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 8;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(11:20,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(11:20,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(9:16,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(9:16,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif strcmp(identifier2, 'P02') || strcmp(identifier2, 'P04')
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [50:74, 148:172]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [50:74, 148:172]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([50:74, 148:172],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 20;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 16;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(11:20,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(11:20,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(9:16,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(9:16,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif identifier2 == 'P08'
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [26:50, 76:100]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [26:50, 76:100]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([26:50, 76:100],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);   
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 10;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 8;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(11:20,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(11:20,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(9:16,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(9:16,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif ismember(identifier2, validIdentifiersB)
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [1:25, 76:100]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [1:25, 76:100]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([1:25, 76:100],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);   
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(1:10,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(1:10,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(1:8,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(1:8,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif ismember(identifier2, validIdentifiersD)
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [51:75, 126:150]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [51:75, 126:150]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([51:75, 126:150],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);   
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 20;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 16;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(21:30,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(21:30,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(17:24,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(17:24,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        elseif ismember(identifier2, validIdentifiersF)
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [26:50, 101:125]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [26:50, 101:125]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([26:50, 101:125],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);   
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 10;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 8;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(11:20,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(11:20,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(9:16,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(9:16,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);

        else
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(:, [26:50, 101:125]);
          snirf_data.data.measurementList = snirf_data.data.measurementList(:, [26:50, 101:125]);
          snirf_data.data.cache.measurementListMatrix = snirf_data.data.cache.measurementListMatrix([26:50, 101:125],:);
          snirf_data.data.dataTimeSeries = snirf_data.data.dataTimeSeries(index:end, :);
          snirf_data.data.time = snirf_data.data.time(index:end, :);
          first_row_value = snirf_data.data.time(1, :);
          snirf_data.data.time = snirf_data.data.time - first_row_value;
          indices_to_keep = ~strcmp({snirf_data.stim.name}, 'RecordS');
          snirf_data.stim = snirf_data.stim(indices_to_keep);
          end_start_indices = strcmp({snirf_data.stim.name}, 'End') | strcmp({snirf_data.stim.name}, 'Start');
          for i = find(end_start_indices)
           data_to_trim = snirf_data.stim(i).data;
           states_to_trim = snirf_data.stim(i).states;
           rows_to_remove_data = data_to_trim(:, 1) < value1;
           snirf_data.stim(i).data(rows_to_remove_data, :) = [];
           rows_to_remove_states = states_to_trim(:, 1) < value1;
           snirf_data.stim(i).states(rows_to_remove_states, :) = [];
          end
          measurementList = snirf_data.data.measurementList;
          for j = 1:numel(measurementList)
            measurementList(j).sourceIndex = measurementList(j).sourceIndex - 10;
            measurementList(j).detectorIndex = measurementList(j).detectorIndex - 8;
          end
          snirf_data.data.measurementList = measurementList;
          snirf_data.probe.sourcePos2D = snirf_data.probe.sourcePos2D(11:20,:);
          snirf_data.probe.sourcePos3D = snirf_data.probe.sourcePos3D(11:20,:);
          snirf_data.probe.detectorPos2D = snirf_data.probe.detectorPos2D(9:16,:);
          snirf_data.probe.detectorPos3D = snirf_data.probe.detectorPos3D(9:16,:);
          snirf_data.probe.sourceLabels = snirf_data.probe.sourceLabels(1:10,:);
          snirf_data.probe.detectorLabels = snirf_data.probe.detectorLabels(1:8,:);
        end 
     
        savename = savename2;
        savename_snirf = savename_snirf2;
    end 

    snirf_data.metaDataTags.tags.fs = 1/snirf_data.data.time(2);
  
    disp('Calculating PSD and plotting PSD and Intensities.')
    snirf_data.metaDataTags.tags.nCh=size(snirf_data.data.dataTimeSeries,2)/length(snirf_data.probe.wavelengths); % Number of channels
    plotSubplotsPSD(snirf_data.data.dataTimeSeries,snirf_data.metaDataTags.tags.fs,figpath,save_arg)
    close all
    step = [];
    valuescheck = checker(snirf_data.data.dataTimeSeries, figpath, step, save_arg);
    plotSubplotsRaw_OD(snirf_data.data.dataTimeSeries,figpath,step,save_arg)
    close all
    
    disp('Converting Intensity to Optical Density')
    step = 'OD';
    Data.raw = snirf_data.data.dataTimeSeries;
    snirf_data.data = hmrR_Intensity2OD( snirf_data.data );
    plotSubplotsRaw_OD(snirf_data.data.dataTimeSeries,figpath,step,save_arg)
    close all
    
    if mc == 1
     disp('Motion artefact correction. May take some time.');
     step = 'mc';
     Data.OD = snirf_data.data.dataTimeSeries;
     snirf_data.data = hmrR_MotionCorrectWavelet(snirf_data.data, [], [], iqr, []);
     plotSubplotsRaw_OD(snirf_data.data.dataTimeSeries, figpath, step, save_arg);
     close all;
     savename_mc = identifier; % Choose an appropriate name
     full_filepath = fullfile(figpath, [savename_mc '.snirf']);
     SnirfSave(full_filepath, snirf_data);
     disp('Motion-corrected data saved.');
    end

    if bp ==1
     disp('Bandpass filtering')
     step = 'f';
     Data.OD_mc = snirf_data.data.dataTimeSeries;  
     snirf_data.data = hmrR_BandpassFilt_UH(snirf_data.data,FilterOrder,fc); 
     %plotSubplotsRaw_OD(snirf_data.data.dataTimeSeries,figpath,step,save_arg)
     close all
    end

    disp('Calculating concentration data.')
    Data.OD_f = snirf_data.data.dataTimeSeries; 
    snirf_data.data = hmrR_OD2Conc( snirf_data.data, snirf_data.probe, DPF );
    Data.HbO=squeeze(snirf_data.data.dataTimeSeries(:,1:3:end));
    Data.HbR=squeeze(snirf_data.data.dataTimeSeries(:,2:3:end));
    Data.HbT=squeeze(snirf_data.data.dataTimeSeries(:,3:3:end));
    plotSubplotsConc(snirf_data.data.dataTimeSeries,figpath,1)
    close all
     
    if cbsi==1
     disp('Computing CBSI')
     snirf_data.data = hmrR_MotionCorrectCbsi(snirf_data.data,[]);
     hold_n = zeros(size(snirf_data.data.dataTimeSeries,1),size(snirf_data.data.dataTimeSeries,2)*size(snirf_data.data.dataTimeSeries,3));
     hold_n(:,1:3:end) = snirf_data.data.dataTimeSeries(:,1,:);
     hold_n(:,2:3:end) = snirf_data.data.dataTimeSeries(:,2,:);
     hold_n(:,3:3:end) = snirf_data.data.dataTimeSeries(:,3,:);
     snirf_data.data.SetDataTimeSeries(hold_n);
     plotSubplotsCBSI(snirf_data.data.dataTimeSeries,figpath,0)
     Data.HbOCBSI=squeeze(snirf_data.data.dataTimeSeries(:,1:3:end));
     Data.HbRCBSI=squeeze(snirf_data.data.dataTimeSeries(:,2:3:end));
     Data.HbTCBSI=squeeze(snirf_data.data.dataTimeSeries(:,3:3:end));
    end
    
    %save everything 

    disp('Saving data');
    snirf_filename = [folderpath,savename_snirf];
    SnirfSave([snirf_filename '.snirf'], snirf_data);
    mat_filename = [folderpath,savename];
    save(mat_filename,'Data')
    disp('Backing up data');
    backup_folder_path = 'C:\Users\emre.yavuz\Desktop\Backupdata\';
    snirf_filename = [backup_folder_path, savename_snirf];
    SnirfSave([snirf_filename '.snirf'], snirf_data);
    mat_filename = [backup_folder_path,savename];
    save(mat_filename,'Data')
    % disp('Done!');

end 
