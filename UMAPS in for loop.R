#install.packages("pacman")
library(pacman)
p_load(umap, ggplot2, ggpubr, plotly, gridExtra, dplyr, tidyr, reshape2,
       tidyverse,
       tidymodels,
       kernlab, ITNr,
       pracma, Hmisc, AMR, install = TRUE)

########################################################### UMAPs 

# Define the folder path
folder_path <- "./data/Foldername_of_full_data_or_subset_TCGA_data/"

# Get a list of files in the folder
file_list <- list.files(folder_path, full.names = TRUE)

# Create a folder for the results if it doesn't exist
results_folder <- "./data/FOLDER"
if (!dir.exists(results_folder)) {
  dir.create(results_folder)
}

# Loop through each file
for (file_path in file_list) {
  # Load file into session
  df <- read.table(file = file_path, sep = '\t', header = TRUE)
  
  # Save the cancer.type.abbreviation column before subset
  cancer_type_column <- df$cancer.type.abbreviation
  
  # Identify numerical columns
  numerical_cols <- sapply(df, is.numeric)
  
  # Subset data (keep only numerical columns)
  dif <- df[, numerical_cols]
  
  # UMAP 3D all genes
  df1.umap <- umap(dif, n_components = 3, random_state = 15)
  
  # Check if the resulting UMAP layout is not empty
  if (nrow(df1.umap$layout) == 0) {
    cat("Empty UMAP layout for file:", file_path, "\n")
    next  # Skip the rest of the loop for this file
  }
  
  layout1 <- data.frame(df1.umap$layout) 
  
  # Add the cancer.type.abbreviation column back to the layout
  final <- cbind(layout1, cancer_type_column)
  
  # Save the resulting 3D UMAP layout to a TSV file
  write.table(final, file = file.path(results_folder, paste0(basename(file_path), "_3D_UMAP.tsv")), sep = "\t", quote = FALSE, row.names = FALSE)
  
  # Close files
  closeAllConnections()
}



########################################################### UMAP for each and save files

# Define the folder path (see above)
folder_path <- "./data/FOLDER"

# Get a list of files in the folder
file_list <- list.files(folder_path, full.names = TRUE)

# Create a folder for the results if it doesn't exist
results_folder <- "./results/"
if (!dir.exists(results_folder)) {
  dir.create(results_folder)
}

# Loop through each file
for (file_path in file_list) {
  # Load file into session
  df <- read.table(file = file_path, sep = '\t', header = TRUE)
  
  # Generate and save the interactive 3D scatter plot as an HTML file
  fig <- plot_ly(df, x = ~X1, y = ~X2, z = ~X3, color = ~cancer_type_column, colors = "viridis") %>%
    add_markers() %>%
    layout(scene = list(xaxis = list(title = 'UMAP1'), 
                        yaxis = list(title = 'UMAP2'), 
                        zaxis = list(title = 'UMAP3')))
  
  # Construct the dynamic HTML file name
  dynamic_html_file_name <- paste0(basename(file_path), ".html")
  
  # Save the interactive plot as an HTML file with dynamic file name
  htmlwidgets::saveWidget(fig, file.path(results_folder, dynamic_html_file_name))
  
  # Close files
  closeAllConnections()
}

