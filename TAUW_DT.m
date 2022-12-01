function DT=TAUW_DT(DT,TAUW)
% For the computer program, a time increment Dt = 0.5 min is used, and
% the following criteria used for stability andaccuracy for all four cooling modes:

if ~(TAUW/DT>9) %Ratio: Winding constant to time increment should be less than 9 (stability criterion)
     while ~(TAUW/DT>9)
         DT=DT/2; % Correction of DT in accordance to the stability criterion
    end
end
end
