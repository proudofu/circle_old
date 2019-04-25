function [strainMats, avgs, stdErr] = showAvgCalTracks(calTracks, medWindow, varargin)
    medSpan = 30;
    medBuf = 3;
    thresh = 1.52;%1.35 < 1.52 < 1.75
    cmap = getCmap;

    clim = [-2 4];

    if length(varargin)>=1
        indie = varargin{1};
    else
        indie = false;%set show individual traces or stdErr
    end
    if length(varargin)>=2
        stepSize = varargin{2};
    else
        stepSize = false;
    end

    if ~exist('medWindow', 'var')
        medWindow = [5 10];
    end
    strains = fields(calTracks);
    avgs = struct();
    stdErr = struct();
    strainMats = struct();
    frameRate = calTracks.(strains{1})(1).frameRate;
    
    for s = 1:length(strains)%get pretty data
        cleanTracks = struct();
        strainTracks = calTracks.(strains{s});
        
        strainTracks = splitEvents(strainTracks, strains{s}, medSpan, medBuf, thresh);
        
        preSpan = max(arrayfun(@(x) find(x.refed, 1), strainTracks)) - 1;
        postSpan = max(arrayfun(@(x) max([find(~flip(x.refed), 1) isempty(find(~flip(x.refed), 1))*length(x.refed)]), strainTracks)) - 1;
        
        cleanTracks.refed = [zeros(1, preSpan) ones(1, postSpan)];
        if stepSize
            cleanTracks.speeds = reCalcSpeeds(strainTracks, preSpan, postSpan, medWindow, stepSize);
        else
            cleanTracks.speeds = getCleanSpeeds(strainTracks, preSpan, postSpan, medWindow);
        end
        
        cleanTracks.fluors = getCleanFluors(strainTracks, preSpan, postSpan, medWindow, medSpan, medBuf);
        
        if length(strainTracks) > 1
            avgs.(strains{s}).speed = nanmean(cleanTracks.speeds);
            avgs.(strains{s}).fluor = nanmean(cleanTracks.fluors);
            if ~indie
                stdErr.(strains{s}).speed = std(cleanTracks.speeds,'omitnan')./sqrt(sum(~isnan([cleanTracks.speeds])));
                stdErr.(strains{s}).fluor = std(cleanTracks.fluors,'omitnan')./sqrt(sum(~isnan([cleanTracks.fluors])));
            end
        else
            avgs.(strains{s}).speed = (cleanTracks.speeds);
            avgs.(strains{s}).fluor = (cleanTracks.fluors);
        
            stdErr.(strains{s}).speed = 0;
            stdErr.(strains{s}).fluor = 0;
        end
            
        fprintf('%s, n of %i\n', strains{s}, size(cleanTracks.fluors, 1))
        strainMats.(strains{s}) = cleanTracks;
        
        if ~indie
            [t, timey] = showStrainTracksStdErr(strains{s}, length(strainTracks), avgs.(strains{s}).speed, avgs.(strains{s}).fluor, ...
                stdErr.(strains{s}).speed, stdErr.(strains{s}).fluor, cleanTracks.refed, frameRate, preSpan, postSpan, medWindow, medSpan, medBuf);
            fig = gcf;
            figure
            imagesc(cleanTracks.fluors, clim);
            title(sprintf('%s (n = %i), NSM Calcium \n(median window smoothing = -%0.2f  to +%0.2f seconds)', strains{s}, length(strainTracks), (medWindow(1)/frameRate), (medWindow(2)/frameRate)));
            xlabel(sprintf('Time (%s)', timey));
            zt = find(t == 0);
            if strcmp(timey, 'min')
                st = mod(zt, 600);
                tInds = [st:600:length(cleanTracks.refed)];
            else
                st = mod(zt, 10);
                tInds = [st:10:length(cleanTracks.refed)];
            end
            xticks(tInds);
            xticklabels(t(tInds));
            xlim([zt-300, zt+2400]);
            
            ax = gca;
            colormap(ax, cmap);
            c = colorbar;
            c.Label.String = 'Fluorescence';
            hold on
            
            plot([preSpan preSpan], [0 length(strainTracks)+ 2], 'Color', 'm', 'LineWidth', 1);
            
            %%%%%%make subplot
            title('');
            ylabel('Worm#');
            ax = gca;
            this = gcf;
            set(ax, 'Parent', fig);
            set(ax, 'Position', [0.5 0.7 0.35 0.2]);
            close(this)
            %%%%%
            
        else
            showStrainTracksIndie(strains{s}, length(strainTracks), avgs.(strains{s}).speed, avgs.(strains{s}).fluor, ...
                cleanTracks.speeds, cleanTracks.fluors, cleanTracks.refed, frameRate, preSpan, postSpan, medWindow);
        end
    end

end

function splitTracks = splitEvents(strainTracks, strain, medSpan, medBuf, thresh)
    splitTracks = struct();
    e = 1;
    for w = 1:length(strainTracks)
        
        totMedian = nanmedian(strainTracks(w).bgmedian);
        include = [strainTracks(w).bgmedian <= thresh*totMedian];
        strainTracks(w).sqintsub(~include) = NaN;
        
        crossings = find(diff(strainTracks(w).refed) ~= 0);
        crossings = [0; crossings; length(strainTracks(w).refed)];                
        if contains(strain, 'fed', 'IgnoreCase', true)
            if length(crossings) == 2
                span = [1:crossings(2)];
                
                preFedFluor = strainTracks(w).sqintsub(~strainTracks(w).refed(span));
                postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1);
                medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
                
                if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) >= medSpan/2
                    splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                    splitTracks(e).refed = strainTracks(w).refed(span);
                    splitTracks(e).speed = strainTracks(w).speed(span);
                    splitTracks(e).xc = strainTracks(w).xc(span);
                    splitTracks(e).yc = strainTracks(w).yc(span);
                    splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                    splitTracks(e).frameRate = strainTracks(w).frameRate;
                    splitTracks(e).bgmedian = strainTracks(w).bgmedian(span);
                    e = e + 1;
                end
            else
                for c = 1:2:length(crossings)-2
                    span = [crossings(c)+1:(crossings(c+2))];
                    
%                     preFed = sum(~strainTracks(w).refed(span));
%                     if preFed - (medSpan + medBuf) >= 0
                    preFedFluor = strainTracks(w).sqintsub(~strainTracks(w).refed(span));
                    postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1); 
                    medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
                    if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) > medSpan/2
                        splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                        splitTracks(e).refed = strainTracks(w).refed(span);
                        splitTracks(e).speed = strainTracks(w).speed(span);
                        splitTracks(e).xc = strainTracks(w).xc(span);
                        splitTracks(e).yc = strainTracks(w).yc(span);
                        splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                        splitTracks(e).frameRate = strainTracks(w).frameRate;
                        splitTracks(e).bgmedian = strainTracks(w).bgmedian(span);
                        e = e + 1;
                    end
                end
            end
        elseif ~strainTracks(w).refed(1)
            if length(crossings) == 2
                span = [1:crossings(2)];
            else
                span = [1:(crossings(3))];
            end
            
%             preFed = sum(~strainTracks(w).refed(span));
%             if preFed - (medSpan + medBuf) >= 0
            preFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 0);
            postFedFluor = strainTracks(w).sqintsub(strainTracks(w).refed(span) == 1);
            medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
            if (length(preFedFluor) - (medSpan + medBuf)) > 0 && sum(~isnan(preFedFluor(medInds))) > medSpan/2 && sum(~isnan(postFedFluor(1:medSpan+medBuf))) > medSpan/2
                splitTracks(e).sqintsub = strainTracks(w).sqintsub(span);
                splitTracks(e).refed = strainTracks(w).refed(span);
                splitTracks(e).speed = strainTracks(w).speed(span);
                splitTracks(e).xc = strainTracks(w).xc(span);
                splitTracks(e).yc = strainTracks(w).yc(span);
                splitTracks(e).pixelSize = strainTracks(w).pixelSize;
                splitTracks(e).frameRate = strainTracks(w).frameRate;
                splitTracks(e).bgmedian = strainTracks(w).bgmedian(span);
                e = e + 1;
            end
        end
    end
    
    return
end

function normFluors = getCleanFluors(cals, preSpan, postSpan, medWindow, medSpan, medBuf)
    preFluors = NaN(length(cals), preSpan);
    postFluors = NaN(length(cals),postSpan);
    
    for w = 1:length(cals)
        fluor = cals(w).sqintsub;
        
        %########################################################################EXPERIMENTAL to normalize to non-negative!!!!!!!
%         fluor = fluor + abs(min(fluor))*(min(fluor)<0);%METHOD A
        fluor(fluor < 0) = NaN;%METHOD C$$$$$$BEST
%         fluor = (fluor - min(fluor))/(max(fluor) - min(fluor));%METHOD B
%       #####################################

        fluor = movmedian(fluor, medWindow, 'omitnan', 'Endpoints', 'shrink');%smooth
               
        preFedFluor = fluor(~cals(w).refed);
        if length(preFedFluor) > (medSpan + medBuf)
            medInds = (length(preFedFluor) - (medSpan + medBuf)):(length(preFedFluor)- medBuf);
        else 
            medInds = 1:length(preFedFluor);
        end
%         ####################$#$#$#$#$#$#$#$#$#$#
%         baseFluor = nanmedian(preFedFluor(medInds));
        baseFluor = nanmean(preFedFluor(medInds));
        
        if isempty(baseFluor) || isnan(baseFluor)
            baseFluor = nanmean(preFedFluor);
        end
        fluor = (fluor/baseFluor) - 1;
        %now normalized:
        preFedFluor = fluor(~cals(w).refed);
        postFedFluor = fluor(cals(w).refed == 1);
        
        preFluors(w, 1:length(preFedFluor)) = fliplr(preFedFluor');%NOTE: in reverse order for alignment purposes
        postFluors(w, 1:length(postFedFluor)) = postFedFluor';  
    end
    
    normFluors = [fliplr(preFluors) postFluors];
    return
end

function allSpeeds = getCleanSpeeds(cals, preSpan, postSpan, medWindow)
    preSpeeds = NaN(length(cals), preSpan);
    postSpeeds = NaN(length(cals),postSpan);
    
    for w = 1:length(cals)
        speed = cals(w).speed;
        speed(speed > 500) = NaN;
        speed = movmedian(speed, medWindow, 'omitnan', 'Endpoints', 'shrink');%medfilt1(cals(w).speed, medWindow, 'omitnan', 'truncate');        
        
        preFedSpeed = speed(~cals(w).refed);
        postFedSpeed = speed(cals(w).refed == 1);
        
        preSpeeds(w, 1:length(preFedSpeed)) = fliplr(preFedSpeed');%NOTE: in reverse order for alignment purposes
        postSpeeds(w, 1:length(postFedSpeed)) = postFedSpeed';  
    end
    
     allSpeeds = [fliplr(preSpeeds) postSpeeds];
    return
end

function newSpeeds = reCalcSpeeds(cals, preSpan, postSpan, medWindow, stepSize)
    %stepSize = 4;%must be even
    
    newCals = struct();
    for w = 1:length(cals)%each worm
        x = cals(w).xc;
        x = medfilt1(x, 3, 'omitnan', 'truncate');%
        dx = arrayfun(@(i) x(i+stepSize) - x(i), [stepSize/2:length(x)-stepSize]);
        dx = [NaN(stepSize/2, 1); dx'; NaN(stepSize, 1)];
        
        y = cals(w).yc;
        y = medfilt1(y, 3, 'omitnan', 'truncate');%
        dy = arrayfun(@(i) y(i+stepSize) - y(i), [stepSize/2:length(y)-stepSize]);
        dy = [NaN(stepSize/2, 1); dy'; NaN(stepSize, 1)];
        
        dist = sqrt(dx.^2 + dy.^2);
        dist = dist*cals(w).pixelSize;
        newCals(w).speed = dist*(cals(w).frameRate/stepSize);
        newCals(w).refed = cals(w).refed;
        
    end
    newSpeeds = getCleanSpeeds(newCals, preSpan, postSpan, medWindow);
    
    return
end

function [t, timey] = showStrainTracksStdErr(strain, num, speed, fluor, stdErrSpeed, stdErrFluor,...
    refed, frameRate, preSpan, postSpan, medWindow, medSpan, medBuf)

    t = [-preSpan:postSpan]/frameRate;%t in seconds
    if length(t) > length(speed)
        t = t(1:end-1);
    end
    timey = 'sec';
    xLim = [-30 240];
    if max(t) > 300
        t = t/60;%t in minutes
        timey = 'min';
        xLim = [-0.5 4];
    end
    
    figure;
    hold on;
    title(sprintf('%s (n = %i), NSM Calcium vs. Speed\n', strain, num)); %(median window smoothing = -%0.2f  to +%0.2f seconds)
    xlabel(sprintf('Time (%s)', timey));
    
    yyaxis left
    err = stdErrFluor;
    %errorshade(t,[fluor + err],[fluor - err], [0 .8 0]);
    patch([t NaN],[fluor NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1)
    ylabel('Fluoresence intensity (R.U.)');
    set(gca, 'YColor', [0 .8 0])
    set(gca, 'ylim', [-2 2])
    grid on
    
    yyaxis right
    err = stdErrSpeed;
    %errorshade(t,[speed + err],[speed - err], 'b');
    patch([t NaN],[speed NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1)
    ylabel('Speed (um/sec)');
    set(gca, 'YColor', 'b')
    set(gca, 'ylim', [0 250])

    set(gca, 'xlim', xLim);%###################XLIM
%     set(gca, 'xlim', [-(medSpan+medBuf)/60 4]);
    xs = [min(t) max(t)];
    lawnTime = t(find(refed == 1, 1)):0.01:xs(2);

    ys = [-9999 9999];
    lawnYs(1:length(lawnTime)) = [ys(1)];
    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
    lawnTime = [lawnTime, flip(lawnTime)];
    
    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.13, 'LineStyle', ':');

end

function showStrainTracksIndie(strain, num, speed, fluor, indieSpeeds, indieFluors,...
    refed, frameRate, preSpan, postSpan, medWindow)

    t = [-preSpan:postSpan]/frameRate;%t in seconds
    if length(t) > length(speed)
        t = t(1:end-1);
    end
    timey = 'sec';
    if max(t) > 300
        t = t/60;%t in minutes
        timey = 'min';
    end
    
    figure;
    hold on;
    title(sprintf('%s (n = %i), NSM Calcium vs. Speed\n(median window smoothing = -%0.2f  to +%0.2f seconds)', strain, num, (medWindow(1)/frameRate), (medWindow(2)/frameRate)));
    xlabel(sprintf('Time (%s)', timey));
    ylabel('Speed (um/sec)');
%     for w = 1:size(indieSpeeds,1)
%         plot(t,indieSpeeds(w, :), 'Color', 'b', 'LineStyle', ':', 'LineWidth', 0.1);
%     end
    patch([t NaN],[speed NaN], 'b', 'EdgeColor', 'b', 'LineWidth', 1.5)
    yyaxis left
    set(gca, 'YColor', 'b')
    set(gca, 'ylim', [0 250])

    yyaxis right
    patch([t NaN],[fluor NaN], [0 .8 0], 'EdgeColor', [0 .8 0], 'LineWidth', 1.5)
    ylabel('Fluoresence intensity (R.U.)');
    set(gca, 'YColor', [0 .8 0])
    set(gca, 'ylim', [-2 2])

    set(gca, 'xlim', [min(t) max(t)]);
    xs = xlim;
    lawnTime = t(find(refed == 1, 1)):0.01:xs(2);

    ys = ylim;
    lawnYs(1:length(lawnTime)) = [ys(1)];
    lawnYs(length(lawnTime)+1:length(lawnTime)*2) = [ys(2)];
    lawnTime = [lawnTime, flip(lawnTime)];

    fill(lawnTime, lawnYs, 'c', 'FaceAlpha', 0.1, 'LineStyle', ':');
    
    for w = 1:size(indieFluors,1)
        disp('Press any key to continue');
        pause;
        yyaxis right
        plot(t,indieSpeeds(w, :), 'Color', 'b', 'LineWidth', 0.001, 'Marker', 'none', 'LineStyle', ':');
        yyaxis left
        plot(t,indieFluors(w, :), 'Color', [0 .8 0], 'LineWidth', 0.001, 'Marker', 'none', 'LineStyle', ':');
    end
    
end

function cmap = getCmap
cmap = [0         0    0
         0         0    0.6111
         0         0    0.6597
         0         0    0.7083
         0         0    0.7569
         0         0    0.8056
         0         0    0.8542
         0         0    0.9028
         0         0    0.9514
         0         0    1.0000
         0    0.0833    1.0000
         0    0.1667    1.0000
         0    0.2500    1.0000
         0    0.3333    1.0000
         0    0.4167    1.0000
         0    0.5000    1.0000
         0    0.5833    1.0000
         0    0.6667    1.0000
         0    0.7500    1.0000
         0    0.8333    1.0000
         0    0.9167    1.0000
         0    1.0000    1.0000
         0    0.9818    0.9091
         0    0.9636    0.8182
         0    0.9455    0.7273
         0    0.9273    0.6364
         0    0.9091    0.5455
         0    0.8909    0.4545
         0    0.8727    0.3636
         0    0.8545    0.2727
         0    0.8364    0.1818
         0    0.8182    0.0909
         0    0.8000         0
    0.0909    0.8182         0
    0.1818    0.8364         0
    0.2727    0.8545         0
    0.3636    0.8727         0
    0.4545    0.8909         0
    0.5455    0.9091         0
    0.6364    0.9273         0
    0.7273    0.9455         0
    0.8182    0.9636         0
    0.9091    0.9818         0
    1.0000    1.0000         0
    1.0000    0.9286         0
    1.0000    0.8571         0
    1.0000    0.7857         0
    1.0000    0.7143         0
    1.0000    0.6429         0
    1.0000    0.5714         0
    1.0000    0.5000         0
    1.0000    0.4286         0
    1.0000    0.3571         0
    1.0000    0.2857         0
    1.0000    0.2143         0
    1.0000    0.1429         0
    1.0000    0.0714         0
    1.0000         0         0
    0.9167         0         0
    0.8333         0         0
    0.7500         0         0
    0.6667         0         0
    0.5833         0         0
    0.5000         0         0];
end