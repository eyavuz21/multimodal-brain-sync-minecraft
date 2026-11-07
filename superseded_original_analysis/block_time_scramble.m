% block_time_scramble
% Saved from notes on 3 September 2026. Code below is verbatim as written.
%
% CHECK BEFORE USING: the movmean smoothing sits INSIDE the
% "if num_blocks*block_len < N" block, so it only runs when the signal length
% is NOT an exact multiple of block_len. If that was meant to smooth every
% output, the final "end" needs moving up to just after the concatenation.
% Left unchanged here so it matches whatever produced your existing results.

function scrambled_signal = block_time_scramble(signal, block_len)

    N = length(signal);
    num_blocks = floor(N / block_len);
    blocks = reshape(signal(1:num_blocks*block_len), block_len, num_blocks);
    perm = randperm(num_blocks);
    scrambled_blocks = blocks(:, perm);
    scrambled_signal = scrambled_blocks(:);
    if num_blocks*block_len < N
        scrambled_signal = [scrambled_signal;
    signal(num_blocks*block_len+1:end)];
    Windowsize=0.1*block_len;
    Windowsize=floor(Windowsize);
    scrambled_signal = movmean(scrambled_signal,Windowsize);
    end
end

% ---------------------------------------------------------------------------
% Loose fragment that was filed with this script, labelled "Nulllatest".
% Incomplete: no surrounding loop, and "fade" and "smoothingsections" are
% undefined here. Kept so it is not lost.
%
% fade .* scrambled_signal(smoothingsections(j)) + ...
%     (1-fade) .* scrambled_signal(smoothingsections(j+1));
