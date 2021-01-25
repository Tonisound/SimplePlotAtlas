function list_regions = generate_lists(varargin)
% generate_lists() generates a list of regions as a cell arrays based on
% input arguments
%
% Possible arguments include
% 'AtlasType' - [ratcoronal(default)|ratsagittal|mousecoronal|mousesagittal] Type of Atlas
% 'DisplayObj' - [regions|groups|all(default)] Displays regions, regions groups or both
% 'DisplayMode' - [unilateral(default)|bilateral] Displays uni/bilateral regions/groups
% 'PlateList' - [array] List of plate numbers to be displayed

if mod(length(varargin),2)==1
    error('List of input arguments must be grouped in pairs.');
end

% Main Parameters
% Default Parameters
AtlasType = 'ratcoronal';
list_plates = 'all';
DisplayObj = 'all';
DisplayMode = 'unilateral';

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
                if sum(strcmp([{'all'},{'regions'},{'groups'}],varargin{i+1}))==0
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

list_regions = plate_name;

end