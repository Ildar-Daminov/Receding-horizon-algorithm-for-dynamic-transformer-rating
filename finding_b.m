function [b]=finding_b(HST,AMB)
%% Purpose
% This function takes HST and AMB and sorts them in descending order (by HST).

% Input:
% HST - Hot spot temperature profile, degC 
% AMB - Ambien temperature profile, degC

% Output:
% b - array sorted by HST a=[HST_hour AMB_hour start finish];

% Contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Prepare HST hour, AMB_hour, start, finish
tt=60; % time step
for hour=1:1440/tt % for each hour
    if hour==1
        start(hour)=1; % beginning of interval
        finish(hour)=hour*tt; % end of interval
        HST_hour(hour)=max(HST(start(hour):finish(hour)))'; % find max HST at interval
        AMB_hour(hour)=mode(AMB(start(hour):finish(hour)))'; % find the most frequent AMB
    else
        start(hour)=start(end)+tt;
        finish(hour)=hour*tt;
        HST_hour(hour)=max(HST(start(hour):finish(hour)))';
        AMB_hour(hour)=mode(AMB(start(hour):finish(hour)))';
    end
end
% Sort start and finish values
start=start';
finish=finish';

% Sort HST and AMB values
HST_hour=HST_hour';
AMB_hour= AMB_hour';

% Array with HST and period
a=[HST_hour AMB_hour start finish];
a=round(a,1);
b=-sortrows(-a,1);

end % end of function