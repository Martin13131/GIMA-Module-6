%% Cellular Automata model
% module 6
clear all
close all
clc

%% Init
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

myField = load('bbg2000zholland.txt');
%myField = myField(2:1001,2:1001);
myField = floor(myField/10);
[ny, nx] = size(myField);

StartTime = 1;
EndTime = 5;
Step = 1;
Time = StartTime;
Change = zeros(ny-2*Step,nx-2*Step);

writerObj = VideoWriter('LanduseZHolland.avi','Uncompressed AVI'); % initialize AVI movie
writerObj.FrameRate = 5; % set frames per second (has to be done before open!)
open(writerObj)
%% Dynamic
while Time <= EndTime
    tic
    for i = (1+Step):(ny-Step) % Rows
        for j = (1+Step):(nx-Step) % Columns
            Window = myField((i-Step):(i+Step), (j-Step):(j+Step)); % Window
            CurLoc = Window(5);
            Window(5) = [];
            
            Adjacency(1,1:8) = false;
            Adjacency(unique(Window)) = true;
            for k = 1:8
                Percentage(1,k) = numel(Window(Window==k)) / numel(Window);
            end
            
            PredictorData = [Adjacency, Percentage];
            switch CurLoc
                case 1
                    Odds = mnrval(B1, PredictorData);
                    Odds([CurLoc,8]) = Odds([8, CurLoc]);
                case 2
                    Odds = mnrval(B2, PredictorData);
                    Odds([CurLoc,8]) = Odds([8, CurLoc]);
                case 3
                    Odds = mnrval(B3, PredictorData);
                    Odds([CurLoc,8]) = Odds([8, CurLoc]);
                case 4
                    Odds = mnrval(B4, PredictorData);
                    Odds([CurLoc,7]) = Odds([7,CurLoc]);
                case 5
                    Odds = mnrval(B5, PredictorData);
                    Odds([CurLoc,7]) = Odds([7,CurLoc]);
                case 6
                    Odds = mnrval(B6, PredictorData);
                    Odds([CurLoc,8]) = Odds([8, CurLoc]);
                case 7
                    Odds = mnrval(B7, PredictorData);
                    Odds([CurLoc,8]) = Odds([8, CurLoc]);
                case 8
                    Odds = mnrval(B8, PredictorData);
                    Odds = [Odds(1:4),0,Odds(5:end)];
            end
            Change(i-Step,j-Step) = PickRandom(Odds);
        end
    end
    myField((1+Step):(ny-Step),(1+Step):(nx-Step)) = Change;
    toc
    %% Visualization
    imagesc(myField)
    colorbar; drawnow;
    title('Landuse in a 10km x 10km "Zuid-Holland" grid regression results')
        frame = getframe(gcf);
        writeVideo(writerObj,frame);
    
    Time = Time + 1;
end
close(writerObj);