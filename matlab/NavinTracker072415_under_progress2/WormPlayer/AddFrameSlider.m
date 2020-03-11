function AddFrameSlider(hfig,pos1,pos2)

movieData = get(hfig,'userdata');

frameText = ''; 
movieData.FrameSlider = uicontrol(hfig, ...
    'tag', 'SLIDER', ...
    'enable', 'off', ...
    'style', 'slider', ...
    'Position', pos1, ... 
    'callback', @ChooseFrame); 

movieData.FrameSliderText = uicontrol(hfig, ...
    'style','text', ...
    'tag', 'SLIDERTEXT', ...
    'string', frameText, ...
    'Position', pos2);

set(hfig,'userdata', movieData);

end

