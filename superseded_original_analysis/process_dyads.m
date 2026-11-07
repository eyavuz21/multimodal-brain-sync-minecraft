function process_dyads(pairTable, parentDirectory, n_iterations, save_path)
    filename1 = fullfile(save_path, 'WTCtableNULL.csv');
    if exist(filename1, 'file')
        delete(filename1); 
    end
    combined_table = table();
    total_trials = 0; 
    for p = 1:size(pairTable, 1)
        participant1 = pairTable.Member1{p};
        participant2 = pairTable.Member2{p};
        filePath1 = fullfile(parentDirectory, participant1, 'Results', 'NIRS.mat');
        filePath2 = fullfile(parentDirectory, participant2, 'Results', 'NIRS.mat');
        channel_results = cell(25,1);
        parfor j = 1:25
            data1_struct = load(filePath1); 
            data2_struct = load(filePath2); 
            data1 = data1_struct.Y.hbo(:, j);
            data2 = data2_struct.Y.hbo(:, j);
            allOnsets = [];
            allDurations = [];
            allTrials = []; 
            filename = strcat(participant1, 'U_onsets.mat');
            dyadtimespaths = fullfile(parentDirectory, participant1, 'Logs', 'Onsets', filename);
            dyadtimes = load(dyadtimespaths); 
            for i = 1:numel(dyadtimes.onsets)
                allOnsets = [allOnsets; dyadtimes.onsets{i}];
                allDurations = [allDurations; dyadtimes.durations{i}];
                numTrials = numel(dyadtimes.onsets{i});
                repeatedTrials = repelem(dyadtimes.names{i}, numTrials);
                allTrials = [allTrials; repeatedTrials'];
            end
            dataTable = table(allTrials, allOnsets, allDurations, 'VariableNames', {'Trialtype','Onsets', 'Durations'});
            dataTable = dataTable(ismember(dataTable.Trialtype, {'Chase', 'Follow'}), :);
            dataTable.onsetsWC = dataTable.Onsets;
            dataTable.durationsWC = dataTable.Durations;
            avg_low_freq_coherence = zeros(n_iterations, 1);
            avg_mid_freq_coherence = zeros(n_iterations, 1);
            avg_high_freq_coherence = zeros(n_iterations, 1);  
            results_cell = cell(n_iterations, 1);
            for iter = 1:n_iterations
                fprintf('Dyad %d, Channel %d, Iteration %d\n', p, j, iter);
                scrambled_signal1 = block_time_scramble(data1);
                scrambled_signal2 = data2;
                [wcoh, ~, f, ~] = wcoherence(scrambled_signal1, scrambled_signal2);
                num_trials = size(dataTable, 1);
                num_freqs = size(wcoh, 1);
                avg_coherence_per_trial = zeros(num_trials, num_freqs); 
                for trial_idx = 1:num_trials
                    trial_start_time = dataTable.onsetsWC(trial_idx);
                    trial_duration = dataTable.durationsWC(trial_idx);
                    trial_end_time = trial_start_time + trial_duration;
                    trial_coherence = wcoh(:, trial_start_time:trial_end_time);
                    avg_coherence_per_freq = mean(trial_coherence, 2);
                    avg_coherence_per_trial(trial_idx, :) = avg_coherence_per_freq;
                end         
                high_freq_band = 0.1; 
                mid_freq_band_lower = 0.03;
                mid_freq_band_upper = 0.1; 
                low_freq_band = 0.03;        
                high_freq_idx = find(f >= high_freq_band & f <= 0.2);
                mid_freq_idx = find(f >= mid_freq_band_lower & f < mid_freq_band_upper);
                low_freq_idx = find(f < low_freq_band & f >= 0.02);   
                avg_high_freq_coherence = mean(avg_coherence_per_trial(:, high_freq_idx), 2);
                avg_mid_freq_coherence = mean(avg_coherence_per_trial(:, mid_freq_idx), 2);
                avg_low_freq_coherence = mean(avg_coherence_per_trial(:, low_freq_idx), 2); 
                dyad_repeated = repmat(p, num_trials, 1);
                channel_repeated = repmat(j, num_trials, 1);
                iteration_repeated = repelem(iter, num_trials, 1);        
                co = table(dataTable.onsetsWC, dataTable.durationsWC, dataTable.Trialtype, avg_low_freq_coherence(:), avg_mid_freq_coherence(:), avg_high_freq_coherence(:), dyad_repeated, channel_repeated, iteration_repeated, ...
                       'VariableNames', {'Onset', 'Duration', 'TrialType', 'AvgCoherenceLowFreq', 'AvgCoherenceMidFreq', 'AvgCoherenceHighFreq', 'Dyad', 'Channel', 'Iteration'});
                results_cell{iter} = co;
            end
            all_co = vertcat(results_cell{:});
            channel_results{j} = all_co;
        end
        dyad_table = vertcat(channel_results{:});
        if exist(filename1, 'file')
            writetable(dyad_table, filename1, 'WriteMode','Append');
        else
            writetable(dyad_table, filename1);
        end
    end
end