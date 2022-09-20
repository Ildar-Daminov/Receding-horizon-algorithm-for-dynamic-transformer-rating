function [DTR,AEQ,PUL_loading]=Finding_DTR_with_RHC(PUL,AMB,TIM,r_limit,PUL_loading)
%% Purpose 
% This function applies receding horizong control to determine DTR of transformer

% Input: 
% PUL - actual load at t- and forecast load at t+, pu
% AMB - actual ambient temperature at t- and forecast amb.temperature at
% TIM - time (minutes) vector 
% r_limit - a right limit in minutes for corresponding hour
% PUL_loading - a historical transformer loading

% Output:
% DTR - Dynamic Thermal Rating of transformer, pu
% AEQ - Aging equivalent, pu
% PUL_loading - transformer loading,pu

% Contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Function execution

% Depending on initial HST and AEQ, different algoritms may be applied.
% 1. if max(HST(r_limit+1:end))<=140|| AEQ<=1 then we apply algorithm 1
% 2. if max(HST(r_limit+1:end))>140|| AEQ>1 then we apply algorithm 2
% Note that there is a specific case for 2 situation then algorithm 3

% Algorithm 1: set DTR at remaining horizon equal to reference DTR (similar
% to reference DTR)) but considering the remaining insulation resource at
% t+

% Algortihm 2: set the DTR at off peak periods equal to 1 (nominal rating)
% and reduced transformer loading at peak periods until the condition 
% "max(HST(r_limit+1:end))<=140|| AEQ<=1" is not met 

% Algortihm 3 (special case): 

% set  loading at interval t+
PUL_loading(r_limit+1:end,1)=PUL(r_limit+1:end,1);

% loading at t- and forecast at t+ (without limitation by DTR)
PUL=PUL_loading;

% estimate thermale regime with consideration of t- and t+
[HST,~,AEQ,Current_ageing,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);

% find residual insulation resource
residual_ageing=1440-Current_ageing(r_limit);

if max(HST(r_limit+1:end))>140|| AEQ>1 % then we apply algorithm 2
    
    % Set a static limit ==1 pu
    static_limit=linspace(1,1,length(PUL))';
    
    % Find the indexes where load is below of nominal rating
    off_peak_interval=find(PUL<static_limit);
    
    % Find in this array the indexes more than r limit
    index_r_limit=off_peak_interval>r_limit;
    
    % Adjust off peak interval according to r limit
    off_peak_interval=off_peak_interval(index_r_limit);
    
    % Set the DTR to nominal rating for this off peak interval
    PUL(off_peak_interval)=1;
    
    % Find DTR at time interval t+
    [DTR,~]=algorithm_2(PUL,AMB,TIM,r_limit);
   
elseif max(HST(r_limit+1:end))<=140|| AEQ<=1 % then we apply algorithm 1
    
    % Estimate reference_DTR area at interval t+
    [reference_DTR]=algorithm_1(AMB,r_limit,residual_ageing,PUL);
    
    % Checking if a load is always below DTR 
    index=reference_DTR(r_limit+1,1)>PUL(r_limit+1,1);
    
    if all(index==1) % if load is always below DTR
        
        % Determine DTR as reference_DTR 
        DTR=reference_DTR; 
        
    else % if PUL is higher than reference_DTR even once 
        % Then we apply algorithm 3 which maximizes the square under load profile
        % if we have the residual resource. In this case DTR is determined 
        % by algorithm 3
        [DTR,AEQ]=algorithm_3(PUL,AMB,TIM,r_limit,residual_ageing);
        disp('ATTENTION: algorithm_3 is given for information purpoes. See NB in code')
        % NB: algorithm 3 represents a possible heuristic logic of setting
        % DTR. However, the logic is not neccesary the optimal one because
        % it was not the goal of the paper. Therefore, the reader should 
        % consider algorithm 3 as one of many possible logics for special case. 
        
    end % end of "if all(index==1)"
    
end % end of if max(HST(r_limit+1:end))>140|| AEQ>1 


end % end of function