
int: staffCount; % total number of tram drivers

array[1..7] of int: demand; % demand for day off days

array[1..7] of var int: daysOff; % number of tram drivers having a day off on weekday i

array[1..7] of var 1..staffCount: dayOffTypeSize; % decision variable: size of the day off types

% days off are always two consecutive days
daysOff = [(i): if i < 7 then dayOffTypeSize[i] + dayOffTypeSize[i+1] else dayOffTypeSize[1] + dayOffTypeSize[7] endif | i in 1..7];

% every driver must be assigned a day off type
constraint sum(dayOffTypeSize) == staffCount;

% the size of a day off type must be even
constraint forall(i in 1..7)(dayOffTypeSize[i] mod 2 = 0);

% day off types can only be twice as big in size than the next day off type and vice versa
constraint forall(i in 1..5)(if dayOffTypeSize[i] > dayOffTypeSize[i+1] then dayOffTypeSize[i] <= dayOffTypeSize[i+1]*2 else dayOffTypeSize[i+1] <= dayOffTypeSize[i]*2 endif);

% distribute the day off types such that the acutal days off are getting as close as possible to the day off demand
var int: cost = sum([abs(demand[x] - daysOff[x]) | x in 1..7]);

solve :: int_search(dayOffTypeSize, smallest, indomain_max)
      minimize cost;