function [PUL,AEQ]=algorithm_2(PUL,AMB,TIM,r_limit)
%% Purpose 
% This function in general calculates loading profile PUL respecting the
% HST and AEQ constraints by sequantially reducing the peak load of
% transformer


% The idea of algortihm 2 is to first find a such HST profile which would
% respect HST and AEQ constraints. Second, for such HST profile algorithm
% finds a corresponding (approximate) load profile(PUL). 


% Input:
% PUL - Load, pu
% AMB - ambien temperature profile, degC
% TIM - time (minutes) vector
% r_limit - right limit in minutes for corresponding hour

% Output:
% PUL -  Loading profile,pu respecting the HST and AEQ constraints
% AEQ - Ageing equivalent, pu of PUL

% Author contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Evaluate initial thermal regime of transformer
[HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);

%% Prepare initial data 
% Checking the HST and AEQ constraints 
if max(HST)>140 || AEQ>1
    
    % Load lookup table - HST (PUL, AMB)
    load('Temp_IEEE.mat')

    % Look-up table is as follows:

%                            Ambient temperature
%  Load     -50     -49       -48    ...     +48       +49       +50
% ----------------------------------------------------------------------
%  0.01 |  HST1_1   HST1_2   HST1_3  ...   HST1_99  HST1_100   HST1_101
%  0.02 |  HST1_2   HST2_2   HST2_3  ...   HST2_99  HST2_100   HST2_101
%  0.03 |  HST3_1   HST3_2   HST3_3  ...   HST3_99  HST3_100   HST3_101
%   ...
%  1.98 | HST198_1 HST198_2 HST198_3 ...  HST198_99 HST198_100 HST198_101
%  1.99 | HST199_1 HST199_2 HST199_3 ...  HST199_99 HST199_100 HST199_101
%   2.0 | HST200_1 HST200_2 HST200_3 ...  HST200_99 HST200_100 HST200_101


    % Name of future GIF file (needed if the section "Prepare GIF file" is uncommented)
    filename='unloading.gif';
    % GIF shows the visualisation of alorithm operation
    
    % Set value for which HST will be decreased
    delta=1;
    
    % set a count for unloading iteration
    n=0;
    
    % Ambient temperature range
    Temperature=-50:1:50;
    
    % Prepare HST hour
    tt=60; % time step
    
    if r_limit==1380 % if hour == 23 
        
        % Set the start and finish of given hour
        start=r_limit;
        finish=r_limit+60;
        
        % Find the HST and AMB at given hour 
        HST_hour=max(HST(start:finish))';
        AMB_hour=mode(AMB(start:finish))';
        
    else % for hours <23
        
        % For each hour of interval t+
        for l=(r_limit+60)/tt:1440/tt-1 % for interval t+
            if l==(r_limit+60)/tt % equal to the beginning of t+
                
                start(1)=(r_limit+60)/tt*tt+1; % beginning of interval
                finish(1)=(r_limit+60)/tt*tt+60; % end of interval
                
                % find max HST and most frequent AMB at given hour
                HST_hour(1)=max(HST(start(1):finish(1)))'; 
                AMB_hour(1)=mode(AMB(start(1):finish(1)))';
                
            else % for not-beginning of interval t+
                
                % Find the beginning and the end of hour
                start(l-(r_limit+60)/tt+1)=start(end)+tt;
                finish(l-(r_limit+60)/tt+1)= start(l-(r_limit+60)/tt+1)+59;
                
                % find max HST and most frequent AMB at given hour
                HST_hour(l-(r_limit+60)/tt+1)=max(HST(start(l-(r_limit+60)/tt+1):finish(l-(r_limit+60)/tt+1)))';
                AMB_hour(l-(r_limit+60)/tt+1)=mode(AMB(start(l-(r_limit+60)/tt+1):finish(l-(r_limit+60)/tt+1)))';
            
            end % end of "if l==(r_limit+60)/tt"
            
        end % end of "for l=(r_limit+60)/tt:1440/tt-1" 
        
        % Sort start and finish values
        start=start';
        finish=finish';
        
        % Sort HST and AMB values
        HST_hour=HST_hour';
        AMB_hour= AMB_hour';
        
        % Set periods
        period=[start finish];
    end
    
    % Create an array with extracted HST AMB and corrsponding period
    a=[HST_hour AMB_hour start finish];
    
    % Round the array
    a=round(a);
    
    % Create a b vector by sorting rows from the highest HST to the lowest
    % one
    b=-sortrows(-a,1);
    
    %% Unloading algorithm
    while ~(AEQ<=1 && max(HST)<140) % while thermal constraints are not met
        
        % Chcking if the highest HST happens few times (ind)
        [ind,~]=find(b(:,1)==b(1,1));
        
        if length(ind)==1 %  the highest HST is not repeated
            % Robust unloading of load profile
            n=n+1;
            
            % Reduce the highest HST (b(1,1) by the delta value 
            b(1,1)=b(1,1)-delta;
            
            % find index (j) of the interval end  for this highest HST 
            j=b(1,4);
            
            % find column index of the closest AMB in reference table 
            [~,t]=min(abs(Temperature-AMB(j))); 
            
            % Until Temperature(t)<AMB(j), increase the index t 
            while Temperature(t)<AMB(j)
                t=t+1;
            end
            
            % find index q which shows the closest HST in look-up table (Temp) to the highest HST (b(1,1) 
            [~, q]= min(abs(Temp(:,t+1)-b(1,1))); 
            
            % Until Temp(q,t+1)>b(1,1), reduce the index q 
            while Temp(q,t+1)>b(1,1)
                q=q-1;
            end
            
            % Assigning the value from look-up table to exisiting load profile
            if tt==1
                PUL(j)=Temp(q,1); % assign of new PUL to exisiting load profile
            else % for tt =/= 1 
                
                % While PUL(b(1,3):b(1,4))<=Temp(q,1) is below loading in
                % Temp, reduce the q index
                while PUL(b(1,3):b(1,4))<=Temp(q,1)
                    q=q-1;
                end
                
                % PUL(start:finish)=assigned vlaue
                PUL(b(1,3):b(1,4))=Temp(q,1); 
            end
            
            % Calculate the thermal regime for corrected load profile
            [HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);
            
        else % there are few highest HST
            
            % Take the HST with the maximum ambient temperature 
            [high_amb_indx,~]=find(b(ind,2)==max(b(ind,2)));
            
            % If there is only one HST with maximum ambient temperature
            if length(high_amb_indx)==1
                
                % Count the unloading 
                n=n+1;
                
                % Reduce the hisghest HST for the delta value 
                b(high_amb_indx,1)=b(high_amb_indx,1)-delta;
                
                % find index of the end of hour where reduction was done 
                j=b(high_amb_indx,4);
                
                % find column index of the closest AMB in reference table
                [~,t]=min(abs(Temperature-AMB(j))); 
                
                % Reduce the t index until Temperature(t) in look-up table becomes greater than AMB(j)
                while Temperature(t)<AMB(j)
                    t=t+1;
                end
                
                % find index q which shows the closest HST in look-up table (Temp) to the highest HST (b(high_amb_indx,1) 
                [~, q]= min(abs(Temp(:,t+1)-b(high_amb_indx,1))); 
                
                % Reduce q index (looking for the loading value) until the HST Temp(q,t+1)in look-up table
                % becomes greater than b(high_amb_indx,1)
                while Temp(q,t+1)>b(high_amb_indx,1)
                    q=q-1;
                end
                
                % assign of new PUL to exisiting load profile
                if tt==1
                    PUL(j)=Temp(q,1); 
                else
                    while PUL(b(high_amb_indx,3):b(high_amb_indx,4))<=Temp(q,1)
                        q=q-1;
                    end
                    
                    % PUL(start:finish)=assigned vlaue
                    PUL(b(high_amb_indx,3):b(high_amb_indx,4))=Temp(q,1); 
                end
                
                % Calculate the thermal regime for corrected load profile
                [HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);
                
            else % few equal ambient
                
                % Count the unloading 
                n=n+1;
                
                % Reduce HST corresponding to the first equal AMB i.e. high_amb_indx(1)
                b(high_amb_indx(1),1)=b(high_amb_indx(1),1)-delta;
                
                % find index of the interval end 
                j=b(high_amb_indx(1),4);
                
                % find column index of the closest AMB in reference table
                [~,t]=min(abs(Temperature-AMB(j))); 
                
                % Increase the t index until temperature in vector becomes 
                % greater than AMB 
                while Temperature(t)<AMB(j)
                    t=t+1;
                end
                
                % find index q of HST
                [~, q]= min(abs(Temp(:,t+1)-b(high_amb_indx(1),1))); 
                
                % Reduce q index (looking for the loading value) until the HST Temp(q,t+1)in look-up table
                % becomes greater than b(high_amb_indx(1),1)
                if Temp(q,t+1)>b(high_amb_indx(1),1)
                    q=q-1;
                end
                
                % assign of new PUL to exisiting load profile
                if tt==1
                    PUL(j)=Temp(q,1); % assign of new PUL to exisiting load profile
                else
                    while PUL(b(high_amb_indx(1),3):b(high_amb_indx(1),4))<=Temp(q,1)
                        q=q-1;
                    end
                    PUL(b(high_amb_indx(1),3):b(high_amb_indx(1),4))=Temp(q,1); % PUL(start:finish)=assigned vlaue
                end
                
                % Calculate the thermal regime for corrected load profile
                [HST,~,AEQ,~,~,~,~]=IEEE_thermal_model(AMB,PUL,TIM);
            end
        end
        
        % Resort HST values (needed after reduction of HST)
        [b]=finding_b(HST,AMB);
        %% Prepare GIF file
        %         % Capture the plot as an image
        %         h=gcf;
        %         frame=getframe(h);
        %         im = frame2im(frame);
        %         [imind,cm] = rgb2ind(im,256);
        %         %annotation('textbox','String',{'Loading ,',['with AEQ =' num2str(AEQ)]});
        %         % Write to the GIF File
        %         if n == 1
        %             imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
        %         else
        %             imwrite(imind,cm,filename,'gif','WriteMode','append');
        %         end
    end % end of while cycle
    
else % max(HST)<=140 || AEQ<=1
    disp('This thermal regime is acceptable. Try Algorithm 3 to maximize energy transfer');

end % end for "if max(HST)>140 || AEQ>1"

end % end of function

