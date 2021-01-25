function build_atlas(varargin)
% build_atlas() builds a plotable Paxinos Atlas in a plate-by-plate manner
% Requires Atlas_XXX.mat plates to be stored in RawPlates folder
% Requires plates.txt & RegionLedger.txt for region correspondence
% Stores the resultins Atlas in PlotableAtlas folder
%
% Possible arguments include
% 'AtlasType' - [ratcoronal(default)|ratsagittal|mousecoronal|mousesagittal] Type of Atlas
% 'AtlasDir' - [path] Atlas directory containing PlotableAtlas folder
% 'LedgerDir' - [path] Ledger directory containing region correspondence txt files
% 'PlateList' - [array] List of plate numbers to be displayed

if mod(length(varargin),2)==1
    error('List of input arguments must be grouped in pairs.');
end

% Main Parameters
% Default Parameters
AtlasType = 'ratcoronal';
dir_txt = '';
temp = which('build_atlas.m');
dir_atlas = strrep(temp,strcat(filesep,'build_atlas.m'),'');
list_plates = 'all';

% Parsing varargin
all_properties = [{'atlastype'};{'ledgerdir'};{'atlasdir'};{'platelist'}];
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
                
            case 'atlasdir'
                if ~exist(varargin{i+1},'dir')
                    error('Property %s is not an existing directory.',varargin{i})
                else
                    dir_atlas = varargin{i+1};
                end
                
            case 'platelist'
                if isnumeric(varargin{i+1}) && sum(floor(varargin{i+1})==varargin{i+1})==length(varargin{i+1})
                    list_plates = varargin{i+1};
                else
                    error('Property %s is not an array of positive integers.',varargin{i})
                end             
        end
    end
end


% Secondary Parameters
% plate_name
switch AtlasType
    case 'ratcoronal'
        plate_name = 'RatCoronalPaxinos';
        if strcmp(list_plates,'all')
            list_plates = 1:161;
        elseif sum(list_plates<1)>0 || sum(list_plates>161)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 161',AtlasType);
        end
    case 'ratsagittal'
        plate_name = 'RatSagittalPaxinos';
        if strcmp(list_plates,'all')
            list_plates = 1:38;
        elseif sum(list_plates<1)>0 || sum(list_plates>38)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 38',AtlasType);
        end
    case 'mousecoronal'
        plate_name = 'MouseCoronalPaxinos';
        if strcmp(list_plates,'all')
            list_plates = 1:100;
        elseif sum(list_plates<1)>0 || sum(list_plates>100)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 100',AtlasType);
        end
    case 'mousesagittal'
        plate_name = 'MouseSagittalPaxinos';
        if strcmp(list_plates,'all')
            list_plates = 1:64;
        elseif sum(list_plates<1)>0 || sum(list_plates>64)>0
            error('PlateList for Atlas %s must contain integer values between 1 and 64',AtlasType);
        end
end

% Manual Selection if dir_txt is not specified
% Seed directory where atlas correspondances (txt files) are located
flag_force = false;
if isempty(dir_txt) || ~exist(fullfile(dir_txt,plate_name),'dir')
    fprintf('Select Ledger Directory.\n')
    dir_txt = uigetdir(dir_atlas,'Select Ledger Directory');
    if dir_txt==0
        choice = questdlg('Ledger Directory not selected. Import unlabeled Atlas ?',...
            'User Confirmation','OK','Cancel','Cancel');
        if isempty(choice) || ~strcmp(choice,'OK')
            fprintf('Build Atlas %s cancelled.\n',AtlasType);
            return;
        else
            flag_force = true;
        end
        %        errordlg('Invalid Ledger directory');
        %        return;
    end
end
folder_mat = fullfile(dir_atlas,'RawPlates',plate_name);
folder_txt = fullfile(dir_txt,plate_name);

% Searching for Atlas plates
d = dir(fullfile(folder_mat,'Atlas*.mat'));
if isempty(d)
    errordlg(sprintf('Wrong directory. Missing Atlas.mat Plates in [%s].',folder_mat));
    return;
end

% Searching for txt files
if ~flag_force
    dd = dir(fullfile(folder_txt,'*.txt'));
    if isempty(dd)
        errordlg(sprintf('Wrong directory. Missing txt files in [%s].',folder_txt));
        return;
    end
end

% Creating save directory
savedir = fullfile(dir_atlas,'PlotableAtlas',plate_name);
if isdir(savedir)
    rmdir(savedir,'s');
end
mkdir(savedir);

% Importing plates
for xyfig = list_plates
    % loading plate
    data_atlas = load(fullfile(folder_mat,sprintf('Atlas_%03d.mat',xyfig)));
    
    % getting coordinate
    switch AtlasType
        case {'ratcoronal','mousecoronal'}
            AP = data_atlas.AP_mm;
        case {'ratsagittal','mousesagittal'}
            AP = data_atlas.ML_mm;
    end
    line_x=data_atlas.line_x;
    line_z=data_atlas.line_z;
    Mask=data_atlas.Mask(:,:,1);
    
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
    
    % Browsing Mask values
    list_regions =[];
    mask_regions=[];
    list_unlabeled =[];
    mask_unlabeled=[];
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
        if isempty(index_region) || contains(atlas_name(index_region),'region')
            %cur_region = sprintf('region%03d',i);
            cur_region = sprintf('r%03d',i);
            list_unlabeled =[list_unlabeled;{cur_region}];
            mask_unlabeled=cat(3,mask_unlabeled,cur_mask);
        else
            cur_region = atlas_name(index_region);
            list_regions =[list_regions;cur_region];
            mask_regions=cat(3,mask_regions,cur_mask);
        end
    end
    
    % Merging list_regions & list_unlabeled
    list_regions = [list_regions;list_unlabeled];
    mask_regions = cat(3,mask_regions,mask_unlabeled);
    
    % sanity check
    if ~isempty(list_regions) && length(list_regions)~=size(mask_regions,3)
        errordlg('sanity check 1 failed');
        return;
    end
    
    %     % Removing duplicates
    %     if length(list_regions)~=length(unique(list_regions))
    %         list_regions
    %     end
    
    % Adding bilateral regions
    %list_test = unique(regexprep(list_regions,'-L|-R',''))
    list_test = [];
    for i = 1:length(list_regions)
        temp = char(list_regions(i));
        if length(temp)>1 && (strcmp(temp(end-1:end),'-L')||strcmp(temp(end-1:end),'-R'))
            list_test = [list_test ; {temp(1:end-2)}];
        else
            list_test = [list_test ; {temp}];
        end
    end
    list_bilateral=unique(list_test);
    
    mask_bilateral = [];
    for i = 1:length(list_bilateral)
        ind_1 = find(strcmp(list_regions,strcat(char(list_bilateral(i)),'-L'))==1);
        ind_2 = find(strcmp(list_regions,strcat(char(list_bilateral(i)),'-R'))==1);
        ind_3 = find(strcmp(list_regions,char(list_bilateral(i)))==1);
        ind_all = [ind_1;ind_2;ind_3];
        cur_mask = [];
        for k=1:length(ind_all)
            cur_mask=cat(3,cur_mask,mask_regions(:,:,ind_all(k)));
        end
        cur_mask = sum(cur_mask,3)>0;
        mask_bilateral = cat(3,mask_bilateral,cur_mask);
    end
    
    %sanitycheck
    if ~isempty(list_bilateral) && length(list_bilateral)~=size(mask_bilateral,3)
        errordlg('sanity check 2 failed');
        return;
    end
    
    % Adding Region Groups
    ledger_txt =  fullfile(dir_txt,'RegionLedger.txt');
    list_groups = [];
    mask_groups = [];
    list_groups_bilateral = [];
    mask_groups_bilateral = [];
    
    if exist(ledger_txt,'file')
        fileID = fopen(ledger_txt);
        %header
        fgetl(fileID);
        while ~feof(fileID)
            hline = fgetl(fileID);
            cline = regexp(hline,'\t','split');
            c1 = strtrim(cline(1));
            % c2 = strtrim(cline(2));
            %c3 = strtrim(cline(3));
            c4 = strtrim(cline(4));
            temp = regexp(char(c4),' ','split')';
            ind_cmp = [];
            ind_cmp2 = [];
            for i =1:length(temp)
                ind_cmp = [ind_cmp;find(strcmp(list_regions,temp(i))==1)];
                ind_cmp2 = [ind_cmp2;find(strcmp(list_bilateral,temp(i))==1)];
            end
            
            cur_mask = [];
            if ~isempty(ind_cmp)
                cur_mask = sum(mask_regions(:,:,ind_cmp),3)>0;
                list_groups = [list_groups;c1];
                mask_groups = cat(3,mask_groups,cur_mask);
            end
            cur_mask2 = [];
            if ~isempty(ind_cmp2)
                cur_mask2 = sum(mask_bilateral(:,:,ind_cmp2),3)>0;
                list_groups_bilateral = [list_groups_bilateral;c1];
                mask_groups_bilateral = cat(3,mask_groups_bilateral,cur_mask2);
            end
        end
        fclose(fileID);
    end
    fprintf('Atlas Plate imported [%s-%03d/%03d].\n',AtlasType,xyfig,length(d));
    
    % sanity check
    if ~isempty(list_groups) && length(list_groups)~=size(mask_groups,3)
        errordlg('sanity check 3 failed');
        return;
    end
    % sanity check
    if ~isempty(list_groups_bilateral) && length(list_groups_bilateral)~=size(mask_groups_bilateral,3)
        errordlg('sanity check 4 failed');
        return;
    end
    
    mask_regions = uint8(mask_regions);
    mask_unlabeled = uint8(mask_unlabeled);
    mask_bilateral = uint8(mask_bilateral);
    mask_groups = uint8(mask_groups);
    mask_groups_bilateral = uint8(mask_groups_bilateral);
    sizemask_1 = size(Mask,1);
    sizemask_2 = size(Mask,2);
    
    save(fullfile(savedir,sprintf('%s-%03d.mat',plate_name,xyfig)),...
        'xyfig','line_x','line_z','AP','sizemask_1','sizemask_2',...
        'list_regions','mask_regions',...'list_unlabeled','mask_unlabeled',...
        'list_bilateral','mask_bilateral',...
        'list_groups','mask_groups',...
        'list_groups_bilateral','mask_groups_bilateral','-v7.3');
end

% Saving plotable Atlas in full
% save(fullfile(savedir,sprintf('PlotableAtlas_%s.mat',plate_name)),'Atlas','-append');
% fprintf('Plotable Atlas (%d plates) saved [%s].\n',length(d),savedir);
fprintf('Plotable Atlas succesfully imported [%s].\n',savedir);

end