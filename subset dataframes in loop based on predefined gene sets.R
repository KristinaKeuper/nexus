#install.packages("pacman")
library(pacman)
p_load(umap, ggplot2, ggpubr, plotly, gridExtra, dplyr, tidyr, reshape2,
       tidyverse,
       tidymodels,
       kernlab, ITNr,
       pracma, Hmisc, AMR, install = TRUE)

###################################################################### Exclude genes in loop from TCGA data file
#read file gene sets found in network based on functional data
genes_to_remove_folder <- "./data/FOLDERNAME"
#read file from TCGA
diff_file_path <- "./data/TCGA_data_file.tsv"
#output folder definition
output_folder <- "./data/output"

# Process each gene information file
gene_files <- list.files(genes_to_remove_folder, full.names = TRUE)

# Load the differential expression data
diff <- read.table(file = diff_file_path, sep = '\t', header = TRUE)

for (gene_file in gene_files) {
  
  # Read lines from the current gene information file
  gene_lines <- readLines(gene_file)
  
  # Extract the genes from the lines
  genes_to_exclude <- gene_lines
  
  # Subset the 'diff' data frame to exclude genes present in the result data frame
  diff_subset <- diff[, !(colnames(diff) %in% genes_to_exclude)]
  
  # Export the subset 'diff' data frame to a TSV file
  file_name <- paste0("rem_", gsub("/", "_", gsub(" ", "_", basename(gene_file))), ".tsv")
  write.table(diff_subset, file = file.path(output_folder, file_name), sep = "\t", quote = FALSE, row.names = FALSE)
}
