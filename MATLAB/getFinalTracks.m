function [allFinalTracks] = getFinalTracks(groups) %filenames must be Date_Group_vid#.finalTracks.mat
dirList = dir;
dirList = dirList(3:length(dirList));
allFinalTracks = struct();
j=1;
for (i=1:length(dirList))
   for (j=1:length(groups))
       if (~isempty((strfind(dirList(i).name,groups(j)))))
        group = char(groups(j));
       end
   end
   load(dirList(i).name);
   if (isfield(allFinalTracks,group))
       oldFinalTracks = allFinalTracks.(group);
       allFinalTracks.(group) = [oldFinalTracks finalTracks];
   else
       allFinalTracks.(group) = finalTracks;
   end
end