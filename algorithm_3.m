function [PUL,AEQ]=algorithm_3(PUL,AMB,TIM,r_limit,residual_ageing)
%% Purpose
% This function maximizes the square under load profile if we have the
% residual resource of winding insulation.

% Note that the algorithm_3 is a special case of algorithm 2. Therefore,
% algorithm_3 is applied only in particular situation (see Finding_DTR_with_RHC.m)


% Input:
% PUL - Load, pu
% AMB - ambien temperature profile, degC
% TIM - time (minutes) vector
% r_limit - right limit in minutes for corresponding hour
% residual_ageing - remaining (daily) resource of winding insulation

% Output:
% PUL -  Loading profile,pu respecting the HST and AEQ constraints
% AEQ - Ageing equivalent, pu of PUL

% Author contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Function execution

% Find the DTR per algorithm 1
[DTR]=algorithm_1(AMB,r_limit,residual_ageing,PUL);

% Checking the condition if DTR is always higher than PUL
condition=DTR(r_limit+1:end)>PUL(r_limit+1:end);

if sum(condition)==length(condition) % if DTR is always higher than PUL
    PUL=DTR; % accept PUL as DTR
    
else % load exceeds DTR (per algorithm 1) at least once
    
    % Looking for intervals where load is lower than DTR at t+
    interval_idx=PUL(r_limit+1:end)<DTR(r_limit+1:end);
    
    % Create the variable "number of interval_idxs" for counting
    number_of_interval=0;
    
    % Create a variable ==1
    start=1;
    
    % Create an empty variable
    range_of_interval=[];
    
    % Checking
    if all(interval_idx==1) % all load below DTR
        
        % There is only 1 interval
        number_of_interval=1;
        
        % Save the range
        range_of_interval{1}=[1:length(PUL)]';
        
    elseif all(interval_idx==0) % all load above DTR
        
        % There is no any intevarls
        number_of_interval=0;
        
        % No savings
        range_of_interval=[];
        
    else % some load below and some load above DTR
        
        % Calculating the interval number
        for i=2:length(interval_idx)
            try
                % Checking the condition
                condition=interval_idx(i)-interval_idx(i-1);
                
                % condition=1-0=1 means that load was below DTR and
                % then exceeded DTR
                
                % condition =0-1=-1 means the opposite that the loading was
                % first above DTR and then reduced below DTR
                
                % condition = 0-0 or 1-1 = 0 means that the loading remains
                % in its previous state (below or above DTR)
                
                if condition==1
                    
                    % Assing variables as i and 1
                    start=i;
                    open_start=1;
                end
                
                if condition==-1
                    finish=i-1;
                    range_of_interval{end+1}=[start:finish];
                    number_of_interval=number_of_interval+1;
                    open_start=0;
                end
                
                if i==length(interval_idx) && open_start==1
                    finish=length(PUL);
                    range_of_interval{end+1}=[start:finish];
                    number_of_interval=number_of_interval+1;
                end
                
            catch
                
                disp ('Problem in finding indexes')
                
            end % end of "try"
            
        end % end of "for i=2:length(interval)"
        
    end % end of "if all(interval==1)"
    %% Finding available insulation resources
    t_length=0;
    for i=1:number_of_interval
        a=range_of_interval{i};
        %         S_nomin=S_nomin+Current_ageing(a(end))-Current_ageing(a(1));
        %         t_length=t_length+a(end)-a(1);
        t_length=t_length+length(a);
    end
    
    % New AAF
    AAF_new=residual_ageing/t_length;
    %% Finding the DTR 
    for i=1:number_of_interval
        try
            optimization_interval=range_of_interval{i}';
            [~,DTR]=sub_algorithm_3(AMB,AAF_new,optimization_interval);
            PUL(optimization_interval)=DTR;
        catch
            disp ('Problem occured. Check the section "final loading" in algorithm 3')
        end
    end
end
%% thermal regime estimation
[HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);

while AEQ>1 || max(HST)>140
    % Reduce the AAF_new 
    AAF_new=AAF_new-0.01;
    
    % Checking for the possible error
    if ~(AAF_new>0)
        error('AAF_new is negative.')
    end
    
    for i=1:number_of_interval
        try
            optimization_interval=range_of_interval{i}';
            %     number_of_hours=length(optimization_interval)/60;
            [~,DTR]=sub_algorithm_3(AMB,AAF_new,optimization_interval);
            %     for i=1:number_of_hours
            
            PUL(optimization_interval)=DTR;
        catch
            disp ('problem occured in last section of algorithm_3')
        end
    end
    
    % Check the thermal parameters
    [HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);
    
end % end of "while AEQ>1 || max(HST)>140"

end % end of function
