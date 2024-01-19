#install.packages("pacman")
library(pacman)
p_load(umap, ggplot2, ggpubr, plotly, gridExtra, dplyr, tidyr, reshape2,
       tidyverse,
       tidymodels,
       kernlab, ITNr,
       pracma, Hmisc, AMR, install = FALSE)

#################################################################### upload gene expression file 
df <- read.table(file = './data/FILENAME.tsv', sep = '\t', header = TRUE)

################################################################### 3D regression surface after training SVM (machine learning model)

# Set the mesh size and margin for the surface plot
mesh_size <- .2
margin <- 0

# Select the input and output variables from the dataset
X <- df %>% select(X1, X2)
y <- df %>% select(X3)

# Train an SVM model with RBF kernel using the input and output variables
model <- svm_rbf(cost = 1.0) %>% 
  set_engine("kernlab") %>% 
  set_mode("regression") %>% 
  fit(X3 ~ X1 + X2, data = df)

# Define the range of x and y values for the mesh grid
x_min <- min(X$X1) - margin
x_max <- max(X$X1) - margin
y_min <- min(X$X2) - margin
y_max <- max(X$X2) - margin
xrange <- seq(x_min, x_max, mesh_size)
yrange <- seq(y_min, y_max, mesh_size)

# Generate a mesh grid for the x and y values
xy <- meshgrid(x = xrange, y = yrange)
xx <- xy$X
yy <- xy$Y
dim_val <- dim(xx)

# Reshape the mesh grid for input into the model
xx1 <- matrix(xx, length(xx), 1)
yy1 <- matrix(yy, length(yy), 1)
final <- cbind(xx1, yy1)


# Predict the output values for the mesh grid using the trained model
pred <- model %>%
  predict(final)
pred <- pred$.pred
pred <- matrix(pred, dim_val[1], dim_val[2])


# Generate a 3D surface plot of the predicted output values
fig <- plot_ly(df, x = ~X1, y = ~X2, z = ~X3 ) %>% 
  #add_markers(size = .1, color = I("black")) %>% 
  add_surface(x=xrange, y=yrange, z=pred, alpha = 0.65, type = 'mesh3d', name = 'pred_surface') %>% 
  layout(scene = list(xaxis = list(title = 'UMAP1'), 
                      yaxis = list(title = 'UMAP2'), 
                      zaxis = list(title = 'UMAP3')))
fig

htmlwidgets::saveWidget(as_widget(fig3), "results/RESULT_NAME.html")
