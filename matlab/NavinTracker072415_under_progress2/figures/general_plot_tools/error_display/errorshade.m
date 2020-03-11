function[fillhandle,msg]=errorshade(xpoints,upper,lower,color,transparency)

if(nargin<4)
    color='k'; %default color is black
end

if(ischar(color))
    color = str2rgb(color);
end

if(nargin<5)    %default is to have a transparency of 0.25
    transparency=0.25;
end 

color(color==0) = 1-transparency;

if(size(xpoints,2)==1)
    xpoints = xpoints';
end

if(size(upper,2)==1)
    upper = upper';
end

if(size(lower,2)==1)
    lower = lower';
end

if length(upper)==length(lower) && length(lower)==length(xpoints)
    msg='';
    

    xpoints =[xpoints xpoints(end:-1:1) xpoints(1)];
    filled = [upper lower(end:-1:1) upper(1)];
    

    
   fillhandle=fill(xpoints,filled,color); %plot the data
   set(fillhandle,'EdgeColor','none');
 %   fillhandle=plot(xpoints,filled,'color',color);
   
    
    % set(fillhandle,'EdgeColor',color,'FaceAlpha',transparency,'EdgeAlpha',transparency);
    
    % dot_fill(xpoints,filled,color);
   
else
    msg='Error: Must use the same number of points in each vector';
end

