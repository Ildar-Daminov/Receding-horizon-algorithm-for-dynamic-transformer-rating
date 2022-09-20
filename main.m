clc
clear all
close all
%% Goal of the script
% This scripts reproduces the Figures from the conference paper [1]:
% Ildar Daminov, Anton Prokhorov, Raphaël Caire, Marie-Cécile
% Alvarez-Hérault. Receding horizon algorithm for dynamic transformer
% rating and its application for real-time economic dispatch.
% IEEE PowerTech 2019, Jun 2019, Milan, Italy.

% If you use this code, please cite a conference paper [1]

% Contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov

% Other articles on this topic are available:
% https://www.researchgate.net/profile/Ildar-Daminov-2

% Note that the figures generated in this script and those given in the
% article may differ as latter had been additionally redrawn
% for a publication.

% Each section (Plotting the Figure X) is independent from each other. So
% you may launch the entire script (using the button "Run") to get all
% figures at one moment or you may launch a special section (using the
% button "Run Section" at the top)to get a specific figure

% Execution time of entire script ≈ 1 minute

tic

%% Validation of IEEE thermal model used in this paper

%  This part was not included in [1] but it is neccesary to validate the
% IEEE_thermal_model.m for further research

% Load data from Annex G IEEE C57.91-2011 (page 86)
load('data_IEEE_AnnexG.mat')

[HST,TOT,AEQ,Current_ageing,ASUM,Ageing_rate,Total_losses_instant]=...
    IEEE_thermal_model(AMB,PUL,TIM);

% Define the time vectors
TIM_minutes=(1:1440)';
t_start = datetime('today');
t_hour=t_start+hours(TIM_IEEE(2:end));
t_minute=t_start+minutes(TIM_minutes(:));

% Find the indexes where t_hours = t_minute
[~,idx] = ismember(t_minute,t_hour);
idx=find(idx>0);

% Find the errors between reference and calculated temperature
Error_HST=HST(idx)-HST_IEEE(2:end); %°C
Error_TOT=TOT(idx)-TOT_IEEE(2:end); %°C
Error_AEQ=AEQ-1.509297; % pu

% Analyze errors of our matlab model IEEE vs reference data
Mean_error=[mean(Error_HST) mean(Error_TOT) Error_AEQ] %°C
Max_error=[max(Error_HST) max(Error_TOT) Error_AEQ] %°C

% As you may see, the errors are neglible.  Therefore, it may be concluded
% that the IEEE_thermal_model.m is validated against the reference model from
% IEEE C57.91 2011
%% Plotting the Figure 1
% Figure name:  General scheme of receding horizon control

% Figure 1 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 2
% Figure name:  RHC, by manipulating the inputs, maintains the output close
% to reference

% Figure 2 in the article [1] was ploted without using MATLAB
%% Plotting the Figure 3
% Figure name:  Inputs and outputs of transformer thermal model

% Figure 3 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 4
% Figure name: Two-machine power system with transformer T1, limiting the
% output of cheap generator

% Figure 4 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 4
% Figure name: Two-machine power system with transformer T1, limiting the
% output of cheap generator

% Figure 4 in the article [1] was ploted without using MATLAB

%% Plotting the Figure 5
% Figure name: Forecasted load ambient temperature profiles of operating day

clc;clear all % clear a command window and a workspace

% Load data
load('initial_data.mat')

% Create figure
figure1 = figure('WindowState','maximized');

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create a time vector
t1 = datetime(2019,1,1,0,0,0,'Format','HH:m');
t2 = datetime(2019,1,1,23,59,0,'Format','HH:m');
t = [t1:minutes(1):t2]';

% Create plot
plot(t,PUL,'DisplayName','Load','Parent',axes1,'LineWidth',3,...
    'LineStyle','-.','Color',[0 0 0]);

% Create ylabel
ylabel('Transformer loading,pu');

% Create xlabel
xlabel('Time,min');

% Preserve the Y-limits of the axes
ylim(axes1,[0.5 1.5]);
yticks(axes1,0.5:0.1:1.5);

box(axes1,'on');
hold(axes1,'off');

% Set the remaining axes properties
set(axes1,'FontSize',20,'YColor',[0 0 0]);

yyaxis right

% Create plot
plot(t,AMB,'DisplayName','Ambient temperature','LineWidth',3,...
    'LineStyle','-.');

% Create ylabel
ylabel('Ambient temperature,°C');

legend('Loading','Ambient temperature')

%% Plotting the Figure 6
% Figure name: Forecasted load ambient temperature profiles of operating day

clc;clear all % clear a command window and a workspace

% Load data
load('initial_data.mat')

% Create figure
figure1 = figure('WindowState','maximized');

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create a time vector
t1 = datetime(2019,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,1,1,23,59,0,'Format','HH:SS');
t = (t1:minutes(1):t2)';

% Create plot
plot(t,PUL,'DisplayName','Load','Parent',axes1,'LineWidth',3,...
    'LineStyle','-.','Color',[0 0 0]);

% Create ylabel
ylabel('Transformer loading,pu');

% Create xlabel
xlabel('Time,min');

% Preserve the Y-limits of the axes
ylim(axes1,[0.5 1.5]);
yticks(axes1,0.5:0.1:1.5);

box(axes1,'on');
hold(axes1,'off');

% Set the remaining axes properties
set(axes1,'FontSize',20,'YColor',[0 0 0]);

yyaxis right

% Create plot
plot(t,AMB,'DisplayName','Ambient temperature','LineWidth',3,...
    'LineStyle','-.');

% Create ylabel
ylabel('Ambient temperature,°C');

yyaxis left
hold on

% Define the vector
Static_limit=linspace(1,1,length(PUL))';

% Create plot
plot(t,Static_limit,'DisplayName','Static limit','LineWidth',3,...
    'LineStyle','-','Color','b');

% Create the legend
legend('Loading','Static limit ','Ambient temperature')

%% Plotting the Figure 7
% Figure name: Static limit, corrected to ambient temperature or reference DTR

clc;clear all % clear a command window and a workspace

% Load data
load('initial_data.mat')

% Create figure
figure1 = figure('WindowState','maximized');

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');

% Create a time vector
t1 = datetime(2019,1,1,0,0,0,'Format','HH:SS');
t2 = datetime(2019,1,1,23,59,0,'Format','HH:SS');
t = (t1:minutes(1):t2)';

% Create plot
plot(t,PUL,'DisplayName','Load','Parent',axes1,'LineWidth',3,...
    'LineStyle','-.','Color',[0 0 0]);

% Create ylabel
ylabel('Transformer loading,pu');

% Create xlabel
xlabel('Time,min');

% Preserve the Y-limits of the axes
ylim(axes1,[0.5 1.5]);
yticks(axes1,0.5:0.1:1.5);

box(axes1,'on');
hold(axes1,'off');

% Set the remaining axes properties
set(axes1,'FontSize',20,'YColor',[0 0 0]);

yyaxis right

% Create plot
plot(t,AMB,'DisplayName','Ambient temperature','LineWidth',3,...
    'LineStyle','-.');

% Create ylabel
ylabel('Ambient temperature,°C');

yyaxis left
hold on

% Define the vector of reference DTR according to IEEE standard Table 3
% (page 12 in IEEE C57.91-2011)
delta=AMB-30;
for i=1:length(delta)
    
    if delta(i)>0
        reference_DTR(i)=1-abs(delta(i))*0.01;
    elseif delta(i)<0
        reference_DTR(i)=1+abs(delta(i))*0.0075;
    elseif delta(i)==0
        reference_DTR(i)=1;
    end % end of if condition
    
end % end of for cycle

%  NB: this is an approximate method from IEEE standard. The approximate
% method  may lead to underutilization of insulation resource or
% temperature limit. Hence,it may be better to use more precise and
% sophisticated algorithms

% Create plot
plot(t,reference_DTR,'DisplayName','Reference DTR','LineWidth',3,...
    'LineStyle','-','Color','b');

% Create the legend
legend('Loading','Reference DTR ','Ambient temperature')


%% Plotting the Figure 8 and Figure 9
% Figure 8 name: The comparison of reference DTR and redefined DTR at 7th hour
% Figure 9 name: Actually transmitted load profile (blue) by the end of
% operating day and the reference DTR with load forecast

clc;clear all % clear a command window and a workspace

% Load data: daily load: PUL, dail ambient temperature: AMB and minutes:TIM
load('initial_data.mat')

PUL_init=PUL;

% Create a datetime vector
t1 = datetime(2017,1,1,0,0,0,'Format','HH:mm');
t2 = datetime(2017,1,1,23,59,0,'Format','HH:mm');
time = (t1:minutes(1):t2)';

% Define the reference DTR according to IEEE standard Table 3
% (page 12 in IEEE C57.91-2011)
delta=AMB-30;
for i=1:length(delta)
    if delta(i)>0
        DTR_init(i,1)=1-abs(delta(i))*0.01;
    elseif delta(i,1)<0
        DTR_init(i,1)=1+abs(delta(i))*0.0075;
    elseif delta(i,1)==0
        DTR_init(i,1)=1;
    end % end of if condition
    
end % end of for cycle

%  NB: this is an approximate method given in IEEE standard. The approximate
% method  may lead to underutilization of insulation resource or
% temperature limit. Hence,it may be better to use more precise and
% sophisticated algorithms

% Save DTR
DTR_old=DTR_init;
DTR_hist{1,1}=DTR_init;

% Create zero vectors
PU_actual_load=zeros(1440,1);   % actual load of consumers,pu
AMB_actual=zeros(1440,1);       % actual ambient temperature,degC
PUL_loading=zeros(1440,1);      % actual transformer loading,pu
PUL_loading_hist=zeros(1440,1); % historical transformer loading,pu

for hour=1:24 % one day - 1h:24h
    if hour==24 % if the last hour
        % find right limit in minutes for corresponding hour
        r_limit=hour*60;
        
        % find left limit in minutes for corresponding hour
        l_limit=r_limit-59;
        
        % find range  in minutes for corresponding hour
        TIM_hour=l_limit:r_limit;
        
        % Set actual (random) PUL and AMB with sigma=0.02
        PUL(TIM_hour) = normrnd(PUL(l_limit,1),0.02);
        AMB(TIM_hour) = normrnd(AMB(l_limit,1),0.02);
        
        % Save the actual load (not transformer loading in two-machine system)
        PU_actual_load(TIM_hour)=PUL(TIM_hour);
        AMB_actual(TIM_hour)=AMB(TIM_hour);
        
        % Update the transformer loading (PUL_loading) depending on DTR
        if PU_actual_load(l_limit:r_limit)<DTR_old(l_limit:r_limit) % if loading below the limit
            
            % Save the transformer loading
            PUL_loading(l_limit:r_limit)=PU_actual_load(l_limit:r_limit);
            
        else % if loading is higher than or equal to the limit
            
            % Save the loading equal to previous limit
            PUL_loading(l_limit:r_limit)=DTR_old(l_limit:r_limit);
            
        end % end of "if"
        
        % Save as historical loading of transformer
        PUL_loading_hist(l_limit:r_limit)=PUL_loading(l_limit:r_limit);
        
    else % all hours except 24
        
        % find right limit in minutes for corresponding hour
        r_limit=hour*60;
        
        % find left limit in minutes for corresponding hour
        l_limit=r_limit-59;
        
        % find range  in minutes for corresponding hour
        TIM_hour=l_limit:r_limit;
        
        % Simulate the actual PUL and AMB
        PUL(TIM_hour) = normrnd(PUL(l_limit,1),0.02);
        AMB(TIM_hour) = normrnd(AMB(l_limit,1),0.02);
        
        % Save actual load and ambient temperature
        PU_actual_load(TIM_hour)=PUL(TIM_hour);
        AMB_actual(TIM_hour)=AMB(TIM_hour);

        if hour==1 % if first hour
            close all
            
            % Open the template figure
            h=openfig('empty_figure_template.fig');
            
            % Plot the past loadings
            plot(time(1:r_limit),PU_actual_load(1:r_limit),'-','MarkerSize',3,'LineWidth',3,'Color',[0 0 0]);
            
            % Plot the initially-forecasted load
            plot(time(1:end),PUL(1:end),'-.','MarkerSize',3,'LineWidth',3,'Color',[0 0 0]);
            
            %  Plot the vertical line = the present moment
            vertical_line = vline(time(r_limit),'g','moment');
            
            % Plot DTR
            plot(time(1:end),DTR_old(1:end),'-','MarkerSize',3,'LineWidth',3,'Color',[0 0 1]);
            plot(time,DTR_init,'-.','MarkerSize',3,'LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
            
            % Save the figure
            filename=['fact',num2str(hour)];
            savefig(filename);
            
        else % all hours except hour 1
            
            % Open the previous figure
            % last_figure=['fact',num2str(hour-1),'.fig'];
            f=openfig('empty_figure_template.fig');

            % Plot the previous loading
            plot(time(1:r_limit),PU_actual_load(1:r_limit),'-','MarkerSize',3,'LineWidth',3,'Color',[0 0 0])
            
            % Plot the initially-forecasted load
            plot(time(1:end),PUL(1:end),'-.','MarkerSize',3,'LineWidth',3,'Color',[0 0 0]);
            
            % plot the vertical line
            vertical_line = vline(time(r_limit),'g','moment');
            
            % Plot DTR
            plot(time(r_limit+1:end),DTR_old(r_limit+1:end),'-','MarkerSize',3,'LineWidth',3,'Color',[0 0 1]);
            plot(time,DTR_init,'-.','MarkerSize',3,'LineWidth',3,'Color',[0.4660 0.6740 0.1880]);
            
        end % if hour==1 else
        
        % Checking the loading relative to the limit
        if PU_actual_load(l_limit:r_limit)<DTR_old(l_limit:r_limit)
            
            % The transformer loading is equal to the actual load
            PUL_loading(l_limit:r_limit)=PU_actual_load(l_limit:r_limit);
            
        else % if the loading is greater than limit
            
            % Loading is equal to the limit
            PUL_loading(l_limit:r_limit)=DTR_old(l_limit:r_limit);
            
        end % end of "if"
        
        % Save as the historical loading
        PUL_loading_hist(l_limit:r_limit)=PUL_loading(l_limit:r_limit);
        
        % Plot historical loading of tranformer
        plot(time(1:r_limit),PUL_loading_hist(1:r_limit),'-','MarkerSize',3,'LineWidth',1,'Color',[0 1 1])
        legend('Actual load','Initial load forecast','Present moment','DTR+RHC','Reference DTR','Actual transformer loading')
        
        % Save the figure
        filename=['fact',num2str(hour)];
        savefig(filename);
        close all
        
        % Define DTR at moment of t for interval t+
        [DTR,~,~]=Finding_DTR_with_RHC(PUL,AMB,TIM,r_limit,PUL_loading_hist);
        DTR_old=DTR;
        
        % Save as the historical value
        DTR_hist{end+1,1}=DTR;
        
    end % end of "if hour==2"
    
end % end of for cycle

% Postprocessing
% G1 and G2 generation
G1_generation=PUL_loading_hist;
G2_generation_index=find(PU_actual_load>G1_generation);G2_generation=zeros(1440,1);
G2_generation(G2_generation_index)=PU_actual_load(G2_generation_index)-G1_generation(G2_generation_index);

% Check: it should be zero if not then there is a mistake
generation_check=sum(PU_actual_load-(G1_generation+G2_generation));
if ~(generation_check==0)
    error ('checking is failed')
else % if no error
    % Calculate the energy of Generator 1 and Generator 2
    Energy_G1_dynamic=trapz(G1_generation);
    Energy_G2_dynamic=trapz(G2_generation);
end % end of if ~(generation_check==0)


close all
% DTR at t=00:00

% Alternative scenario with reference DTR
index_corr_AMB=find(DTR_init<PU_actual_load);
PUL_cor=PU_actual_load;
PUL_cor(index_corr_AMB)=DTR_init(index_corr_AMB);

% Generator schedule
G1_sl_amb=PUL_cor;
G2_sl_amb_index=find(PU_actual_load>G1_sl_amb);
G2_sl_amb=zeros(1440,1);
G2_sl_amb(G2_sl_amb_index)=PU_actual_load(G2_sl_amb_index)-PUL_cor(G2_sl_amb_index);

% Check: it should be zero if not then there is a mistake
static_AMB_check=sum(PU_actual_load-(G1_sl_amb+G2_sl_amb));
if ~(static_AMB_check==0)
    error ('checking is failed')
else
    Energy_G2_sl_amb=trapz(G2_sl_amb);
    Energy_G1_sl_amb=trapz(G1_sl_amb);
end

G1_cost=6; % Tariff, $/MWh for 1 generator
G2_cost=30; % Tariff, $/MWh for 2 generator

% Costs for each generator (for 2 scenarios):

% initial DTR
cost_G1_sl_amb=Energy_G1_sl_amb*G1_cost; 
cost_G2_sl_amb=Energy_G2_sl_amb*G2_cost;

%  DTR+ Receding horizon control
cost_G1_dynamic=Energy_G1_dynamic*G1_cost;
cost_G2_dynamic=Energy_G2_dynamic*G2_cost;

% Total cost of energy production
Total_cost_static_amb=cost_G1_sl_amb+cost_G2_sl_amb; % Reference DTR
Total_cost_dynamic=cost_G1_dynamic+cost_G2_dynamic; % DTR+RHC

close all


% Create figure 9 (per conference paper) 
openfig('empty_figure_template.fig');

% Define a static limit
Static_limit=linspace(1,1,length(PUL))';

% Create multiple lines using matrix input to plot
plot1 = plot(time,[PUL_loading_hist,PU_actual_load,PUL_init,DTR_init,Static_limit]...
    ,'LineWidth',3,'LineStyle','--');
set(plot1(1),'DisplayName','Trasnmitted power DTR+RHC','LineWidth',8,...
    'LineStyle','-');
set(plot1(2),'DisplayName','Actual load','Color',[1 0 0],'LineStyle','-');
set(plot1(3),'DisplayName','Forecasted load','LineWidth',2,'Color',[0 0 0]);
set(plot1(4),'DisplayName','Forecasted static limit +AMB');
set(plot1(5),'DisplayName','Static limit');

% Create ylabel
ylabel('Load, pu');

% Create xlabel
xlabel('Time,min');

% Show legend 
legend

% Open Figure 8 (per conference paper) 
openfig('fact7.fig')

%% checking the execution time of the entire script
Elapsed_time=toc; 