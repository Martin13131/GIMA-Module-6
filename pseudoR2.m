%% Init, loading data
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
clear TimeAll Coordinates Adjacency Percentages


% 4,5 doesn't go to 8
% 8 doesn't go to 5
%% Calculating regression errors
Time = 1;
EndTime = 100;
% while Time <= EndTime
    parfor i = 1:length(Landuses)
        switch Landuses(i,1)
            case 1
                Odds = mnrval(B1, PredictorData(i,:));
                Odds([Landuses(i,1),8]) = Odds([8, Landuses(i,1)]);
            case 2
                Odds = mnrval(B2, PredictorData(i,:));
                Odds([Landuses(i,1),8]) = Odds([8, Landuses(i,1)]);
            case 3
                Odds = mnrval(B3, PredictorData(i,:));
                Odds([Landuses(i,1),8]) = Odds([8, Landuses(i,1)]);
            case 4
                Odds = mnrval(B4, PredictorData(i,:));
                Odds([Landuses(i,1),7]) = Odds([7,Landuses(i,1)]);
            case 5
                Odds = mnrval(B5, PredictorData(i,:));
                Odds([Landuses(i,1),7]) = Odds([7,Landuses(i,1)]);
            case 6
                Odds = mnrval(B6, PredictorData(i,:));
                Odds([Landuses(i,1),8]) = Odds([8, Landuses(i,1)]);
            case 7
                Odds = mnrval(B7, PredictorData(i,:));
                Odds([Landuses(i,1),8]) = Odds([8, Landuses(i,1)]);
            case 8
                Odds = mnrval(B8, PredictorData(i,:));
                Odds = [Odds(1:4),0,Odds(5:end)];
        end
        Change(i) = PickRandom(Odds);
    end
    
    MaxY = max(Coordinates(:,1));
    MaxX = max(Coordinates(:,2));
    MaxZ = max(Coordinates(:,3));
    RegressionResults(1:MaxY,1:MaxX,1:MaxZ) = 0;
    
    for i = 1:length(Coordinates)
       RegressionResults(Coordinates(i,1),Coordinates(i,2),Coordinates(i,3)) = Change(i); 
    end
    
    RegressionErrors(:,Time) = sum(Change ~= Landuses(:,2)');
   
    for i = 1:8
       Counts(i) = sum(Change == i);
    end
    
    %% establishing baseline on random selection based on percentage
    % Calculate total number of changes from and to each landuse
    for i = 1:8
        for j = 1:8
            NrChanges(i,j) = sum((Landuses(:,1)==i) & (Landuses(:,2) == j));
        end
    end
    
    % Initialise "change variable"
    Change = Landuses(:,1);
    % For each landuse at T = 0
    for i = 1:8
        % Get random indices of the number of changes
        ToChange = datasample(find(Landuses(:,1)==i), sum(NrChanges(i,:)),'Replace',false);
        for j = 1:8
            [Rands, idx] = datasample(ToChange, NrChanges(i,j),'Replace',false);
            ToChange(idx) = [];
            Change(Rands) = j;
        end
    end
    
    
    
    BaselineResults(1:MaxY,1:MaxX,1:MaxZ) = 0;
    for i = 1:length(Coordinates)
       BaselineResults(Coordinates(i,1),Coordinates(i,2),Coordinates(i,3)) = Change(i); 
    end
    
    BaselineErrors(:,Time) = sum(Change ~= Landuses(:,2));
    Time = Time + 1;
% end
%% R square
1 - (RegressionErrors / BaselineErrors); % becomes 0.0155

%% Mapping actual vs regression vs baseline
ActualResults(1:MaxY,1:MaxX,1:MaxZ) = 0;
for i = 1:length(Coordinates)
    ActualResults(Coordinates(i,1),Coordinates(i,2),Coordinates(i,3)) = Landuses(i,2); 
end
figure(1)
for i = 1:4
    subplot(4,3,i*3 - 2)
    imagesc(RegressionResults(:,:,i))
    subplot(4,3,i*3 - 1)
    imagesc(BaselineResults(:,:,i))
    subplot(4,3,i*3)
    imagesc(ActualResults(:,:,i))
end
subplot(4,3,1)
title('Regression results')
subplot(4,3,2)
title('Baseline results')
subplot(4,3,3)
title('Actual results')

Errors = (RegressionResults(:,:,i) ~= ActualResults(:,:,i)) .* 0;
figure(2)
for i = 1:4
    subplot(1,5,i)
    imagesc(RegressionResults(:,:,i) ~= ActualResults(:,:,i));
    Errors = Errors + RegressionResults(:,:,i) ~= ActualResults(:,:,i);
end
subplot(1,5,5)
imagesc(Errors)