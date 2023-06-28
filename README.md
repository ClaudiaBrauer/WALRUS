
## The Wageningen Lowland Runoff Simulator (WALRUS): a lumped rainfall-runoff model for catchments with shallow groundwater

The Wageningen Lowland Runoff Simulator (WALRUS) is a novel rainfall-runoff model to fill the gap between complex, spatially
distributed models which are often used in lowland catchments and
simple, parametric  (conceptual) models which have mostly been developed for
sloping catchments. WALRUS explicitly accounts for processes
that are important in lowland areas, notably (1)
groundwater-unsaturated zone coupling, (2) wetness-dependent flow
routes, (3) groundwater-surface water feedbacks and (4) seepage and
surface water supply. WALRUS consists of a coupled
groundwater-vadose zone reservoir, a quickflow reservoir and
a surface water reservoir.  WALRUS is suitable for operational use
because it is computationally efficient and numerically stable
(achieved with a flexible time step approach). In the open source
model code default relations have been implemented, leaving only
four parameters which require calibration. For research purposes,
these defaults can easily be changed. 

![WALRUS model structure](documentation/figures/model_structure_WALRUS_GitHub.png)


### Code availability

The WALRUS code is available as an R-package through this GitHub (WALRUS_1.x.tar.gz). If you want to be kept informed about WALRUS developments, please send me an email (claudia.brauer-at-wur.nl) so I can add you to my WALRUS-update-mailing-list. You can also visit this site from time to time of course.

![Screenshot of WALRUS in RStudio](documentation/figures/screenshot_WALRUS_R_GitHub.jpg)

### Documentation

WALRUS and its first applications have been published in two peer reviewed, open access, scientific journals:
- C.C. Brauer, A.J. Teuling, P.J.J.F. Torfs, R. Uijlenhoet (2014a): 
[The Wageningen Lowland Runoff Simulator (WALRUS): a lumped rainfall-runoff model for catchments with shallow groundwater](http://www.geosci-model-dev.net/7/2313/2014/gmd-7-2313-2014.pdf), 
Geoscientific Model Development, 7, 2313-2332.
- C.C. Brauer, P.J.J.F. Torfs, A.J. Teuling, R. Uijlenhoet (2014b): 
[The Wageningen Lowland Runoff Simulator (WALRUS): application to the Hupsel Brook catchment and Cabauw polder](www.hydrol-earth-syst-sci.net/18/4007/2014/hess-18-4007-2014.pdf), 
Hydrology and  Earth System Sciences, 18, 4007-4028.
- C.C. Brauer, R. Uijlenhoet, P.J.J.F. Torfs, A.J. Teuling: [R package for WALRUS (Wageningen Lowland Runoff Simulator)](https://data.4tu.nl/articles/software/R_package_for_WALRUS_Wageningen_Lowland_Runoff_Simulator_/19107734), 4TU Research data.  
For Dutch water managers and engineers:
- C.C. Brauer, P.J.J.F. Torfs, A.J. Teuling, R. Uijlenhoet (2016): 
[De Wageningen Lowland Runoff Simulator (WALRUS): een snel neerslag-afvoermodel speciaal voor laaglandstroomgebieden](http://edepot.wur.nl/390418),
Stromingen, 22:1, 2-18.

To facilitate application of WALRUS, we wrote a [user manual](https://github.com/ClaudiaBrauer/WALRUS/blob/master/documentation/WALRUS_manual.pdf), which is provided in the documentation-folder, together with the two papers.

![The WALRUS-publications](documentation/figures/WALRUS_publications.png)


### Other publications

- C.C. Brauer (2014):
[Modelling rainfall-runoff processes in lowland catchments](http://edepot.wur.nl/296285),
PhD thesis, Wageningen University, The Netherlands.
- C.C. Brauer, A. Overeem, H. Leijnse, R. Uijlenhoet (2016):
[The effect of differences between rainfall measurement techniques on groundwater and discharge simulations in a lowland catchment](http://onlinelibrary.wiley.com/doi/10.1002/hyp.10898/epdf),
Hydrological Processes, 30, 3885–3900
- T. de Boer-Euser, L. Bouaziz, J. De Niel, C. Brauer, B. Dewals, G. Drogue, F. Fenicia, B. Grelier, J. Nossent, F. Pereira, H. Savenije, G. Thirel, P. Willems (2017): 
[Looking beyond general metrics for model comparison–lessons from an international model intercomparison study](www.hydrol-earth-syst-sci.net/21/423/2017/hess-21-423-2017.pdf ),
Hydrol. Earth Syst. Sci., 21, 423-440.
- A. Pijl, C.C. Brauer, G. Sofia, A.J. Teuling, P. Tarolli (2018):
[Hydrologic impacts of changing land use and climate in the Veneto lowlands of Italy](www.sciencedirect.com/science/article/pii/S2213305418300249),
Anthropocene, 22, 20-30.
- D. Heuvelink, M. Berenguer, C.C. Brauer, R. Uijlenhoet (2020): 
[Hydrological application of radar rainfall nowcasting in the Neherlands](https://www.sciencedirect.com/science/article/pii/S0160412019327746?via%3Dihub), 
Environ. Int., 136 , 105431.
- Y. Sun, W. Bao, K. Valk, C.C. Brauer, J. Sumihar, A.H. Weerts (2020):
[Improving forecast skill of lowland hydrological models using ensemble Kalman filter and unscented Kalman filter](https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2020WR027468),
Water Resour. Res. 56, e2020WR027468.
- L.J.E. Bouaziz, G. Thirel, T. de Boer-Euser, L.A. Melsen, J. Buitink, C.C. Brauer, J. De Niel, S. Moustakas, P. Willems, B. Grelier, 
G. Drogue, F. Fenicia, J. Nossent, F. Pereira, E. Sprokkereef, J. Stam, B.J. Dewals, A.H. Weerts, H.H.G. Savenije and M. Hrachowitz (2021)
[Behind the scenes of streamflow model performance](https://hess.copernicus.org/articles/21/423/2017/hess-21-423-2017.pdf),
Hydrol. Earth Syst. Sci., 25, 2069-2095.
- P.C. Astagneau, G. Thirel, O. Delaigue, J.H.A. Guillaume, J. Parajka, C.C. Brauer, A. Viglione, W. Buytaert and K.J. Beven (2021): 
[Technical note: Hydrology modelling R packages – a unified analysis of models and practicalities from a user perspective](https://doi.org/10.5194/hess-25-3937-2021), 
Hydrol. Earth Syst. Sci., 25, 3937–39730.
- R.O. Imhoff, C.C. Brauer, K.-J. van Heeringen, H. Leijnse, A. Overeem, A. Weerts and R. Uijlenhoet (2021):
[A climatological benchmark for operational radar rainfall bias reduction](https://hess.copernicus.org/articles/25/4061/2021/hess-25-4061-2021.pdf),
Hydrol. Earth Syst. Sci., 25, 4061-4080.
- R.O. Imhoff, C.C. Brauer, K.J. van Heeringen, R. Uijlenhoet, A.H. Weerts (2022),
[Large-sample evaluation of radar rainfall nowcasting for flood early warning](https://agupubs.onlinelibrary.wiley.com/doi/epdf/10.1029/2021WR031591),
Water Resour. Res., 58, e2021WR031591.


### Copyright

WALRUS is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.  If not, see http://www.gnu.org/licenses/.


![WUR logo](documentation/figures/wu.png).

[Hydrology and Quantitative Water Management Group](https://www.hwm.wur.nl), Wageningen University, The Netherlands
