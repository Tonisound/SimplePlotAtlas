function [this_regions,this_occurences] = generate_lists(varargin)
% generate_lists() generates a list of regions as a cell arrays based on
% input arguments
%
% Possible arguments include
% 'AtlasType' - [ratcoronal(default)|ratsagittal|mousecoronal|mousesagittal] Type of Atlas
% 'DisplayObj' - [regions(default)|groups] Displays regions, regions groups or both
% 'DisplayMode' - [unilateral(default)|bilateral] Displays uni/bilateral regions/groups
% 'PlateList' - [array] List of plate numbers to be displayed

if mod(length(varargin),2)==1
    error('List of input arguments must be grouped in pairs.');
end

% Main Parameters
% Default Parameters
AtlasType = 'ratcoronal';
list_plates = 'all';
DisplayObj = 'regions';
DisplayMode = 'unilateral';
temp = which('generate_lists.m');
dir_atlas = strrep(temp,strcat(filesep,'generate_lists.m'),'');


% Parsing varargin
all_properties = [{'atlastype'};{'displayobj'};{'displaymode'};{'platelist'}];
for i =1:2:length(varargin)
    if sum(strcmpi(all_properties,varargin{i}))==0
        error('Unknown Property : %s.',varargin{i});
    else
        switch lower(varargin{i})
            case 'atlastype'
                if sum(strcmp([{'ratsagittal'},{'ratcoronal'},{'mousesagittal'},{'mousecoronal'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    AtlasType = varargin{i+1};
                end
                
            case 'platelist'
                if isnumeric(varargin{i+1}) && sum(floor(varargin{i+1})==varargin{i+1})==length(varargin{i+1})
                    list_plates = varargin{i+1};
                else
                    error('Property %s is not an array of positive integers.',varargin{i})
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
        end
    end
end


% Secondary Parameters
% plate_name & n_plates
switch AtlasType
    case 'ratcoronal'
        plate_name = 'RatCoronalPaxinos';
        n_plates = 161;

    case 'ratsagittal'
        plate_name = 'RatSagittalPaxinos';
        n_plates = 38;

    case 'mousecoronal'
        plate_name = 'MouseCoronalPaxinos';
        n_plates = 100;

    case 'mousesagittal'
        plate_name = 'MouseSagittalPaxinos';
        n_plates = 64;

end
% Setting list_plates if argument is 'all'
if strcmp(list_plates,'all')
    list_plates = 1:n_plates;
elseif sum(list_plates<1)>0 || sum(list_plates>n_plates)>0
    error('PlateList for Atlas %s must contain integer values between 1 and %d',AtlasType,n_plates);
end

% Load lists
savedir = fullfile(dir_atlas,'Plates',plate_name);
data_atlas = load(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)));

% Restricting to list_plates
% Mask1
Maskfull = data_atlas.Mask_regions(:,:,list_plates);
all_indexes = unique(Maskfull(Maskfull~=0));
list_regions = data_atlas.list_regions(all_indexes(all_indexes~=0));
id_regions = data_atlas.id_regions(all_indexes(all_indexes~=0));

% Mask2
Maskfull = data_atlas.Mask_bilateral(:,:,list_plates);
all_indexes = unique(Maskfull(Maskfull~=0));
list_bilateral = [];
id_bilateral = [];
for i = 1:length(all_indexes)
    list_bilateral = [list_bilateral;data_atlas.list_bilateral(data_atlas.id_bilateral==all_indexes(i))];
    id_bilateral = [id_bilateral;all_indexes(i)];
end
% Mask3
Maskfull = data_atlas.Mask_groups(:,:,list_plates);
all_indexes = unique(Maskfull(Maskfull~=0));
list_groups = [];
id_groups = [];
for i = 1:length(all_indexes)
    list_groups = [list_groups;data_atlas.list_groups(data_atlas.id_groups==all_indexes(i))];
    id_groups = [id_groups;all_indexes(i)];
end
% Mask4
Maskfull = data_atlas.Mask_groups_bilateral(:,:,list_plates);
all_indexes = unique(Maskfull(Maskfull~=0));
list_groups_bilateral = [];
id_groups_bilateral = [];
for i = 1:length(all_indexes)
    list_groups_bilateral = [list_groups_bilateral;data_atlas.list_groups_bilateral(data_atlas.id_groups_bilateral==all_indexes(i))];
    id_groups_bilateral = [id_groups_bilateral;all_indexes(i)];
end

if strcmp(DisplayMode,'unilateral')
    switch DisplayObj
        case 'regions'
            this_regions = list_regions;
            this_Mask = data_atlas.Mask_regions(:,:,list_plates);
            this_id = id_regions;
        case 'groups'
            this_regions = list_groups;
            this_Mask = data_atlas.Mask_bilateral(:,:,list_plates);
            this_id = id_groups;
    end
elseif strcmp(DisplayMode,'bilateral')
    switch DisplayObj
        case 'regions'
            this_regions = list_bilateral;
            this_Mask = data_atlas.Mask_groups(:,:,list_plates);
            this_id = id_bilateral;
        case 'groups'
            this_regions = list_groups_bilateral;
            this_Mask = data_atlas.Mask_groups_bilateral(:,:,list_plates);
            this_id = id_groups_bilateral;
    end
end

% Counting occurences
%this_occurences = ones(size(this_regions));
this_occurences = [];
for i =1:length(this_id)
    occurence = squeeze(sum(sum(this_Mask==this_id(i),1),2));
    this_occurences = [this_occurences;sum(occurence>0)];
end

end

% l = generate_lists('DisplayObj','groups','DisplayMode','bilateral');
% folder_save = '/Users/tonio/Desktop/RegionGroups';
% 
% for i =1:length(l)
%     cur_region = l(i);
%     savename=fullfile(folder_save,strcat(char(cur_region),'.png'));
%     plot_atlas(cur_region,'DisplayObj','groups','DisplayMode','bilateral',...
%         'SaveName',savename,'FontSize',4,'PaperOrientation','landscape',...
%         'PlateList',10:99,'NColumns',10,'LineWidth',.001);
% end