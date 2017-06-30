%% Landuse script module 6
clear
close all
clc

%% Loading data
bbg(:,:,1) = load('bbg2000.txt');
bbg(:,:,2) = load('bbg2003.txt');
bbg(:,:,3) = load('bbg2006.txt');
bbg(:,:,4) = load('bbg2008.txt');
bbg(:,:,5) = load('bbg2010.txt');
bbg(:,:,6) = load('bbg2012.txt');
bbg(bbg == -9999) = NaN;
bbg = floor(bbg/10);
[ny, nx, nz] = size(bbg);

%save('AllBBG.mat', 'bbg','-v7.3')

%% Checking environment
Step = 1;
adjacency((1+Step):(ny-Step),(1+Step):(nx-Step),1:5,1:8) = false;
Percentages((1+Step):(ny-Step),(1+Step):(nx-Step),1:5,1:8) = 0;
for k = 1:5 % Time
    for i = (1+Step):(ny-Step) % Rows
        for j = (1+Step):(nx-Step) % Columns
            Window = bbg( (i-Step):(i+Step), (j-Step):(j+Step), k);
            Window(1+Step,1+Step) = NaN;
            Window = Window( ~isnan(Window) );

            if numel(Window) > 0
                %Adjacent = unique(Window);
                %adjacency(i,j,k,1:numel(Adjacent)) = Adjacent;
                adjacency(i,j,k,unique(Window)) = true;
                for l = 1:8 % Landuse
                    Percentages(i,j,k,l) = numel(Window(Window==l)) / numel(Window);
                end
            end
        end
    end
end


%% Disseminating environment to better format:
for k = 1:5 % Time
    Count = 1;
    imagesc(bbg(:,:,k))
    hold on
    Size = numel(~(isnan(bbg(:,:,k)) | isnan(bbg(:,:,k+1))));
    FullData(1:Size,1:21) = 0;
    for i = (1+Step):(ny-Step) % Rows
        for j = (1+Step):(nx-Step) % Columns
            if ~ ( isnan(bbg(i,j,k)) || isnan(bbg(i,j,k+1)) )
                FullData(Count,1:5) = [i, j, k, bbg(i,j,k), bbg(i,j,k+1)];
                FullData(Count,6:13) = adjacency(i,j,k,:);
                FullData(Count, 14:21) = Percentages(i,j,k,:);
%                 for l = 1:length(adjacency(i,j,k))
%                     FullData(Count,5+adjacency(i,j,k,l)) = 1;
%                 end
                
                Count = Count + 1;

                % Show progress
                if mod(Count,10000) == 0
                    Count
                end
                if mod(Count,100000)==0
                    plot(j, i, 'r*', 'MarkerSize', 20)
                    drawnow
                end
            end
        end
    end
    %save(['Timestep',num2str(k),'.txt'],'FullData','-ascii')
    save(['Timestep',num2str(k),'.mat'],'FullData', '-v7.3')
    clear FullData
end
%% Next part
clear all

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

% clear Errors

TimeAll = [Time1; Time2; Time3; Time4];
clear Time1 Time2 Time3 Time4 Time5

% Divide into different arrays
Coordinates = TimeAll(:,1:3);
Landuses = TimeAll(:,4:5);
Adjacency = TimeAll(:,6:13);
Percentages = TimeAll(:,14:21);
clear TimeAll Coordinates



for i = 1:8
    A = [Adjacency(Landuses(:,1) == i,:),Percentages(Landuses(:,1) == i,:)];
    B = Landuses(Landuses(:,1) == i,2);
    B = SwapVals(B,i,8);
    [Response,index] = sort(categorical(B));
    Predictor = A(index,:);
    save(['Landuse',num2str(i),'.mat'],'Predictor','Response','-v7.3')
end

for i = 1:8
[b,dev,stats] = mymnrfit(Predictor, Response);
save(['LowResLanduseB',num2str(i),'.mat'],'b','dev','stats')
end
