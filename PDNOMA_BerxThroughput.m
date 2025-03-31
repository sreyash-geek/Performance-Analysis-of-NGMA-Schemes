clc; clear; close all;
%% Parameters
N = 10^5; % Number of bits
SNR_dB = 0:2:20; % SNR range in dB
SNR = 10.^(SNR_dB/10); % Convert to linear scale
alpha1 = 0.8; % Power allocation for User 1 (stronger power, weaker channel)
alpha2 = 1 - alpha1; % Power allocation for User 2 (weaker power, stronger channel)
M = 4; % QPSK modulation (4 symbols)

%% Channel: Rayleigh Fading
h1 = (randn(1, N) + 1j * randn(1, N)) / sqrt(2); % User 1 channel
h2 = (randn(1, N) + 1j * randn(1, N)) / sqrt(2); % User 2 channel

%% BER and Throughput Initialization
BER_user1 = zeros(1, length(SNR));
BER_user2 = zeros(1, length(SNR));
Throughput_NOMA = zeros(1, length(SNR));
Throughput_OFDMA = zeros(1, length(SNR));
for i = 1:length(SNR)
    % Transmit signal (QPSK)
    bits1 = randi([0 1], 1, N);
    bits2 = randi([0 1], 1, N);
    s1 = sqrt(alpha1) * (2*bits1 - 1); % BPSK User 1
    s2 = sqrt(alpha2) * (2*bits2 - 1); % BPSK User 2
    x_noma = s1 + s2; % Superposed signal
    % Multipath Rayleigh channel + AWGN
    noise_var = 1/SNR(i);
    noise = sqrt(noise_var/2) * (randn(1, N) + 1j * randn(1, N));
    y1 = h1 .* x_noma + noise; % User 1 received signal
    y2 = h2 .* x_noma + noise; % User 2 received signal
    % Successive Interference Cancellation (SIC) at User 2
    y2_sic = y2 - sqrt(alpha1) * h2 .* (2*bits1 - 1); % Remove User 1's signal
    detected_bits1 = real(y1 ./ h1) > 0;
    detected_bits2 = real(y2_sic ./ h2) > 0;
    % BER Calculation
    BER_user1(i) = sum(bits1 ~= detected_bits1) / N;
    BER_user2(i) = sum(bits2 ~= detected_bits2) / N;
    % Shannon Capacity for Throughput Analysis
    Throughput_NOMA(i) = log2(1 + SNR(i) * alpha1) + log2(1 + SNR(i) * alpha2);
    Throughput_OFDMA(i) = 0.5 * log2(1 + SNR(i)); % Equal bandwidth split for OFDMA
end

%% Plot BER Performance
figure;
semilogy(SNR_dB, BER_user1, 'ro-', 'LineWidth', 1.5); hold on;
semilogy(SNR_dB, BER_user2, 'bs-', 'LineWidth', 1.5);
xlabel('SNR (dB)'); ylabel('Bit Error Rate (BER)');
title('BER Performance of PD-NOMA with Multipath Fading');
legend('User 1 (Weak Channel, High Power)', 'User 2 (Strong Channel, Low Power)');
grid on;

%% Plot Throughput Comparison
figure;
plot(SNR_dB, Throughput_NOMA, 'r-o', 'LineWidth', 1.5); hold on;
plot(SNR_dB, Throughput_OFDMA, 'b-s', 'LineWidth', 1.5);
xlabel('SNR (dB)'); ylabel('Throughput (bps/Hz)');
title('Throughput Comparison: PD-NOMA vs OFDMA');
legend('PD-NOMA', 'OFDMA');
grid on;