function showCalTracks(calTracks, medWindow)
% make sure structure being fed into function is not nested
    if ~exist('medWindow', 'var')
        medWindow = [5 5];
    end
    allCals = calTracks;
    c = length(calTracks);    
    
    medSpan = 50;
    medBuf = 5;

    fig = figure;
    hold on
    for d = 1:c
        calTracks = allCals(d);
        strains = fields(calTracks);
        frameRate = calTracks.frameRate;
        speed = calTracks.speed;
        fluor = movmedian(calTracks.sqintsub, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(calTracks.(strains{s})(w).sqintsub, medWindow, 'omitnan', 'truncate');
        preFedFluor = fluor(~calTracks.refed); 
        if length(preFedFluor) > (medSpan + medBuf)
                    medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
        else 
                    medInds = length(preFedFluor);
        end
        baseFluor = nanmedian(preFedFluor(medInds));
        if isempty(baseFluor) || isnan(baseFluor)
              baseFluor = nanmean(preFedFluor);
        end
        normFluor = (fluor/baseFluor) - 1;
        pre = find(calTracks.refed == 1,1) - 1;
        post = length(calTracks.refed) - pre - 1;
        t = [-pre:post]/calTracks.frameRate;%t in seconds
        timey = 'sec';
        if max(t) > 300
             t = t/60;%t in minutes
             timey = 'min';
        end
        ys = [-1000 1000];
                
        crossings = find(diff(calTracks.refed) ~= 0);
        if isempty(crossings) && calTracks.refed(1) == 1
                    crossings = 1;
        end 
        if mod(length(crossings),2)
                    crossings(end + 1) = length(t);
                end
        for l = 1:2:length(crossings)
            lawnTime = t(crossings(l):crossings(l+1));
            lawnYs(1:length(lawnTime)) = [ys(1)];
            lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
            lawnTime = [lawnTime, flip(lawnTime)];
            %lawnYs = [lawnYs fliplr(lawnYs)];
            fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.1, 'LineStyle', ':');
            clear lawnTime lawnYs;
        end
         yyaxis left
         plot(t, normFluor, 'Color', [0 .8 0])
         ylabel('Fluoresence intensity (R.U.)');
         set(gca, 'YColor', [0 .8 0])
         set(gca, 'ylim', [-1 4])
         grid on
        % yyaxis right
        % plot(t, speed, 'Color', 'b');
         title(sprintf('Worm %s, NSM Calcium & Speed \n %s', d, calTracks.name));
        % xlabel(sprintf('Time (%s)', timey));
        % ylabel('Speed (um/sec)');                
                
         %set(gca, 'YColor', 'b')
         %set(gca, 'ylim', [0 250])

         set(gca, 'xlim', [min(t) max(t)]);
         set(gcf, 'UserData', t)
         disp('Press any key to continue');
         pause;
         clf;
         hold on
       end
    end