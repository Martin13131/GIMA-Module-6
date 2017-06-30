%% loading data
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

%% Get baseline odds
for i = 1:8
    for j = 1:8
        NrChanges(i,j) = sum((Landuses(:,1)==i) & (Landuses(:,2) == j));
    end
end
BaselineOdds = NrChanges./sum(NrChanges,2);

%% Deterministic R2
% baseline
[UniqueBase, ia2, ic2] = unique(Landuses,'rows');
for i = 1:length(UniqueBase)
    UniqueOdds(i) = BaselineOdds(UniqueBase(i,1),UniqueBase(i,2));
end
BaselineCorrect(1:length(Landuses),1) = UniqueOdds(ic2);
BaselineErrors = 1-BaselineCorrect;

% Regression
RegressionCorrect(1:length(Landuses)) = 0;
for i = 1:length(Landuses)
    RegressionCorrect(i) = ActOdds(i,Landuses(i,2));
end
RegressionErrors = 1 - RegressionCorrect;

% Calculation
1-mean(RegressionErrors'./BaselineErrors)