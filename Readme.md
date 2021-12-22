Paper Title: The Impact of HVAC on the Development of Autonomous and Electric Vehicle Concepts ------
Authors: Adrian König, Sebastian Mayer, Lorenzo Nicoletti, Stephan Tumphart and Markus Lienkamp 

------- HVAC-Consumption-Calculator ---------

This is the readme file for MATLAB HVAC Consumption-Calculator. It contains the coefficients for the regressions and regression equations. 
Furthermore it contains a function script "HVAC_calculation", which can be used for calculation using the regressions.

Therefore, the function can be called with the following command:
[Consumption]   = HVAC_calculation(scenario, body_type, T_ambient, alpha, betta, gamma, Area_Front, Area_Side, Area_Rear, Area_Cabin, Massflow, Percentage_Circulation_air);

The above-mentioned input variables are explained in the paper, the output is the electric consumption of the HVAC system in W.

(c) 2021
