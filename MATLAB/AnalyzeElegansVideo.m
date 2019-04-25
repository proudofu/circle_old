%% this is a wrapper for processing of C. elegans videos

function AnalyzeElegansVideo(fileName,numWormsInd,numWormsVec)

    TrackerAutomatedScript(fileName,'NumWorms',numWormsVec);
    
    %%%find linkedTracks file
    
    currDir = dir;
    for(i=3:length(currDir))
        testmatch = strfind(currDir(i).name,'linkedTracks');
        if(length(testmatch>0))
            %then this is a linkedTracks file
            ltInd = i;
        end
    end
    
    load(currDir(ltInd).name);
    
    ref_events = {'lRevOmega' 'lRevUpsilon' 'pure_lRev' 'pure_omega' 'pure_sRev' 'sRevOmega' 'sRevUpsilon'};
    %tracknum=6;
    numTracks = length(linkedTracks);
    for(tracknum=1:numTracks)

        Reorient_Data = linkedTracks(tracknum).Reorientations;
        keeperind = [];
        for(i=1:length(Reorient_Data))
            class = Reorient_Data(i).class;
            testmatch = strmatch(class,ref_events);
            if(~isempty(testmatch))
                %then it is a real turn
                keeperind = [keeperind i];
            end
        end
    Reorient_Data = Reorient_Data(keeperind);
    linkedTracks(tracknum).Reorientations = Reorient_Data;
    

    end
    
    outputFileName = currDir(ltInd).name;
    save(outputFileName,'linkedTracks');
end


