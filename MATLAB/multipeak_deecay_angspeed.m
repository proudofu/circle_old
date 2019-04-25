time = -120:0.3333333333333:419.6666666666666;
Average = zeros(10, 1620);
Averageroaming = zeros(10, 1620);
stdAverageroaming = zeros(10, 1620);
Averagedwelling = zeros(10, 1620);
stdAveragedwelling = zeros(10, 1620);
Standard = zeros(10, 1620);
stimoos = [1 196 391 586 961 1336 1531 1726 2101 2296 2671 ]; 
file_names = dir('*.linkedTracks.mat');
linkedTracks_merged = [];
for fls = 1: length(file_names)
    load(sprintf('%s', file_names(fls).name))
    linkedTracks_merged = [linkedTracks_merged linkedTracks];
end  
linkedTracks = linkedTracks_merged;


for d = 1:length(stimoos)
    i = stimoos(d);
  [AllChOPHits] = summarizeChOPdata_Copper_YCHuang_extSpeed_alteredIJ_ang(linkedTracks,'180518_NSM_MultipeakMultiDecay.stim', i);  
  
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
 title('Average Speed Pattern: multipeakdecay Stim Off FOOD');
 xlabel('Time(sec)');
 ylabel('Speed(mm/sec)');
 %pause
end

Peak_value = zeros(size(Average));
Peak_error = zeros(size(Average)) ;
Peak_value(1,:) = (Average(6,:) + Average(11,:))/2;
Peak_error(1,:) = (Standard(6,:) + Standard(11,:))/2;
Peak_value(2,:) = (Average(2,:) + Average(7,:))/2;
Peak_error(2,:) = (Standard(2,:) + Standard(7,:))/2;
Peak_value(3,:) = (Average(3,:) + Average(9,:))/2;
Peak_error(3,:) = (Standard(3,:) + Standard(9,:))/2;


figure; hold on;
H1 = plot(time, Peak_value(1,:), 'Color', 'r', 'LineWidth', 1.5);
H15 = shadedErrorBar(time, Peak_value(1,:), Peak_error(1,:), 'lineprops', '-r');
H2 = plot(time, Peak_value(2,:), 'Color', 'k', 'LineWidth', 1.5);
H25 = shadedErrorBar(time, Peak_value(2,:), Peak_error(2,:), 'lineprops', '-k');
H3 = plot(time, Peak_value(3,:), 'Color', 'b', 'LineWidth', 1.5);
H35 = shadedErrorBar(time, Peak_value(3,:), Peak_error(3,:), 'lineprops', '-b');

ylabel('Worm Angular Speed (mm/s)');
xlabel('Time(s)');
set(gca, 'xlim', [min(time) max(time)]);
set(gca, 'ylim', [-10 60]);
grid on
legend([H1, H2, H3], ... 
    '0.25mW Peak', '0.75mW Peak', '1.5mW Peak', ... 
    'location', 'Northeast');



Decay_value = zeros(10, 1620);
Decay_error = zeros(10, 1620);
Decay_value(1,:) = (Average(2,:) + Average(7,:))/2;
Decay_error(1,:) = (Standard(2,:) + Standard(7,:))/2;
Decay_value(2,:) = (Average(4,:) + Average(8,:))/2;
Decay_error(2,:) = (Standard(4,:) + Standard(8,:))/2;
Decay_value(3,:) = (Average(3,:) + Average(9,:))/2;
Decay_error(3,:) = (Standard(3,:) + Standard(9,:))/2;
Decay_value(4,:) = (Average(5,:) + Average(10,:))/2;
Decay_error(4,:) = (Standard(5,:) + Standard(10,:))/2;


figure; hold on;
H1 = plot(time, Decay_value(1,:), 'Color', 'k', 'LineWidth', 1.5);
H15 = shadedErrorBar(time, Decay_value(1,:), Decay_error(1,:), 'lineprops', '-k');
H2 = plot(time, Decay_value(2,:), 'Color', 'g', 'LineWidth', 1.5);
H25 = shadedErrorBar(time, Decay_value(2,:), Decay_error(2,:), 'lineprops', '-g');
H3 = plot(time, Decay_value(3,:), 'Color', 'b', 'LineWidth', 1.5);
H35 = shadedErrorBar(time, Decay_value(3,:), Decay_error(3,:), 'lineprops', '-b');
H4 = plot(time, Decay_value(4,:), 'Color', 'm', 'LineWidth', 1.5);
H45 = shadedErrorBar(time, Decay_value(4,:), Decay_error(4,:), 'lineprops', '-m');

ylabel('Worm Angular Speed (mm/s)');
xlabel('Time(s)');
set(gca, 'xlim', [min(time) max(time)]);
set(gca, 'ylim', [-10 60]);
grid on
legend([H1, H2, H3, H4], ... 
    '0.75mW Peak, 180s Decay', '0.75mW Peak, 360s Decay', '1.5mW Peak, 180s Decay', ' 1.5mW Peak, 360s Decay',  ... 
    'location', 'Northeast');


