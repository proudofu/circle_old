classdef GraphScannerGUI < hgsetget & handle
%GraphScannerGUI Class for extracting points from a picture.
    %{ 
      This program is a GUI which enables to define desired points 
      from a given picture.
      
      Mikko Lepp�nen 08/03/2011 ver. 2.2
    %}
    properties (Access = private)
        logo;
        logoErr = false;
    end
    properties (Constant)
        hMainFigColor = [0.6 0.8 1];
        color = repmat(0.8,1,3);
        scaleIndex = 7.5e-3;
    end
    properties
        hMainFig;
        hFileMenu;
        hOptionsMenu;
        hLoadPictureMenu;
        hCoordinateSystemMenu;
        hNewCurveMenu;
        hCurveDataPanel;
        hScalePushPlus;
        hScalePushMinus;
        hPicturePanel;
        hCurveDataTable;
        hConMenu;
        hSelectedXPoint;
        hSelectedYPoint;
        hCurveList;
        hFitMenu;
        tableData = zeros(10,2);
        scaleValuePlusPre;
        scaleValueMinusPre;
        defaultCurveName = {'Curve dataset',''};
        xyScaleMatrix = zeros(2,1);
        xyCoordinatesMatrix = zeros(3,4);
        colorDataInd =  struct('linecolor',{zeros(3,1)},...
                               'markerecolor',{[1 0 0]},...
                               'markerfcolor',{[0 0 1]});
        gridSpacing = ones(2,1);
        origPicSize = zeros(2,1);
        cellSelectionPreData = [];
        coordinateFigState;
        curveNames = {};
        xDataHistory = {};
        yDataHistory = {};
        xyDataValues = {};
        scaleHistory = {};
        coordinateHistory = {};
        xAxisLabel = '';
        yAxisLabel = ''; 
    end
    properties(SetObservable)
        isGuiAlter = false;
    end
    
    events 
        updateGraph
    end

    methods
        function obj = GraphScannerGUI
            % Class constructor builds main window for the GUI and setup
            % necessary uicontrols
            clc;
            format long;
            screensize = get(0,'ScreenSize');
            obj.hMainFig = figure('units','pixels',...
                                  'pos',[screensize(1)*50,screensize(2)*50,...
                                         screensize(3)*0.75,screensize(4)*0.75],...
                                  'name','GraphScanner',... 
                                  'numbertitle', 'off',... 
                                  'menubar','none',...
                                  'visible','on',...
                                  'toolbar','figure',...
                                  'color',obj.hMainFigColor,...
                                  'tag','GSFig',...
                                  'CreateFcn','movegui(''center'')',...
                                  'DeleteFcn',@(varargin)figDeleteFcn(obj,varargin));             
            try
                obj.logo = imread([pwd,'\GSlogo.jpg']);
            catch ME
                obj.logoErr = true;
                warndlg(ME.message,ME.identifier)
            end
            if ~obj.logoErr
                imageInfo = imfinfo([pwd,'\GSlogo.jpg']);
                uicontrol('parent',obj.hMainFig,...
                          'style','push',...
                          'units','pixels',...
                          'pos',[15 15 imageInfo.Width imageInfo.Height],...
                          'cdata',obj.logo,...
                          'foregroundcolor',[1 1 1],...
                          'selectionhighlight','off',...
                          'hittest','off');
            end
            obj.hFileMenu = uimenu('handlevisibility','on',...
                                   'label','File',...
                                   'tag','hFileMenu');
            uimenu('parent',obj.hFileMenu,...
                   'handlevisibility','on',...
                   'label','Save',...
                   'tag','save',...
                   'callback',@(varargin)save(obj,varargin),...
                   'enable','off');
            uimenu('parent',obj.hFileMenu,...
                   'handlevisibility','on',...
                   'label','Save As...',...
                   'callback',@(varargin)saveAs(obj,varargin));
            uimenu('parent',obj.hFileMenu,...
                   'handlevisibility','on',...
                   'label','Print Figure...',...
                   'callback',@(varargin)print(obj,varargin));     
            uimenu('parent',obj.hFileMenu,...
                   'handlevisibility','on',...
                   'label','Exit',...
                   'separator','on',...
                   'callback',@(varargin)quit(obj,varargin));   
            obj.hOptionsMenu = uimenu('handlevisibility','on',...
                                      'label','Options',...
                                      'tag','hOptionsMenu');                     
            uimenu('parent',obj.hOptionsMenu,...
                   'handlevisibility','on',...
                   'label','Settings',...
                   'callback',@(varargin)setting(obj,varargin),...
                   'enable','on');
            uimenu('parent',obj.hOptionsMenu,...
                   'handlevisibility','on',...
                   'label','Resize...',...
                   'callback',@(varargin)resize(obj,varargin),...
                   'enable','off');
            obj.hFitMenu = uimenu('parent',obj.hOptionsMenu,...
                                  'handlevisibility','on',...
                                  'label','Fitting',...
                                  'callback',@(varargin)fitting(obj,varargin),...
                                  'enable','off');   
            obj.hLoadPictureMenu = uimenu('handlevisibility','callback',...
                                          'label','Load Picture',...
                                          'tag','hLoadPictureMenu');
            uimenu('parent',obj.hLoadPictureMenu,...
                   'handlevisibility','callback',...
                   'label','New Picture',...
                   'callback',@(varargin)loadPicture(obj,varargin));
            uimenu('parent',obj.hLoadPictureMenu,...
                   'handlevisibility','callback',...
                   'label','Delete Picture',...
                   'separator','on',...
                   'callback',@(varargin)deletePicture(obj,varargin));  
            obj.hCoordinateSystemMenu = uimenu('handlevisibility','on',...
                                               'label','New Coordinate',...
                                               'tag','hCoordinateSystemMenu');
            uimenu('parent',obj.hCoordinateSystemMenu,...
                   'handlevisibility','on',...
                   'label','New Coordinates',...
                   'callback',@(varargin)setCoordinates(obj,varargin),...
                   'enable','off',...
                   'tag','newCoordinates');
            uimenu('parent',obj.hCoordinateSystemMenu,...
                   'handlevisibility','on',...
                   'label','Coordinate Settings',...
                   'callback',@(varargin)setCoordinates(obj,varargin),...
                   'enable','off',...
                   'tag','coordinateSettings');     
            obj.hNewCurveMenu = uimenu('handlevisibility','on',...
                                       'label','Curve',...
                                       'callback',@(varargin)setCurve(obj,varargin),...
                                       'enable','off',...
                                       'tag','hNewCurveMenu');                     
            obj.hCurveDataPanel = uipanel('parent',obj.hMainFig,...
                                          'title',obj.defaultCurveName{1},...
                                          'units','normalized',...
                                          'background',obj.hMainFigColor,...
                                          'pos',[0.01 0.53 0.18 0.33],...
                                          'userdata','',...
                                          'tag','pCurveDataPanel');           
            obj.hScalePushPlus = uicontrol('style','push',...
                                           'units','normalized',...
                                           'userdata',1,...
                                           'pos',[0.01 0.9 0.016 0.025],...
                                           'cdata',...
                                           cell2mat(struct2cell(load(fullfile(matlabroot,...
                                           'toolbox','matlab','icons','zoomplus.mat')))),...
                                           'backgroundcolor','white',...
                                           'selectionhighlight','off',...
                                           'tooltipstring','Scale-up',...
                                           'callback',@(varargin)pushPlusScale(obj,varargin),...
                                           'enable','off',...
                                           'tag','hScalePushPlus');
            obj.scaleValuePlusPre = get(obj.hScalePushPlus,'userdata');                    
            obj.hScalePushMinus = uicontrol('Style','push',...
                                            'Units','normalized',...
                                            'Userdata',1,...
                                            'pos',[0.035 0.9 0.016 0.025],...
                                            'CData',...
                                            cell2mat(struct2cell(load(fullfile(matlabroot,...
                                            'toolbox','matlab','icons','zoomminus.mat')))),...
                                            'backgroundcolor','white',...
                                            'selectionhighlight','off',...
                                            'tooltipstring','Scale-down',...
                                            'callback',@(varargin)pushMinusScale(obj,varargin),...
                                            'enable','off',...
                                            'tag','hScalePushMinus');
            obj.scaleValueMinusPre = get(obj.hScalePushMinus,'userdata');
            obj.hPicturePanel = uipanel('parent',obj.hMainFig,...
                                        'title','',...
                                        'fontweight','bold',...
                                        'fontsize',10,...
                                        'units','normalized',...
                                        'background','white',...
                                        'highlightcolor','white',...
                                        'pos',[0.2 0.025 0.785 0.95],...
                                        'tag','hPicturePanel');
            obj.hCurveDataTable = uitable(obj.hCurveDataPanel,...
                                          'units','normalized',...
                                          'pos', [0.01 0.01 0.98 0.99],...
                                          'data',obj.tableData,...
                                          'columnname',{'XData','YData'},...
                                          'columnformat',{'numeric','numeric'},...
                                          'columneditable',[false false],...
                                          'columnwidth',{75},...
                                          'visible','off',...
                                          'tag','hCurveDataTable');
            obj.hConMenu = uicontextmenu('tag','hConMenu');
            uimenu(obj.hConMenu,'label','New Curve',...
                   'tag','UIcmcurve',...
                   'enable','off');
            uimenu(obj.hConMenu,'label','Add Point','tag','UIcmadd');
            uimenu(obj.hConMenu,'label','Delete Point','tag','UIcmdelete');
            uimenu(obj.hConMenu,'label','Move Point','tag','UIcmmove');
            uimenu(obj.hConMenu,'label','Select Point','tag','UIcmselect');
            uimenu(obj.hConMenu,'label','Coordinate Settings',...
                   'tag','UIcmsetting',...
                   'callback',@(varargin)setCoordinates(obj,varargin),...
                   'separator','on');                   
            obj.hSelectedXPoint = uicontrol('parent',obj.hMainFig,...
                                            'style','edit',...                
                                            'tag','selectedXPoint',...
                                            'backgroundcolor','white',...
                                            'units','normalized',...
                                            'pos',[0.01 0.5 0.08 0.025],...
                                            'visible','on',...
                                            'string','',...
                                            'tooltipstring','');
            obj.hSelectedYPoint = uicontrol('parent',obj.hMainFig,...
                                            'style','edit',...
                                            'tag','selectedYPoint',...
                                            'backgroundcolor','white',...
                                            'units','normalized',...
                                            'pos',[0.095 0.5 0.08 0.025],...
                                            'visible','on',...
                                            'string','',...
                                            'tooltipstring','');                          
           obj.hCurveList = uicontrol('parent',obj.hMainFig,...
                                      'style','popupmenu',...
                                      'units','normalized',...
                                      'pos',[0.01 0.95 0.100 0.025],...
                                      'enable','on',...
                                      'string',obj.defaultCurveName{1},...
                                      'callback',@(varargin)curveListFcn(obj,varargin),...
                                      'tag','hCurveList',...
                                      'value',1,...
                                      'userdata',1);                            
           addlistener(obj,'isGuiAlter','PostSet',@(varargin)listenGuiState(obj,varargin));
           addlistener(obj,'updateGraph',@(varargin)listenUpdateGraph(obj,varargin));
        end 
    end
    methods 
        curveListFcn(obj,varargin);
    end
    methods(Access = protected)
        save(obj,varargin);
        saveAs(obj,varargin);
        print(obj,varargin);
        quit(obj,vardargin);
        loadPicture(obj,varargin);
        deletePicture(obj,varargin);
        pushMinusScale(obj,varargin);
        pushPlusScale(obj,varargin);
        fitting(obj,varargin);
        
        function figDeleteFcn(obj,varargin)
        % Class destructor
            if isvalid(obj) && isobject(obj) 
                delete(obj)
            end
        end
        
        function setting(obj,varargin)
            GSGUI.setting(obj);
        end
        
        function resize(obj,varargin)
            GSGUI.resize(obj);
        end
        
        function setCoordinates(obj,varargin)
            handle = get(gcbo,'tag');
            switch handle
                case 'newCoordinates'
                    obj.coordinateFigState = 'new';
                    GSGUI.setCoordinates(obj);
                case {'coordinateSettings','UIcmsetting'}
                    obj.coordinateFigState = 'current';
                    GSGUI.setCoordinates(obj);
            end
        end
        
        function setCurve(obj,varargin)
            GSGUI.setCurve(obj);
        end 
        % Listeners for events
        function listenGuiState(obj,varargin)
            switch obj.isGuiAlter
                case true
                    set(findobj('tag','save'),'enable','on')
                case false
                    set(findobj('tag','save'),'enable','off')
            end
        end
        
        function listenUpdateGraph(obj,varargin)
            if ~isempty(findobj('tag','plotting'))
                set(findobj('tag','plotting'),...
                    'xdata',obj.xDataHistory{get(obj.hCurveList,'userdata')},...
                    'ydata',obj.yDataHistory{get(obj.hCurveList,'userdata')},...
                    'marker','o',...
                    'color',obj.colorDataInd.linecolor,...
                    'markeredgecolor',obj.colorDataInd.markerecolor,...
                    'markerfacecolor',obj.colorDataInd.markerfcolor,...
                    'markersize',8);
            end
        end
    end

    % Define neccessary static methods
    methods (Static)
        [xxLogInt,yyLogInt] = gridCalculation(data,scale,varargin);
        [xout, yout] = outOfRange(data,x,y);
        NewCoordinates = calculation(x,y,data,xyScaleMatrix);
        [x,y,place] = checkDistance(x_1,y_1,pts,mode,xi);
        [x,y] = extractpts(handle);
        [pointerShape, pointerHotSpot] = createPointer;
    end
end
