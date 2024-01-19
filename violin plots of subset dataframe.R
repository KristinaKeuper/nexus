#install.packages("pacman")
library(pacman)
p_load(ggplot2, reshape2, ggpubr, gridExtra, dplyr, tidyr, tidyverse, Hmisc, AMR, install = FALSE)

####################################################################read file in the folder, merge and add filename
df <- read.table(file = './data/FILENAME_of_subset_TCGA_data.tsv', sep = '\t', header = TRUE)

###################################################################columns to rows and remove irrelevant clutter

df <- df %>%
  select(-age_group_2050, -age_group_5, -age_group_50, -age_group_child) ##in case metadata needs to be excluded

# use melt to transform columns into rows with variable and value pairs
df_long <- melt(df, id.vars=c("sample", "gender", "cancer.type.abbreviation", "age_group_10"), ##in case age should stay 
                variable.name = "gene", 
                value.name = "expression")
head(df_long)

#compare
dim(df)
dim(df_long)


# Create a ggplot object with violin plots for both LAML-specific and all data points
plot1 <- ggplot(df_long, aes(x = gene, y = expression)) +
  geom_point(data = df_long, aes(fill = "darkgrey"), size = 0.1, position = position_jitter(seed = 1, width = 0.2), shape = ".", alpha = 0.3, show.legend = FALSE) +
  geom_violin(data = df_long, aes(fill = "darkgrey"), alpha = 0.5, color = "darkgrey", fill = "darkgrey") +
  geom_point(data = subset(df_long, cancer.type.abbreviation == "LAML"), aes(color = factor(gene)), size = 0.5, shape = ".") +
  geom_violin(data = subset(df_long, cancer.type.abbreviation == "LAML"), aes(fill = factor(gene)), alpha = 0.5) +  
  theme(legend.position = "none") +
  xlab("")+
  ylab("expression") +
  guides(fill = "none", color = "none") +  
  theme_classic(base_size = 17)

plot1
