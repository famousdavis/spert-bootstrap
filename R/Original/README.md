# SPERT implementation in R

## Overview
The nonparametric SPERT-type algorithm for work progress simulation. The method computes bootstrapped distribution from the given data and uses it to simulate work progress. The confidence intervals for the simulation are computed with percentile method. Please be aware that the confidence intervals may be biased due to the small sample size.

## Future work 
Future releases will contain the intergration of this algorithm into Excel.

## Reference
Please refer to the original github repository of the project for details: https://github.com/famousdavis/spert-bootstrap .

A complete description of the method can be found here: https://www.projectmanagement.com/articles/301593/Introducing-Statistical-PERT
