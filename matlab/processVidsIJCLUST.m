function processVids(dates, numworms, small) %dates is a cell array with lists of foldernames with subfolders to be processed (generally organized by dates videos were taken)

faults = {};
f = 1;

for d=1:length(dates)
    cd (char(dates(d)))
    folders = dir; %avi should be in own folder named date_genotype_vid#_Cam#
    vids = {};
    for i=3:length(folders)
        vids(i-2)={folders(i).name};
        cam = char(vids(i-2));
        cam = cam((length(cam)-3):end);
        measure = strcat('measure', cam, '.avi');
       
     TrackerAutomatedScript2(', 'scale', 'measureCam1.avi','NumWorms', [10, 500]);
           
       
    end
    
    for i=1:length(vids)
        try
            processTracks(char(vids(i)));
        catch
            faults{f} = sprintf('%s failed processTracks\n', vids{i});
            f = f + 1;
        end
    end
    cd ..
end

for v = 1:f-1
    fprintf('%s \n', faults{v})
end

end
