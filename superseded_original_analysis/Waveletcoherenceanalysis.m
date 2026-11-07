%% wavelet coherence analysis. This script goes through each dyad and correlates their CBSI signals to determine the points within the experiment where brain synchrony is increased. 

%1. Determine which participants to include in the analysis.  

Excluded=['P07';'P08';'P14';'P15';'P19';'P22';'P26';'P31'];
Excluded = cellstr(Excluded);
participant_numbers = arrayfun(@(x) sprintf('%02d', x), 1:32, 'UniformOutput', false);
participant_numbers = strcat('P', participant_numbers).';
participant_numbers = cellstr(participant_numbers);
ismem = ismember(participant_numbers,Excluded); 
include = participant_numbers(~ismem); 
pairTable = table('Size',[0,2],'VariableTypes',{'string','string'},'VariableNames',{'Member1','Member2'});
for i = 1:2:numel(participant_numbers)
    if i+1 <= numel(participant_numbers)
        pairTable = [pairTable; {participant_numbers{i}, participant_numbers{i+1}}];
    end
end
pairTable.index = (1:height(pairTable)).';
rows_to_remove = [];
for i = 1:height(pairTable)
    if ~ismember(pairTable.Member1(i), include) || ~ismember(pairTable.Member2(i), include)
        rows_to_remove = [rows_to_remove, i];
    end
end
pairTableFiltered = pairTable;
pairTableFiltered(rows_to_remove, :) = [];
pairTable = pairTableFiltered; 

%2. Collate the NIRS data for each participant. 

parentDirectory = 'C:\Users\emre.yavuz\Desktop\DataGLM';
combinedtable = [];
raw_rows = {};
row_counter = 1;
for p = 1:size(pairTable, 1)
    participant1 = pairTable.Member1(p);
    participant2 = pairTable.Member2(p);
    filePath1 = fullfile(parentDirectory, participant1, 'Results', 'NIRS.mat');
    filePath2 = fullfile(parentDirectory, participant2, 'Results', 'NIRS.mat');

    for j = 1:25
        data1 = load(filePath1); 
        data1 = data1.Y.hbo;
        data2 = load(filePath2); 
        data2 = data2.Y.hbo;
        data1 = data1(:,j);
        data2 = data2(:,j);
        allOnsets = [];
        allDurations = [];
        allTrials = []; 

 %3. Determine the onsets and durations of each trial type. 

        filename = strcat(participant1,'U_onsets.mat');
        dyadtimespaths = fullfile('C:\Users\emre.yavuz\Desktop\DataGLM\',participant1,'Logs','Onsets',filename);
        dyadtimes = load(dyadtimespaths); 
        for i = 1:numel(dyadtimes.onsets)
            allOnsets = [allOnsets; dyadtimes.onsets{i}];
            allDurations = [allDurations; dyadtimes.durations{i}];
            numTrials = numel(dyadtimes.onsets{i});
            repeatedTrials = repelem(dyadtimes.names{i}, numTrials);
            allTrials = [allTrials; repeatedTrials'];
        end
        dataTable = table(allTrials, allOnsets, allDurations, 'VariableNames', {'Trialtype','Onsets', 'Durations'});
        dataTable.onsetsWC = dataTable.Onsets / 0.0625;
        dataTable.durationsWC = dataTable.Durations / 0.0625;
        save_path = 'C:\Users\emre.yavuz\Desktop\DataGLM\Waveletcoherence';
        save_name = sprintf('Dyad_%d_Channel_%dtimingsWC.csv', p, j);
        save_file = fullfile(save_path, save_name);
        writetable(dataTable, save_file);

 %4. Run the 'wcoherence' function in order to plot the coherence values for each channel and for each dyad, overlaying the hunt and follow trials on top of the coherence plot.  

        wcoherence(data1, data2);
        ax = gca;
        final_onset = dataTable.onsetsWC(end);
        final_duration = dataTable.durationsWC(end);
        max_x_limit = final_onset + final_duration;
        xlim([0, max_x_limit]);
        y_lim = ax.YLim;
        dy_lim = y_lim(2)-y_lim(1);
        for i = 1:height(dataTable)
            onset = dataTable.onsetsWC(i);
            duration = dataTable.durationsWC(i);
            trialType = dataTable.Trialtype(i);
            if strcmp(trialType, 'Chase')
                barColor = [1, 0, 0, 0.5]; 
                textToDisplay = 'H'; 
            elseif strcmp(trialType, 'Follow')
                barColor = [0, 1, 0, 0.5]; 
                textToDisplay = 'F'; 
            end
            rectangle(ax, 'Position', [onset, y_lim(1), duration, dy_lim], ...
        'FaceColor', barColor, 'EdgeColor', 'black');
            textX = onset + duration / 2;
            textY = y_lim(1) + dy_lim / 2;
            text(textX, textY, textToDisplay, 'Color', 'white', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        end
        figure_title = sprintf('Dyad-%d-Channel-%d', p, j);
        set(gcf, 'Name', figure_title);
        save_path = 'C:\Users\emre.yavuz\Desktop\DataGLM\Waveletcoherence';
        save_name = sprintf('Dyad_%d_Channel_%d.fig', p, j);
        saveas(gcf, fullfile(save_path, save_name));

 %5. Run the 'wcoherence' function and determine the level of coherence for
 %the low, medium and high frequency bands for each trial type, for each
 %dyad, for each channel. 

        onsetsWC = dataTable.onsetsWC;
        durationsWC = dataTable.durationsWC;
        trialtypesWC = dataTable.Trialtype;
        [wcoh,~,f,coi] = wcoherence(data1, data2);
        num_trials = size(dataTable, 1);
        num_freqs = size(wcoh, 1);
        avg_coherence_per_trial = zeros(num_trials,num_freqs);
        high_freq_band = 0.1; 
        mid_freq_band_lower = 0.03;
        mid_freq_band_upper = 0.1; 
        low_freq_band = 0.03;
        high_freq_idx = find(f >= high_freq_band & f <= 0.2);
        mid_freq_idx = find(f >= mid_freq_band_lower & f < mid_freq_band_upper);
        low_freq_idx = find(f < low_freq_band & f >= 0.02);
        for trial_idx = 1:num_trials
            trial_start_time = onsetsWC(trial_idx);
            trial_duration = durationsWC(trial_idx);
            trial_end_time = trial_start_time + trial_duration;
            trial_coherence = wcoh(:, trial_start_time:trial_end_time);
            trial_coherence_downsampled = trial_coherence(:, 1:16:end);
            time_points = floor(size(trial_coherence, 2) / 16); 
            for t = 1:time_points
                coh_vec = trial_coherence_downsampled(:, t);
                low_val = mean(coh_vec(low_freq_idx));
                mid_val = mean(coh_vec(mid_freq_idx));
                high_val = mean(coh_vec(high_freq_idx));
                raw_rows{row_counter, 1} = trial_start_time + (t - 1); 
                raw_rows{row_counter, 2} = trial_idx;
                raw_rows{row_counter, 3} = trial_start_time; 
                raw_rows{row_counter, 4} = trial_duration;    
                raw_rows{row_counter, 5} = trialtypesWC(trial_idx);      
                raw_rows{row_counter, 6} = low_val;         
                raw_rows{row_counter, 7} = mid_val;         
                raw_rows{row_counter, 8} = high_val;        
                raw_rows{row_counter, 9} = p;               
                raw_rows{row_counter, 10} = j;          
                row_counter = row_counter + 1;
            end
            avg_coherence_per_freq = mean(trial_coherence, 2);
            avg_coherence_per_trial(trial_idx, :) = avg_coherence_per_freq;          
        end  
        avg_high_freq_coherence = mean(avg_coherence_per_trial(:, high_freq_idx), 2);
        avg_mid_freq_coherence = mean(avg_coherence_per_trial(:, mid_freq_idx), 2);
        avg_low_freq_coherence = mean(avg_coherence_per_trial(:, low_freq_idx), 2); 
        p_repeated = repmat(p, size(onsetsWC));
        j_repeated = repmat(j, size(onsetsWC));
        co = table(onsetsWC, durationsWC, trialtypesWC, avg_low_freq_coherence, avg_mid_freq_coherence, avg_high_freq_coherence, p_repeated, j_repeated);
        co.Properties.VariableNames = {'Onset', 'Duration', 'TrialType', 'AvgCoherenceLowFreq', 'AvgCoherenceMidFreq', 'AvgCoherenceHighFreq', 'Dyad', 'Channel'};
        co = sortrows(co, 'Onset');
        combinedtable = vertcat(combinedtable,co);     
    end
end 
save_path = 'C:\Users\emre.yavuz\Desktop\DataGLM\Waveletcoherence';
raw_flat_table = cell2table(raw_rows, ...
        'VariableNames', {'Time', 'TrialIdx', 'Onset', 'Duration', 'TrialType', ...
                      'CoherenceLow', 'CoherenceMid', 'CoherenceHigh', 'Dyad', 'Channel'});
raw_filename = fullfile(save_path, 'WTC_raw_flattened.csv');
writetable(raw_flat_table, raw_filename);
filename = fullfile(save_path, 'WTCtable.csv');
writetable(combinedtable, filename);

%6. Do phase-scrambling WTC method 

Excluded=['P07';'P08';'P14';'P15';'P19';'P22';'P26';'P31'];
Excluded = cellstr(Excluded);
participant_numbers = arrayfun(@(x) sprintf('%02d', x), 1:32, 'UniformOutput', false);
participant_numbers = strcat('P', participant_numbers).';
participant_numbers = cellstr(participant_numbers);
ismem = ismember(participant_numbers,Excluded); 
include = participant_numbers(~ismem); 
pairTable = table('Size',[0,2],'VariableTypes',{'string','string'},'VariableNames',{'Member1','Member2'});
for i = 1:2:numel(participant_numbers)
    if i+1 <= numel(participant_numbers)
        pairTable = [pairTable; {participant_numbers{i}, participant_numbers{i+1}}];
    end
end
pairTable.index = (1:height(pairTable)).';
rows_to_remove = [];
for i = 1:height(pairTable)
    if ~ismember(pairTable.Member1(i), include) || ~ismember(pairTable.Member2(i), include)
        rows_to_remove = [rows_to_remove, i];
    end
end
pairTableFiltered = pairTable;
pairTableFiltered(rows_to_remove, :) = [];
pairTable = pairTableFiltered; 
save_path = 'C:\Users\emre.yavuz\Desktop\DataGLM\Waveletcoherence';
filename = fullfile(save_path, 'pairTable.csv');
writetable(pairTable, filename);
parentDirectory = 'C:\Users\emre.yavuz\Desktop\DataGLM';
n_iterations = 100; 
save_path = 'C:\Users\emre.yavuz\Desktop\DataGLM\Waveletcoherence';
process_dyads(pairTable, parentDirectory, n_iterations, save_path);
