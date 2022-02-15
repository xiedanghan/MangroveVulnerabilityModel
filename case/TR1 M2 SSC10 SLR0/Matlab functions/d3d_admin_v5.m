%% A function which can handle administration in Delft3D when coupling the vegetation
% model to Delft3D by changing the mdf/mor file to the according time-scales

function[mdf] = d3d_admin_v5(dir, ID, ts, ets, mdf, year, m, tstep, res)
% ID: ID of the run (each run is copied every ecological timestep to the results folder carrying the ID)
% ts: minutes of ecological timestep. The start and stop times of the runs are
% adjusted to this value and of each timesteps results are written in the
% results folder
% ets: running ID for the ecological loop or the ecological time step
% year: the simulation eco. year
% m: if morphology is taken into account (m=1)
% vi: VegIn parameter indicating that there is internal 'static' vegetation
% MDF = MDF file

% Adjust mdf- and mor-file
if year ==1 && ets ==1  % after first timestep MB_0: initial conditions have to be deleted
    a1 = strmatch('Zeta0', mdf); % find location of zeta0, initial water level
    a2 = strmatch('C0',mdf); % find location of C0, initial sediment concentration [kg/m3]
    for n=(a1+1):a2(end)
        mdf{n,1}  = sprintf('%s','Commnt = '); % Delete the rows containing initial hydromorphology conditions
    end
    % Overwrite restID with the new ID
    mdf{a1,1}     = sprintf('%s',strcat('Restid = #trim-', ID, '#')); %Replace position of Zeta0 by Restid corresponds to Trim-file containing conditions of previous run to set as new initial condition
end

% Adjust mor-file spin-up
if m == 1 % only if morphology is taken into account (otherwise no morfac)
    % Open mor-file
    fid_mor = fopen(strcat(dir,'work/',ID,'.mor'),'r');
    mor     = textscan(fid_mor,'%s','delimiter','\n');
    fclose(fid_mor);
    % Find location of morstt and replace by actual time
    try
        % try funtion, if something wrong in try block, the program will
        % turn to operate the catch block instead of stopping running
        a3       = strmatch('MorStt', mor{1,1}); % find morphological start time, Spin-up interval from TStart
        % MorStt, Spin-up interval from TStart till start of morphological changes
        Time_mor = mor{1,1}{a3,1}; % find morphological start time
        Time_mor = Time_mor(8:19);
        Time_mor = str2double(Time_mor);
        % Determine if spin-up interval is still to consider
        % dh: ini_work already run the program once
        Time_mor = Time_mor-ts;
        if Time_mor/ts>0
            mor{1,1}{a3,1} = sprintf('%s',strcat('MorStt =        ', num2str(Time_mor),'     [min]    Spin-up interval from TStart till start of morphological changes')); % Set morphological start time to 0
        else
            mor{1,1}{a3,1} = []; % in case spin-up is over
        end
    catch
    end
    % Write mor-file to folder
    fid_mor = fopen(strcat(dir,'work/',ID,'.mor'),'w');
    for k=1:numel(mor{1,1})
        fprintf(fid_mor,'%s\r\n',mor{1,1}{k,1});
    end
    fclose(fid_mor);
end

% Adjust the start and stop time for the new run
if res==1 && ets==1 && year==1 % seems useless
    % Extract start and stop time from mdf-file_0 as integer
    for i=1:length(mdf)
        a5 = strmatch('Tstart', mdf{i,1});
        if a5==1
            Time_start = mdf{[i,1]};
            Time_start = Time_start(9:length(Time_start));
            Time_start = str2double(Time_start);
            mdf{i,1}   = strcat('Tstart = ',sprintf('% 2.8g',(Time_start)));
            mdf{i+1,1} = strcat('Tstop  = ',sprintf('% 2.8g',(Time_start+ts)));
        end
    end
else
    % dh: No need to loop
    a6           = strmatch('Tstop',mdf);
    Time_stop    = mdf{a6,1};
    Time_stop    = str2double(Time_stop(9:length(Time_stop)));
    mdf{a6-1,1}  = strcat('Tstart = ',sprintf('% 2.8g',(Time_stop)));
    mdf{a6,1}    = strcat('Tstop  = ',sprintf('% 2.8g',(Time_stop+ts)));
    %>>DH: 03/12/2018 Update Flmap
    a7           = strmatch('Flmap',mdf);
    mdf{a7,1}    = strcat('Flmap  = ',sprintf('% 2.8g  %2.8g  %2.8g',Time_stop,tstep,Time_stop+ts));
end

% Write new mdf-file
fid_mdf = fopen(strcat(dir,'work/',ID,'.mdf'),'w');
for k=1:numel(mdf)
    fprintf(fid_mdf,'%s\r\n',mdf{k,1});
end
fclose(fid_mdf);
end