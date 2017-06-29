%% Initialising variables
[UniqueLocations, ia, ic]= unique([PredictorData,Landuses(:,1)],'rows');
Odds(1:length(UniqueLocations),1:8) = 0;
ActOdds(1:length(Landuses),1:8) = 0;
Time = 1;
TimeEnd = 100;
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
        ToChange = datasample(find(Landuses(:,1)==i), sum(NrChanges(i,:)),'Replace',false);
        for j = 1:8
            [Rands, idx] = datasample(ToChange, NrChanges(i,j),'Replace',false);
            ToChange(idx) = [];
            Change(Rands) = j;
        end
        %[val, Change(Change == i)] = max(NrChanges(i,:),[],2);
    end
    BaseLineErrors(Time) = sum(Change ~= Landuses(:,2));
    
    % Visualize baseline results
%     subplot(1,2,1)
%     imagesc(Coordinates(:,2),Coordinates(:,1),Change)
%     title('Baseline')
    
    % Regression calc   
    Change = PickRandom(ActOdds);
    %[maxval, Change] = max(ActOdds,[],2); % R2 = 0.4669
    RegressionErrors(Time) = sum(Change ~= Landuses(:,2));
    
    % visualise regression results
%     subplot(1,2,1)
%     imagesc(Coordinates(:,2),Coordinates(:,1),Change)
%     title('Regression')
%     drawnow

    Time = Time + 1;
end

%% Deterministic montecarlo
BaselineOdds = NrChanges./sum(NrChanges,2);
%  = BaselineOdds([Landuses(:,1)],[Landuses(:,2)]);
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