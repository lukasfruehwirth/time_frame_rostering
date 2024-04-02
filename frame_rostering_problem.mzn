include "globals.mzn";

int: positions; % number of roster positions
array[1..dayOffTypes] of int: maxPos; % size of each day-off type
int: dayOffTypes; % number of day off types
int: frames; % number of time frames
int: frameSets; % number of frame sets
int: splitSets; % number of split frame sets
int: slots; % number of time slots
int: undesSeqs; % number of undesirable sequences
int: forbSeqs; % number of forbidden sequences
int: weekdays; % number of weekdays
int: workweekTypes; % number of workweek types
int: startEncoding; % number where the encoding of the empty rosters starts
int: wS1; % weight for soft constraint s1
int: wS2; % weight for soft constraint s2
int: wS3; % weight for soft constraint s3
int: wS4; % weight for soft constraint s5
int: wS5; % weight for soft constraint s6
int: hardConstrPenalty; % penalty if a softened hard constraint is violated

array[1..frames, 1..3] of int: frameProperties; % start, end and type of each frame
array[1..slots] of int: slot; % start of each time slot
array[1..positions, 1..weekdays + 3] of int: roster; % unasigned roster containing the days-off (-1 and 0) and workweek types (20-30)
array[1..weekdays, 1..slots] of int: minCover; % minimum coverage of each time slot for frames 1-11
array[1..weekdays, 1..slots] of int: minCoverSplit; % minimum coverage of each time slot for frames 12-15
array[1..weekdays, 1..slots] of int: minCoverBuffer; % buffer coverage according to drivers absence prob.
array[1..weekdays, 1..slots] of int: minCoverSplitBuffer; % buffer coverage according to drivers absence prob.
array[1..frameSets, 1..weekdays] of int: minFrame; % mininum demand of a frame or set of frames for each weekday
array[1..frameSets, 1..weekdays] of int: maxFrame; % maximum demand of a frame or set of frames for each weekday
array[1..splitSets, 1..weekdays] of int: minMaxSplit; % demand for frames 12-15 for each weekday
array[1..forbSeqs, 1..2] of int: forbSeq; % list of forbidden sequences
array[1..undesSeqs, 1..3] of int: undesSeq; % list of undesired sequences
array[1..weekdays - 1] of int: maxDev; % maximum deviation between the frame count of two weekdays
array[1..workweekTypes, 1..frames + 2] of int: forbFrames; % list of forbidden frames according to the workweek type

array[1..positions, 1..weekdays] of var -1..frames: newRoster; % output or decision variable

% count each frame for each weekday
array[1..frames, 1..weekdays] of var 0..positions: frameCount = [(f,w): count(newRoster[1..positions,w],f) | f in 1..frames, w in 1..weekdays];

% count all possible sets of frames for each weekday
array[1..frameSets, 1..weekdays] of var 0..positions: frameSetCount = [(fs,w): 
if fs = 1 then frameCount[1,w] 
elseif fs = 2 then frameCount[2,w]
elseif fs = 3 then frameCount[6,w]
elseif fs = 4 then frameCount[7,w]
elseif fs = 5 then frameCount[10,w]
elseif fs = 6 then frameCount[1,w] + frameCount[2,w]
elseif fs = 7 then frameCount[3,w] + frameCount[14,w]
elseif fs = 8 then frameCount[6,w] + frameCount[7,w]
elseif fs = 9 then frameCount[8,w] + frameCount[10,w]
elseif fs = 10 then frameCount[9,w] + frameCount[10,w]
elseif fs = 11 then frameCount[11,w] + frameCount[15,w]
elseif fs = 12 then frameCount[2,w] + frameCount[3,w] + frameCount[14,w]
elseif fs = 13 then frameCount[4,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 14 then frameCount[5,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 15 then frameCount[7,w] + frameCount[8,w] + frameCount[10,w]
elseif fs = 16 then frameCount[1,w] + frameCount[2,w] + frameCount[3,w] + frameCount[14,w]
elseif fs = 17 then frameCount[4,w] + frameCount[5,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 18 then frameCount[5,w] + frameCount[6,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 19 then frameCount[6,w] + frameCount[7,w] + frameCount[8,w] + frameCount[10,w]
elseif fs = 20 then frameCount[3,w] + frameCount[4,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 21 then frameCount[4,w] + frameCount[5,w] + frameCount[6,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 22 then frameCount[5,w] + frameCount[6,w] + frameCount[7,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 23 then frameCount[2,w] + frameCount[3,w] + frameCount[4,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 24 then frameCount[3,w] + frameCount[4,w] + frameCount[5,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 25 then frameCount[4,w] + frameCount[5,w] + frameCount[6,w] + frameCount[7,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 26 then frameCount[1,w] + frameCount[2,w] + frameCount[3,w] + frameCount[4,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 27 then frameCount[2,w] + frameCount[3,w] + frameCount[4,w] + frameCount[5,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 28 then frameCount[3,w] + frameCount[4,w] + frameCount[5,w] + frameCount[6,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 29 then frameCount[5,w] + frameCount[6,w] + frameCount[7,w] + frameCount[8,w] + frameCount[10,w] + frameCount[11,w] + frameCount[15,w]
elseif fs = 30 then frameCount[3,w] + frameCount[4,w] + frameCount[5,w] + frameCount[6,w] + frameCount[7,w] + frameCount[11,w] + frameCount[14,w] + frameCount[15,w]
else 0 endif | fs in 1..frameSets, w in 1..weekdays];

% count specific sets of frames, which are only relevant for split shifts, for each weekday 
array[1..splitSets, 1..weekdays] of var 0..positions: frameSplitCount = [(fs,w): 
if fs = 1 then frameCount[12,w] + frameCount[13,w]
elseif fs = 2 then frameCount[12,w]
elseif fs = 3 then frameCount[13,w]
elseif fs = 4 then frameCount[12,w] + frameCount[13,w] + frameCount[14,w] + frameCount[15,w]
elseif fs = 5 then frameCount[12,w] + frameCount[14,w]
elseif fs = 6 then frameCount[13,w] + frameCount[15,w]
elseif fs = 7 then frameCount[12,w] + frameCount[13,w] + frameSetCount[26,w]
else 0 endif | fs in 1..splitSets, w in 1..weekdays];

% count how often a time slot is covered by a frame
array[1..weekdays, 1..slots] of var 0..positions: cover = [(j,s): sum([frameCount[i,j] | i in 1..11 where check_frame_covers_slot(i,s)]) | s in 1..slots, j in 1..weekdays];

array[1..weekdays, 1..slots] of var 0..positions: coverSplit = [(j,s): sum([frameCount[i,j] | i in 12..frames where check_frame_covers_slot_split(i,s)]) | s in 1..slots, j in 1..weekdays];

array[1..weekdays, 1..slots] of var -positions..positions: diffCover = [(i,j): cover[i,j] - minCoverBuffer[i,j]| i in 1..weekdays, j in 1..slots];

int: penBound = pow(floor(positions / 4),4);

array[1..weekdays, 1..slots] of var 0..penBound: diffCoverPen = [(i,j): if diffCover[i,j] < 0 then pow(diffCover[i,j], 4) 
                                                                                else pow(diffCover[i,j], 2) endif | i in 1..weekdays, j in 1..slots];

array[1..weekdays, 1..slots] of var -positions..positions: diffCoverSplit = [(i,j): coverSplit[i,j] - minCoverSplitBuffer[i,j]| i in 1..weekdays, j in 1..slots];

array[1..frameSets, 1..weekdays] of var -positions..positions: diffMinFrame = [(i,j): frameSetCount[i,j] - minFrame[i,j]| i in 1..frameSets, j in 1..weekdays];

array[1..splitSets, 1..weekdays] of var -positions..positions: diffMinFrameSplit = [(i,j): frameSplitCount[i,j] - minMaxSplit[i,j]| i in 1..splitSets, j in 1..weekdays];

% save for every position in the roster, the consecutive position according to the rotating schedule
array[1..positions, 1..weekdays] of var -1..frames: nextDay = [(i,j): next_day(i,j,roster[i,2],roster[i,3]) | i in 1..positions, j in 1..weekdays];



% FUNCTIONS

function var bool: check_frame_covers_slot(int: f, int: s) = frameProperties[f, 1] < slot[s] + 1 /\ frameProperties[f, 2] > slot[s];

function var bool: check_frame_covers_slot_split(int: f, int: s) = if f = 14 then 7 < slot[s] + 1 /\ 40 > slot[s]
                                                                   elseif f = 15 then 10 < slot[s] + 1 /\ 44 > slot[s]
                                                                   else frameProperties[f, 1] < slot[s] + 1 /\ frameProperties[f, 2] > slot[s] endif;
                                                                   
function var int: check_if_undes_seq(int: p, int: w) = sum([if newRoster[p,w] = undesSeq[x,1] /\ next_day(p,w,roster[p,2],roster[p,3]) = undesSeq[x,2] then undesSeq[x,3] else 0 endif | x in 1..undesSeqs]);

function var int: count_cost_of_slots() = sum([diffCoverPen[i,j] + pow(diffCoverSplit[i,j],2) | i in 1..weekdays, j in 1..slots]);

function var int: count_cost_frame_deviation() = sum([abs(frameCount[i,j] - frameCount[i,j+1]) | i in 1..frames, j in 1..weekdays - 3]);

function var int: count_cost_undes_seq() = sum([if newRoster[p,w] > 0 then check_if_undes_seq(p,w) else 0 endif | p in 1..positions, w in 1..weekdays]);

function var int: count_cost_below_min_frame() = sum([if frameSplitCount[fs,w] < minMaxSplit[fs,w] then (minMaxSplit[fs,w] - frameSplitCount[fs,w]) * hardConstrPenalty else 0 endif  | fs in 4..splitSets, w in 1..weekdays]);

function var int: count_cost_same_frame_next_day() = sum([if newRoster[p,w] = nextDay[p,w] then 1 else 0 endif | p in 1..positions, w in 1..weekdays]);

function var int: count_cost_same_frame_next_week() = sum([if newRoster[p,w] > 0 /\ roster[p,3] < dayOffTypes then
                                                           if maxPos[roster[p,3]] > roster[p,2] + 1 then if newRoster[p,w] = newRoster[p+2,w] then 1 else 0 endif
                                                           else if newRoster[p,w] = newRoster[p-maxPos[roster[p,3]]+2,w] then 1 else 0 endif endif else 0 endif | p in 1..positions, w in 1..weekdays]);

function var int: next_day(int: p, int: w, int: pt, int: t) = if w != weekdays then newRoster[p,w+1] elseif pt != maxPos[t] then newRoster[p+1,1] else newRoster[p-maxPos[t]+1,1] endif;



% CONSTRAINTS

% hard constraint h_1_a: make sure that the minimum coverage is covered
constraint forall(i in 1..weekdays, j in 1..slots)(cover[i,j] >= minCover[i,j]);

% hard constraint h_1_b: make sure that the minimum split coverage is covered
constraint forall(i in 1..weekdays, j in 1..slots)(coverSplit[i,j] >= minCoverSplit[i,j]);

% hard constraint h_2_a: make sure that the minimum frame set demand is given, constraint h_8 is already included
constraint forall(fs in 1..frameSets, w in 1..weekdays)(frameSetCount[fs,w] >= minFrame[fs,w]);

% hard constraint h_3: make sure that the maximum frame set demand is not exceeded, constraint h_7_b is already included
constraint forall(fs in 1..frameSets, w in 1..weekdays)(frameSetCount[fs,w] <= maxFrame[fs,w]);

% hard constraint h_2_b-g: make sure that the minimum split frame set demand is given
constraint forall(fs in 1..3, w in 1..weekdays)(if fs = 1 \/ (minMaxSplit[1,w] = 0 /\ minMaxSplit[4,w] = 0) then frameSplitCount[fs,w] = minMaxSplit[fs,w]
                                                        else frameSplitCount[fs,w] >= minMaxSplit[fs,w] endif);
                                                        
constraint forall(fs in 4..splitSets-1, w in 1..weekdays)(if (minMaxSplit[1,w] = 0 /\ minMaxSplit[4,w] = 0) then frameSplitCount[fs,w] = minMaxSplit[fs,w] endif);                                                        
                                                                                                               
% hard_constraint h_4: no forbidden sequences are allowed
constraint forall(i in 1..positions, j in 1..weekdays)(count([newRoster[i,j] = forbSeq[x,1] /\ nextDay[i,j] = forbSeq[x,2] | x in 1..forbSeqs]) = 0);                                                                                                     
                                                                                                                                                                                                                                                                                                         
% hard constraint h_5: ensure frame is allowed according to workweek type
constraint forall(i in 1..positions, j in 1..weekdays)(if roster[i,j+3] < startEncoding then newRoster[i,j] = roster[i,j+3] 
                                                       else newRoster[i,j] > 0 /\ forbFrames[roster[i,j+3] - startEncoding + 3, newRoster[i,j] + 2] = 1 endif);

% hard constraint h_6: make sure the frame count of days with similar shifts does not deviate too much
constraint forall(f in 1..frames, w in 1..weekdays - 1)(abs(frameCount[f,w] - frameCount[f,w+1]) <= maxDev[w]);
constraint forall(f in 1..frames, w in 1..weekdays - 4)(abs(frameCount[f,w] - frameCount[f,w+2]) <= maxDev[w]);
constraint forall(f in 1..frames, w in 1..weekdays - 5)(abs(frameCount[f,w] - frameCount[f,w+3]) <= maxDev[w]);
constraint forall(f in 1..frames, w in 1..weekdays - 6)(abs(frameCount[f,w] - frameCount[f,w+4]) <= maxDev[w]);

constraint forall(i in 1..positions, j in 1..weekdays)(if newRoster[i,j] > 0 /\ newRoster[i,j] < 4 then newRoster[i,j] >= nextDay[i,j]
                                                       elseif newRoster[i,j] > 6 /\ newRoster[i,j] < 11 then newRoster[i,j] >= nextDay[i,j] else true endif);
               
% hard constraint h_7_a: night frames are only allowed if there are also shifts during the night                                                                                               
constraint forall(w in 1..weekdays)(if sum([minCover[w,s] | s in 53..slots]) = 0 then frameSetCount[10,w] = 0 endif);


% soft constraint s_1: costs for over- or undercoverage
var int: costOfSlots = count_cost_of_slots()*wS1;

% soft constraint s_2: costs for undesired sequences
var int: costUndesSeq = count_cost_undes_seq()*wS2;

% soft constraint s_3: costs for deviation in frame count for weekdays 1-5
var int: costFrameDeviation = count_cost_frame_deviation()*wS3;

% soft constraint s_4: costs if hard constraint h_2_d-g are violated
var int: costBelowMinFrame = count_cost_below_min_frame();

% soft constraint s_5: costs if the same frame is assigned to two consecutive days
var int: costSameFrameNextDay = count_cost_same_frame_next_day()*wS4;

% soft constraint s_6: costs if the same frame is assigned to two consecutive early or late weeks
var int: costSameFrameNextWeek = count_cost_same_frame_next_week()*wS5;


var int: cost = costOfSlots + costUndesSeq + costFrameDeviation + costSameFrameNextDay + costSameFrameNextWeek + costBelowMinFrame;

solve :: int_search(newRoster, input_order, indomain_random)
      minimize cost;


output["{ 'New Roster': ", showJSON(newRoster), ", 'Frame Count': ", showJSON(frameCount), ", 'Frame Split Count': ", showJSON(frameSplitCount), ", 'Difference Frame Count': ", showJSON(diffMinFrame), ", 'Difference Frame Split Count': ", showJSON(diffMinFrameSplit), ", 'Difference Cover': ", showJSON(diffCover), ", 'Difference Split Cover': ", showJSON(diffCoverSplit), ", 'Total Cost': ", show(cost), ", 'Deviation Costs Cover': ", show(costOfSlots), ", 'Costs Undesirable Seqs': ", show(costUndesSeq), ", 'Costs Frame Deviation': ", show(costFrameDeviation), ", 'Costs Same Frame Next Day': ", show(costSameFrameNextDay), ", 'Costs Same Frame Next Week': ", show(costSameFrameNextWeek), ", 'Costs Below Min Frame': ", show(costBelowMinFrame), "}"];

