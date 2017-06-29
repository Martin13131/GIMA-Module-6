function Vals = PickRandom(ArrayOfOdds)
    dice = rand(length(ArrayOfOdds),1);
    ArrayOfOdds = cumsum(ArrayOfOdds, 2);
    Change = sum(ArrayOfOdds <= dice,2);
    Vals = Change + 1;
    
    
%% For one value at a time 
% function val = PickRandom(Odds)
%     Odds = cumsum(Odds);
%     dice = rand;
%     i = 1;
%     while dice >= Odds(i)
%        i = i + 1;
%     end
%     val = i;