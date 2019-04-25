
% Panel can incorporate an existing axis.
%
% (a) Create the root panel.
% (b) Create an axis yourself.
% (c) Pack an automatically created axis, and your own axis,
%       into the root panel.



%% (a)

% create a column-pair layout
p = panel();
p.pack('h', [95 -1]);

% and put an axis in the left one
h_axis = p(1).select();

% and, hell, an image too
[X,Y,Z] = peaks(50);
surfc(X,Y,Z);



%% (b)

% sometimes you'll want to use some other function than
% Panel to create one or more axes. for instance,
% colorbar...
h_colorbar_axis = colorbar('peer', h_axis);



%% (c)

% panel can manage the layout of these too
p(2).select(h_colorbar_axis);



