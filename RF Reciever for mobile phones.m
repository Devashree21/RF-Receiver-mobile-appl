% Model for Radio Frequency Reciever for mobile phones
% This is a Digital Filter - FIR - Bandpass type 
% All frequency values are in kHz.

%*************************************************************%
% Part 1: Generating a test signal with different freqencies

fs = 15e3 ;     % Samping frequency of 15 kHz
ts=1/fs;        % Sampling Time
dt=0:ts:5e-3;   % Time vector

%Since MHz frequencies are converted/downsampled to kHz before passing through Bandpass filter
% we assume the available frequencies are in kHz
% The range of frequencies to be allowed is 9-12 KHz %


f1 = 1e3;       % Frequency 1= 1kHz
f2 = 10.1e3;    % Frequency 2= 10kHz
f3 = 50e3;      % Frequency 3= 50kHz
    
% This is the test signal with different frequencies present
% This signal can be changed to study filter response for different
% frequencies

y = 5*sin(2*pi*f1*dt)+10*sin(2*pi*f2*dt)+5*sin(2*pi*f3*dt);

%*************************************************************%
% Part 2: Converting to Frequency domain for Time domain signal
% using FastFourierTransform fft function

nfft=length(y); %assume the signal to be of n length
nfft2=2.^nextpow2(nfft);
fy=fft(y,nfft2); % This computes the DFT of the signal at points n
fy=fy(1:nfft2/2);
xfft=fs.*(0:nfft2/2-1)/nfft2;
%plot(xfft,abs(fy/max(fy)));

%*************************************************************%
% Part 3: Setting up the FIR Bandpass filter values
% using Signal Processing Toolbox

order=200;          % order of the filter for method 1: Hamming Window
f_cut1=9e3/fs/2;    % cutoff frequency 1
f_cut2=12e3/fs/2;   % cutoff frequency 2

%%% Method 1: Hamming Window based

b = fir1(order,[f_cut1 f_cut2]); % fir1(n,[Wn1 Wn2])=> n is order of filter and Wn1, Wn2 are cutoff frequencies
figure;
freqz(b);% plotting frequency response of filter
title('Hamming Window Filter Design');
legend('Hamming Window');

%%% Method 2: Equiripple based
% Define filter parameters
order1= 200;        % Order of filter for method 2: Equiripple

Fstop1 = 0.2;       % First Stopband Frequency
Fpass1 = f_cut1;    % First Passband Frequency
Fpass2 = f_cut2;    % Second Passband Frequency
Fstop2 = 0.5;       % Second Stopband Frequency

dens   = 20;        % Density Factor required for Equiripple method

% Default values used by MATLAB for magnitude 

Wstop1 = 60;         % First Stopband Weight
Wpass  = 1;          % Passband Weight
Wstop2 = 80;         % Second Stopband Weight


% Calculate the coefficients using the FIRPM function for the filter.
b1  = firpm(order1, [0 Fstop1 Fpass1 Fpass2 Fstop2 1], [0 0 1 1 0 0],[Wstop1 Wpass Wstop2], {dens});
figure;
freqz(b1);
title('Equiripple Filter Design');
legend('Equiripple');

%*************************************************************%
% Part 4 : FFT of filtered signal

% for Window method

fh=fft(b,nfft2);
fh=fh(1:nfft2/2);

%filtering the noisy signal in frequency domain by using mul (matrix multiplication) technique
mul=fh.*fy;
%can also be filtered in time domain by using convolution method
con=conv(y,b);

% for Equiripple method
fh1=fft(b1,nfft2);
fh1=fh1(1:nfft2/2);

%filtering the noisy signal in frequency domain by using mul technique
mul1=fh1.*fy;

%can also be filtered in time domain by using convolution method
con1=conv(y,b1);

%**********************************************************%

%Part 5: Plotting both frequency and time domain plots

figure;

%fig 1 RECEIVED SIGNAL
subplot(4,2,1)
plot(dt,y);
xlabel('Time (s)');
ylabel('Amplitude');
title('Received Signal');
legend('Received Signal');

%fig 2 FREQUENCY DOMAIN REPRESENTATION OF RECEIVED SIGNAL

subplot(4,2,2)
plot(xfft,abs(fy/max(fy))); %normalizing amplitude to 1
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Frequency Domain of Received Signal');

%fig 3 IMPULSE RESPONSE FILTER METHOD 1

subplot(4,2,3)
stem(b);
xlabel('Samples');
ylabel('Amplitude');
title('Impulse Response of Bandpass filter');
legend('Hamming Window');

%fig 4 IMPULSE RESPONSE FILTER METHOD 2

subplot(4,2,4)
stem(b1,'Color',[.6 0 0]);
xlabel('Samples');
ylabel('Amplitude');
title('Impulse Response of Bandpass filter');
legend('Equiripple');

%fig 5

subplot(4,2,5)
plot(abs(mul));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Bandpass filtering');

%fig 6

subplot(4,2,6)
plot(abs(mul1),'Color',[.6 0 0]);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Bandpass filtering');

%fig 7 FILTERED SIGNAL METHOD 1 

subplot(4,2,7)
plot(con);
xlabel('Time (s)');
ylabel('Amplitude');
title('Filtered Signal by Hamming Window Method');
legend('Filtered signal');

%fig 8 FILTERED SIGNAL METHOD 2

subplot(4,2,8)
plot(con1,'Color',[.6 0 0]);
xlabel('Time (s)');
ylabel('Amplitude');
title('Filtered Signal by Equiripple Method');
legend('Filtered signal');