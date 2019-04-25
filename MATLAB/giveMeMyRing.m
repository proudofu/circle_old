function Ring = giveMeMyRing(pixelsize_MovieName,PathName, filesep, FilePrefix)
global Prefs;
Prefs = [];
target_numworms = 0;
Prefs = define_preferences(Prefs);
scaleRing = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
Ring.RingX = [];
Ring.RingY = [];
Ring.ComparisonArrayX = [];
Ring.ComparisonArrayY = [];
Ring.Area = 0;
Ring.Level = eps;
Ring.PixelSize = Prefs.DefaultPixelSize;
Ring.FrameRate = Prefs.FrameRate; % default framerate
Ring.NumWorms = [];
Ring.DefaultThresh = [];
Ring.meanWormSize = [];
background = calculate_background(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix));
summary_image = background; % calculate_summary_image(moviename);
Ring = find_square_ring_manually(background, summary_image);
Ring.PixelSize = scaleRing.PixelSize;
if(isempty(Ring.DefaultThresh))
    [~, ~, ~, Ring] = default_worm_threshold_level(sprintf('%s%s%s.avi',PathName, filesep, FilePrefix), background, [], target_numworms, Ring, 1);
end
ringfile = sprintf('%s%s%s.Ring.mat',PathName, filesep, FilePrefix);
save(ringfile, 'Ring');
return

end