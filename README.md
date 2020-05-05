# proprioceptive_localization_hand
Compute and visualize proprioceptive errors in the Localization Task (Longo & Haggard, 2010). 

Data01 refers to Peviani & Bottini, 2018
Data02 are the data reported in Peviani, Liotta & Bottini, 2020
Both the datasets are organized with the following variables organized in columns:
- subj (subj number),
- itemN (ordinal number of the trial)
- LM (landmark: 1 to 10 --> 1 to 5 fingertips (thumb to little) and 6 to 10 knuckles (thumb to little)),
- percX (X coordinate of perceived landmark position for that trial)
- percY (Y coordinate of perceived landmark position for that trial)
- realX (X coordinate of real landmark position for that trial)
- realY (Y coordinate of perceived landmark position for that trial)
- convIDX (conversion index: number of pixels per cm)

The ParametersLoc script guides you through:
1) the spatial preprocessing (with function PreprocessingLoc) of the raw data (XY coordinates of localization judgments in pixels organized in a spreadsheet);
2) the extraction of the proximo-distal and medio-lateral error components (with function Systematic_errorsLoc);
3) computing of the consistency of the error direction and its visualization (with function Angle_consistencyLoc);
4) plotting the average actual and perceived localization judgments (with function Plot_mapsLoc);
5) the PCA of the data and its visualization (with function PCALoc).

For questions/requests/bugs contact me please! 
valeria.peviani@gmail.com
valeria-carmen.peviani@ae.mpg.de

