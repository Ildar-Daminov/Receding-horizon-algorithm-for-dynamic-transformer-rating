function [PUL_interval,DTR]=sub_algorithm_3(AMB,AAF_new,optimization_interval)
%% Purpose
% This function maximizes the square under load profile if we have the
% residual resource of winding insulation.

% Note that the algorithm_3 is a special case of algorithm 2. Therefore,
% algorithm_3 is applied only in particular situation (see Finding_DTR_with_RHC.m)


% Input:
% AMB - Ambien temperature profile, degC
% AAF_new - Ageing 
% optimization_interval - Interval where the optimization of loading takes place 

% Output:
% PUL_interval -  Loading profile, pu
% DTR - Dynamic Thermal Rating of transformers 

% Author contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Function execution 

% Load the look-up table with ageing 
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

% Vector of reference ambient temperature (used to navigate in Ageing
% table)
Temperature=-50:1:50;

% Find the unique values of AMB at optimization interval 
unique_values=unique(AMB(optimization_interval));

% Extract PUL values for optimization interval 
for i=1:length(unique_values)
    
    % Find the closest value of AMB in Temperature vector
    [~,t]=min(abs(Temperature-unique_values(i)));
    
    
    if length(AAF_new)==1 % if AAF_new is value
        [~, q]= min(abs(Ageing(:,t+1)-AAF_new));
    else % if AAF_new is a vector (probably it is better to delete it)
        [~, q]= min(abs(Ageing(:,t+1)-AAF_new(i)));
    end
    
    % Extract a PUL value corresponding to AAF_new
    PUL_interval(i,1)=Ageing(q,1);
end

% Reconstruct the PUL final
for i=1:length(unique_values)
    index=find(AMB(optimization_interval)==unique_values(i));
    DTR(index)=PUL_interval(i);
end