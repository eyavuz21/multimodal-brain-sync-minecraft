function scrambled_signal = block_time_scramble(signal)
    boundary = floor(0.01*length(signal));
    shiftAmount = randi([1+boundary, length(signal)-boundary]);
    scrambled_signal = circshift(signal, shiftAmount);
    start_idx = max(1,shiftAmount-floor(0.01*length(signal)));
    end_idx = min(shiftAmount+floor(0.01*length(signal)),length(signal)); 
    left_slice  = scrambled_signal(start_idx:shiftAmount);
    right_slice = scrambled_signal(shiftAmount+1:end_idx);
    fade_left = linspace(1, 0, length(left_slice))';
    fade_right = linspace(1, 0, length(right_slice))';
    disp(size(scrambled_signal(start_idx:shiftAmount)));
    disp(size(fade_left .* left_slice));
    scrambled_signal(start_idx:shiftAmount) = fade_left .* left_slice;
    scrambled_signal(shiftAmount+1:end_idx) = fade_right .* right_slice;
end