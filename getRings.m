function getRings(date)
    % Master function for generating .Ring files for each video in a given folder (named 'date')
    % Launches getRing for each .avi 
    
    % Establish path to date folder
    path  = 'X:/circle_data_local';
    folders = dir(sprintf('%s%s%s', path, filesep, date));
    
    % Display encouraging and informative instructions on selecting the ROI
    questdlg(sprintf('Select three points to define the circular ROI and hit the Return button when done.'),...
    sprintf("You're doing a great job."), 'OK', 'OK');
    
    % Loop through each video folder and get .Ring file
    for i = 3:length(folders)
        folder = folders(i).name; % name of the folder
        % If a folder and not the one containing the plots, called 'figure'...
        if isfolder(sprintf('%s%s%s%s%s', path, filesep, date, filesep, folder)) && (convertCharsToStrings(folder) ~= "figure")
            % ... then launch the GUI and get the .Ring ROI
            getOneRing(date, folder);
        end
    end

end
