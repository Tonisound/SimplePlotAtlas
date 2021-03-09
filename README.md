Package Build and Plot Atlas
Version 1.5.1 - Date 09/03/2021
Contact: antoine.bergel@espci.fr

This package contains two main functions
- build_atlas takes as input raw plates (saved in Plates folder) and generates a plotable atlas for easy display
- plot_atlas takes as input the plotable atlas (saved in Plates folder) and generates a compact plate-by-plate display that can be color-coded
- viewer_atlas takes no input and displays the Plotable Atlas and values for regions in a simple GUI.

The list of parameters for each function is detailed in help build_atlas.m and help plot_atlas.m
Each plate is composed of regions (unilateral or bilateral) and groups of regions (unilateral or bilateral)
Groups and region names are specified in txt files in the Ledger Directory.

Example 1: plot all plates with region names and saves in folder Test
>> plot_atlas({'all'},'VisibleMask','off','PlateList',1:10:120,'AtlasType','ratcoronal',...
    'DisplayObj','regions','DisplayMode','unilateral','FontSize',6,'PaperOrientation','portrait',...
    'SaveName',fullfile('Test','Example1A.pdf'));
>> plot_atlas({'all'},'VisibleMask','off','PlateList',1:4:38,'AtlasType','ratsagittal',...
    'DisplayObj','regions','DisplayMode','unilateral','FontSize',6,'PaperOrientation','landscape',...
    'SaveName',fullfile('Test','Example1B.pdf'));

Example 2: plot all regions in colors according to value_regions
>> list_regions = {'S1BF-L';'S1BF-R';'CPu-L';'CPu-R';};
>> value_regions = rand(length(list_regions),1);
>> plot_atlas(list_regions,'Values',value_regions,'PlateList',1:5:120,'VisibleColorBar','on','SaveName','Example2A.pdf');
>> plot_atlas(list_regions,'Values',value_regions,'PlateList',1:5:120,'AtlasType','ratsagittal','VisibleColorBar','on','SaveName','Example2A.pdf');

Example 3: Display bilateral regions groups (with or without masks)
>> plot_atlas({'all'},'PlateList',10:11,'DisplayObj','groups','DisplayMode','bilateral','SaveName','Example3A.pdf');
>> plot_atlas({'all'},'PlateList',10:11,'DisplayObj','regions','DisplayMode','unilateral','SaveName','Example3B.pdf');

Example 4: Look for regions/groups across plates
>> plot_atlas({'S1BF-L';'S1BF-R'},'VisibleName','on','PlateList',5:5:120,'SaveName','Example4A.pdf');
>> plot_atlas({'MotorCtx'},'VisibleName','on','PlateList',5:5:120,'DisplayMode','bilateral','SaveName','Example4B.pdf');