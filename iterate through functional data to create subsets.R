#install.packages("pacman")
library(pacman)
p_load(umap, ggplot2, ggpubr, plotly, gridExtra, dplyr, tidyr, reshape2,
       tidyverse,
       tidymodels,
       kernlab, ITNr,
       pracma, Hmisc, AMR, install = TRUE)


####################################################################read file (functional enrichment file)

file_path <- "./data/FILENAME.tsv"

# Read the TSV file
data <- read.delim(file_path, sep = "\t")

dim(data)
#head(data)

#################################################### loop through functional data to create new files removing genes from one funcitonal term term at a time

# Create an empty list to store individual data frames
result_list <- list()

# Iterate through each row of the data table
for (i in 1:nrow(data)) {
  
  # Extract the relevant information from the current row
  label_column <- data[i, "matching.proteins.in.your.network..labels."]
  description_column <- data[i, "term.description"]
  
  # Split the comma-separated gene names
  gene_names <- unlist(strsplit(label_column, ","))
  
  # Create a new data frame with one column using the gene names
  new_df <- data.frame(Label = gene_names)
  
  # Set the column header as the description column data
  colnames(new_df) <- description_column
  
  # Append the new data frame to the result list
  result_list[[i]] <- new_df
  
  # Export the current data frame to a TSV file
  file_name <- paste0("output_", gsub("/", "_", gsub(" ", "_", description_column)), ".tsv")
  write.table(new_df, file = file_name, sep = "\t", quote = FALSE, row.names = FALSE)
}




