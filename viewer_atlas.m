function [f,handles] = viewer_atlas()
% viewer_atlas() 
% Interactive viewer for regions visualization
%
% Possible arguments include
% 'AtlasType' - [ratcoronal(default)|ratsagittal|mousecoronal|mousesagittal] Type of Atlas
% 'DisplayObj' - [regions(default)|groups] Displays regions or groups of regions
% 'DisplayMode' - [unilateral(default)|bilateral] Displays uni/bilateral regions/groups
% 'PlateList' - [array] List of plate numbers to be displayed

% 'SaveName' - [path] Figure saving name (can include path & extension)
% 'NColumns' - [integer] Number of columns for display
% visiblename = 'off';
% visiblemask = 'on';

close all;


% Tab1 Parameters
str_atlas = [{'ratcoronal'},{'ratsagittal'},{'mousesagittal'},{'mousecoronal'}];
str_obj = [{'regions'},{'groups'}];
str_mode = [{'unilateral'},{'bilateral'}];
str_plates = '10:1:99';
% Starting Parameters
val_atlas = 1;
val_obj = 2;
val_mode = 2;

% Tab2 Parameters
temp = which('viewer_atlas.m');
Params.dir_atlas = strrep(temp,strcat(filesep,'viewer_atlas.m'),'');
Params.dir_values = fullfile(Params.dir_atlas,'Values');
if ~exist(Params.dir_values,'dir')
    mkdir(Params.dir_values);
end

% Setting up figure
f = figure('Units','normalized',...
    'HandleVisibility','Callback',...
    'IntegerHandle','off',...
    'MenuBar','figure',...
    'Toolbar','figure',...
    'NumberTitle','off',...
    'Color','w',...
    'Tag','MainFigure',...
    'Position',[.1   .1    0.8    0.8],...
    'PaperPositionMode','manual',...
    'PaperOrientation','portrait',...
    'Renderer','Painters',...
    'Name','Simple Viewer Atlas');
clrmenu(f);
colormap(f,'jet');
f.UserData.Params = Params;


w1 = .15;
panel1 = uipanel('Units','normalized',...
    'Position',[0 0 w1 1],...
    'bordertype','etchedin',...
    'Tag','Panel1',...
    'Parent',f);
panel2 = uipanel('Units','normalized',...
    'Position',[w1 0 1-w1 1],...
    'bordertype','etchedin',...
    'Tag','Panel2',...
    'Parent',f);
tabgp = uitabgroup('Units','normalized',...
    'Position',[0 0 1 1],...
    'Parent',panel2,...
    'Tag','TabGroup');
tab1 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','Slices',...
    'Tag','Tab1');
tab2 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','2D Projections',...
    'Tag','Tab2');
tab3 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','3D Volume (full)',...
    'Tag','Tab3');
tab4 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','3D Volume (partial)',...
    'Tag','Tab4');
tab5 = uitab('Parent',tabgp,...
    'Units','normalized',...
    'Title','3D Volume (binary)',...
    'Tag','Tab5');

h1 = .03;
uicontrol('Units','normalized',...
    'Position',[0 1-h1 1 h1],...
    'Style','popup',...
    'Parent',panel1,...
    'String',str_atlas,...
    'TooltipString','AtlasType',...
    'Value',val_atlas,...
    'UserData',val_atlas,...
    'Tag','Popup1');
uicontrol('Units','normalized',...
    'Position',[0 1-2*h1 1 h1],...
    'Style','popup',...
    'Parent',panel1,...
    'String',str_obj,...
    'TooltipString','DisplayObj',...
    'Value',val_obj,...
    'UserData',val_obj,...
    'Tag','Popup2');
uicontrol('Units','normalized',...
    'Position',[0 1-3*h1 1 h1],...
    'Style','popup',...
    'Parent',panel1,...
    'String',str_mode,...
    'TooltipString','DisplayMode',...
    'Value',val_mode,...
    'UserData',val_mode,...
    'Tag','Popup3');
uicontrol('Units','normalized',...
    'Position',[0 1-4*h1 1 h1],...
    'Style','popup',...
    'Parent',panel1,...
    'String','-',...
    'Enable','off',...
    'TooltipString','Value to Display',...
    'Tag','Popup4');
uicontrol('Units','normalized',...
    'Position',[.02 1-5*h1 .46 h1],...
    'Style','edit',...
    'Parent',panel1,...
    'String',str_plates,...
    'TooltipString','PlateList',...
    'UserData',str_plates,...
    'Tag','Edit1');
uicontrol('Units','normalized',...
    'Position',[.5 1-5*h1 .25 h1],...
    'Style','edit',...
    'Parent',panel1,...
    'String',-100,...
    'TooltipString','Lower Threshold Value',...
    'UserData',-100,...
    'Tag','Edit2');
uicontrol('Units','normalized',...
    'Position',[.75 1-5*h1 .25 h1],...
    'Style','edit',...
    'Parent',panel1,...
    'String',100,...
    'TooltipString','Lower Threshold Value',...
    'UserData',100,...
    'Tag','Edit3');
uicontrol('Units','normalized',...
    'Position',[0 1-6*h1 .5 h1],...
    'Style','pushbutton',...
    'Parent',panel1,...
    'String','Load Plates',...
    'Tag','Button1');
uicontrol('Units','normalized',...
    'Position',[.5 1-6*h1 .5 h1],...
    'Style','pushbutton',...
    'Parent',panel1,...
    'String','Load Values',...
    'Tag','Button1b');

table1 = uitable('Units','normalized',...
    'Position',[.02 4*h1 .96 1-10.1*h1],...
    'ColumnFormat',{'char'},...
    'ColumnWidth',{100},...
    'ColumnEditable',false,...
    'ColumnName','',...
    'Data',[],...
    'RowName','',...
    'Tag','Table1',...
    'RowStriping','on',...
    'Parent',panel1);
table1.UserData.Selection = [];
% Adjust Columns
table1.Units = 'pixels';
table1.ColumnWidth ={table1.Position(3)};
table1.Units = 'normalized';

uicontrol('Units','normalized',...
    'Position',[0 3*h1 .2 h1],...
    'Style','edit',...
    'Parent',panel1,...
    'String','0',...
    'TooltipString','CLim(1)',...
    'UserData','0',...
    'Tag','Edit11');
uicontrol('Units','normalized',...
    'Position',[.8 3*h1 .2 h1],...
    'Style','edit',...
    'Parent',panel1,...
    'String','1',...
    'TooltipString','CLim(2)',...
    'UserData','1',...
    'Tag','Edit12');
ax = axes('Parent',panel1,'Visible','off');
c = colorbar(ax,'Parent',panel1,'Location','south');
c.Position = [.25 3.2*h1 .5 .6*h1];
c.Box = 'off';
c.Ticks = [];
c.Tag = 'Colorbar1';

uicontrol('Units','normalized',...
    'Position',[0 2*h1 .5 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'TooltipString','Collapse/Expand Axes',...
    'Tag','Checkbox1');
uicontrol('Units','normalized',...
    'Position',[.1 2*h1 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',0,...
    'TooltipString','Title on/off',...
    'Tag','Checkbox1b');
uicontrol('Units','normalized',...
    'Position',[.2 2*h1 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',1,...
    'TooltipString','Plate on/off',...
    'Tag','Checkbox2');
uicontrol('Units','normalized',...
    'Position',[.3 2*h1 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',1,...
    'TooltipString','Mask on/off',...
    'Tag','Checkbox3');
uicontrol('Units','normalized',...
    'Position',[.4 2*h1 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',0,...
    'TooltipString','Sticker on/off',...
    'Tag','Checkbox4');
uicontrol('Units','normalized',...
    'Position',[.5 2*h1 .3 h1],...
    'Style','popup',...
    'Parent',panel1,...
    'String','VolumeRendering|MaximumIntensityProjection|Isosurface',...
    'Value',2,...
    'TooltipString','Volume Rendering mode',...
    'Tag','Popup5');
uicontrol('Units','normalized',...
    'Position',[.82 2*h1 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',0,...
    'TooltipString','CLim mode (manual/auto)',...
    'Tag','Checkbox5');
uicontrol('Units','normalized',...
    'Position',[.92 0 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',0,...
    'TooltipString','Lock plot',...
    'Tag','Checkbox6');
uicontrol('Units','normalized',...
    'Position',[.92 2*h1 .1 h1],...
    'Style','checkbox',...
    'Parent',panel1,...
    'Value',1,...
    'TooltipString','Lock CAxis Volumes',...
    'Tag','Checkbox7');

uicontrol('Units','normalized',...
    'Position',[0 h1 .5 h1],...
    'Style','pushbutton',...
    'Parent',panel1,...
    'String','Reset',...
    'TooltipString','Reset Values',...
    'Tag','Button0');
uicontrol('Units','normalized',...
    'Position',[.5 h1 .5 h1],...
    'Style','pushbutton',...
    'Parent',panel1,...
    'String','Save',...
    'TooltipString','Save Figure',...
    'Tag','Button0b');
uicontrol('Units','normalized',...
    'Position',[0 0 .9 h1],...
    'Style','pushbutton',...
    'Parent',panel1,...
    'String','Plot',...
    'TooltipString','View Atlas',...
    'Tag','Button2');


% Callback attribution
handles = guihandles(f);
table1.CellSelectionCallback={@template_uitable_select,handles};
handles.Edit11.Callback = {@checkbox5_callback,handles};
handles.Edit12.Callback = {@checkbox5_callback,handles};

handles.MainFigure.KeyPressFcn={@key_press_fcn,handles};

handles.Popup4.Callback = {@update_popup4_callback,handles};
handles.Button0.Callback = {@reset_controls,handles};
handles.Button0b.Callback = {@save_callback,handles};
handles.Button1.Callback = {@loadPlates_callback,handles};
handles.Button1b.Callback = {@loadValues_callback,handles};
handles.Button2.Callback = {@plot_callback,handles};

handles.Checkbox1.Callback = {@checkbox1_callback,handles};
handles.Checkbox1b.Callback = {@checkbox1b_callback,handles};
handles.Checkbox2.Callback = {@checkbox2_callback,handles};
handles.Checkbox3.Callback = {@checkbox3_callback,handles};
handles.Checkbox4.Callback = {@checkbox4_callback,handles};
handles.Checkbox5.Callback = {@checkbox5_callback,handles};
handles.Checkbox6.Callback = {@checkbox6_callback,handles};

end

function reset_controls(~,~,handles)

handles.Popup1.Value = handles.Popup1.UserData;
handles.Popup2.Value = handles.Popup2.UserData;
handles.Popup3.Value = handles.Popup3.UserData;
handles.Popup4.String = '-';
handles.Popup4.Value = 1;
handles.Popup4.Enable = 'off';

handles.Edit1.String = handles.Edit1.UserData;
handles.Edit2.String = handles.Edit2.UserData;
handles.Edit3.String = handles.Edit3.UserData;
handles.Edit11.String = handles.Edit11.UserData;
handles.Edit12.String = handles.Edit12.UserData;
handles.Table1.Data = [];
handles.Table1.UserData.Selection = [];
handles.Table1.Units = 'pixels';
handles.Table1.ColumnWidth ={handles.Table1.Position(3)};
handles.Table1.Units = 'normalized';

% delete(handles.Panel2.Children);
delete(handles.Tab1.Children);
delete(handles.Tab2.Children);
delete(handles.Tab3.Children);
delete(handles.Tab4.Children);
delete(handles.Tab5.Children);
Params = handles.MainFigure.UserData.Params;
handles.MainFigure.UserData = [];
handles.MainFigure.UserData.Params = Params;

end

function loadPlates_callback(~,~,handles)

f = handles.MainFigure;
AtlasType = char(handles.Popup1.String(handles.Popup1.Value,:));
DisplayObj = char(handles.Popup2.String(handles.Popup2.Value,:));
DisplayMode = char(handles.Popup3.String(handles.Popup3.Value,:));
list_plates = eval(handles.Edit1.String);
n_plates = length(list_plates);
%list_regions = handles.Table1.Data(handles.Table1.UserData.Selection);

try
    [list_select,occurences_select] = generate_lists('AtlasType',AtlasType,'DisplayObj',DisplayObj,...
        'DisplayMode',DisplayMode,'PlateList',list_plates);   
catch
    error('Unable to load regions Plate List [%s] AtlasType [%s] DisplayObj [%s] DisplayMode [%s].',handles.Edit1.String,AtlasType,DisplayObj,DisplayMode);
end

% Restricting list_select
% handles.Table1.Data = list_select;
% handles.Table1.Data = [list_select,num2cell(occurences_select)];
handles.Table1.Data = [list_select,cellstr(num2str(occurences_select))];
handles.Table1.Units = 'pixels';
handles.Table1.ColumnWidth ={.75*handles.Table1.Position(3) .25*handles.Table1.Position(3)};
handles.Table1.Units = 'normalized';
fprintf('Regions loaded from Plate List [%s] AtlasType [%s] DisplayObj [%s] DisplayMode [%s].\n',handles.Edit1.String,AtlasType,DisplayObj,DisplayMode);

% Removing field
if isfield(handles.MainFigure.UserData,'values_txt')
    rmfield(handles.MainFigure.UserData,'values_txt');
end
if isfield(handles.MainFigure.UserData,'this_tt_data')
    rmfield(handles.MainFigure.UserData,'this_tt_data');
end

handles.Popup4.String = '-';
handles.Popup4.Value = 1;
handles.Popup4.Enable = 'off';

% Loading Atlas
dir_atlas = f.UserData.Params.dir_atlas;
switch AtlasType
    case 'ratcoronal'
        plate_name = 'RatCoronalPaxinos'; 
    case 'ratsagittal'
        plate_name = 'RatSagittalPaxinos';
    case 'mousecoronal'
        plate_name = 'MouseCoronalPaxinos';       
    case 'mousesagittal'
        plate_name = 'MouseSagittalPaxinos';
end
savedir = fullfile(dir_atlas,'Plates',plate_name);
if exist(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)),'file')
    data_atlas = load(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)));
    fprintf('Plotable Atlas loaded [%s].\n',savedir);
else
    error('Missing Atlas [%s]',fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)));
end

f.Pointer = 'watch';
drawnow;

% Loading lists
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

% clear
delete(handles.Tab1.Children);
delete(handles.Tab2.Children);
delete(handles.Tab3.Children);
delete(handles.Tab4.Children);
delete(handles.Tab5.Children);

% Setting up
n_columns = ceil(sqrt(n_plates));
n_rows = ceil(n_plates/n_columns);
linewidth = .1;
linecolor = [.5 .5 .5];
fontsize = 8;
textColor = 'r';
margin_w = .002;
margin_h = .02;
tick_width =.5;
thresh_average = .5;
all_markers = {'none';'none';'none'};
all_linestyles = {'--';':';'-'};
patch_alpha = .1;

% Creating axes
all_axes = [];
all_positions = [];
for ii = 1:n_rows
    for jj = 1:n_columns
        index = (ii-1)*n_columns+jj;
        if index>n_plates
            continue;
        end
        x = mod(index-1,n_columns)/n_columns;
        y = (n_rows-1-(floor((index-1)/n_columns)))/n_rows;
        % ax = axes('Parent',handles.Panel2);
        ax = axes('Parent',handles.Tab1);
        ax.Position= [x+margin_w y (1/n_columns)-margin_w (1/n_rows)-margin_h];
        ax.XAxisLocation ='origin';
        ax.Title.String = sprintf('Ax-%02d',index);
        ax.Title.Visible = 'on';
        
        all_positions = [all_positions ;ax.Position];
        all_axes = [all_axes;ax];
        
        xyfig = list_plates(index);
        data_plate = load(fullfile(dir_atlas,'Plates',plate_name,sprintf('Atlas_%03d.mat',xyfig)));
        switch AtlasType
            case {'ratcoronal','mousecoronal'}
                data_plate.AP = data_plate.AP_mm;
            case {'ratsagittal','mousesagittal'}
                data_plate.AP = data_plate.ML_mm;
        end
        ax.UserData.data_plate = data_plate;
        ax.UserData.index = index;
        fprintf('Atlas Plate %d/%d mm loaded [%.2f mm].\n',index,n_plates,data_plate.AP);
        
        % Ploting Atlas
        l = line('XData',data_plate.line_x,'YData',data_plate.line_z,...
            'Tag','Plate','Color',linecolor,'Linewidth',linewidth,'Parent',ax);
        l.ButtonDownFcn = {@click_plate,handles};
        
        switch AtlasType
            case {'ratcoronal','mousecoronal'}
                ax.Title.String = sprintf('%.2f mm (%d)',data_plate.AP,data_plate.xyfig);
            case {'ratsagittal','mousesagittal'}
                ax.Title.String = sprintf('%.2f mm (%d)',data_plate.AP,data_plate.xyfig);
        end
        ax.YDir = 'reverse';
        %ax.XDir = 'reverse';
        
        % Axes Limits
        ax.XLim = [min(data_plate.line_x) max(data_plate.line_x)];
        ax.YLim = [min(data_plate.line_z) max(data_plate.line_z)];
        ax.Visible = 'off';
        ax.Title.Visible='on';
    end
end

% Creating projection axes
ax1 = axes('Parent',handles.Tab2,'Position',[.025 .675 .3 .275],'Visible','on');
ax1b = axes('Parent',handles.Tab2,'Position',[.025 .35 .3 .275],'Visible','on');
ax1c = axes('Parent',handles.Tab2,'Position',[.025 .025 .3 .275],'Visible','on');
% ax1.Title.String = 'Coronal';
% set(ax1,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
% set(ax1b,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax2 = axes('Parent',handles.Tab2,'Position',[.35 .675 .3 .275],'Visible','on');
ax2b = axes('Parent',handles.Tab2,'Position',[.35 .35 .3 .275],'Visible','on');
ax2c = axes('Parent',handles.Tab2,'Position',[.35 .025 .3 .275],'Visible','on');
% set(ax2,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
% set(ax2b,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
% ax2.Title.String = 'Sagittal';
ax3 = axes('Parent',handles.Tab2,'Position',[.675 .675 .3 .275],'Visible','on');
ax3b = axes('Parent',handles.Tab2,'Position',[.675 .35 .3 .275],'Visible','on');
ax3c = axes('Parent',handles.Tab2,'Position',[.675 .025 .3 .275],'Visible','on');
% set(ax3,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
% set(ax3b,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
% ax3.Title.String = 'Transverse';
projection_axes = [ax1,ax1b,ax1c;ax2,ax2b,ax2c;ax3,ax3b,ax3c];

% Storing
f.UserData.id_show = id_show;
f.UserData.list_show = list_show;
f.UserData.mask_show = mask_show;
f.UserData.all_axes = all_axes;
f.UserData.projection_axes = projection_axes;
f.UserData.all_positions = all_positions;
f.UserData.margin_w = margin_w;
f.UserData.margin_h = margin_h;
f.UserData.n_columns = n_columns;
f.UserData.n_rows = n_rows;
f.UserData.n_plates = n_plates;

% Current Axis
f.UserData.CurrentAxisIndex = 1;
update_current_axis(handles);

f.Pointer = 'arrow';

end

function loadValues_callback(~,~,handles)

% Load file
%fid = fopen(fullfile(folder_save,strcat(f.Name,'.txt')),'w');
[FileName,PathName,FilterIndex] = uigetfile(fullfile(handles.MainFigure.UserData.Params.dir_values,'*.txt'));

% Read file
ledger_txt =  fullfile(PathName,FileName);
% all_c1 = [];
% all_c4 = [];
fileID = fopen(ledger_txt);
%header
header = regexp(fgetl(fileID),'\t','split');
list_group = [];
for i=1:length(header)
    temp = strtrim(char(header(i)));
    if i==1 || strcmp(temp,'')
        % Ignore first/empty row
        continue;
    else
        list_group = [list_group ;{temp}];
    end
end

list_regions = [];
tt_data = [];
while ~feof(fileID)
    hline = fgetl(fileID);
    cline = regexp(hline,'\t','split');
    list_regions = [list_regions;strtrim(cline(1))];
    tt_data_line = [];
    for j =1:length(list_group)
        tt_data_line = [tt_data_line,eval(char(cline(j+1)))];
    end
    tt_data = [tt_data ;tt_data_line];
end
fclose(fileID);

% Finding matching regions
this_regions = handles.Table1.Data(:,1);
this_tt_data = [];
for k=1:length(this_regions)
    ind_list = find(strcmp(list_regions,this_regions(k))==1);
    if ~isempty(ind_list)
        this_tt_data = [this_tt_data;tt_data(ind_list(1),:)];
    else
        this_tt_data = [this_tt_data;zeros(1,size(tt_data_line,2))];
    end
end
fprintf('Value Regions loaded [File:%s].\n',ledger_txt);


handles.Popup4.String = list_group;
handles.Popup4.Value = 1;
handles.Popup4.Enable = 'on';

% Storing
handles.MainFigure.UserData.values_txt = ledger_txt;
handles.MainFigure.UserData.this_tt_data = this_tt_data;
update_popup4_callback([],[],handles);

end

function update_popup4_callback(~,~,handles)

this_tt_data = handles.MainFigure.UserData.this_tt_data(:,handles.Popup4.Value);
handles.Table1.Data = [handles.Table1.Data(:,1),num2cell(this_tt_data)];
% Adjust Columns
handles.Table1.ColumnWidth ='auto';

end

function save_callback(~,~,handles)

f = handles.MainFigure;
str1 = char(handles.Popup4.String(handles.Popup4.Value,:));
str2 = char(handles.Popup2.String(handles.Popup2.Value,:));
str3 = char(handles.Popup3.String(handles.Popup3.Value,:));

if isfield(f.UserData,'values_txt')
    [A,B,C] = fileparts(f.UserData.values_txt);
    defaultans = sprintf('%s-%s[%s-%s]',B,str1,str2,str3);
else
    defaultans = sprintf('%s-%s[%s-%s]','Plates',str1,str2,str3);
end

prompt={'Saving Menu'};
name = 'FileName';
answer = inputdlg(prompt,name,[1 100],{defaultans});

if ~isempty(answer)
    saveas(f,strcat(char(answer),'.pdf'));
    fprintf('Figure Saved [%s].\n',strcat(char(answer),'.pdf'));
end

% Storing
if isfield(f.UserData,'full_volume')
    full_volume_thresholded=f.UserData.full_volume_thresholded;
    full_volume_binary=f.UserData.full_volume_binary;
    full_volume=f.UserData.full_volume;
    save(strcat(char(answer),'.mat'),'full_volume','full_volume_thresholded','full_volume_binary');
    fprintf('Data Saved [%s].\n',strcat(char(answer),'.mat'));
end


end

function key_press_fcn(~,evnt,handles)

f = handles.MainFigure;
if ~isfield(f.UserData,'all_axes')
    return;
else
    n_columns = f.UserData.n_columns;
    n_rows = f.UserData.n_rows;
    n_plates = f.UserData.n_plates;
end

switch evnt.Key
    case 'leftarrow'
        f.UserData.CurrentAxisIndex = max(1,f.UserData.CurrentAxisIndex-1);
    case 'rightarrow'
        f.UserData.CurrentAxisIndex = min(n_plates,f.UserData.CurrentAxisIndex+1);
    case 'uparrow'
        f.UserData.CurrentAxisIndex = max(1,f.UserData.CurrentAxisIndex-n_columns);
    case 'downarrow'
        f.UserData.CurrentAxisIndex = min(n_plates,f.UserData.CurrentAxisIndex+n_columns);
end
update_current_axis(handles);
%checkbox1_callback(handles.Checkbox1,[],handles);

end

function update_current_axis(handles)

if ~isfield(handles.MainFigure.UserData,'all_axes')
    return;
end

all_axes = handles.MainFigure.UserData.all_axes;
all_obj = findobj(all_axes,'Tag','Box');
delete(all_obj);
ax = all_axes(handles.MainFigure.UserData.CurrentAxisIndex);
line('XData',[ax.XLim(1) ax.XLim(2) ax.XLim(2) ax.XLim(1) ax.XLim(1)],...
    'YData',[ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2) ax.YLim(1)],...
    'Color','r','Parent',ax,'Tag','Box','LineWidth',1)

end

function plot_callback(~,~,handles)

% getting Variables
f = handles.MainFigure;
AtlasType = char(handles.Popup1.String(handles.Popup1.Value,:));
DisplayObj = char(handles.Popup2.String(handles.Popup2.Value,:));
DisplayMode = char(handles.Popup3.String(handles.Popup3.Value,:));
list_plates = eval(handles.Edit1.String);
list_regions = handles.Table1.Data(handles.Table1.UserData.Selection);
n_plates = length(list_plates);

% Retrieving
if ~isfield(f.UserData,'all_axes')
    warning('Load Atlas Plates and Regions before plotting.');
    return;
elseif isempty(handles.Table1.UserData.Selection)
    warning('Select Regions to plot.');
    return;
end
id_show = f.UserData.id_show;
list_show = f.UserData.list_show;
mask_show = f.UserData.mask_show;
all_axes = f.UserData.all_axes;
projection_axes = f.UserData.projection_axes;

full_volume = NaN(size(mask_show));
% label_volume = cell(size(mask_show));

f.Pointer = 'watch';
drawnow;

% Updating Axes
tic
for index=1:n_plates
    ax =  all_axes(index);
    hold(ax,'on');
    delete(findobj(ax,'Tag','FullMask')); 
    
    xyfig = list_plates(index);
    cur_mask = mask_show(:,:,xyfig);        
    data_plate = ax.UserData.data_plate;
    
    if isfield(handles.MainFigure.UserData,'values_txt')%size(handles.Table1.Data,2)>1
        value_regions = cell2mat(handles.Table1.Data(handles.Table1.UserData.Selection,2));
        M = max(value_regions(:));
        m = min(value_regions(:));
        handles.Edit11.String = sprintf('%.2f',m);
        handles.Edit12.String = sprintf('%.2f',M);
%         handles.Colorbar1.Limits = [m M];
    else
        value_regions = ones(length(list_regions),1);
    end
    
    % Building full_mask
    full_mask = NaN(size(data_plate.Mask,1),size(data_plate.Mask,2));
%     label_mask = cell(size(data_plate.Mask,1),size(data_plate.Mask,2));
    all_ids = [];
    all_regions = [];
    for i =1:length(list_regions)
        ind_region = find(strcmp(list_show,list_regions(i))==1);
        if ~isempty(ind_region)
            for j=1:length(ind_region)
                cur_id = id_show(ind_region(j));
                cur_region = list_show(ind_region(j));
                full_mask(cur_mask==cur_id)=value_regions(i);
%                 label_mask(cur_mask==cur_id)=cur_region;
                all_ids = [all_ids;cur_id];
                all_regions = [all_regions;cur_region]; 
            end
        end
    end
    
    % 3D rendering
    full_volume(:,:,xyfig) = full_mask;
%     label_volume(:,:,xyfig) = label_mask;

    % Storing data
    ax.UserData.cur_mask = cur_mask;
    ax.UserData.all_ids = all_ids;
    ax.UserData.all_regions = all_regions;
    
    % Plotting final mask
    im=imagesc(full_mask,'Tag','FullMask','Parent',ax);
    im.AlphaData = double(~isnan(full_mask));
    % uistack(im,'top');
    
    if isfield(handles.MainFigure.UserData,'values_txt')%size(handles.Table1.Data,2)>1
        ax.CLim = [m M];
    end
end

% Removing empty sections in full_volume
mean_xy = mean(full_volume,3,'omitnan');
mean_xz = squeeze(mean(full_volume,2,'omitnan'));
ind_keep_1 = ~isnan(mean(mean_xy,1,'omitnan'));
ind_keep_2 = ~isnan(mean(mean_xy,2,'omitnan'));
ind_keep_3 = ~isnan(mean(mean_xz,1,'omitnan'));
full_volume = full_volume(ind_keep_2,ind_keep_1,ind_keep_3);

% Interpolation Step
[Xq,Yq,Zq] = meshgrid(1:size(full_volume,2),1:size(full_volume,1),1:.75:size(full_volume,3));
full_volume = interp3(full_volume,Xq,Yq,Zq);
% full_volume = interp3(full_volume,interp_value);

% Only for plotting
% full_volume(1,1,1)=-5;
% full_volume(end,end,end)=50;

% Thresholded Volume
thresh_1 = str2double(handles.Edit2.String);
thresh_2 = str2double(handles.Edit3.String);
full_volume_thresholded = full_volume;
full_volume_thresholded(full_volume<thresh_1) = NaN;
full_volume_thresholded(full_volume>thresh_2) = NaN;

% Binary Volume
full_volume_binary = full_volume_thresholded;
full_volume_binary(~isnan(full_volume_binary)) = 1;

% Recomputing slices
mean_xy = mean(full_volume,3,'omitnan');
mean_xz = squeeze(mean(full_volume,2,'omitnan'));
mean_yz = squeeze(mean(full_volume,1,'omitnan'));

mean_xy_thresholded = mean(full_volume_thresholded,3,'omitnan');
mean_xz_thresholded = squeeze(mean(full_volume_thresholded,2,'omitnan'));
mean_yz_thresholded = squeeze(mean(full_volume_thresholded,1,'omitnan'));
mean_xy_thresholded(mean_xy_thresholded==0)=NaN;
mean_xz_thresholded(mean_xz_thresholded==0)=NaN;
mean_yz_thresholded(mean_yz_thresholded==0)=NaN;

mean_xy_binary = sum(full_volume_binary,3,'omitnan')./sum(~isnan(full_volume),3);
mean_xz_binary = squeeze(sum(full_volume_binary,2,'omitnan'))./squeeze(sum(~isnan(full_volume),2));
mean_yz_binary = squeeze(sum(full_volume_binary,1,'omitnan'))./squeeze(sum(~isnan(full_volume),1));
mean_xy_binary(mean_xy_binary==0)=NaN;
mean_xz_binary(mean_xz_binary==0)=NaN;
mean_yz_binary(mean_yz_binary==0)=NaN;

ax1 =  projection_axes(1,1);
im1 = imagesc(mean_xy,'Parent',ax1);
ax1.Title.String = 'Coronal';
set(ax1,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax1b =  projection_axes(1,2);
im1b = imagesc(mean_xy_thresholded,'Parent',ax1b);
ax1b.Title.String = 'Coronal (thresholded)';
set(ax1b,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax1c =  projection_axes(1,3);
im1c = imagesc(mean_xy_binary,'Parent',ax1c);
ax1c.Title.String = 'Coronal (binary)';
set(ax1c,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
colorbar(ax1);
colorbar(ax1b);
colorbar(ax1c);

ax2 =  projection_axes(2);
im2 = imagesc(mean_xz,'Parent',ax2);
set(ax2,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax2.Title.String = 'Sagittal';
ax2b =  projection_axes(2,2);
im2b = imagesc(mean_xz_thresholded,'Parent',ax2b);
set(ax2b,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax2b.Title.String = 'Sagittal (thresholded)';
ax2c =  projection_axes(2,3);
im2c = imagesc(mean_xz_binary,'Parent',ax2c);
ax2c.Title.String = 'Sagittal (binary)';
set(ax2c,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
colorbar(ax2);
colorbar(ax2b);
colorbar(ax2c);

ax3 =  projection_axes(3);
im3 = imagesc(mean_yz,'Parent',ax3);
set(ax3,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax3.Title.String = 'Transverse';
ax3b =  projection_axes(3,2);
im3b = imagesc(mean_yz_thresholded,'Parent',ax3b);
set(ax3b,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
ax3b.Title.String = 'Transverse (thresholded)';
ax3c =  projection_axes(3,3);
im3c = imagesc(mean_yz_binary,'Parent',ax3c);
ax3c.Title.String = 'Transverse (binary)';
set(ax3c,'XTick',[],'XTickLabel',[],'YTick',[],'YTickLabel',[]);
colorbar(ax3);
colorbar(ax3b);
colorbar(ax3c);

% Clearing background
all_images=[im1;im1b;im1c;im2;im2b;im2c;im3;im3b;im3c];
for i=1:length(all_images)
    im = all_images(i);
    im.AlphaData = ~isnan(im.CData);
end

% Plotting final Volume
f.Renderer='opengl';
% Recreate panel
delete(handles.Tab3.Children);
delete(handles.Tab4.Children);
delete(handles.Tab5.Children);
panel3 = uipanel('Units','normalized',...
    'Position',[0 0 1 1],...
    'bordertype','etchedin',...
    'Tag','Panel3',...
    'Parent',handles.Tab3);
panel4 = uipanel('Units','normalized',...
    'Position',[0 0 1 1],...
    'bordertype','etchedin',...
    'Tag','Panel4',...
    'Parent',handles.Tab4);
panel5 = uipanel('Units','normalized',...
    'Position',[0 0 1 1],...
    'bordertype','etchedin',...
    'Tag','Panel5',...
    'Parent',handles.Tab5);
    
renderer_mode = strtrim(handles.Popup5.String(handles.Popup5.Value,:));
% Display Volumes
% V = volshow(cat(2,full_volume,full_volume_thresholded),'Parent',panel3);
V = volshow(full_volume,'Parent',panel3);
V.Colormap = f.Colormap;
V.BackgroundColor = 'w';
% V.Renderer = 'MaximumIntensityProjection';
V.Renderer = renderer_mode;
V.CameraPosition = [1.0802 -2.6265 -2.1782];
V.CameraUpVector = [0.0400 -0.8979 0.4384];

% Adding extreme values as pixels in full_volume_thresholded 
if handles.Checkbox7.Value && isfield(handles.MainFigure.UserData,'values_txt')
    full_volume_thresholded(1,1,1)=m;
    full_volume_thresholded(end,end,end)=M;
end

V2 = volshow(full_volume_thresholded,'Parent',panel4);
V2.Colormap = f.Colormap;
V2.BackgroundColor = 'w';
% V2.Renderer = 'MaximumIntensityProjection';
V2.Renderer = renderer_mode;
V2.CameraPosition = V.CameraPosition;
V2.CameraUpVector = V.CameraUpVector;

V3 = volshow(full_volume_binary,'Parent',panel5);
V3.Colormap = f.Colormap;
V3.BackgroundColor = 'w';
% V3.Renderer = 'MaximumIntensityProjection';
V3.Renderer = renderer_mode;
V3.CameraPosition = V.CameraPosition;
V3.CameraUpVector = V.CameraUpVector;

% Storing
f.UserData.full_volume_thresholded=full_volume_thresholded;
f.UserData.full_volume_binary=full_volume_binary;
f.UserData.full_volume=full_volume;
f.UserData.V=V;
f.UserData.V2=V2;
f.UserData.V3=V3;

checkbox3_callback(handles.Checkbox3,[],handles);
checkbox4_callback(handles.Checkbox4,[],handles);
checkbox5_callback(handles.Checkbox5,[],handles);
toc

f.Pointer = 'arrow';

end

function e4_Callback(hObj,~,handles)

f = handles.MainFigure;
panel3 = findobj(f,'Tag','Panel3');
panel4 = findobj(f,'Tag','Panel4');
val = str2double(hObj.String);

end

function template_uitable_select(hObj,evnt,handles)

if ~isempty(evnt.Indices)
    hObj.UserData.Selection = unique(evnt.Indices(:,1));
else
    hObj.UserData.Selection = [];
end

if handles.Checkbox6.Value
    plot_callback([],[],handles);
end

end

function checkbox1_callback(hObj,~,handles)

if ~isfield(handles.MainFigure.UserData,'CurrentAxisIndex')
    return;
end

all_axes = handles.MainFigure.UserData.all_axes;
all_positions = handles.MainFigure.UserData.all_positions;
margin_w = handles.MainFigure.UserData.margin_w;
margin_h = handles.MainFigure.UserData.margin_h;
%cur_axis = all_axes(handles.MainFigure.UserData.CurrentAxisIndex);
box = findobj(all_axes,'Tag','Box');

if hObj.Value
    % Collapse
    box.Visible = 'off';
    for i =1:length(all_axes)
        if i==handles.MainFigure.UserData.CurrentAxisIndex
            all_axes(i).Position = [margin_w 0 1-margin_w 1-margin_h];    
        else
            all_axes(i).Position = [1 1 1 1];
        end
    end
else
    % Expand
    box.Visible = 'on';
    for i =1:length(all_axes)
        all_axes(i).Position = all_positions(i,:);
    end
end

end

function checkbox1b_callback(hObj,~,handles)

all_axes = handles.MainFigure.UserData.all_axes;
if hObj.Value
    for i = 1:length(all_axes)
        all_axes(i).Title.Visible = 'on';
    end
else
    for i = 1:length(all_axes)
        all_axes(i).Title.Visible = 'off';
    end
end

end

function checkbox2_callback(hObj,~,handles)

all_axes = handles.MainFigure.UserData.all_axes;
all_obj = findobj(all_axes,'Tag','Plate');
if hObj.Value
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'on';
    end
else
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'off';
    end
end

end

function checkbox3_callback(hObj,~,handles)

all_axes = handles.MainFigure.UserData.all_axes;
all_obj = findobj(all_axes,'Tag','FullMask');
if hObj.Value
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'on';
    end
else
    for i = 1:length(all_obj)
        all_obj(i).Visible = 'off';
    end
end

end

function checkbox4_callback(hObj,~,handles)

textColor = 'r';
fontsize = 10;
all_axes = handles.MainFigure.UserData.all_axes;
all_obj = findobj(all_axes,'Tag','Sticker');
delete(all_obj);

if hObj.Value
    for i = 1:length(all_axes)
        ax = all_axes(i);
        if ~isfield(ax.UserData,'all_regions')
            continue;
        end
        
        for j = 1:length(ax.UserData.all_regions)
            cur_id = ax.UserData.all_ids(j);
            cur_region = char(ax.UserData.all_regions(j));
            % Display Name
            [X,Y]=meshgrid(1:size(ax.UserData.cur_mask,2),1:size(ax.UserData.cur_mask,1));
            temp_X = X.*(ax.UserData.cur_mask==cur_id);
            temp_X(temp_X==0)=NaN;
            x = mean(mean(temp_X,'omitnan'),'omitnan');
            temp_Y = Y.*(ax.UserData.cur_mask==cur_id);
            temp_Y(temp_Y==0)=NaN;
            y = mean(mean(temp_Y,'omitnan'),'omitnan');
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

end

function checkbox5_callback(hObj,~,handles)

if ~isfield(handles.MainFigure.UserData,'all_axes')
    return;
end
if ~isfield(handles.MainFigure.UserData,'projection_axes')
    return;
end

% handles.Colorbar1.Limits = [str2double(handles.Edit11.String) str2double(handles.Edit12.String)];
all_axes = handles.MainFigure.UserData.all_axes;
projection_axes = handles.MainFigure.UserData.projection_axes;
all_andpro_axes = [all_axes;projection_axes(:,1);projection_axes(:,2)];

if hObj.Value
    % clim mode auto
    for i = 1:length(all_andpro_axes)
        all_andpro_axes(i).CLimMode = 'auto';
    end
    fprintf('CLimMode set to auto.\n');
else
    % clim mode manual
    for i = 1:length(all_andpro_axes)
        all_andpro_axes(i).CLimMode = 'manual';
        all_andpro_axes(i).CLim = [str2double(handles.Edit11.String) str2double(handles.Edit12.String)];
    end
    fprintf('CLimMode set to manual.\n');
end

end

function checkbox6_callback(hObj,~,handles)

if hObj.Value
    handles.Button2.Enable = 'off';
else
    handles.Button2.Enable = 'on';
end

end

function click_plate(hObj,~,handles)
    ax = hObj.Parent;
    handles.MainFigure.UserData.CurrentAxisIndex = ax.UserData.index;
    update_current_axis(handles);
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