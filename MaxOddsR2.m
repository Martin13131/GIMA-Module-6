%% Loading data
load StatisticBLanduse1
B1 = b;
load StatisticBLanduse2
B2 = b;
load StatisticBLanduse3
B3 = b;
load StatisticBLanduse4
B4 = b;
load StatisticBLanduse5
B5 = b;
load StatisticBLanduse6
B6 = b;
load StatisticBLanduse7
B7 = b;
load StatisticBLanduse8
B8 = b;

Time1 = load('Timestep1.mat');
Time1 = Time1.FullData;
Errors = Time1 == 0;
Time1(sum(Errors, 2) == 21, :) = [];

Time2 = load('Timestep2.mat');
Time2 = Time2.FullData;
Errors = Time2 ==0;
Time2(sum(Errors, 2)==21, :) = [];

Time3 = load('Timestep3.mat');
Time3 = Time3.FullData;
Errors = Time3 == 0;
Time3(sum(Errors, 2) == 21, :) = [];

Time4 = load('Timestep4.mat');
Time4 = Time4.FullData;
Errors = Time4 == 0;
Time4(sum(Errors, 2) == 21, :) = [];

% Time5 = load('Timestep5.mat');
% Time5 = Time5.FullData;
% Errors = Time5 == 0;
% Time5(sum(Errors, 2) == 21, :) = [];

clear Errors

TimeAll = [Time1; Time2; Time3; Time4];
clear Time1 Time2 Time3 Time4 Time5

% Divide into different arrays
Coordinates = TimeAll(:,1:3);
Landuses = TimeAll(:,4:5);
Adjacency = TimeAll(:,6:13);
Percentages = TimeAll(:,14:21);
PredictorData = [Adjacency,Percentages];
clear TimeAll Adjacency Percentages

%% Initialising variables
[UniqueLocations, ia, ic]= unique([PredictorData,Landuses(:,1)],'rows');
Odds(1:length(UniqueLocations),1:8) = 0;
ActOdds(1:length(Landuses),1:8) = 0;
Time = 1;
TimeEnd = 1;
RegressionErrors(1:TimeEnd) = 0;
BaselineErrors(1:TimeEnd) = 0;
%% Get the odds from mnrval for every unique window

for i = 1:length(UniqueLocations)
    TempOdds = zeros(1,8);
    switch UniqueLocations(i,17)
        case 1
            TempOdds = mnrval(B1, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),8]) = TempOdds([8, UniqueLocations(i,17)]);
            Odds(i,:) = TempOdds;
        case 2
            TempOdds = mnrval(B2, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),8]) = TempOdds([8, UniqueLocations(i,17)]);
            Odds(i,:) = TempOdds;
        case 3
            TempOdds = mnrval(B3, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),8]) = TempOdds([8, UniqueLocations(i,17)]);
            Odds(i,:) = TempOdds;
        case 4
            TempOdds = mnrval(B4, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),7]) = TempOdds([7,UniqueLocations(i,17)]);
            Odds(i,:) = [TempOdds,0];
        case 5
            TempOdds = mnrval(B5, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),7]) = TempOdds([7,UniqueLocations(i,17)]);
            Odds(i,:) = [TempOdds,0];
        case 6
            TempOdds = mnrval(B6, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),8]) = TempOdds([8, UniqueLocations(i,17)]);
            Odds(i,:) = TempOdds;
        case 7
            TempOdds = mnrval(B7, UniqueLocations(i,1:16));
            TempOdds([UniqueLocations(i,17),8]) = TempOdds([8, UniqueLocations(i,17)]);
            Odds(i,:) = TempOdds;
        case 8
            TempOdds = mnrval(B8, UniqueLocations(i,1:16));
            Odds(i,:) = [TempOdds(1:4),0,TempOdds(5:end)];
    end
end

ActOdds(1:length(Landuses),:) = Odds(ic,:);
%% monte carlo r2
% Baseline Prep
for i = 1:8
    for j = 1:8
        NrChanges(i,j) = sum((Landuses(:,1)==i) & (Landuses(:,2) == j));
    end
end


while Time <= TimeEnd
    % Baseline calc
    Change = Landuses(:,1);
        % For each landuse at T = 0
    for i = 1:8
        % Get random indices of the number of changes
%         ToChange = datasample(find(Landuses(:,1)==i), sum(NrChanges(i,:)),'Replace',false);
%         for j = 1:8
%             [Rands, idx] = datasample(ToChange, NrChanges(i,j),'Replace',false);
%             ToChange(idx) = [];
%             Change(Rands) = j;
%         end
        [val, Change(Change == i)] = max(NrChanges(i,:),[],2);
    end
        BaseLineErrors(Time) = sum(Change ~= Landuses(:,2));
    
    
    % Regression calc   
    [maxval, Change] = max(ActOdds,[],2); % R2 = 0.4669
    RegressionErrors(Time) = sum(Change ~= Landuses(:,2));


    Time = Time + 1;
end

1-RegressionErrors/BaselineErrors