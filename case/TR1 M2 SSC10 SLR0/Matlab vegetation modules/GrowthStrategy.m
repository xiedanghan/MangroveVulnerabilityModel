%% Why Grow second?
%>>: Only in the first ets, we need to argue grow first or mortality first
%:>> Vegetation grow because they have experienced the last ets 
%>>: Based on Inundation and competition of last ets, vegetation parameters (height and diameter) need to update
%>>: And if mortality second, then vegetation will grow and biomass will changed, influencing the mortality evaluation
%>>: But after mortality, biomass will also change because of the reducing trees
%:>> And the growth rate will also be influenced by the changing competition stress
%:>> So it depends on how you explain your model
%%
if general_veg_char(1,4,nv) == 1
    
    GrowthStrategy_mangrove;
    
elseif general_veg_char(1,4,nv) == 2
    
%% We are going to have another big code here
    
end