function plot_atlas(list_regions,varargin)
% plot_atlas(list_regions,'property_name',property_value') 
% Plots multiple Paxinos Atlas plates and draws colored/transparent masks
% for the region listed in list_regions
%
% Possible arguments include
% 'list_regions' - [cell array|{''}|{'all'}] List of region names
% 'Values' - [numeric array] regions will be color-coded according to this vector
% 'AtlasType' - [ratcoronal(default)|ratsagittal|mousecoronal|mousesagittal] Type of Atlas
% 'DisplayObj' - [regions(default)|groups] Displays regions or groups of regions
% 'DisplayMode' - [unilateral(default)|bilateral] Displays uni/bilateral regions/groups
% 'AtlasDir' - [path] Atlas directory containing PlotableAtlas folder
% 'SaveName' - [path] Figure saving name (can include path & extension)
% 'PlateList' - [array] List of plate numbers to be displayed
% 'NColumns' - [integer] Number of columns for display
% 'VisibleColorbar' - [on|off(default)] Creates colorbars in figure
% 'VisibleName' - [on(default)|off] Displays region names in figure
% 'VisibleMask' - [on(default)|off] Displays region masks in figure
% 'LineWidth' - [numeric] Linewidth region borders
% 'LineColor' - [string|numeric] LineColor region borders
% 'FontSize' - [numeric] FontSize region names
% 'TextColor' - [string|numeric] FontSize region names
% 'PaperOrientation' — ['portrait'(default)|'landscape'] Orientation of page
%
% Example of use: plot all regions in plate #i
% plot_atlas({'all'},'Values',0,'VisibleName','on','PlateList',i,...
%     'DisplayObj','regions','DisplayMode','unilateral',...
%      'SaveName',fullfile('folder',sprintf('plate%03d.pdf',i)));


close all;

if nargin == 0
    list_regions = {};
end

if ~iscell(list_regions)
    error('First input argument must be a cell input.');
end

if mod(length(varargin),2)==1
    error('List of input arguments must be grouped in pairs.');
end

% Main Parameters
% Default Parameters
value_regions = 1:length(list_regions);
% value_regions = ones(size(list_regions));
AtlasType = 'ratcoronal';
DisplayObj = 'regions';
DisplayMode = 'unilateral';
temp = which('plot_atlas.m');
dir_atlas = strrep(temp,strcat(filesep,'plot_atlas.m'),'');
savename = '';
visiblecolorbar = 'off';
visiblename = 'off';
visiblemask = 'on';
linkaxescbar = 'on';
n_columns = 6;
list_plates = 15:3:80;
linewidth = .1;
linecolor = [.5 .5 .5];
fontsize = 8;
textColor = 'r';
paper_orientation = 'portrait';


% Parsing varargin
all_properties = [{'values'};{'atlastype'};{'displayobj'};{'displaymode'};...
    {'atlasdir'};{'savename'};{'platelist'};...
    {'ncolumns'};{'visiblecolorbar'};{'visiblename'};{'visiblemask'};...
    {'LineWidth'};{'LineColor'};{'FontSize'};{'TextColor'};{'PaperOrientation'}];
for i =1:2:length(varargin)
    if sum(strcmpi(all_properties,varargin{i}))==0
        error('Unknown Property : %s.',varargin{i});
    else
        switch lower(varargin{i})
            case 'values'
                if ~isnumeric(varargin{i+1})
                    error('Values must be a numeric array.')
                elseif length(varargin{i+1})==1
                    value_regions = varargin{i+1}*ones(size(list_regions));
                elseif length(varargin{i+1})~=length(list_regions)
                    error('Values length must be 1 or the same as of list_regions.')
                else
                    temp = varargin{i+1};
                    value_regions = temp(:);
                end
                
            case 'atlastype'
                if sum(strcmp([{'ratsagittal'},{'ratcoronal'},{'mousesagittal'},{'mousecoronal'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    AtlasType = varargin{i+1};
                end
                
            case 'displayobj'
                if sum(strcmp([{'regions'},{'groups'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    DisplayObj = varargin{i+1};
                end
                
            case 'displaymode'
                if sum(strcmp([{'unilateral'},{'bilateral'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    DisplayMode = varargin{i+1};
                end
                
            case 'atlasdir'
                if ~exist(varargin{i+1},'dir')
                    error('Property %s is not an existing directory.',varargin{i})
                else
                    dir_atlas = varargin{i+1};
                end
                
            case 'savename'
                if ~ischar(varargin{i+1})
                    error('Property %s is not a character array.',varargin{i})
                else
                    savename = varargin{i+1};
                end
                
            case 'platelist'
                if isnumeric(varargin{i+1}) && sum(floor(varargin{i+1})==varargin{i+1})==length(varargin{i+1})
                    list_plates = varargin{i+1};
                else
                    error('Property %s is not an array of positive integers.',varargin{i})
                end
                
            case 'ncolumns'
                if isnumeric(varargin{i+1}) && length(varargin{i+1})==1 && floor(varargin{i+1})==varargin{i+1} && varargin{i+1}>0
                    n_columns = varargin{i+1};
                else
                    error('Property %s is not a positive integer.',varargin{i})
                end
                
            case 'visiblecolorbar'
                if sum(strcmp([{'on'},{'off'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    visiblecolorbar = varargin{i+1};
                end
                
            case 'visiblename'
                if sum(strcmp([{'on'},{'off'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    visiblename = varargin{i+1};
                end
                
            case 'visiblemask'
                if sum(strcmp([{'on'},{'off'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    visiblemask = varargin{i+1};
                end
                
            case 'linewidth'
                if isnumeric(varargin{i+1}) && length(varargin{i+1})==1 && varargin{i+1}>0
                    linewidth = varargin{i+1};
                else
                    error('Property %s is not a positive integer.',varargin{i})
                end

            case 'linecolor'
                if isnumeric(varargin{i+1}) && length(varargin{i+1})==3 && sum(varargin{i+1}>0)==3
                    linecolor = varargin{i+1};
                elseif ischar(varargin{i+1})
                    linecolor = varargin{i+1};
                else
                    error('Property %s is not a positive integer.',varargin{i})
                end

            case 'fontsize'
                if isnumeric(varargin{i+1}) && length(varargin{i+1})==1 && varargin{i+1}>0
                    fontsize = varargin{i+1};
                else
                    error('Property %s is not a positive integer.',varargin{i})
                end

            case'textcolor'
                if isnumeric(varargin{i+1}) && length(varargin{i+1})==3 && sum(varargin{i+1}>0)==3
                    textColor = varargin{i+1};
                elseif ischar(varargin{i+1})
                    textColor = varargin{i+1};
                else
                    error('Property %s is not a positive integer.',varargin{i})
                end
                
            case 'paperorientation'
                if sum(strcmp([{'portrait'},{'landscape'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    paper_orientation = varargin{i+1};
                end
        end
    end
end

% Secondary Parameters
% plate_name
switch AtlasType
    case 'ratcoronal'
        plate_name = 'RatCoronalPaxinos';
        if sum(list_plates<1)>0 || sum(list_plates>161)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 161',AtlasType);
        end
    case 'ratsagittal'
        plate_name = 'RatSagittalPaxinos';
        if sum(list_plates<1)>0 || sum(list_plates>38)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 38',AtlasType);
        end
    case 'mousecoronal'
        plate_name = 'MouseCoronalPaxinos';
        if sum(list_plates<1)>0 || sum(list_plates>100)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 100',AtlasType);
        end
    case 'mousesagittal'
        plate_name = 'MouseSagittalPaxinos';
        if sum(list_plates<1)>0 || sum(list_plates>64)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 64',AtlasType);
        end
end
n_plates = length(list_plates);
% checkbox values
if strcmp(visiblename,'on')
    cb1def = 1;
else
    cb1def = 0;
end
if strcmp(visiblecolorbar,'on')
    cb2def = 1;
else
    cb2def = 0;
end
if strcmp(visiblemask,'on')
    cb3def = 1;
else
    cb3def = 0;
end
if strcmp(linkaxescbar,'on')
    cb4def = 1;
else
    cb4def = 0;
end
% formatting savename
if isempty(savename)
    savedir = '';
    fName = 'PlotAtlas';
else
    ind_filesep = strfind(savename,filesep);
    if isempty(ind_filesep)
        savedir = pwd;
        fName = savename;
    else
        savedir = savename(1:ind_filesep(end)-1);
        fName = savename(ind_filesep(end)+1:end);
    end
end
if length(list_plates)<n_columns
    n_columns = length(list_plates);
end
% detecting if list_regions is 'all'
flag_all = false;
if length(list_regions)==1 && strcmp(char(list_regions),'all')
    flag_all = true;
    warning('Property Values set to default when list_regions is "all".');
end

% Setting up figure
f = figure;
f.Units = 'normalized';
f.Position = [0.4423    1.0905    0.8399    0.8229];
clrmenu(f);
f.Name = fName;
f.Renderer = 'Painters';
f.PaperPositionMode='manual';
f.PaperOrientation=paper_orientation;
f.Color='w';
colormap(f,'jet');
f_colormap = f.Colormap;
f_colors = f.Colormap(round(1:64/length(list_regions):64),:);
f.Pointer = 'watch';
drawnow;

% Setting up axes
margin_w = .01;
margin_h = .02;
n_rows = ceil(n_plates/n_columns);
tick_width =.5;
thresh_average = .5;
all_markers = {'none';'none';'none'};
all_linestyles = {'--';':';'-'};
patch_alpha = .1;

% Creating axes
all_axes = [];
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        
        if index>n_plates
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        ax = axes('Parent',f);
        ax.Position= [x+2*margin_w y+margin_h (1/n_columns)-3*margin_w (1/n_rows)-3*margin_h];
        ax.XAxisLocation ='origin';
        ax.Title.String = sprintf('Ax-%02d',index);
        
        ax.Title.Visible = 'on';
        all_axes = [all_axes;ax];
    end
end

% Creating checkboxes
cb1 = uicontrol('Style','checkbox','Units','normalized','Value',cb1def,...
    'TooltipString','Display Sticker','Tag','Checkbox1','Parent',f);
cb2 = uicontrol('Style','checkbox','Units','normalized','Value',cb2def,...
    'TooltipString','Display Colorbar','Tag','Checkbox2','Parent',f);
cb3 = uicontrol('Style','checkbox','Units','normalized','Value',cb3def,...
    'TooltipString','Display Mask','Tag','Checkbox3','Parent',f);
cb4 = uicontrol('Style','checkbox','Units','normalized','Value',cb4def,...
    'TooltipString','Linkaxes Cbar','Tag','Checkbox4','Parent',f);
cb1.Position = [0 .97 .02 .03];
cb2.Position = [0 .94 .02 .03];
cb3.Position = [0 .91 .02 .03];
cb4.Position = [0 .88 .02 .03];
set(cb1,'Callback',{@cb1_Callback,textColor,fontsize});
set(cb2,'Callback',{@cb2_Callback});
set(cb3,'Callback',{@cb3_Callback});
set(cb4,'Callback',{@cb4_Callback});

% Loading Atlas
% Load lists
savedir = fullfile(dir_atlas,'Plates',plate_name);
if exist(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)),'file')
    data_atlas = load(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)));
    fprintf('Plotable Atlas loaded [%s].\n',savedir);
else
    warningdlg('Missing Atlas [%s]',fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)));
    return;
end

% Plot objects
if strcmp(DisplayMode,'unilateral')
    switch DisplayObj
        case 'regions'
            id_show = data_atlas.id_regions;
            list_show = data_atlas.list_regions;
            mask_show = double(data_atlas.Mask_regions);
        case 'groups'
            id_show = data_atlas.id_groups;
            list_show = data_atlas.list_groups;
            mask_show = double(data_atlas.Mask_groups);
    end
elseif strcmp(DisplayMode,'bilateral')
    switch DisplayObj
        case 'regions'
            id_show = data_atlas.id_bilateral;
            list_show = data_atlas.list_bilateral;
            mask_show = double(data_atlas.Mask_bilateral);
        case 'groups'
            id_show = data_atlas.id_groups_bilateral;
            list_show = data_atlas.list_groups_bilateral;
            mask_show = double(data_atlas.Mask_groups_bilateral);
    end
end


% Updating Axes
for index=1:n_plates
    ax =  all_axes(index);
    hold(ax,'on');
    
    xyfig = list_plates(index);
    cur_mask = mask_show(:,:,xyfig);        
    data_plate = load(fullfile(dir_atlas,'Plates',plate_name,sprintf('Atlas_%03d.mat',xyfig)));
    switch AtlasType
        case {'ratcoronal','mousecoronal'}
            data_plate.AP = data_plate.AP_mm;
        case {'ratsagittal','mousesagittal'}
            data_plate.AP = data_plate.ML_mm;
    end
    fprintf('Plotting Atlas Plate Bregma %.2f mm [%d/%d]...',data_plate.AP,index,n_plates);
    
    % Display all available objects if list_regions={all} option
    if flag_all
        list_regions = list_show;
        % reseting value_regions if needed
        % Setting to 0 if unspecified
        if length(value_regions)~=length(list_regions)
            value_regions = 1:length(list_regions);
        end
    end
    
    full_mask = zeros(size(data_plate.Mask,1),size(data_plate.Mask,2));
    all_ids = [];
    all_regions = [];
    
    for i =1:length(list_regions)
        
        ind_region = find(strcmp(list_show,list_regions(i))==1);
        if ~isempty(ind_region)
            for j=1:length(ind_region)
                cur_id = id_show(ind_region(j));
                cur_region = list_show(ind_region(j));
                full_mask(cur_mask==cur_id)=value_regions(i);
                
                all_ids = [all_ids;cur_id];
                all_regions = [all_regions;cur_region];
                
                
%                 % Display Name
%                 [X,Y]=meshgrid(1:size(cur_mask,2),1:size(cur_mask,1));
%                 temp_X = X.*(cur_mask==cur_id);
%                 temp_X(temp_X==0)=NaN;
%                 x = mean(mean(temp_X,'omitnan'),'omitnan');
%                 temp_Y = Y.*(cur_mask==cur_id);
%                 temp_Y(temp_Y==0)=NaN;
%                 y = mean(mean(temp_Y,'omitnan'),'omitnan');
%                 t = text(x,y,cur_region,'Parent',ax,'Color',textColor,'FontSize',fontsize,...
%                     'Visible',visiblename,'Tag','Sticker','Parent',ax);
%                 %t.BackgroundColor = [.5 .5 .5];
%                 t.EdgeColor = textColor;
%                 t.LineWidth = .1;
%                 t.UserData.Value = 0;
%                 t.UserData.cur_mask = cur_mask;
%                 t.ButtonDownFcn = {@click_text};
            end
        end
    end

    % Storing data
    ax.UserData.cur_mask = cur_mask;
    ax.UserData.all_ids = all_ids;
    ax.UserData.all_regions = all_regions;
    
    % Plotting final mask
    im=imagesc(full_mask,'Tag','FullMask','Parent',ax);
    im.AlphaData = double(full_mask>0);
    uistack(im,'bottom');
    
    % Ploting Atlas
    line('XData',data_plate.line_x,'YData',data_plate.line_z,...
        'Color',linecolor,'Linewidth',linewidth,'Parent',ax);
    
    switch AtlasType
        case {'ratcoronal','mousecoronal'}
            ax.Title.String = sprintf('Bregma %.2f mm [%03d]',data_plate.AP,xyfig);
        case {'ratsagittal','mousesagittal'}
            ax.Title.String = sprintf('Lateral %.2f mm [%03d]',data_plate.AP,xyfig);
    end
    ax.YDir = 'reverse';
    ax.XDir = 'reverse';
    
    % Axes Limits
    ax.XLim = [min(data_plate.line_x) max(data_plate.line_x)];
    ax.YLim = [min(data_plate.line_z) max(data_plate.line_z)];
    ax.Visible = 'off';
    ax.Title.Visible='on';
    
    fprintf(' done.\n');
end

% Execute Callbacks
cb1_Callback(cb1,[],textColor,fontsize);
cb2_Callback(cb2,[]);
cb3_Callback(cb3,[]);
cb4_Callback(cb4,[]);

% Save if savename is specified
if ~isempty(savename)
    if ~isdir(savedir)
        mkdir(savedir);
        warning('Directory %s created.',savedir)
    end
    
    if ~contains(fName,'.')
        fullname = fullfile(savedir,strcat(fName,'.pdf'));
    else
        fullname = fullfile(savedir,strcat(fName));
    end
    saveas(f,fullname);
end

f.Pointer = 'arrow';

end

function cb1_Callback(hObj,~,textColor,fontsize)

tic

all_axes = findobj(hObj.Parent,'Type','axes');
all_obj = findobj(all_axes,'Tag','Sticker');
delete(all_obj);

if hObj.Value
    for i = 1:length(all_axes)
        ax = all_axes(i);
        for j = 1:length(ax.UserData.all_regions)
            cur_id = ax.UserData.all_ids(j);
            cur_region = char(ax.UserData.all_regions(j));
            % Display Name
%             [X,Y]=meshgrid(1:size(ax.UserData.cur_mask,2),1:size(ax.UserData.cur_mask,1));
%             temp_X = X.*(ax.UserData.cur_mask==cur_id);
%             temp_X(temp_X==0)=NaN;
%             x = mean(mean(temp_X,'omitnan'),'omitnan');
%             temp_Y = Y.*(ax.UserData.cur_mask==cur_id);
%             temp_Y(temp_Y==0)=NaN;
%             y = mean(mean(temp_Y,'omitnan'),'omitnan');
            x = 1;
            y=1;
            t = text(x,y,cur_region,'Parent',ax,'Color',textColor,'FontSize',fontsize,...
                'Tag','Sticker','Parent',ax);
            %t.BackgroundColor = [.5 .5 .5];
            t.EdgeColor = textColor;
            t.LineWidth = .1;
            t.UserData.Value = 0;
            t.UserData.cur_mask = (ax.UserData.cur_mask==cur_id);
            t.ButtonDownFcn = {@click_text};
        end 
        
    end
end
toc

end

function cb2_Callback(hObj,~)

all_axes = findobj(hObj.Parent,'Type','axes');
all_obj = findobj(hObj.Parent,'Tag','Colorbar');
delete(all_obj);

if hObj.Value
    for i = 1:length(all_axes)
        colorbar(all_axes(i),'Tag','Colorbar','Visible','on','Location','southoutside');
    end
end

end

function cb3_Callback(hObj,~)

all_axes = findobj(hObj.Parent,'Type','axes');
all_obj = findobj(all_axes,'Tag','FullMask');
if hObj.Value
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'on';
        uistack(all_obj(i),'bottom');
    end
else
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'off';
    end
end

end

function cb4_Callback(hObj,~)

all_axes = findobj(hObj.Parent,'Type','axes');
all_im = findobj(hObj.Parent,'Type','Image');

all_im_cdata = [];
for i =1:length(all_im)
    all_im_cdata = cat(3,all_im_cdata,all_im(i).CData);
end
if isempty(all_im_cdata)
    m=0;
    M=1;
else
    m=min(all_im_cdata(all_im_cdata~=0));
    M=max(all_im_cdata(all_im_cdata~=0));
end

if hObj.Value
    for i = 1:length(all_axes)
        ax = all_axes(i);
        ax.CLimMode = 'manual';
        ax.CLim = [m M];
    end
else
    for i = 1:length(all_axes)
        ax = all_axes(i);
        ax.CLimMode = 'auto';
    end
end

end

function click_text(hObj,~)
hObj.UserData.Value = 1-hObj.UserData.Value;
delete(findobj(hObj.Parent,'Tag','ClickTextMask'));
if hObj.UserData.Value
    % Extract boundaries
    B = bwboundaries(hObj.UserData.cur_mask);
    for j=1:length(B)
        boundary = B{j};
        line('XData',boundary(:,2),'YData',boundary(:,1),...
            'Color',hObj.Color,...
            'Parent',hObj.Parent,...
            'Tag','ClickTextMask',...
            'Hittest','off');
    end
end
end