[stereoAudio, Fs] = audioread("project.wav"); % Read the audio file
monoAudio = (stereoAudio(:,1))'; % Monoaudio is now a row vector
digitalBits = a2d(monoAudio); % Stream of bits

% Send bits to the encoder
encoded_sig = cell(1,2); % preallocating a cell for inPhase component and quadrature phase components
[encoded_sig{1},encoded_sig{2}] = encoder(digitalBits);

lineCoded_sig = cell(1,2); % preallocating a cell for inPhase lineCodinand quadrature phase lineCoding
% LineCoding using raised Cosine
lineCoded_sig{1} = lineCoding_raisedCosine(encoded_sig{1});
lineCoded_sig{2} = lineCoding_raisedCosine(encoded_sig{2});

% Modulation
modulated_sig = modulate(lineCoded_sig);

% Adding Channel Noise
sigma = 0.1; % Vary from 0 to 1 
rx_sig = channel_memoryless(modulated_sig, sigma);

% Demodulation 
demod_sig = demodulate(rx_sig);

% Line Decoding
decoded_sig = cell(1,2);
decoded_sig{1} = lineDecoding(demod_sig{1});
decoded_sig{2} = lineDecoding(demod_sig{2});

% Decoder
digits = decoder(decoded_sig{1},decoded_sig{2});
out = d2a(digits);
out = out/max(out);

% Finding Probability of error
N = length(digits);
differences = 0;
for k = 1 : N
    if(digits(k)~=digitalBits(k))
        differences = differences + 1;
    end
end
p_e = differences/N;
disp(p_e);

% Write the audio file
audiowrite("outputtest.wav", out, Fs);