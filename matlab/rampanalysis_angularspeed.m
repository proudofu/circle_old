time = -120:0.3333333333333:419.66666666666666666;
Average = zeros(10, 1620);
Averageroaming = zeros(10, 1620);
stdAverageroaming = zeros(10, 1620);
Averagedwelling = zeros(10, 1620);
stdAveragedwelling = zeros(10, 1620);
Standard = zeros(10, 1620);
stimoos = [30 240 480 665 846 1041 1251 1491 1676 1857 2052 ];   
file_names = dir('*.linkedTracks.mat');
linkedTracks_merged = [];
for fls = 1: length(file_names)
    load(sprintf('%s', file_names(fls).name))
    linkedTracks_merged = [linkedTracks_merged linkedTracks];
end  
linkedTracks = linkedTracks_merged;

for d = 1:length(stimoos)
    i = stimoos(d);
  [AllChOPHits] = summarizeChOPdata_Copper_YCHuang_extSpeed_alteredIJ_ang(linkedTracks,'180420_multirampb_nsm.stim', i);  
  
%for p = 1:length(AllChOPHits(:, 1))
    %figure;
    %plot(time(330:900), AllChOPHits(p, 335:905))
    %pause
%end
pause
wormspeed = zeros(1, length(AllChOPHits(:,1)));
for iy = 1:length(AllChOPHits(:,1))
    wormspeed(iy) = mean(AllChOPHits(iy, 5:end));
end
dwelling = wormspeed < 0.05;
roaming = wormspeed > 0.05;

    
 for u = 5:length(AllChOPHits(1, :))
     Average(d, (u-4)) = mean(AllChOPHits(:, u));
     Standard(d, (u-4)) = std(AllChOPHits(:,u))/sqrt(length(AllChOPHits(:,1)));
     Averagedwelling(d, (u-4)) = mean(AllChOPHits(dwelling, u));
     stdAveragedwelling(d, (u-4)) = std(AllChOPHits(dwelling, u));
     Averageroaming(d, (u-4)) = mean(AllChOPHits(roaming, u));
     stdAverageroaming(d, (u-4)) = std(AllChOPHits(roaming, u));
 end
figure;
 plot(time(120:1619), Average(d, 120:1619));
 title('Average Speed Pattern: RAMP Stim Off FOOD');
 xlabel('Time(sec)');
 ylabel('Speed(mm/sec)');
 %pause
end

Peak_value = zeros(size(Average));
Peak_error = zeros(size(Average)) ;
Peak_value(1,:) = (Average(5,:) + Average(10,:))/2;
Peak_error(1,:) = (Standard(5,:) + Standard(10,:))/2;
Peak_value(2,:) = (Average(4,:) + Average(9,:))/2;
Peak_error(2,:) = (Standard(4,:) + Standard(9,:))/2;
Peak_value(3,:) = (Average(6, :) + Average(11,:))/2;
Peak_error(3,:) = (Standard(6,:) + Standard(11,:))/2;
Peak_value(4,:) = (Average(2,:) + Average(7,:))/2;
Peak_error(4,:) = (Standard(2,:) + Standard(7,:))/2;
Peak_value(5,:) = (Average(3, :) + Average(8,:))/2;
Peak_error(5,:) = (Standard(3,:) + Standard(8,:))/2;

figure; hold on;
H1 = plot(time, Peak_value(1,:), 'Color', 'r', 'LineWidth', 1.5);
H15 = shadedErrorBar(time, Peak_value(1,:), Peak_error(1,:), 'lineprops', '-r');
H2 = plot(time, Peak_value(2,:), 'Color', 'k', 'LineWidth', 1.5);
H25 = shadedErrorBar(time, Peak_value(2,:), Peak_error(2,:), 'lineprops', '-k');
H3 = plot(time, Peak_value(3,:), 'Color', 'b', 'LineWidth', 1.5);
H35 = shadedErrorBar(time, Peak_value(3,:), Peak_error(3,:), 'lineprops', '-b');
H4 = plot(time, Peak_value(4,:), 'Color', 'g', 'LineWidth', 1.5);
H45 = shadedErrorBar(time, Peak_value(4,:), Peak_error(4,:), 'lineprops', '-g');
H5 = plot(time, Peak_value(5,:), 'Color', 'm', 'LineWidth', 1.5);
H55 = shadedErrorBar(time, Peak_value(5,:), Peak_error(5,:), 'lineprops', '-m');




ylabel('Worm Angular Speed (mm/s)');
xlabel('Time(s)');
set(gca, 'xlim', [min(time) max(time)]);
set(gca, 'ylim', [-10 60]);
grid on
legend([H1, H2, H3, H4, H5], ... 
    '1s rise time', '5s rise time', '15s rise time', '30s rise time', '60s rise time',  ... 
    'location', 'Northeast');