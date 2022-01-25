% Script to quantify sleep-wake activity in Zebrafish
% Behavioural data of fish is collected using the ZebraBox (Viewpoint)
%
% Mojtaba Bandarabadi, PhD, University of Lausanne, 2021
% mojtaba.bandarabadi@unil.ch
%
clear; close all; clc;
dataTable = xlsread('fishData.xlsx');

noWells = 96;   % number of wells
durRecord = 72; % total recording time in hour
activityValues = dataTable(:,7)+dataTable(:,9);
activityValues = reshape(activityValues,noWells,[])';

%% time-course analysis of sleep
for i = 1:noWells
    activityWell = reshape(activityValues(:,i),[],durRecord); % activity matrix of a well reshaped in hour
    totalActivity(:,i) = sum(activityWell); % total activity time per hour
    for j = 1:durRecord
        wake(j)  = nnz(activityWell(:,j));  % number of segments with activity (wake)
        sleep(j) = nnz(~activityWell(:,j)); % number of segments without activity (sleep)
    end
    numWake(:,i)  = wake;
    numSleep(:,i) = sleep;
end

%% average and number of sleep bouts per light/dark cycles
lenSegment = [840 600 840 600 840 600]; % number of light/dark segments (1 min segments)
for i = 1:noWells
    segments = mat2cell(activityValues(:,i),lenSegment,1); % divide to light/dark segments
    for j = 1:length(lenSegment)
        segmentsTemp = segments{j};
        counter = 0;
        DurSleepBouts = [];
        if segmentsTemp(1)==0
            start = 1;
            counter = counter+1;
        end
        for k = 2:size(segmentsTemp,1)
            if segmentsTemp(k-1)~=0 && segmentsTemp(k)==0
                counter = counter+1;
                start = k;
            end
            if segmentsTemp(k-1)==0 && segmentsTemp(k)~=0
                stop = k;
                DurSleepBouts(1,counter) = stop-start;
            end
        end
        if segmentsTemp(size(segmentsTemp,1))==0
            stop = size(segmentsTemp,1)+1;
            DurSleepBouts(1,counter) = stop-start;
        end
        meanDurSleepBouts{i,j} = mean(DurSleepBouts);        % average of sleep durations
        numberSleepBouts{i,j}  = counter/(lenSegment(j)/60); % number of sleep bouts per h
    end
end
