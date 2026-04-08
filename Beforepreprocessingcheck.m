%% Before preprocessing  

%before preprocessing - check triggers for a given dyad by visualising them 

[xlsx_filename, xlsx_path] = uigetfile('*.xlsx', 'Select the XLSX data file');
[~, ~, data] = xlsread(fullfile(xlsx_path, xlsx_filename));
value1 = data{2, 1}; 
value = (value1 - 5) / 0.04;
index = round(value);
[filename_nirs, pathname] = uigetfile('.snirf','Select the SNIRF data file');
filename=fullfile(pathname ,filename_nirs);
[~, snirf_name, ~] = fileparts(filename_nirs);
snirf_data = SnirfLoad(filename);
identifier = snirf_name;
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
        
elseif identifier == 'P06'
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

elseif strcmp(identifier, 'P02') || strcmp(identifier, 'P04')
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

elseif identifier == 'P08'
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
end 

sources_data = table(snirf_data.probe.sourceLabels(1:10), ...
                     snirf_data.probe.sourcePos3D(1:10, 1), ...
                     snirf_data.probe.sourcePos3D(1:10, 2), ...
                     snirf_data.probe.sourcePos3D(1:10, 3), ...
                     'VariableNames', {'Label', 'X', 'Y', 'Z'});
detectors_data = table(snirf_data.probe.detectorLabels(1:8), ...
                       snirf_data.probe.detectorPos3D(1:8, 1), ...
                       snirf_data.probe.detectorPos3D(1:8, 2), ...
                       snirf_data.probe.detectorPos3D(1:8, 3), ...
                       'VariableNames', {'Label', 'X', 'Y', 'Z'});

%extract source and detector positions from ch_config.txt file 

file_path = 'C:\Users\emre.yavuz\Desktop\ch_config.txt';
data_table = readtable(file_path, 'Delimiter', ',');
data_table.Properties.VariableNames = {'Ch', 'Source', 'Detector'};
sorted_data = sortrows(data_table, 1);
sorted_data.Source = cellfun(@(x) sprintf('S%d', x), num2cell(sorted_data.Source), 'UniformOutput', false);
sorted_data.Detector = cellfun(@(x) sprintf('D%d', x), num2cell(sorted_data.Detector), 'UniformOutput', false);
unique_sources_list = {};
unique_detectors_list = {};
for i = 1:numel(sorted_data.Source)
    current_source = sorted_data.Source{i};
    if ~any(strcmp(unique_sources_list, current_source))
        unique_sources_list = [unique_sources_list, current_source];
    end
end
for i = 1:numel(sorted_data.Detector)
    current_detector = sorted_data.Detector{i};
    if ~any(strcmp(unique_detectors_list, current_detector))
        unique_detectors_list = [unique_detectors_list, current_detector];
    end
end
sources_data.Label = categorical(sources_data.Label, unique_sources_list, 'Ordinal', true);
ordered_sources_data = sortrows(sources_data, 'Label');
detectors_data.Label = categorical(detectors_data.Label, unique_detectors_list, 'Ordinal', true);
ordered_detectors_data = sortrows(detectors_data, 'Label');
new_labels_sources = strcat('S', num2str((1:10)','%d'));
sourceLabelsCellArray = cell(size(new_labels_sources, 1), 1);
for i = 1:size(new_labels_sources, 1)
    sourceLabelsCellArray{i} = strrep(new_labels_sources(i, :), ' ', '');
end
new_labels_sources = sourceLabelsCellArray;
ordered_sources_data.Label = new_labels_sources;
new_labels_detectors = strcat('D', num2str((1:8)','%d'));
detectorLabelsCellArray = cell(size(new_labels_detectors, 1), 1);
for i = 1:size(new_labels_detectors, 1)
    detectorLabelsCellArray{i} = strrep(new_labels_detectors(i, :), ' ', '');
end
new_labels_detectors = detectorLabelsCellArray;
ordered_detectors_data.Label = new_labels_detectors;
snirf_data.probe.sourcePos3D = ordered_sources_data{1:10, 2:4};
snirf_data.probe.detectorPos3D = ordered_detectors_data{1:8, 2:4};
snirf_data.probe.sourceLabels = ordered_sources_data{1:10,1};
snirf_data.probe.detectorLabels = ordered_detectors_data{1:8,1};

%visualise the source and detector positions

detectorPos3D = snirf_data.probe.detectorPos3D;
sourcePos3D = snirf_data.probe.sourcePos3D;
detectorLabels = snirf_data.probe.detectorLabels;
sourceLabels = snirf_data.probe.sourceLabels;

figure;
scatter3(detectorPos3D(:, 1), detectorPos3D(:, 2), detectorPos3D(:, 3), 'bo');
hold on;
scatter3(sourcePos3D(:, 1), sourcePos3D(:, 2), sourcePos3D(:, 3), 'ro');
for i = 1:length(detectorLabels)
    text(detectorPos3D(i, 1), detectorPos3D(i, 2), detectorPos3D(i, 3), detectorLabels(i));
end
for i = 1:length(sourceLabels)
    text(sourcePos3D(i, 1), sourcePos3D(i, 2), sourcePos3D(i, 3), sourceLabels(i));
end
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('3D Positions of Source and Detector Channels');
grid on;
legend('Detector', 'Source');
hold off;
desktopPath = 'C:\Users\emre.yavuz\Desktop\';
plotName = 'SDcheck';
saveas(gcf, fullfile(desktopPath, [plotName, '.png']));

% plot the trigger times to visualise when fNIRS and minecraft timestamps match up 

numDatasets = numel(snirf_data.stim);
tablesCell = cell(numDatasets, 1);
for i = 1:numDatasets
    namesCell = repmat({snirf_data.stim(i).name}, size(snirf_data.stim(i).data, 1), 1);
    onsetDataCell = snirf_data.stim(i).data(:, strcmp(snirf_data.stim(i).dataLabels, 'Onset'));
    currentTable = table(namesCell, onsetDataCell, 'VariableNames', {'Name', 'OnsetData'});
    tablesCell{i} = currentTable; 
end
combinedTable = vertcat(tablesCell{:});
combinedTable.Name = strrep(combinedTable.Name, 'End', 'Trial.End');
combinedTable.Name = strrep(combinedTable.Name, 'Start', 'Trial.Start');
combinedTable.Name = strrep(combinedTable.Name, 'RecordE', 'Recording.End');
startRow = find(strcmp(combinedTable.Name, 'Trial.Start'), 1, 'first');
combinedTable.OnsetData = combinedTable.OnsetData - combinedTable.OnsetData(startRow);
desktopPath = 'C:\Users\emre.yavuz\Desktop\';
csvFilePath = fullfile(desktopPath, 'combinedTable.csv');
writetable(combinedTable, csvFilePath);
uniqueEventTypes = unique(combinedTable.Name);
maxOnsetData = max(combinedTable.OnsetData);
h = gobjects(numel(uniqueEventTypes), 1); 
for i = 1:numel(uniqueEventTypes)
    event_type = uniqueEventTypes{i};
    event_df = combinedTable(strcmp(combinedTable.Name, event_type), :);
    switch event_type
        case 'Trial.Start'
            color = 'green';
        case 'Trial.End'
            color = 'red';
        case 'Recording.End'
            color = 'magenta';
        otherwise
            color = 'black';
    end
    for j = 1:size(event_df, 1)
         h(i) = plot([event_df.OnsetData(j), event_df.OnsetData(j)], [0, 1], 'Color', color, 'LineStyle',  '-', 'DisplayName', event_type);
         hold on;
    end
end
hold off; 
xlim([0,maxOnsetData]);
yticks([]);
xlabel('Time (seconds)');
[~, directory, ~] = fileparts(filename);
directoryParts = strsplit(directory, filesep);
subjectID = directoryParts{1};
title(['Timeline of Events for File: ', subjectID]);
legend(h, uniqueEventTypes, 'Location', 'best');
desktopPath = 'C:\Users\emre.yavuz\Desktop\';
saveas(gcf, fullfile(desktopPath, 'Timeline_of_Events.png'));
figure;
