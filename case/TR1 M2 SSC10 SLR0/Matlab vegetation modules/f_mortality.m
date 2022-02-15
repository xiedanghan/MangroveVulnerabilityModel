%% Mortality rule
%>> 1st: reach 5 consecutively small value of I*C (i.e., I*C<=0.5)
%>> 2nd: every time, 10 trees will be removed by the weight of inundation stress>>small I, large death num
%>> 3rd: competition stress or biomass will be recalculated and all the I*C will be rechecked
%>> 4th: when I*C>0.5 again, mortality mark decreases from 5 to 4

%% -------Let's start to kill mangroves------
% Preparation for colonization
Mort_temp      = trv_trd_temp(trv_trd_temp(:,19)==5,:); % Detai death cells
Mort_rc_temp   = unique(Mort_temp(:,[1,2]),'rows');     % Death Cell with only rows and columns and appear only once
Mort_list      = sub2ind(size(P),Mort_rc_temp(:,1),Mort_rc_temp(:,2)); % convert to 1d coordinate, no plants colonize at these cells
clear Mort_temp Mort_rc_temp

% Step 0: Adjust the num to 0 if Inundation <=0.5 & Mort_mark == 5
trv_trd_temp(trv_trd_temp(:,14) <= 0.5 & trv_trd_temp(:,19)==5,12) = 0; % There is no chance for a Mortality mark plant which has a small I
trv_trd_temp(trv_trd_temp(:,12)==0,:)  = []; % delete the death plants
trv_trd_temp(:,20)                     = 1:1:size(trv_trd_temp,1); % update matrix sequence

% Step1: Taget the death coordinate (rows and columns)
Mort_temp    = trv_trd_temp(trv_trd_temp(:,19)==5 & trv_trd_temp(:,12)~=0,:); % Death Matrix, maybe repetitive cells due to different plants!
Mort_rc_temp = unique(Mort_temp(:,[1,2]),'rows'); % Death Cell with only rows and columns and appear only once

% Step 2: Kill the mangroves cell by cell, find the slow motion below
for i=1:size(Mort_rc_temp,1)
    %~~Motion 1: count all the vegetations in the death cell no matter healthy or sick
    k             = find(trv_trd_temp(:,1) == Mort_rc_temp(i,1) & trv_trd_temp(:,2) == Mort_rc_temp(i,2));
    Mort_cell     = trv_trd_temp(k,:); % cell includes both healthy and sick plants
    Mort_cell     = sortrows(Mort_cell,13); % sort by veg diameter (cm)
    Death_mark    = find(Mort_cell(:,19)==5); % find the death rows in Mort_cell
    
    %~~Motion 2: identify vegetation types from the death tree
    nv_Mort_cell  = unique(Mort_cell(Death_mark,11)); % detail veg types in the death cell
    
    %~~Motion 3: when multiple mangrove exist, murder is based on inundation stress)
        % I~=0, then need to kill veg by num
        while (length(nv_Mort_cell)>1)
            for n =1:length(nv_Mort_cell)
                v_type(n)      = nv_Mort_cell(n);
                v_type_Loc{n}  = find(Mort_cell(:,11)== v_type(n) & Mort_cell(:,19)==5 ); % find location of each veg type
                In_s(n)        = Mort_cell(v_type_Loc{n}(1),14); % inundation stress
            end
            % num of trees need to be removed for each type
            In_s_inverse               =1./In_s; % reciprocal
            for n =1:length(nv_Mort_cell)
                Remove_v(n)     = round(Mort_plant/(In_s(n)*sum(In_s_inverse)));
                if Remove_v(n)  > Mort_cell(v_type_Loc{n}(1),12)
                    Remove_v(n) = Mort_cell(v_type_Loc{n}(1),12);
                end
                Mort_cell(v_type_Loc{n}(1),12) = Mort_cell(v_type_Loc{n}(1),12)-Remove_v(n);
                Mort_cell(:,16)           = Mort_cell(:,15).*Mort_cell(:,12); % recalculate the biomass
                Bio_total_cell            = sum(Mort_cell(:,16));
                Mort_cell(:,17)           = 1./(1+exp(d(Mort_cell(v_type_Loc{n}(1),11)).*(B_half(Mort_cell(v_type_Loc{n}(1),11))-Bio_total_cell))); % recalculate the competition stress
                if Mort_cell(v_type_Loc{n}(1),12)==0
                    Mort_cell(v_type_Loc{n}(1),11) = 9999; % Mark 9999 as the death tree
                    v_type_Loc{n}(1)               = [];
                end
            end
            Mort_cell(:,18)               = Mort_cell(:,14).*Mort_cell(:,17); % I*C
            for m = 1:size(Death_mark,1) % reevaluate the mortality and rewrite the mortality mark if IC>0.5
                if Mort_cell(Death_mark(m),18)>0.5
                    Mort_cell(Death_mark(m),19) = 4;
                end
            end
            Death_mark    = find(Mort_cell(:,19)==5 & Mort_cell(:,12)~=0 & Mort_cell(:,11)~=9999); % find the death rows where the plants still exist in Mort_cell
            nv_Mort_cell  = unique(Mort_cell(Death_mark,11)); % num of veg type in the death cell
        end
        
        %~~Motion 4: when single mangrove exists, kill ten by ten
        for j = 1:size(Death_mark,1)
            while (Mort_cell(Death_mark(j),12)>0 && Mort_cell(Death_mark(j),19)==5) % when Mort_cell =5, meaning 5 consecutively depressing growth
                Mort_cell(Death_mark(j),12) = Mort_cell(Death_mark(j),12)-1; % decrease plants num onece at a time
                Mort_cell(Death_mark(j),16) = Mort_cell(Death_mark(j),15).*Mort_cell(Death_mark(j),12); % recalculate the biomass
                Bio_total_cell              = sum(Mort_cell(:,16));
                Mort_cell(:,17)             = 1./(1+exp(d(Mort_cell(Death_mark(j),11))*(B_half(Mort_cell(Death_mark(j),11))-Bio_total_cell))); % recalculate the competition stress
                Mort_cell(:,18)             = Mort_cell(:,14).*Mort_cell(:,17); % I*C
                for m = j:size(Death_mark,1) % reevaluate the mortality and rewrite the mortality mark if IC>0.5
                    if Mort_cell(Death_mark(m),18)>0.5
                        Mort_cell(Death_mark(m),19) = 4;
                    end
                end
            end
        end
    trv_trd_temp(Mort_cell(:,20),:)     = Mort_cell; % update veg matrix after all the cells have been checked
end
trv_trd_temp(trv_trd_temp(:,12)==0,:)   = []; % delete the death plants
% 13/08/2018 consider roots
trv_trd_temp(:,4)                       = trv_trd_temp(:,12)/num_all; % update the Area Fraction after mortality process
trv_trd_temp(:,20)                      = 1:1:size(trv_trd_temp,1); % update matrix sequence

clear Mort_Loc Mort_temp Mort_rc_temp i k Mort_cell v_type In_s In_s_inverse v_type_Loc 
clear Death_mark nv_Mort_cell n Remove_v Bio_total_cell m