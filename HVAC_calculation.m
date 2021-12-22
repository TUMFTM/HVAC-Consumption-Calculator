
%% Calling the function use:
%[Consumption]   = HVAC_calculation(scenario, body_type, T_ambient, alpha, betta, gamma, Area_Front, Area_Side, Area_Rear, Area_Cabin, Massflow, Percentage_Circulation_air);
%% Examples
%% Winter:
%[Consumption]   = HVAC_calculation('Winter', 1, 5, 26.5, 65, 41, 1.36, 0.67,0.553, 6.5, 5, 0);
%% Summer:
%[Consumption]   = HVAC_calculation('Summer', 1, 27, 26.5, 65, 41, 1.36, 0.67,0.553, 6.5, 5, 0);
%% Spring/Fall:
%[Consumption]   = HVAC_calculation('SpringFall', 1, 10, 26.5, 65, 41, 1.36, 0.67,0.553, 6.5, 5, 0);

function [E_con] = HVAC_calculation(scenario, body_type,T_amb, alpha, beta, gamma, A_f, A_s, A_r, A_cab, m_flow, perc_ca)
%% Description:
%This function creates a Metamodel out of the simuulation data in KULI

% Author:   Adrian König, Ph.D. Candidate, TU Munich, Institute for Automotive Technologie
% Date:     02.11.21

%% Input
%Scenario   =   Scenario (Winter, Summer, SpringFall)
%Body type  =   Type of body in white (1=Conventional, 2=One-box-design)
%T_amb      =   Ambient temperature in °C
%Alpha      =   Angle of windshield in °
%Betta      =   Angle of side window in °
%Gamma      =   Angle of rear window in °
%A_f        =   Area of windshield/front window in m^2
%A_s        =   Area of side window in m^2
%A_r        =   Area of rear window in m^2
%A_cab      =   Area of cabine in m^2
%m_flow     =   Mass flow in kg/min
%perc_ca    =   Percentage circulation air in %/100


% Content
% 1) Load regression
% 2) Calculation of consumption
% 3) Display output


%% 1) Load regression
%a) Load regression for scenario
filename    =   strcat('Coeff_',scenario,'.mat'); 
varname     =   strcat('Coeff_',scenario); 
load (filename,varname)

%b) Select regression
%% Scenario Winter
if strcmp(scenario,'Winter')
    % Create input array
    Input= [T_amb, m_flow, A_cab, perc_ca];
    % read in regression
    reg_fun     =   Coeff_Winter{3,1}; %Regression function
    coeff_fun   =   Coeff_Winter{2,1}; %Coefficienc of function
    num_limit     =   0;               %0= Value can be directly calculated
%% Scenario Summer
elseif strcmp(scenario,'Summer')
    %Create input array
    Input= [alpha, beta, gamma, A_f, A_s, A_r, A_cab];
    if ismember(T_amb,[25,28,30,32])
        %Select number to load correct regression
        switch T_amb
            case 25
                num=1;
            case 28
                num=2;
            case 30
                num=3;
            case 32
                num=4;
        end
        
        %Check if onebox is selected
        if body_type==2
            num=num+4;
        end
        
        %No limits needed
        num_limit=0;
        
        %Load regression
        reg_fun     =   Coeff_Summer{3,num}; %Regression function
        coeff_fun   =   Coeff_Summer{2,num}; %Coefficienc of function
    else
        switch T_amb
            case {26,27}
                num_limit = [1,2];
            case 29
                num_limit = [2,3];
            case 31
                num_limit = [3,4];
        end
        
        %Check if onebox is selected
        if body_type==2
            num_limit=num_limit+4;
        end
        
        %Load regression
        reg_fun_low     =   Coeff_Summer{3,num_limit(1)}; %Regression function
        coeff_fun_low   =   Coeff_Summer{2,num_limit(1)}; %Coefficienc of function
        
        reg_fun_up     =   Coeff_Summer{3,num_limit(2)}; %Regression function
        coeff_fun_up   =   Coeff_Summer{2,num_limit(2)}; %Coefficienc of function
    end
    
    %% Scenario SpringFall
elseif strcmp(scenario,'SpringFall')
    % Create input array
    Input= [alpha, beta, gamma, A_f, A_s, A_r, A_cab, m_flow];
    % read in regression
    reg_fun     =   Coeff_SpringFall{3,1}; %Regression function
    coeff_fun   =   Coeff_SpringFall{2,1}; %Coefficienc of function
    num_limit     =   0;               %0= Value can be directly calculated
end

%% 2) Calculation of consumption(s)
if num_limit==0 %No Interpolation is needed
    E_con=reg_fun(coeff_fun,Input); %Calculate consumption in W
else %Interpolate value between regressions (only for summer)
    E_con_low=reg_fun_low(coeff_fun_low,Input); %Calculate consumption in W
    E_con_up=reg_fun_up(coeff_fun_up,Input); %Calculate consumption in W
    
    if T_amb==26
        E_con=(E_con_low*2+E_con_up)/3;
    elseif T_amb==27
        E_con=(E_con_low+E_con_up*2)/3;
    else
        E_con=(E_con_low+E_con_up)/2;
    end
end

%% 3) Output
fprintf('The HVAC consumption is %4.f W. \n',E_con);

end

