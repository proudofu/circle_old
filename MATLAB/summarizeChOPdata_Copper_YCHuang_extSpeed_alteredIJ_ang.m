% Takes a folder, finds linkedTracks files within the embedded folders, 

% finds the animals that were within the ROI 

% at appropriate times and gives back data in matrix form, where each line

% is a single time that an animal was hit with the LED:



% column 1: track number (i.e. anim #);

% column 2: stimulus numb (e.g. 5th of out of 6 stim)

% column 3: NaN

% column 4: NaN

% columns 5-1624: speed starting at t = -2min







function [AllChOPHits] = summarizeChOPdata_Copper_YCHuang_extSpeed(linkedTracks,stimulusfile,stimtoIncl)

   %Which Stimuli are we including?

    stimulus = load(stimulusfile);

    if(stimtoIncl==0)

        stimtoIncl= 1:1:length(stimulus(:,1));

    end

    

    index1 = 1;

    %%%%%%find relevant tracks and annotate stimulusvector field

    ChOPfinalTracks = identifyChOPTracks_Copper_YCHUang(linkedTracks,stimulusfile,stimtoIncl);   
%    [EventTimes] = IdentifyReversalTimes(ChOPfinalTracks);
    

    %%%%Gather relevant data vectors from ChOPfinalTracks

    lengthofStimFrames = ((stimulus(stimtoIncl(1),2)-stimulus(stimtoIncl(1),1)) * 3);

 

    

    for(i=1:length(ChOPfinalTracks))

        ChOPFrames = find(ChOPfinalTracks(i).stimulus_vector==1);

        numChOPFrames = length(ChOPFrames);

        numStimuli = numChOPFrames/lengthofStimFrames;

        for(j=1:numStimuli)



            %%Go back in time 360 frames, and then forward in time 809

            %%frames - total = 270 second window

            StartIndex = (ChOPFrames((lengthofStimFrames*j)-(lengthofStimFrames-1)))-360;           

            StopIndex = StartIndex+809+810;
            
            NumberofFOI = StopIndex-StartIndex+1;



            if(StartIndex>0) 

                if(StopIndex<length(ChOPfinalTracks(i).Frames))

                    %Then we have the data, so put it into AllChOPHits

                    Tracknumb = i;

                    AllChOPHits(index1,1) = Tracknumb;



                    StartFrame = ChOPfinalTracks(i).Frames(StartIndex+360);

                    Stimuli = (stimulus(:,1))*3;

                    StimulusNumb = unique(find(Stimuli==StartFrame));

                    AllChOPHits(index1,2) = StimulusNumb;



                    %Find Speed and AngSpeed, put into AllChOPHits Matrix

                    %Speed = ChOPfinalTracks(i).Speed(StartIndex:StopIndex);

                    AngSpeed = abs(ChOPfinalTracks(i).AngSpeed(StartIndex:StopIndex));  

                    AllChOPHits(index1,3:4) = NaN;

                    %AllChOPHits(index1,5:1624) = Speed(1:end);

                    AllChOPHits(index1, 5:1624) = AngSpeed(1:end);
                    
                    %%%%Find, bin, and store Reversals

%                     BinLength = 15; % in frames
%                     edges = [1 BinLength:BinLength:810]; % define the borders of the bins
%                     edges = edges+StartIndex-1;
%                     numBins = length(edges);
%                     binnedData = zeros(1,numBins); % initialize with all zeros
%                     if(~isempty(EventTimes{Tracknumb}))
%                         EventTimes_Vect = EventTimes{Tracknumb}; % Get Vector of animal's Reorientation Start Times and change to real time (divide by 180)
%                         binnedData = binnedData + histc(EventTimes_Vect,edges); % use histc to sum events in each bin
%                     end
%                     binnedData = binnedData*12;
% %                     display(StartIndex)
% %                     display(StopIndex)
% %                     display(edges)
% %                     display(EventTimes_Vect)
% %                     display(binnedData)
% %                     pause;
% 
%                     AllChOPHits(index1,(NumberofFOI*2)+5:(NumberofFOI*2)+59) = binnedData;

                    index1 = index1+1;

                end

            end

        end

        

    end

 %   subplot(3,1,1)
  %  plot(nanmean(AllChOPHits(:,5:814)))    
  %  subplot(3,1,2)
  %  plot(nanmean(AllChOPHits(:,815:1624)))
 %   subplot(3,1,3)
%    plot(nanmean(AllChOPHits(:,1625:1679)))
    
end



            

    

    