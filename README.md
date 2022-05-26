Package Build and Plot Atlas
Version 2.1 - Date 26/05/2022
Contact: antoine.bergel@espci.fr

This package contains two main functions
- build_atlas takes as input raw plates (saved in Plates folder) and generates a plotable atlas for easy display
- viewer_atlas takes no input and displays the Plotable Atlas and color-codes regions as listed in text file
Plotable Atlas is both rendered in 2D (slices, projections) and 3D (volume)
 
The list of parameters for each function is detailed in help build_atlas.m and help viewer_atlas.m
Each plate is composed of regions (unilateral or bilateral) and groups of regions (unilateral or bilateral)
Groups and region names are specified in txt files in the Ledger Directory.

It also contains
- plot_atlas: programatically plot of color-coded regions
- generate_lists: generates a list of regions for a given atlas and list of plates
- reformat_ledger: reformats region ledger (1 line, 1 regions, 1 group)

See Examples folder to see the toolbox capabilities.