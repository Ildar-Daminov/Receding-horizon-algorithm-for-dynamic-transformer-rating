clc
clear
close all

%% Purpose
% This script creates two lookup tables: (1) HST and Ageing rate as function 
% of PUL&AMb. Later, these lookup tables will be used in algorithms (1,2,3)

% Example of such table 
%                            Ambient temperature
%  Load     -50     -49       -48    ...     +48       +49       +50
% ----------------------------------------------------------------------
%  0.01 |  AAF1_1   AAF1_2   AAF1_3  ...   AAF1_99  AAF1_100   AAF1_101
%  0.02 |  AAF1_2   AAF2_2   AAF2_3  ...   AAF2_99  AAF2_100   AAF2_101
%  0.03 |  AAF3_1   AAF3_2   AAF3_3  ...   AAF3_99  AAF3_100   AAF3_101
%   ...
%  1.98 | AAF198_1 AAF198_2 AAF198_3 ...  AAF198_99 AAF198_100 AAF198_101
%  1.99 | AAF199_1 AAF199_2 AAF199_3 ...  AAF199_99 AAF199_100 AAF199_101
%   2.0 | AAF200_1 AAF200_2 AAF200_3 ...  AAF200_99 AAF200_100 AAF200_101

% Author contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Caclulation of lookup tables 
% Set the initial data
AMB_all=(-50:50)'; % vector of ambient temperature, degC
PUL_all=(0.01:0.01:2)'; % vector of loadings, pu
TIM=(1:1440)'; % vector of minutes

% Create a zero array
Ageing=zeros(length(PUL_all),length(AMB_all));
Temp=zeros(length(PUL_all),length(AMB_all));

% Calculate the lookup table for all combinations of load and amb
for j=1:length(PUL_all)
    
    % Set the constant load 
    PUL=linspace(PUL_all(j),PUL_all(j),1440)';
    
    for i=1:length(AMB_all)
        % Set the constant AMB over 1 day (1440 min)
        AMB=linspace(AMB_all(i),AMB_all(i),1440);
        
        % Estimation of thermal parameters
        [HST,~,~,~,~,Ageing_rate,~]=IEEE_thermal_model(AMB,PUL,TIM);
        
        % Extract the Ageing rate
         Ageing(j,i)=Ageing_rate(500);
         
         % Extract the hot spot temperature 
         Temp(j,i)=HST(500);
    end
end