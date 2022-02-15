%% A module developed for reading mdf file and trim file
% Reads the .mdf- and trim-files and calls d3d_admin_v5-function.
% This function adjusts the start and stop time in the mdf-file, and deletes initial condition, and deletes the spin-up interval in the .mor-file.

% Copy the new data to the work dir
fid_mdf1 = fopen(strcat(directory,'work\',ID1,'.mdf'),'r');
mdf1     = textscan(fid_mdf1,'%s','delimiter','\n'); % delimit the numbers and remove the comma in between
fclose(fid_mdf1);
NFS      = vs_use(strcat(directory, 'work\', 'trim-', ID1,'.dat'),'quiet'); % read last trim file from previous year fine domain

%% Run Delft3D administration function which adjusts mdf-file for further calculations
d3d_admin_v5(directory, ID1, (eco_timestep/morfac), ets, mdf1{1,1}, year, mor,tstep, Restart);
% Note:
% directory: the main directory; ID1: the ID number extracting from definition of the file in general module;
% mdf{1,1}: information in the mdf file
% eco_timestep/morfac: the hydrodynamic time per ecological time
% ets: no. of ecological time step(total=12/year); year: the no. of loop year
% mor: 1include morphology or not
% t_eco_year: the amount of ecological time steps/year; Restart: 0 run from pristine conditions

clear fid_mdf1 mdf1