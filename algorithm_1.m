function [DTR]=algorithm_1(AMB,r_limit,residual_ageing,PUL)
%% Purpose 
% This function calculates DTR at the interval t+ considering the residual
% resource of insulation (residual_ageing)

% Input
% AMB - ambien temperature profile, degC
% r_limit - right limit in minutes for corresponding hour
% residual_ageing - a residual insulation resource of windings
% PUL - Load, pu
% 
% Output:
% DTR -  Dynamic Thermal Rating of a transformer, pu

% Author contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Function execution

% Keep the initial ambient temperature profile (used later in
% IEEE_thermal_model):
AMB_init=AMB;

% Round the ambient temperature (for code acceleration) as this allows
% faster find the AMB in look-up table (from Ageing_IEEE.mat)
AMB=round(AMB(r_limit+1:end,1));

% Range of ambient temperature
Temperature=-50:1:50;

% Load look-up table of Ageing rate as a function of AMB and PUL
load('Ageing_IEEE.mat')

% Look-up table is as follows:

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


% Find the unique values of ambient temperature
unique_values=unique(AMB);

% Find a new AAF according to residual ageing at remaining interval
AAF_new=residual_ageing/(1440-r_limit);

% For each unique value of ambient temperature
for i=1:length(unique_values)
    
    % Find the closet value in Temperature vector
    [~,t]=min(abs(Temperature-unique_values(i)));
    
    % Check if the closest value is greater than the given unique value
    if Temperature(t)>unique_values(i)
        t=t+1; % if yes, than increase the index (needed for look-up table)
    end
    
    % Find the closet AAF for AAF_new in look-up table
    [~, q]= min(abs(Ageing(:,t+1)-AAF_new));
    
    % Find the corresponding loading for q index
    if Ageing(q,t+1)<=AAF_new % if the closest value is below or equal to AAF_new
        PUL_interval(i,1)=Ageing(q,1);
    else % otherwise
        q=q-1;
        PUL_interval(i,1)=Ageing(q,1);
    end
    
end % end of "for i=1:length(unique_values)"

% For each unique value
for i=1:length(unique_values)
    
    % Find the index where unique value is equal to AMB profile
    index=find(AMB==unique_values(i));
    
    % For these intervals (index) set the loading
    PUL_index(index)=PUL_interval(i);
    
end

% Check if AEQ>100
DTR=zeros(1440,1);
DTR(1:r_limit,1)=PUL(1:r_limit,1);
DTR(r_limit+1:end,1)=PUL_index(1:end,1);

% set TIm vector
TIM=linspace(1,1440,1440)';

% Calculate the thermal parameters of transformer
[HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB_init,DTR,TIM);

% Checking if ageing is OK
if AEQ<=1 && max(HST)<=140 % if ageing and HST is OK
    % do nothing
else % otherwise apply algorithm 2 which would reduce loading at peak intervals
    [DTR,~]=algorithm_2(DTR,AMB_init,TIM,r_limit);
end % end of "if AEQ<=1 && max(HST)<140"

end % end of function