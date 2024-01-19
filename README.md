# Nexus

## Overview

This repository contains the code used to generate figures for our latest review (doi follows) @DCI. The code utilizes various R packages, including `networkD3`, `umap`, `tidymodels` for SVM-RBF, and `plotly` and `ggplot2` for visualizing big datasets.

## Prerequisites

Make sure you have R and RStudio installed on your machine. You can install the required R packages easier using a package manager, such as `pacman`. 

## Usage
Clone this repository to your local machine and use the supplementary data or your own data to conduct the data analysis.

## Structure

1. Functional investigation using string.db
2. Network generation using networkD3
3. TCGA PANCAN expression analysis using UMAP
4. SVM-RBF AI model for classification using tidymodels
5. Iteration through datasets with coordinated data removal based on reactome knowledgebase to identify outlier specifc gene sets

## License
This project is licensed under the GNU General Public License v3.0 - see the LICENSE.md file for details.

## Acknowledgments
A big thank you goes to Joanna Maria Merchut-Maya for proofreading the manuscript.
Most importantly, I thank my supervisors, Apolinar Maya-Mendoza and Jiri Bartek, for their support.
