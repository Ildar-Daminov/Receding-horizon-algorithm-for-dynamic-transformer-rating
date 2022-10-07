# Receding horizon algorithm for dynamic transformer rating and its application for real-time economic dispatch
<img align="left" alt="Coding" width="150" src="https://www.showsbee.com/newmaker/www/u/2018/20185/cfr_img/IEEE-PES-PowerTech-2019.png">

  
This repository shares the MATLAB code and data for the conference paper 📋:\
Ildar Daminov, Anton Prokhorov, Raphael Caire, Marie-Cécile Alvarez-Herault, ["Receding horizon control application for dynamic transformer ratings in a real-time economic dispatch,"](https://ieeexplore.ieee.org/document/8810511)in IEEE PES Powertech, Milan, Italy, 2019. DOI: [10.1109/PTC.2019.8810511](https://ieeexplore.ieee.org/document/8810511#:~:text=DOI%3A%2010.1109/PTC.2019.8810511)
  
  
## Paper's abstract
This paper proposes algorithm, defining the dynamic transformer rating (DTR) for maximization of energy transfer through oil-immersed transformer. Algorithm ensures that windings temperature and loss of insulation life do not exceed their permissible limits. To achieve this goal, we use receding horizon control. Receding horizon control considers load and ambient temperature at past and future intervals to update the DTR. Proposed algorithm is intended for application in real-time economic dispatch at balancing market where it could allow the decreasing of energy generation cost. We consider a two-machine power system as case study, where cheap generation is constrained by transformer rating. The expensive generation does not have any network constraints. The algorithm application increased the cheap generation by 12% in comparison with static thermal limit and by 3% in comparison with static thermal limit corrected to ambient temperature. The generation rescheduling, allowed by DTR, decreased the energy generation cost by 27.9% and 9.8% correspondingly.

## How to run a code 
There are two ways how you may run this code:
  
I. Launching all calculations at once. This will reproduce all figures in the paper for 1 minute:
1. Copy this repository to your computer 
2. Open the script main.m
3. Launch the script "main.m" by clicking on the button "Run" (usually located at the top of MATLAB window).\
As alternative, you may type ```main``` 
in Command Window to launch the entire script. 


II. Launching the specific section of the code to reproduce the particular figure: 
1. Copy this repository to your computer 
2. Open the script main.m 
3. Find the section (Plotting the Figure XX) corresponding to the Figure you would like to reproduce. 
4. Put the cursor at any place of this section and click on the button "Run Section" (usually located at the top of MATLAB window)


## Files description
Main script:
* main.m - the principal script which launches all calculations

Additional script:
* IEEE_thermal_model_create_lookup_tables.m - this script creates two lookup tables:  hot spot temperature and ageing rate as a function of transformer loading and ambient temperature.  Later, these lookup tables will be used in algorithms (1,2,3)

Additional functions: 
* IEEE_thermal_model.m - a IEEE thermal model (Annex G, page 81 of IEEE C.57 91) of  power transformer rated as ONAN/ONAF/ONAF-T-60- 28000/37333/46667/52267-138000-34500Y/19919.
* Finding_DTR_with_RHC.m - this function applies receding horizong control to determine DTR of transformer
* algorithm_1.m -this function calculates DTR at the interval t+ considering the residual resource of insulation 
* algorithm_2.m - this function, in general, calculates loading profile PUL respecting the HST and AEQ constraints by sequantially reducing the peak load of transformer
* algorithm_3.m - this algorithm is given for information purposes as it correspponds to particular situation between DTR and load profile. 
* sub_algorithm_3.m - this sub algorithm calcualtes DTR within the algorithm 3 
* finding_b.m - this function takes HST and AMB and sorts them in descending order by HST. b represents an array of like [HST_hour AMB_hour start finish];
* vline.m -  this function draws a vertical line on the current axes of figure (in our case we use it for visualization of present moment)

Initial data:
* initial_data.mat - data of daily transformer load in per units (PUL), ambient temperature (AMB) and time vector (TIM)
* data_IEEE_AnnexG.mat - data from Annex G IEEE C57.91-2011 (page 86). in our case, we use this data for validation of IEEE_thermal_model.m
* Temp_IEEE.mat - look-up table with hot spot temperatures calculated by the script IEEE_thermal_model_create_lookup_tables.m  
* Ageing_IEEE.mat - look-up table with ageing rates calculated by the script IEEE_thermal_model_create_lookup_tables.m 


## More about DTR of power transformers 
<img align="left" alt="Coding" width="260" src="https://media-exp1.licdn.com/dms/image/C4E22AQFVhDYtt2te_w/feedshare-shrink_1280/0/1652876006660?e=1668038400&v=beta&t=eBRX9SszlDbTvlrkZOmlU_YBncHo2tHmdpjqxRxikbA">This paper was prepared during PhD thesis "Dynamic Thermal Rating of Power Transformers: Modelling, Concepts, and Application case" (but finally the paper was not included into PhD manuscript). The full text of PhD thesis is available on [Researchgate](https://www.researchgate.net/publication/363383515_Dynamic_Thermal_Rating_of_Power_Transformers_Modelling_Concepts_and_Application_case) or [HAL theses](https://tel.archives-ouvertes.fr/tel-03772184). Other GitHub repositories on DTR of power transformers:
* Article: Assessment of dynamic transformer rating, considering current and temperature limitations. [GitHub repository](https://github.com/Ildar-Daminov/Assessment_Dynamic_Thermal_Rating_of_Transformers)
* Article: Demand Response Coupled with Dynamic Thermal Rating for Increased Transformer Reserve and Lifetime. [GitHub repository](https://github.com/Ildar-Daminov/Demand-response-coupled-with-DTR-of-transformers)
* Article: Energy limit of oil-immersed transformers: A concept and its application in different climate conditions. [GitHub repository](https://github.com/Ildar-Daminov/Energy-limit-of-power-transformer)
* Conference paper: Optimal ageing limit of oil-immersed transformers in flexible power systems [GitHub repository](https://github.com/Ildar-Daminov/MATLAB-code-for-CIRED-paper)
* Conference paper: Application of dynamic transformer ratings to increase the reserve of primary substations for new load interconnection. [GitHub repository](https://github.com/Ildar-Daminov/Reserve-capacity-of-transformer-for-load-connection)
