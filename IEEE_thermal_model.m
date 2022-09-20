function [HST,TOT,AEQ,Current_ageing,ASUM,Ageing_rate,Total_losses_instant]=IEEE_thermal_model(AMB,PUL,TIM)
%% ************************************************************************
% Purpose: This function represents the thermal model of power transformer
% as given in Annex G of IEEE loading guide C.57.91 

%% ************************************************************************
%% Information on code version
% V1.1 17/09/2022 prepared by Ildar DAMINOV based on IEEE C.57.91 Annex G

% Version history
% v1.0 - this version corresponds to IEEE C.57.91 Annex G
% v1.1 - this version is a same as v.1.0 but also includes the 
%        'Total_losses_instant' representing the profile of total losses 
%        inside of transformer. This parameter is validated partially for 
%        load conditons mentioned in IEEE C.57.91 (28000 kVA, page 85)
         

% The code was done for the paper (may be used for citation):
% Ildar Daminov, Anton Prokhorov, Raphael Caire, Marie-Cécile Alvarez-Herault, 
% "Receding horizon control application for dynamic transformer ratings in 
% a real-time economic dispatch," IEEE PES Powertech, Milan, Italy, 2019,
% DOI: https://doi.org/10.1109/PTC.2019.8810511


% Input of IEEE_thermal_model.m:
% AMB   -  ambient temperature profile  in degC; e.g.[24x1] or [1440x1]
% PUL   -  load  profile  in per units; e.g.[24x1] or [1440x1]
% TIM   -  time values in hours

% Output of IEEE_thermal_model.m:
% HST - hot spot temperature profile, degC
% TOT - top oil temperature profile, degC
% AEQ - ageing equivalent for given period, pu
% Current_ageing - a profile of accumulated ageing at given time moment, pu  
% ASUM - equivalent ageing, hours 
% Ageing_rate - ageing_rate at given moment of time, pu 
% Total_losses_instant - profile of total losses at given moment 

% Author contacts: 
%       Linkedin - https://www.linkedin.com/in/ildar-daminov/
%       Researchgate - https://www.researchgate.net/profile/Ildar-Daminov-2
%       GitHub - https://github.com/Ildar-Daminov
%% Input data processing
% Ensuring the column vector
if (size(PUL,2) > size(PUL,1)) % If number of columns > number of rows
    PUL = PUL';
end
if (size(AMB,2) > size(AMB,1)) % If number of columns > number of rows
    AMB = AMB';
end
if (size(TIM,2) > size(TIM,1)) % If number of columns > number of rows
    TIM = TIM';
end
%% Transformer data from Annex G
XKVA1=28000;    % KVA base for losses in input data
TKVA1=75;       % Temperature base for losses at this KVA, degC
PW=51690;       % I2R losses, W
PE=0;           % Winding eddy losses, W
PS=21078;       % Stray losses, W
PC=36986;       % Core loss, W
XKVA2=52267;    % One per unit kVA base for load cycle
THKVA2=65;      % Rated ave. winding rise over ambient at kVA base of load cycle, degC
THEWA=63;       % Tested or rated average rise over ambient,degC
THEHSA=80;      % Winding hottest-spot rise over ambient, degC
THETOR=55;      % Top fluid rise over ambient at rated load, C
THEBOR=25;      % Bottom fluid rise over ambient at rated load, degC
TAR=30;         % Rated ambient at kVA base for load cycle, degC
MC=2;           % Winding conductor 1=aluminum, 2=copper
PUELHS=0;       % Per unit eddy loss at winding hot-spot location (per unit of I2R loss)
TAUW=5;         % Winding time constant, minutes
HHS=1;          % Per unit of winding height to hot spot location
WCC=75600;      % Weight of core and coils, lb
WTANK=31400;    % Weight of tank and fittings, lb
MF=1;           % Type of fluid, 1=oil, 2=silicone, 3=HTHC
GFLUID=4910;    % Gallons of fluid
MCORE=0;        % Overexcitation occurs, 0=no, 1=yes
TIMCOR=0;       % Time when overexcitation occurs,h
PCOE=36986;     % Core loss during overexcitation, W
%LCAS=1;         % Loading case 1(Load cycle repeats and initial Temperatures are unknown) or 2 (Temperatures are inputs) HERE IT IS FOR CASE1
MA=2;           % Cooling code 1=ONAN, 2=ONAF, 3=non directed OFAF, 4=directed ODAF
MPR1=0;         % Print temperature 1=yes 2=no
DTP=60;         % Time increment for printing, minutes
JJ=length(TIM); % Number of points on load cycle
resolution=2;   % Choosing time resolutin of output: 1: hour 2: minute

%load data_IEEE_thermal_model;
%TIMP=zeros(KK,1);
%% Additional input data calculation
if JJ==1440
    % do nothing
    TIM_min=1:TIM(end);
    
else % ~(JJ==1440)
    for i=1:JJ
        % Converting hours to minutes
        TIM(i)=60.*TIM(i);
    end
    TIM_min=1:TIM(end);
end

PT=PW+PE+PS+PC; % Total losses at xkva1 (28 000 kVA)
if MPR1==1 % if printing is permitted
    fprintf('KVA base for loss input data %d \n',XKVA1)
    fprintf('Temperature base for loss input data %d degC \n',TKVA1)
    fprintf('Winding I square R %d watts \n',PW)
    fprintf('Winding eddy loss %d watts \n',PE)
    fprintf('Stray losses %d watts \n',PS)
    fprintf('Core losses %d watts \n',PC)
    fprintf('Total losses %d watts \n',PT)
end
if MC==1 % Winding conductor choice 1-Al; 2-Cu;
    if MPR1==1 % if printing is permitted
        fprintf('Winding conductor is aluminium \n')
    end
    TK=225;     % Temperature factor for resistance correction, degC
    CPW=6.798;  % Specific heat of winding material W-min/lb degC
else % if winding conductor is made of copper;
    if MPR1==1 % if printing is permitted
        fprintf('Winding conductor is copper \n')
    end
    TK=234.5; % Temperature factor for resistance correction, degC
    CPW=2.91; % Specific heat of winding material W-min/lb degC
end
if MPR1==1 % if printing is permitted
    fprintf('Per unit eddy loss at hot spot location %d \n', PUELHS)
    fprintf('Winding time constant %d minutes \n', TAUW)
    fprintf('Per unit winding height to hot spot %d \n', HHS)
    fprintf('Weight of core & coils %d \n', WCC)
    fprintf('Weight of tank and fittings %d pounds \n', WTANK)
    fprintf('Gallons of fluid %d \n', GFLUID)
end

if MF==1            % If type of fluid is 1=oil
    if MPR1==1      % if printing is permitted
        fprintf('Cooling fluid is transformer oil\n')
    end
    CPF=13.92;      % Specific heat of fluid, W-min/lb degC
    RHOF=0.031621;  % Fluid density, lb/in3
    C=2797.3;       % Constant in viscosity equation
    B=0.0013473;    % Constant in viscosity equation
else if MF==2           % If type of fluid is 2=silicon
        if MPR1==1 % if printing is permitted
            fprintf('Cooling fluid is silicon\n')
        end
        CPF=11.49;      % Specific heat of fluid, W-min/lb degC
        RHOF=0.0347;    % Fluid density, lb/in3
        C=1782.3;       % Constant in viscosity equation
        B=0.12127;      % Constant in viscosity equation
    else if MF==3         % If type of fluid is 3=HTHC
            if MPR1==1 % if printing is permitted
                fprintf('Cooling fluid is HTHC\n')
            end
            CPF=14.55;    % Specific heat of fluid, W-min/lb degC
            RHOF=0.03178; % Fluid density, lb/in3
            C=4434.7;     % Constant in viscosity equation
            B=7.343e-05;  % Constant in viscosity equation
        end
    end
end
if MA==1            % if Cooling is 1=ONAN,
    X=0.5;          % Exponent for duct oil rise over bottom oil
    YN=0.8;         % Exponent of average fluid rise with heat loss
    Z=0.5;          % Exponent for top to bottom fluid temperature difference
    THEDOR=THETOR;  % Temperature rise of fluid at top of duct over ambient at rated load
else if MA==2  % if Cooling is 2=ONAF
        X=0.5;
        YN=0.9;
        Z=0.5;
        THEDOR=THETOR;
    else if MA==3 % If Cooling is  3=non directed OFAF
            X=0.5;
            YN=0.9;
            Z=1;
            THEDOR=THEWA;
        else if MA==4 % if cooling is  4=directed ODAF
                X=1;
                YN=1;
                Z=1;
                THEDOR=THETOR;
            end
        end
    end
end
TWR=TAR+THKVA2; % Rated Average winding temperature at rated load, °C
TWRT=TAR+THEWA; % Average winding temperature at rated load tested, °C
THSR=TAR+THEHSA; % Winding hottest-spot temperature at rated load, °C
TTOR=TAR+THETOR; % Top fluid temperature in tank and radiator at rated load, °C
TBOR=TAR+THEBOR; % Bottom fluid temperature at rated load, °C
TTDOR=THEDOR+TAR; % Fluid temperature at top of duct at rated load, °C
TWOR=(HHS*(TTDOR-TBOR))+TBOR; % Temperature of oil adjacent to winding hot spot at rated load, °C
TDAOR=(TTDOR+TBOR)/2;% Average temperature of fluid in cooling ducts at rated load, °C
TFAVER=(TTOR+TBOR)/2; % Average fluid temperature in tank and radiator at rated load, °C
XK2=(XKVA2/XKVA1)^2;% Ratio between rated power and power used for losses measurement
TK2=(TK+TWR)/(TK+TKVA1);% Temperature factor for resistance correction, °C
PW=XK2*PW*TK2; % full load I2R losses at 75 degC,W
PE=XK2*PE/TK2; % full load eddy losses at 75 degC,W
PS=XK2*PS/TK2; % Stray losses at rated load, W
PT=PW+PE+PS+PC;% Total losses at rated load, W
if (PE/PW)>PUELHS %If ratio of eddy to I2R losses is greater than eddy loss at winding hot spot location
    PUELHS=PE/PW; % Eddy loss at winding hot spot location, per unit of I2R loss
end
TKHS=(THSR+TK)/(TWR+TK); % Correction factor for correction of losses to hot-spot temperature
PWHS=TKHS*PW; % Winding I2R loss at rated load and rated hot-spot temperature, W
PEHS=PUELHS*PWHS;% Eddy loss of windings at rated load and rated winding hot-spot temperature,W

% Printing results
if MPR1==1 % if printing is permitted
    fprintf('At this KVA losses at %d degC are as follows \n', TWR)
    fprintf('Winding I square R %d watts \n',PW)
    fprintf('Winding eddy loss %d watts \n',PE)
    fprintf('Stray losses %d watts \n',PS)
    fprintf('Core losses %d watts \n',PC)
    fprintf('Total losses %d watts \n',PT)
    fprintf('At this KVA input data for temperatures as follows: \n')
    fprintf('Rated average winding rise over ambient %d degC  \n',THKVA2)
    fprintf('Tested average winding rise over ambient %d degC  \n',THEWA)
    fprintf('Hottest spot rise over ambient %d degC  \n',THEHSA)
    fprintf('Top fluid rise over ambient %d degC  \n',THETOR)
    fprintf('Bottom fluid rise over ambient %d degC  \n',THEBOR)
    fprintf('Rated ambient temperature %d degC  \n',TAR)
end
DT=0.5; % Time step used to calculate thermal mode, min
% Note that  there is no problem if DT is different than time step of
% load profile. DT is needed for internal calculations

% For the computer program, a time increment Dt = 0.5 min is used, and
% the following criteria used for stability andaccuracy for all four cooling modes:
DT= TAUW_DT(DT,TAUW); % Function

XMCP=(PE+PW)*TAUW/(TWRT-TDAOR); % Winding mass times specific heat, W-min/°C
WWIND=XMCP/CPW; % Mass of windings, lb
if WWIND>WCC %If Mass of windings is higher than Weight of core and coils
    disp ('Winding constant is too high')
    disp ('Change input to lower value')
end
WCORE=WCC-WWIND;  % Mass of core, lb
CPST=3.51;        % Specific heat of steel, W-min/lb degC
WFL=GFLUID*231*RHOF; % Mass of fluid, lb
SUMMCP=(WTANK*CPST)+(WCORE*CPST)+(WFL*CPF); % Total mass times specific heat of fluid, tank, and core, W-min/degC
T1=(TWRT+TDAOR)/2;   % Temperature to calculate viscosity, degC
VISR=B*exp(C/(T1+273)); % Viscosity of fluid for average winding temperature rise at rated load, cP
T2=(THSR+TWOR)/2;       % Temperature to calculate viscosity, °C
VIHSR=B*exp(C/(T2+273));% Viscosity of fluid for hot-spot calculation at rated load, cP
TMP=0; % Time to print a calculation, min
% if MPR1<1
%     DTP=15
% end
KK=fix((TIM(JJ)/DTP)+0.01); % Number of times results are printed
for K=1:KK
    TMP=TMP+DTP;  % Time to print a calculation, min
    TIMP(K,1)=TMP;% Times when results are printed, min
end
THS=THSR;   % Winding hottest-spot temperature, degC
TW=TWRT;    % Average winding temperature, degC
TTO=TTOR;   % Top fluid temperature in tank and radiator, °C
TTDO=TTDOR; % Fluid temperature at top of duct, °C
TBO=TBOR;   % Bottom fluid temperature, °C
PR=0;       % given in intial program but not used in this function
JLAST=2;    % given in intial program but not used in this function
TFAVE=(TTO+TBO)/2; % Average fluid temperature in tank and radiator, degC
TWO=TBO+(HHS*(TTDO-TBO)); % Temperature of oil adjacent to winding hot spot, degC
%% First iteration
THSMAX=THS; % Maximum hottest-spot temperature during load cycle, degC
TIMHS=0;    % Time during load cycle when maximum hot spot occurs, h
TTOMAX=TTO; % Maximum top fluid temperature in tank during load cycle, °C
TIMTO=0;    % Time during load cycle when maximum top oil temperature occurs, h
J=1;        % point on load cycle
K=1;        % KK - Number of times results are printed
TIMS=0;     % Elapsed time, min
TIMSH=0;    % Elapsed time, h
ASUM=0;     % Equivalent insulation aging over load cycle, h

HTS=zeros(length(TIMP),1);  % Creating zero array for HST calculation
% Total_losses=zeros(length(TIMP),1); Creating zero array for Losses calculation
%QWE=zeros(2*length(TMP),1);
PU_Load=zeros(KK,1);% Creating zero array for PU_load calculation
AMB_Temp= zeros(KK,1); % Creating zero array for AMB calculation
TOPO=zeros(KK,1);% Creating zero array for Temperature top oil calculation
TOPDO=zeros(KK,1);
BOTO=zeros(KK,1);
Time_hours=zeros(KK,1);
HST=zeros(length(PUL),1);
TOT=zeros(length(PUL),1);
Total_losses_instant=zeros(length(PUL),1);

i=0;
ind=1;
while ~(TIMS>TIM(JJ))
    if TIMS<TIMP(K)
        TIMS=TIMS+DT; % Calculation of elapsed time, min
        i=i+1;
        if TIMS>TIM(J+1)
            J=J+1;
        end
        TIMSH=TIMS/60; % Calculation of elapsed time in hours
        if abs(TIM(J+1)-TIM(J))<0.01
            J=J+1;
        end
        SL=(PUL(J+1)-PUL(J))/(TIM(J+1)-TIM(J)); %Slope of line between two load points of load cycle curve
        PL=PUL(J)+(SL*(TIMS-TIM(J))); % ratio of load L to rated load, per unit
        SLAMB=(AMB(J+1)-AMB(J))/(TIM(J+1)-TIM(J));% Slope of line between two ambient temperature points of load cycle curve
        TA=AMB(J)+(SLAMB*(TIMS-TIM(J)));% Ambient temperature, degC
        TDAO=(TTDO+TBO)/2;% Average temperature of fluid in cooling ducts, °C
        TKW=(TW+TK)/(TWR+TK); %Temperature correction for losses of winding
        QWGEN=PL.*PL.*((TKW.*PW)+(PE./TKW)).*DT;%Heat generated by windings, W-min
        if TW<TDAO % if mean winding temperature is less than mean temperature of fluid in cooling ducts
            QWLOST=0;% Heat lost by winding, W-min
            if TW<TBO % if average winding temperature is less than Bottom fluid temperature
                TW=TBO;% average winding temperature , deg C
            end
        else %TW>=TDAO
            if MA==1 || MA==2 || MA==3 %if Cooling code (MA) is 1=ONAN, 2=ONAF or 3=non directed OFAF,
                T=(TW+TDAO)/2; % Temperature to calculate viscosity, degC
                VIS= B*exp(C/(T+273)); % Viscosity of fluid for average winding temperature rise calc., cP
                QWLOST=(((TW-TDAO)./(TWRT-TDAOR)).^1.25)*((VISR./VIS).^0.25)*(PW+PE)*DT; % Heat lost by winding, W-min
            else
                QWLOST=((TW-TDAO)./(TWRT-TDAOR))*(PW+PE)*DT; %# Heat lost by winding, W-min
            end
        end
        TW=(QWGEN-QWLOST+(XMCP*TW))/XMCP;% Average winding temperature, °C
        DTDO=(TTDOR-TBOR)*((QWLOST/((PW+PE)*DT))^X);%Temperature rise of fluid at top of duct over bottom fluid, °C
        TTDO=TBO+DTDO;% Fluid temperature at top of duct, °C
        TDAO=(TTDO+TBO)/2; % Average temperature of fluid in cooling ducts, °C
        TWO=TBO+(HHS*DTDO);%Temperature of oil adjacent to winding hot spot, °C
        TKHS=(THS+TK)/(THSR+TK); %Temperature correction for losses at hot spot location
        if (TTDO+0.1)<TTO %If Fluid temperature at top of duct is less than Top fluid temperature in tank and radiator
            TWO=TTO; % Temperature of oil adjacent to winding hot spot, degC
        end
        if THS<TW  %  If winding hot spot temperature is less than average winding temperature
            THS=TW; % Winding hottest-spot temperature, degC
        end
        if THS<TWO %If Winding hottest-spot temperature is less than temperature of oil adjacent to winding hot spot
            THS=TWO;  % Winding hottest-spot temperature, degC
        end
        QHSGEN=PL.*PL.*((TKHS.*PWHS)+(PEHS./TKHS)).*DT;%Heat generated at hot spot temperature, W-min
        if MA==1 || MA==2 || MA==3 % if Cooling code (MA) is 1=ONAN, 2=ONAF or 3=non directed OFAF,
            T=(THS+TWO)/2;%Temperature to calculate viscosity, °C
            VISHS=B*exp(C/(T+273));%Viscosity of fluid for hot-spot calculation, cP
            QLHS =(((THS-TWO)/(THSR-TWOR))^1.25)*((VIHSR/VISHS)^0.25)*(PWHS+PEHS)*DT;%Heat lost for hot-spot calculation, W-min
        else
            QLHS=((THS-TWO)/(THSR-TWOR))*(PWHS+PEHS)*DT;  % Heat lost for hot-spot calculation, W-min
        end
        %         PW_moment=PW*TKW;
        PE_moment=PE/TKW; % full load eddy losses at 75 degC
        %         PS_moment=PS/TKW;
        PW_instant=PL.*PL.*((TKW.*PW)+(PE./TKW)); % Instant I2R losses, W
        PS_instant=((PL*PL*PS)/TKW); % Instant stray losses, W
        THS=(QHSGEN-QLHS+(XMCP*THS))/XMCP; %Winding hottest-spot temperature, degC
        if TIMS==TIM(ind)
            HST(ind)=THS;
        end
        %QWE(i)=THS;
        QS=((PL*PL*PS)/TKW)*DT; % Heat generated by stray losses, W-min
        QLOSTF=(((TFAVE-TA)/(TFAVER-TAR))^(1/YN))*PT*DT; % Heat lost by fluid to ambient, W-min
        if MCORE<1 %  Core overexcitation occurs during load cycle, 0 = no, 1 = yes
            QC=PC*DT; % Heat generated by core, W-min
        elseif TIMS<TIMCOR % If elapsed time is less than Time when core overexcitation occurs, h
            QC=PC*DT; % Heat generated by core, W-min
        else % TIMS > = TIMCOR:
            QC=PCOE*DT;  % Heat generated by core, W-min
        end
        TFAVE=(QWLOST+QC+QS-QLOSTF+(SUMMCP*TFAVE))/SUMMCP;%Average fluid temperature in tank and radiator, °C
        DTTB=((QLOSTF/(PT*DT))^Z)*(TTOR-TBOR);%Temperature rise of fluid at top of radiator over bottom fluid, °C
        TTO=TFAVE+(DTTB/2); %Top fluid temperature in tank and radiator, °C
        
        if TIMS==TIM(ind)
            TOT(ind)=TTO;
            Total_losses_instant(ind)=PW_instant+PE_moment+PS_instant+PC;
            ind=ind+1;
        end
        
        TBO=TFAVE-(DTTB/2);%Bottom fluid temperature, °C
        if TBO<TA % If Bottom fluid temperature is less than ambient temperature
            TBO=TA; % Bottom fluid temperature, degC
        end
        if TTDO<TBO % If Fluid temperature at top of duct is less than Bottom fluid temperature
            TTDO=TBO; % Fluid temperature at top of duct,degC
        end
        AX=(15000/383)-(15000./(THS+273)); % Power of exp (see next line)
        A=exp(AX); % Aging acceleration factor
        ASUM=ASUM+(A*DT); % Equivalent insulation aging over load cycle, h
        if ~(THS<THSMAX) % If Winding hottest temperature is greater or equal to its maximum,registered before
            THSMAX=THS; % Maximum hottest-spot temperature during load cycle, degC
        end
        if ~(TTO<TTOMAX)% If top oil temperature is  greater or equal to its maximum
            TTOMAX=TTO; % Maximum top fluid temperature in tank during load cycle, degC
        end
    elseif K<=length(TIMP)
        HTS(K)=THS;
        %         Total_losses(K)=PW_moment+PE_moment+PS_moment+PC;
        PU_Load(K)=PL;
        Time_hours(K)=TIMSH;
        AMB_Temp(K)=TA;
        TOPO(K)=TTO;
        TOPDO(K)=TTDO;
        BOTO(K)=TBO;
        if K<KK
            K=K+1;
        else %K > = JJ
            break
        end
    else % # TIMS >=TIMP(K):
        break
    end
end
if MPR1==1 % if printing is permitted
    fprintf('Time\tPU_Load   AMB\t  HS\t TOPO\t TOPDO\t BOTO\n')
    fprintf('%.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t \n',0,PUL(1), AMB(1),HTS(end), TTO(end),TTDO(end),TBO(end))
end
%% Second iteration calculation
Current_ageing=0; % Set current ageing to zero
THSMAX=THS; % Import winding hottest spot temperature from first iteration and set it as THSMAX
TIMHS=0; % Set Time during load cycle when maximum hot spot occurs, h to zero
TTOMAX=TTO;  % Import top-oil temperature from first iteration and set it as TTOMAX
TIMTO=0;  % Set Time during load cycle when maximum top oil temperature occurs, h to zero
J=1;
K=1;
% Set to zero following parameters:
TIMS=0;
TIMSH=0;
ASUM=0;
HTS=zeros(length(TIMP),1);
%QWE=zeros(2*length(TMP),1);
PU_Load=zeros(KK,1);
AMB_Temp= zeros(KK,1);
TOPO=zeros(KK,1);
TOPDO=zeros(KK,1);
BOTO=zeros(KK,1);
Time_hours=zeros(KK,1);
HST=zeros(length(PUL),1);
TOT=zeros(length(PUL),1);
Total_losses_instant=zeros(length(PUL),1);

HST_min=zeros(length(TIM_min),1);
TOT_min=zeros(length(TIM_min),1);
Total_losses_instant_min=zeros(length(TIM_min),1);
Current_ageing_min=zeros(length(TIM_min),1);
Ageing_rate_min=zeros(length(TIM_min),1);

i=0;
ind=1;
% Recalculate the thermal mode of transformer
while ~(TIMS>TIM(JJ))
    if TIMS<TIMP(K)
        TIMS=TIMS+DT;
        i=i+1;
        if TIMS>TIM(J+1)
            J=J+1;
        end
        TIMSH=TIMS/60;
        if abs(TIM(J+1)-TIM(J))<0.01
            J=J+1;
        end
        SL=(PUL(J+1)-PUL(J))/(TIM(J+1)-TIM(J)); % Slope of line between two load points of load cycle curve
        PL=PUL(J)+(SL*(TIMS-TIM(J))); % ratio of load L to rated load, per unit
        SLAMB=(AMB(J+1)-AMB(J))/(TIM(J+1)-TIM(J)); % Slope of line between two ambient temperature points of load cycle curve
        TA=AMB(J)+(SLAMB*(TIMS-TIM(J))); % Ambient temperature, degC
        TDAO=(TTDO+TBO)/2; % Average temperature of fluid in cooling ducts, degC
        TKW=(TW+TK)/(TWR+TK); % Temperature correction for losses of winding
        QWGEN=PL.*PL.*((TKW.*PW)+(PE./TKW)).*DT; % Heat generated by windings, W-min
        if TW<TDAO % if mean winding temperature is less than mean temperature of fluid in cooling
            QWLOST=0; % Heat lost by winding, W-min
            if TW<TBO  % if average winding temperature is less than Bottom fluid temperature
                TW=TBO; %  average winding temperature, degC
            end
        else % TW> = TDAO
            if MA==1 || MA==2 || MA==3 % if Cooling code (MA) is 1=ONAN, 2=ONAF or 3=non directed OFAF
                T=(TW+TDAO)/2; % Temperature to calculate viscosity, degC
                VIS= B*exp(C/(T+273)); % Viscosity of fluid for average winding temperature rise calc., cP
                QWLOST=(((TW-TDAO)./(TWRT-TDAOR)).^1.25)*((VISR./VIS).^0.25)*(PW+PE)*DT; %  Heat lost by winding, W-min
            else
                QWLOST=((TW-TDAO)./(TWRT-TDAOR))*(PW+PE)*DT;% Heat lost by winding, W-min
            end
        end
        TW=(QWGEN-QWLOST+(XMCP*TW))/XMCP; % average winding temperature, degC
        DTDO=(TTDOR-TBOR)*((QWLOST/((PW+PE)*DT))^X);  % Temperature rise of fluid at top of duct over bottom fluid, °C
        TTDO=TBO+DTDO;  % Fluid temperature at top of duct, °C
        TDAO=(TTDO+TBO)/2; % Average temperature of fluid in cooling ducts, °C
        TWO=TBO+(HHS*DTDO); % Temperature of oil adjacent to winding hot spot, °C
        TKHS=(THS+TK)/(THSR+TK); % Correction factor for correction of losses to hot-spot temperature
        if (TTDO+0.1)<TTO
            TWO=TTO; % Temperature of oil adjacent to winding hot spot, °C
        end
        if THS<TW %If winding hot spot temperature is less than average winding temperature
            THS=TW; %  winding hottest spot temperature
        end
        if THS<TWO % If Winding hottest-spot temperature is less than temperature of oil adjacent to  winding hot spot
            THS=TWO; % winding hottest spot temperature
        end
        QHSGEN=PL.*PL.*((TKHS.*PWHS)+(PEHS./TKHS)).*DT;% Heat generated at hot spot temperature,
        if MA==1 || MA==2 || MA==3 % if Cooling code (MA) is 1=ONAN, 2=ONAF or 3=non directed OFAF
            T=(THS+TWO)/2;%Temperature to calculate viscosity, degC
            VISHS=B*exp(C/(T+273)); % Viscosity of fluid for hot-spot calculation, cP
            QLHS =(((THS-TWO)/(THSR-TWOR))^1.25)*((VIHSR/VISHS)^0.25)*(PWHS+PEHS)*DT;%Heat lost for hot-spot calculation, W-min
        else % if MA is 4=directed ODAF
            QLHS=((THS-TWO)/(THSR-TWOR))*(PWHS+PEHS)*DT; %Heat lost for hot-spot calculation, W-min
        end
        %         PW_moment=PW*TKW;
        PE_moment=PE/TKW; % full load eddy losses at 75 degC
        %         PS_moment=PS/TKW;
        PW_instant=PL.*PL.*((TKW.*PW)+(PE./TKW)); % Instant I2R losses, W
        PS_instant=((PL*PL*PS)/TKW); % Instant stray losses, W
        THS=(QHSGEN-QLHS+(XMCP*THS))/XMCP;% Winding hottest-spot temperature, degC
        if TIMS==TIM(ind)
            HST(ind)=THS;
        end
        QS=((PL*PL*PS)/TKW)*DT;%Heat generated by stray losses, W-min
        QLOSTF=(((TFAVE-TA)/(TFAVER-TAR))^(1/YN))*PT*DT; %Heat lost by fluid to ambient, W-min
        if MCORE<1%if Core overexcitation does not occur during load cycle, 0 = no, 1 = yes
            QC=PC*DT;%Heat generated by core, W-min
        elseif TIMS<TIMCOR
            QC=PC*DT;%Heat generated by core, W-min
        else %TIMS > = TIMCOR:
            QC=PCOE*DT;%Heat generated by core, W-min
        end
        TFAVE=(QWLOST+QC+QS-QLOSTF+(SUMMCP*TFAVE))/SUMMCP;%Average fluid temperature in tank and radiator, °C
        DTTB=((QLOSTF/(PT*DT))^Z)*(TTOR-TBOR);%Temperature rise of fluid at top of radiator over bottom fluid, °C
        TTO=TFAVE+(DTTB/2);%Top fluid temperature in tank and radiator, °C
        if TIMS==TIM(ind)
            TOT(ind)=TTO;
            Total_losses_instant(ind)=PW_instant+PE_moment+PS_instant+PC;
            ind=ind+1;
        end
        TBO=TFAVE-(DTTB/2);%Bottom fluid temperature, °C
        if TBO<TA%If Bottom fluid temperature is less than Ambient temperature
            TBO=TA;%Bottom fluid temperature, °C
        end
        if TTDO<TBO %If Fluid temperature at top of duct is less than Bottom fluid temperature
            TTDO=TBO;%Fluid temperature at top of duct, degC
        end
        AX=(15000/383)-(15000./(THS+273)); %Power of exp (see next line)
        A=exp(AX);%Ageing acceleration factor
        ASUM=ASUM+(A*DT);%Equivalent insulation aging over load cycle, h
        if ismember(TIMS,TIM_min) % min resolution
            ind_min=find(TIM_min==TIMS);
            HST_min(ind_min,1)=THS;
            TOT_min(ind_min,1)=TTO;
            Total_losses_instant_min(ind_min,1)=PW_instant+PE_moment+PS_instant+PC;
            Current_ageing_min(ind_min,1)=ASUM/(TIM_min(end));
            Ageing_rate_min(ind_min,1)=A';
        end
        
        if ~(THS<THSMAX)% If Winding hottest temperature is greater or equal to  its maximum,registered before
            THSMAX=THS; % Maximum hottest-spot temperature during load cycle, degC
            TIMHS=TIMSH;% Time during load cycle when maximum hot spot occurs
        end
        if ~(TTO<TTOMAX)%If top oil temperature is  greater or equal to its maximum
            TTOMAX=TTO; %Maximum top fluid temperature in tank during load cycle, degC
            TIMTO=TIMSH;%Time during load cycle when maximum top oil temperature occurs, h
        end
    elseif K<=length(TIMP)
        HTS(K)=THS;
        %         Current_ageing(K)=ASUM/60/length(PUL); % Ageing to particular moment
        Current_ageing(K)=ASUM/(TIM(end));
        Ageing_rate(K)=A';
        PU_Load(K)=PL;
        Time_hours(K)=TIMSH;
        AMB_Temp(K)=TA;
        TOPO(K)=TTO;
        TOPDO(K)=TTDO;
        BOTO(K)=TBO;
        if K<KK
            K=K+1;
        else
            break
        end
    else
        break
    end
end

if (size(Current_ageing,2) > size(Current_ageing,1)) % If number of columns > number of rows
    Current_ageing = Current_ageing';
end
% ASUM=ASUM/60;%Equivalent insulation aging over load cycle, h
AEQ=ASUM/TIM(end);%Equivalent aging acceleration factor over a complete load cycle

%% Printing the second iteration results
if MPR1==1 % if printing is permitted
    for K=1:KK
        if K<=KK-1
            fprintf('%.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t \n',Time_hours(K), PU_Load(K), AMB_Temp(K), HTS(K), TOPO(K), TOPDO(K), BOTO(K))
        elseif K==KK
            fprintf('%.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t %.2f\t \n',Time_hours(K),PUL(1), AMB(1),HTS(end), TTO(end),TTDO(end),TBO(end))
        end
    end
    fprintf ('Temperature during load cycle\n')
    fprintf ('MAX.HOT SPOT TEMP.= %f AT %0.5f HOURS\n',THSMAX,TIMHS)
    fprintf ('MAX. TOP FLUID TEMP.= %f AT %0.5f HOURS\n',TTOMAX,TIMTO)
    fprintf ('FINAL HOT SPOT TEMP.= %f\n',THS)
    fprintf ('FINAL AVE. WIND. TEMP.= %f\n', TW)
    fprintf ('FINAL TOP OIL TEMP.= %f\n', TTO)
    fprintf ('FINAL TOP DUCT OIL TEMP.= %f\n', TTDO)
    fprintf ('FINAL BOT. OIL TEMP.= %f\n', TBO)
    fprintf ('EQUIVALENT AGING = %f HOURS\n', ASUM)
    fprintf ('LOAD CYCLE DURATION = %f\n',TIMSH)
    fprintf ('EQUIVALENT AGING FACTOR =%f\n', AEQ)
    figure (1)
    hax=plotyy(Time_hours,HTS,Time_hours,PU_Load);
    legend({'HST','PUL'});
    grid on
    xlabel('Time');
    ylabel (hax(1),'HST');
    ylabel (hax(2),'PU load');
    title (['Hot spot temperature with EAF=',num2str(AEQ)]);
end
%% Choosing the time resolution of output
if resolution==2 % minute resolution is chosen
    % Changing the output variable
    HST=HST_min;
    TOT=TOT_min;
    Current_ageing=Current_ageing_min;
    Ageing_rate=Ageing_rate_min;
    Total_losses_instant=Total_losses_instant_min;
end % end of if resolution==2

end % end of IEEE_thermal_model.m