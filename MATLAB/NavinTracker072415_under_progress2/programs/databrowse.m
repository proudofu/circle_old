function handle = databrowse(mat,x,ygroup,defaultsettings)% find or make DataBrowse figurefigH = findobj(0,'tag','DataBrowse');if isempty(figH)    figH = figure(25); set(figH,'Tag','DataBrowse','Name','DataBrowse','NumberTitle','off');endfigure(figH);% find existing data if none givenif ~exist('mat')    Data = get(figH,'UserData');    if ~isempty(Data)        mat = Data.mat;        x = Data.x;        ygroup = Data.ygroup;        h = Data.handles;        sig = Data.sig; output = Data.output;    endendif ~exist('x') || isempty(x) x = 1:size(mat,2); endif ~exist('ygroup') || isempty(ygroup) ygroup = ones(size(mat,1),1); endif ~exist('sig') sig = []; endif ~exist('output') output = []; end% get group info[a,b,c] = unique(ygroup); [d,e] = sort(b); [f,g] = sort(e);groups = a(e); groupindex = g(c);ds = {1:length(groups),0,1,0,1,1,1,0};if ~exist('defaultsettings')     defaultsettings = ds;else    deflen = length(defaultsettings);    if deflen < length(ds)        defaultsettings(deflen+1:length(ds)) = ds(deflen+1:length(ds));    endend% default settingsif ~exist('Data') || ~isfield(Data,'settings')    Data.settings = defaultsettings;else    Data.settings = get(h(3:10),'Value');endvalues = [1:6,8,10,15,20,25,30];% set up figure if neededif ~exist('h')    h(1) = subplot('Position',[.1 .55 .7 .4]);    h(2) = subplot('Position',[.1 .1 .7 .35]);    h(3) = uicontrol('Style', 'listbox',...           'Tag','grouplist',...           'Units','normalized',...           'Position', [0.85, 0.55, 0.1, 0.4],...           'String', groups,...           'Value', cell2mat(Data.settings(1)),...           'Min',1,'Max',length(groups)+1,...           'CallBack', 'databrowse;');             h(4) = uicontrol('Style', 'togglebutton',...           'Units','normalized',...           'Position', [0.85, 0.4, 0.1, 0.05],...           'String', 'Individual',...           'Value', cell2mat(Data.settings(2)),...           'CallBack', 'databrowse;');           h(5) = uicontrol('Style', 'togglebutton',...           'Units','normalized',...           'Position', [0.85, 0.35, 0.1, 0.05],...           'String', 'Mean',...           'Value', cell2mat(Data.settings(3)),...           'CallBack', 'databrowse;');           h(6) = uicontrol('Style', 'togglebutton',...           'Units','normalized',...           'Position', [0.85, 0.3, 0.1, 0.05],...           'String', 'SD',...           'Value', cell2mat(Data.settings(4)),...           'CallBack', 'databrowse;');           h(7) = uicontrol('Style', 'togglebutton',...           'Units','normalized',...           'Position', [0.85, 0.25, 0.1, 0.05],...           'String', 'SEM',...           'Value', cell2mat(Data.settings(5)),...           'CallBack', 'databrowse;');           h(8) = uicontrol('Style', 'togglebutton',...           'Units','normalized',...           'Position', [0.85, 0.2, 0.1, 0.05],...           'String', 'Fill',...           'Value', cell2mat(Data.settings(6)),...           'CallBack', 'databrowse;');       h(9) = uicontrol('Style', 'popupmenu',...           'Units','normalized',...           'String',sprintf('%d|',values),...           'Position', [0.85, 0.075, 0.1, 0.05],...           'Value', cell2mat(Data.settings(7)),...           'CallBack', 'databrowse;');    h(10) = uicontrol('Style', 'togglebutton',...           'Units','normalized',...           'Position', [0.85, 0.15, 0.1, 0.05],...           'String','Stats',...                      'Value', cell2mat(Data.settings(8)),...           'CallBack', 'databrowse;');%            uicontrol('Style', 'pushbutton',...%            'Units','normalized',...%            'Position', [0.85, 0.1, 0.1, 0.05],...%            'String', 'Transfer Plot to gca',...%            'CallBack', 'disp(gca); disp(gcf);');%        % %            'CallBack', 'Data = get(gcf,''UserData''); if gca ~= Data.h(8); copyobj(get(Data.h(8),''Children''),gca); end');           % set colors       %     a = [3 0 2 1 3 3 3 2 2 0 2 3 0 1 2 1 0 1 0 1 1%          0 0 1 1 0 3 2 2 1 2 0 1 3 2 3 0 1 3 0 2 0%          0 3 0 1 3 0 1 2 3 1 1 2 0 3 1 2 2 2 0 0 2]'/3;%     a = [3 0 0 2 0 1 1 0 2 %          0 0 3 1 2 0 2 1 0 %          0 3 0 0 1 2 0 2 1 ]'/3;    ng = max(5,length(groups)); sep = floor(254/(ng-1));%    a = jet(sep*(ng-1) + 1); a = a(1:sep:255,:);    a = jet(sep*(ng) + 1); a = a(1:sep:255,:);    set(h(2),'ColorOrder',a);endframeavg = values(cell2mat(Data.settings(7)));if frameavg > 1    mat2 = binaverage(mat',frameavg,0)';    x2 = x(1:frameavg:end);else    mat2 = mat;     x2 = x;end% plot heatmapxn = x2; if iscell(x2) xn = 1:length(x); endsubplot(h(1)); imagesc(xn,1:size(mat2,1),mat2); xlabel('Time');set(gca,'YTick',1:size(mat2,1),'YTickLabel',ygroup);colormap([.7 .7 .7; jet(254)]);colorbar;if iscell(x) set(gca,'XTick',xn,'XTickLabel',num2str(cell2mat(x))); end    % plot tracessubplot(h(2)); cla; hold on;% get ui settingsgroupsel = cell2mat(Data.settings(1));showind = cell2mat(Data.settings(2));showmean = cell2mat(Data.settings(3));showsd = cell2mat(Data.settings(4));showsem = cell2mat(Data.settings(5));plotfilled = cell2mat(Data.settings(6));showstats = cell2mat(Data.settings(8));if showstats & isempty(sig)    %allexps = iselement(groupindex,groupsel);    tic    for i = 1:size(mat,2);         output = anova1multicompare(mat(:,i),ygroup);         sig(:,i) = output.stats(:,4);     end    tocendydat = [];for g = 1:length(groupsel)    exps = find(groupindex == groupsel(g));        if length(exps)>1        ymean = nanmean(mat2(exps,:));        ysd = nanstd(mat2(exps,:));        ysem = ysd / sqrt(length(exps));    else        ymean = mat2(exps,:);        ysd = zeros(size(ymean)); ysem = ysd;    end        colors = get(gca,'ColorOrder');    color = colors(rem(groupsel(g)-1,size(colors,1))+1,:);        if showsd        if plotfilled            jbfill(xn, ymean-ysd, ymean+ysd, .8+.2*color, .8+.2*color, 1, 1);        else            errorbar(xn, ymean, ysd, 'Color', .6+.4*color);        end    end    hold on;        if showsem        if plotfilled            jbfill(xn, ymean-ysem, ymean+ysem, .6+.4*color, .6+.4*color, 1, 1);        else            errorbar(xn, ymean, ysem, 'Color', .8*color);        end    end    hold on;    if showind        plot(xn,mat2(exps,:),'Color',color);    end        if showmean        plot(xn,ymean,'LineWidth', 2,'Color', .7*color, 'Tag','mean');    end        if showstats & length(groupsel)>1 & g>1        c = find(output.stats(:,1) == groupsel(1) & iselement(output.stats(:,2),groupsel(g)));        scatter(xn,ymean,(sig(c,:)+1).^3,.5*color)    end        ydat(g,:,1) = ymean;    ydat(g,:,2) = ysd;    ydat(g,:,3) = ysem;endif iscell(x) set(gca,'XTick',xn,'XTickLabel',num2str(cell2mat(x))); end%set(findobj(gca,'type','patch'),'EdgeAlpha',0,'FaceAlpha',0.6);legh = findobj(gca,'Tag','mean');if ~isempty(legh)    legend(flipud(legh), groups(groupsel));end% deposit data in figureData.mat = mat;Data.x = x;Data.ygroup = ygroup;Data.handles = h;Data.sig = sig;Data.output = output;Data.ydata = ydat;set(figH,'UserData',Data);handle = h([2,1]);return;end%-----------------------------------------function M2 = binaverage(M, x, crop)%  function M2 = binaverage(M, x, crop)%%  where M is the matrix with row-data to be averaged%    and x is the multiplier (# of bins to combine)%    and crop = 1 drops any extra originalbinsif nargin < 3 crop = 0; endM2 = [];lenM = size(M,1);for i = 1:floor(lenM / x)    Msection = M((i-1)*x+1:i*x,:);    Mavg = nanmean(Msection);    M2 = [M2; Mavg];end% if any bins left...if (lenM > (i*x) & ~crop)    Msection = M(x*i+1:lenM,:);    Mavg = nanmean(Msection);    M2 = [M2; Mavg];endreturn;end%-----------------------------------------function[fillhandle,msg]=jbfill(xpoints,upper,lower,color,edge,add,transparency)if nargin<7;transparency=.5;end %default is to have a transparency of .5if nargin<6;add=1;end     %default is to add to current plotif nargin<5;edge='k';end  %dfault edge color is blackif nargin<4;color='b';end %default color is blueupper(find(isnan(upper)))=0;lower(find(isnan(lower)))=0;if edge == -1;    edge = 'k';    noedge = 1;else    noedge = 0;endif length(upper)==length(lower) && length(lower)==length(xpoints)    msg='';    filled=[upper,fliplr(lower)];    xpoints=[xpoints,fliplr(xpoints)];    if add        hold on    end    fillhandle=fill(xpoints,filled,color);%plot the data    set(fillhandle,'EdgeColor',edge,'FaceAlpha',transparency,'EdgeAlpha',transparency);%set edge color        if noedge        set(fillhandle,'LineStyle','none');    end        if add        hold off    end    set(gca,'Layer','top');else    msg='Error: Must use the same number of points in each vector';endreturn;end%-----------------------------------------function output = anova1multicompare(datavector, groupvector, plist, comparisontype)% USAGE: output = anova1multicompare(datavector, groupvector, plist, comparisontype)%%       plist is list of p-values to test (default is : [0.05 0.01 0.001 0.0001]%       comparisontype is 'tukey-kramer' (default), 'bonferroni', etc.%if nargin < 4 comparisontype = 'tukey-kramer'; endif nargin < 3 plist = [0.05 0.01 0.001 0.0001]; endplist = [1,sort(plist,'descend')];ds = size(datavector);gs = size(groupvector);if ~all(ds == gs)    if all(ds == fliplr(gs))        gs = gs';    else        error('datavector and groupvector must have same size');        return    endend    [p,t,st] = anova1(datavector,groupvector,'off');output.anovap = p;output.anovat = t;output.anovast = st;n = 0; for i = 1:length(st.means)-1; n = n+i; endpvali = ones(n,1);for i = 2:length(plist)    [c,m,h,gnames] = multcompare(st,'alpha',plist(i),'ctype',comparisontype,'display','off');    ptest = ~xor(c(:,3)>0, c(:,5)>0);  % true if comparison p-value at least plist(i)    pvali = pvali + ptest;    output.multcomp(i-1).alpha = plist(i);    output.multcomp(i-1).c = c;endpval = plist(pvali);ns = find(pvali == 1);output.stats = [c(:,[1 2 4]), pvali-1, pval'];output.statcell = [gnames(c(:,1:2)), num2cell(c(:,4)), num2cell(pval')];output.statcell(ns,4) = {'n.s.'};output.groups = gnames;return;end