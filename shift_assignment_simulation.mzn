include "globals.mzn";

int: positions;
int: frames;
int: maxShifts;

array[1..maxShifts, 1..5] of int: shifts; % list of shifts for a single weekday including their properties

array[1..frames, 1..3] of int: frameProperties; % list of frames including their properties

array[1..positions] of int: frameRoster; % list of frames

array[1..positions] of var 0..maxShifts: shiftRoster; %decision variable/output: roster where shifts are assigned to basend on the frameRoster

% every position must be assigned a different shift, except if no shift is assigned
constraint all_different_except_0(shiftRoster);

% every split shift must be assigned
constraint forall(i in 1..maxShifts)(if shifts[i,4] = 1 then count(shiftRoster, i) > 0 else true endif);

% if the shift roster is smaller than the number of shifts, every shift must be assigned. Otherwise, the number of unassigned positions is the number of positions - the number of shifts
constraint if positions <= maxShifts then count(shiftRoster, 0) = 0 else count_eq(shiftRoster, 0, positions - maxShifts) endif;

% a shift can only be assigned to a time frame if there is no type violation (regular and split shifts) and the shift fits within the time frame's interval
constraint forall(i in 1..positions)(if shiftRoster[i] > 0 then 
                                      if shifts[shiftRoster[i],4] = 0 then frameProperties[frameRoster[i],3] != 1 /\ shifts[shiftRoster[i],2] >= frameProperties[frameRoster[i],1] /\ shifts[shiftRoster[i],3] <= frameProperties[frameRoster[i],2]
                                      elseif frameRoster[i] = 14 then shifts[shiftRoster[i],2] >= 7 /\ shifts[shiftRoster[i],3] <= 40 
                                      elseif frameRoster[i] = 15 then shifts[shiftRoster[i],2] >= 10 /\ shifts[shiftRoster[i],3] <= 44 
                                      else frameProperties[frameRoster[i],3] > 0 /\ shifts[shiftRoster[i],2] >= frameProperties[frameRoster[i],1] /\ shifts[shiftRoster[i],3] <= frameProperties[frameRoster[i],2] endif 
                                     else true endif);

solve :: int_search(shiftRoster, smallest, indomain_min) satisfy;

