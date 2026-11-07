function scrambled_signal = phase_scramble(signal)
    ft_signal = fft(signal);
    random_phases = exp(1j * (rand(size(signal)) * 2 * pi));
    scrambled_ft_signal = abs(ft_signal) .* random_phases;
    scrambled_signal = real(ifft(scrambled_ft_signal));
end