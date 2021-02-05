function build_atlas(varargin)
% build_atlas() builds a volumetric plotable Paxinos Atlas
% Browses individual plates in the Plates folder
% Browses txt files in directory LedgerDir for region correspondence
% Stores the resulting Atlas as a numeric volumetric Mask (PlotableAtlas.mat)
%
% Possible arguments include
% 'AtlasType' - [ratcoronal(default)|ratsagittal|mousecoronal|mousesagittal] Type of Atlas
% 'LedgerDir' - [path] Ledger directory containing region correspondence txt files
% 'PlateList' - [array|'all'(default)] List of plate numbers to be displayed
% 'Unlabeled' - [on|off (default)] include unlabeled regions in Atlas

if mod(length(varargin),2)==1
    error('List of input arguments must be grouped in pairs.');
end

% Main Parameters
% Default Parameters
AtlasType = 'ratcoronal';
list_plates = 'all';
include_unlabeled = 'off';

temp = which('build_atlas.m');
dir_atlas = strrep(temp,strcat(filesep,'build_atlas.m'),'');
dir_txt = fullfile(dir_atlas,'LedgerDir');


% Parsing varargin
all_properties = [{'atlastype'};{'ledgerdir'};{'platelist'};{'unlabeled'}];
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
                
            case 'ledgerdir'
                if ~exist(varargin{i+1},'dir')
                    error('Property %s is not an existing directory.',varargin{i})
                else
                    dir_txt = varargin{i+1};
                end
                
            case 'platelist'
                if isnumeric(varargin{i+1}) && sum(floor(varargin{i+1})==varargin{i+1})==length(varargin{i+1})
                    list_plates = varargin{i+1};
                else
                    error('Property %s is not an array of positive integers.',varargin{i})
                end
                
            case 'unlabeled'
                if sum(strcmp([{'on'},{'off'}],varargin{i+1}))==0
                    error('Unknown value for property %s.',varargin{i})
                else
                    include_unlabeled = varargin{i+1};
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

% % Manual Selection if dir_txt is not specified
% % Seed directory where atlas correspondances (txt files) are located
% flag_force = false;
% if isempty(dir_txt) || ~exist(fullfile(dir_txt,plate_name),'dir')
%     fprintf('Select Ledger Directory.\n')
%     dir_txt = uigetdir(dir_atlas,'Select Ledger Directory');
%     if dir_txt==0
%         choice = questdlg('Ledger Directory not selected. Import unlabeled Atlas ?',...
%             'User Confirmation','OK','Cancel','Cancel');
%         if isempty(choice) || ~strcmp(choice,'OK')
%             fprintf('Build Atlas %s cancelled.\n',AtlasType);
%             return;
%         else
%             flag_force = true;
%         end
% %         errordlg('Invalid Ledger directory');
% %         return;
%     end
% end
folder_mat = fullfile(dir_atlas,'Plates',plate_name);
folder_txt = fullfile(dir_txt,plate_name);

% Searching for Atlas plates
d = dir(fullfile(folder_mat,'Atlas*.mat'));
if isempty(d)
    errordlg(sprintf('Wrong directory. Missing Atlas.mat Plates in [%s].',folder_mat));
    return;
end

% Searching for txt files
dd = dir(fullfile(folder_txt,'*.txt'));
if isempty(dd)
    errordlg(sprintf('Wrong directory. Missing txt files in [%s].',folder_txt));
    return;
end

% Creating save directory
% savedir = fullfile(dir_atlas,'PlotableAtlas',plate_name);
% if isdir(savedir)
%     rmdir(savedir,'s');
% end
% mkdir(savedir);
savedir = folder_mat;

% Initialize
data_init = load(fullfile(folder_mat,sprintf('Atlas_%03d.mat',1)));
Mask1full = repmat({''},size(data_init.Mask,1),size(data_init.Mask,2),n_plates);
Mask2full = repmat({''},size(data_init.Mask,1),size(data_init.Mask,2),n_plates);
Mask3full = repmat({''},size(data_init.Mask,1),size(data_init.Mask,2),n_plates);
Mask4full = repmat({''},size(data_init.Mask,1),size(data_init.Mask,2),n_plates);
    

% Importing plates
for xyfig = list_plates
    % loading plate
    data_plate = load(fullfile(folder_mat,sprintf('Atlas_%03d.mat',xyfig)));
    Mask=data_plate.Mask(:,:,1);

    % Adding Regions
    atlas_txt =  fullfile(folder_txt,sprintf('%s-plate%d.txt',plate_name,xyfig));
    region_id = [];
    atlas_name = [];
    if exist(atlas_txt,'file')
        fileID = fopen(atlas_txt);
        while ~feof(fileID)
            hline = fgetl(fileID);
            cline = regexp(hline,'\t','split');
            c1 = strtrim(cline(1));
            c2 = strtrim(cline(2));
            c2 = strrep(c2,'_','-');
            %c3 = strtrim(cline(3));
            region_id = [region_id;eval(char(c1))];
            atlas_name = [atlas_name;c2];
            %channel_type = [channel_type;c3];
        end
        fclose(fileID);
    end
    
    % Mask1: Regions unilateral
    % Browsing Mask values
    Mask1 =repmat({''},size(Mask,1),size(Mask,2));
    for i=1:max(Mask(:),[],'omitnan')
        cur_mask = (Mask==i);
        if sum(cur_mask(:))==0
            continue;
        end
        % checking for multiple indexing
        index_region = find(region_id==i);
        if length(index_region)>1
            warning('Muliple indexing for region %d [%s].',i);
            index_region=index_region(1);
        end
        if isempty(index_region) || startsWith(atlas_name(index_region),'region')
            if strcmp(include_unlabeled,'on')
                cur_region = sprintf('region%d',i);
            else
                continue;
            end
        else
            cur_region = char(atlas_name(index_region));
        end
        Mask1(Mask==i)={cur_region};
    end
    this_regions = unique(Mask1(:));
    this_regions = this_regions(~strcmp(this_regions,''));
    Mask1full(:,:,xyfig) = Mask1; 
    
    % Mask2 : Regions bilateral
    % Removing -L and -R at the end (and before a '!')
    Mask2 = Mask1;
    Mask2 = strrep(Mask2,'-L!','!');
    Mask2 = strrep(Mask2,'-R!','!');
    this_regions = strrep(this_regions,'-L!','!');
    this_regions = strrep(this_regions,'-R!','!');
    for i = 1:length(this_regions)
        cur_region = char(this_regions(i));
        if length(cur_region)>2 && (strcmp(cur_region(end-1:end),'-L')||strcmp(cur_region(end-1:end),'-R'))
            this_regions(i) = {cur_region(1:end-2)};
            temp = unique(regexp(char(this_regions(i)),'!','split'));
            if length(temp)>1
                Mask2(strcmp(Mask2,cur_region)) = {strjoin(temp,'!')};
            else
                Mask2(strcmp(Mask2,cur_region)) = temp;
            end
        end
    end
    Mask2full(:,:,xyfig) = Mask2;
    
    % Adding Region Groups
    Mask3 =repmat({''},size(Mask,1),size(Mask,2));
    Mask4 =repmat({''},size(Mask,1),size(Mask,2));
    
    ledger_txt =  fullfile(dir_txt,'RegionLedger.txt');    
    if exist(ledger_txt,'file')
        fileID = fopen(ledger_txt);
        %header
        fgetl(fileID);
        while ~feof(fileID)
            hline = fgetl(fileID);
            cline = regexp(hline,'\t','split');
            c1 = strtrim(cline(1));
            % c2 = strtrim(cline(2));
            % c3 = strtrim(cline(3));
            c4 = strtrim(cline(4));
            temp = regexp(char(c4),' ','split')';
            % Mask3
            all_masks = [];
            for i =1:length(temp)
                cur_mask = strcmp(Mask1,temp(i));
                all_masks = cat(3,all_masks,cur_mask);
            end
            cur_mask = sum(all_masks,3)>0;
            Mask3(cur_mask) = c1;
            % Mask4            
            all_masks = [];
            for i =1:length(temp)
                cur_mask = strcmp(Mask2,temp(i));
                all_masks = cat(3,all_masks,cur_mask);
            end
            cur_mask = sum(all_masks,3)>0;
            Mask4(cur_mask) = c1;

        end
        fclose(fileID);
    end
    Mask3full(:,:,xyfig) = Mask3;
    Mask4full(:,:,xyfig) = Mask4;
    fprintf('Atlas Plate imported [%s-%03d/%03d].\n',plate_name,xyfig,length(d));    
end

% Efficient Storing
% Mask1
Maskfull = Mask1full;
all_regions = unique(Maskfull(:));
all_regions = sort(all_regions(~strcmp(all_regions,'')));
all_ids = NaN(size(all_regions));
Masknumeric = zeros(size(Maskfull,1),size(Maskfull,2),size(Maskfull,3));
for i =1:length(all_regions)
    all_ids(i) = i;
    Masknumeric(strcmp(Maskfull,char(all_regions(i))))=all_ids(i);
    fprintf('Bulding Mask Unilateral Regions - [%s (%d/%d)]\n',char(all_regions(i)),i,length(all_regions));
end
id_regions = all_ids;
list_regions = all_regions;
Mask_regions = Masknumeric;
% Mask2
Maskfull = Mask2full;
all_regions = unique(Maskfull(:));
all_regions = sort(all_regions(~strcmp(all_regions,'')));
all_ids = NaN(size(all_regions));
Masknumeric = zeros(size(Maskfull,1),size(Maskfull,2),size(Maskfull,3));
for i =1:length(all_regions)
    all_ids(i) = i+.1;
    Masknumeric(strcmp(Maskfull,char(all_regions(i))))=all_ids(i);
    fprintf('Bulding Mask Bilateral Regions - [%s (%d/%d)]\n',char(all_regions(i)),i,length(all_regions));
end
id_bilateral = all_ids;
list_bilateral = all_regions;
Mask_bilateral = Masknumeric;
% Mask3
Maskfull = Mask3full;
all_regions = unique(Maskfull(:));
all_regions = sort(all_regions(~strcmp(all_regions,'')));
all_ids = NaN(size(all_regions));
Masknumeric = zeros(size(Maskfull,1),size(Maskfull,2),size(Maskfull,3));
for i =1:length(all_regions)
    all_ids(i) = i+.2;
    Masknumeric(strcmp(Maskfull,char(all_regions(i))))=all_ids(i);
    fprintf('Bulding Mask Unilateral Groups - [%s (%d/%d)]\n',char(all_regions(i)),i,length(all_regions));
end
id_groups = all_ids;
list_groups = all_regions;
Mask_groups = Masknumeric;
% Mask4
Maskfull = Mask4full;
all_regions = unique(Maskfull(:));
all_regions = sort(all_regions(~strcmp(all_regions,'')));
all_ids = NaN(size(all_regions));
Masknumeric = zeros(size(Maskfull,1),size(Maskfull,2),size(Maskfull,3));
for i =1:length(all_regions)
    all_ids(i) = i+.3;
    Masknumeric(strcmp(Maskfull,char(all_regions(i))))=all_ids(i);
    fprintf('Bulding Mask Bilateral Groups - [%s (%d/%d)]\n',char(all_regions(i)),i,length(all_regions));
end
id_groups_bilateral = all_ids;
list_groups_bilateral = all_regions;
Mask_groups_bilateral = Masknumeric;

% Saving plotable Atlas in full
save(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)),...
    'AtlasType','plate_name','list_plates','dir_txt','dir_atlas',...
    'id_regions','id_bilateral','id_groups','id_groups_bilateral',...
    'list_regions','list_bilateral','list_groups','list_groups_bilateral',...
    'Mask_regions','Mask_bilateral','Mask_groups','Mask_groups_bilateral','-v7.3');
fprintf('Plotable Atlas succesfully imported [%s].\n',savedir);

end