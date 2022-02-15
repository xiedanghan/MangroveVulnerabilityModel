%% Initialize and extract parameters from Delft3D for initial state
% Read important temporal data from the .mdf-file
% It is better to keep the reference date starting from day 1 and month 1

%% Read MDF and extract run-id fine grid
ini_mdf  = mdf('read',strcat(name_model_original1, '.mdf'));   % read initial MDF file
ID1      = strcat(name_model_original1); % now is '210x1'

%% Extract static parameters from Delft3D
dimensions  = str2num(cell2mat(ini_mdf.mdf.Data{1,2}(strmatch('MNKmax', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2)));
% determine size of grid str2double converts str, while str2num converts an array or a vector
Mdim        = dimensions(1,1); % grid dimensions
Ndim        = dimensions(1,2); % grid dimensions
clear dimensions
% morfac
if mor ==0 % if there is no morphology, no morfac is required
    morfac = morf;
else
    morfac   = strmatch('MorFac', char(ini_mdf.mor.Data{2,2}(:,1)), 'exact'); % find location of morfac
    morfac   = ini_mdf.mor.Data{2,2}(morfac,2); % extract morfac data
    C        = strsplit(morfac{1}); % split string
    morfac   = str2double(C{1}); % convert to number
    clear C a morf
end
% extract time-scales and chezy from mdf
Lchezy                  = strmatch('Ccofu', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); % location of chezy
chezy                   = str2double(ini_mdf.mdf.Data{1,2}(Lchezy,2)); % value of chezy
Ltstep                  = strmatch('Flmap', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); % Location of time step
tstep                   = str2num(cell2mat(ini_mdf.mdf.Data{1,2}(Ltstep,2))); % value of output timestep
tstep                   = tstep(2);
loc_start               = strmatch('Tstart', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); % location of Tstart
Tstart                  = str2double(ini_mdf.mdf.Data{1,2}(loc_start,2))*morfac; % value of Tstart
loc_stop                = strmatch('Tstop', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact');  % location of Tstop
Tstop                   = str2double(ini_mdf.mdf.Data{1,2}(loc_stop,2))*morfac; % value of Tstop
Total_sim_time          = Tstop - Tstart; % total simulation time in minutes
years                   = ceil(Total_sim_time/(365.25*24*60)); % number of morph. years in the simulation, ceil function returns a bigger integer ceil(e.g., -1.9)=-1
clear Lchezy Tstart Tstop loc_start loc_stop Total_sim_time Ltstep
clear  ini_mdf