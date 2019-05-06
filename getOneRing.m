function getOneRing(date, FilePrefix)
    % FilePrefix is the name of the folder containing the .avi file with the same name.
    % Script for generating Ring file using Matlab GUI.
    % Can transfer .avi, .Ring, and measureCam files to cluster and resume analysis using TrackerAutomatedScript2 function.

    
    % Turn off anticipated warnings
    warning('off', 'images:initSize:adjustingMag') % Image resizing during user region selection in GUI

    
    % Set up paths and dumb variables for Navin scripts
    directoryListFilename = sprintf('%s.avi', FilePrefix);
    PathName = sprintf('G:%sExperiments%s%s', filesep, filesep, date); % hard-coded for Kamal's hard drive.
    filename_parts      = strsplit('_', directoryListFilename);
    filename_last_part  = char(filename_parts(end));
    cam_number          = filename_last_part(4); % Hard-coded for single-digit cam numbers
    pixelsize_MovieName = sprintf('G:%sExperiments%smeasureCam%s.avi', filesep, filesep, cam_number);
    
    
    % Change directory to date folder because Navin scripts are dumb
%     cd(PathName)

    
    % Dumb dependencies for Navin scripts
    global Prefs;
    Prefs = [];
    Prefs = define_preferences(Prefs);
    aviread_to_gray;
    scaleRing = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
    Prefs.DefaultPixelSize = scaleRing.PixelSize;
    Prefs.PixelSize = scaleRing.PixelSize;
    Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);

    
    % Calculate background and get Ring ROI using GUI
    background = calculate_background(sprintf('%s%s%s%s%s.avi',PathName, filesep, FilePrefix, filesep, FilePrefix));
    Ring = find_square_ring_manually(background, background); %#ok "Ring unused"; Ring is saved in the next line
    save(sprintf('%s%s%s%s%s.Ring.mat', PathName, filesep, FilePrefix, filesep, FilePrefix), 'Ring');

end