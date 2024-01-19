#install.packages("pacman")
library(pacman)
p_load(htmlwidgets,
       plyr,
       magrittr,
       htmltools,
       tools,
       igraph,yaml,Rcpp,jsonlite,digest,networkD3, install = FALSE)


#################################################################### read data
# Data format: dataframe with 3 variables; variables 1 & 2 correspond to interactions; variable 3 is weight of interaction

edgeList1 <- read.table("./data/FILENAME.tsv", header = TRUE, sep = "\t")
edgeList <- edgeList1[, c("node1", "node2", "combined_score")] #combined_score is given by string.db, can be changed as needed (e.g coexpression)
colnames(edgeList) <- c("SourceName", "TargetName", "Weight")

# Create a graph. Use simplify to ensure that there are no duplicated edges or self loops
gD <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=FALSE))

# Create a node list object (actually a data frame object) that will contain information about nodes
nodeList <- data.frame(ID = c(0:(igraph::vcount(gD) - 1)), # because networkD3 library requires IDs to start at 0
                       nName = igraph::V(gD)$name)

# Map node names from the edge list to node IDs
getNodeID <- function(x){
  which(x == igraph::V(gD)$name) - 1 # to ensure that IDs start at 0
}


# And add them to the edge list
edgeList <- plyr::ddply(edgeList, .variables = c("SourceName", "TargetName", "Weight"), 
                        function (x) data.frame(SourceID = getNodeID(x$SourceName), 
                                                TargetID = getNodeID(x$TargetName)))
head(edgeList)
############################################################################################
# Calculate some node properties and node similarities that will be used to illustrate different plotting abilities and add them to the edge and node lists

# Calculate degree for all nodes
nodeList <- cbind(nodeList, nodeDegree=igraph::degree(gD, v = igraph::V(gD), mode = "all"))

##################CENTRALITY CHOICE
##alternatives: betweenness, closeness, harmonic centrality, degree, PageRank ... there is a multitude of different algorithms to apply here


#calculate Eigenvector values as 3rd possibility to get the centrality measure
evAll <- igraph::evcent(gD, directed = FALSE)$vector
evAll.norm <- (evAll - min(evAll))/(max(evAll) - min(evAll))
nodeList <- cbind(nodeList, nodeEigenvector=80*evAll.norm) # scaling the value by multiplying it by 100 for visualization purposes only (to create larger nodes)
rm(evAll, evAll.norm)

####################SIMILARITY calculation

#Calculate Dice similarities between all pairs of nodes
dsAll <- igraph::similarity.dice(gD, vids = igraph::V(gD), mode = "all")

F1 <- function(x) {data.frame(diceSim = dsAll[x$SourceID +1, x$TargetID + 1])}
edgeList <- plyr::ddply(edgeList, .variables=c("SourceName", "TargetName", "Weight", "SourceID", "TargetID"), 
                        function(x) data.frame(F1(x)))

rm(dsAll, F1, getNodeID, gD)

head(edgeList)
############################################################################################
# create a set of colors for each edge, based on their dice similarity values
# --> interpolate edge colors based on the using the "colorRampPalette" function, that 
# returns a function corresponding to a color pallette of "bias" number of elements (in this case, that
# will be a total number of edges, i.e., number of rows in the edgeList data frame)

F2 <- colorRampPalette(c("#5d5d5d", "#050505"), bias = nrow(edgeList), space = "rgb", interpolate = "linear")
colCodes <- F2(length(unique(edgeList$diceSim)))
edges_col <- sapply(edgeList$diceSim, function(x) colCodes[which(sort(unique(edgeList$diceSim)) == x)])


rm(colCodes, F2)

############################################################################################ network visualization


D3_network_LM <- networkD3::forceNetwork(Links = edgeList, # data frame that contains info about edges
                                         Nodes = nodeList, # data frame that contains info about nodes
                                         Source = "SourceID", # ID of source node 
                                         Target = "TargetID", # ID of target node
                                         Value = "Weight", # value from the edge list (data frame) that will be used to value/weight relationship among nodes
                                         NodeID = "nName", # value from the node list (data frame) that contains node description we want to use (e.g., node name)
                                         Nodesize = "nodeEigenvector",  # value from the node list (data frame) that contains value we want to use for a node size
                                         Group = "nodeDegree",  # value from the node list (data frame) that contains value we want to use for node color
                                         height = 1000, # Size of the plot (vertical)
                                         width = 1000,  # Size of the plot (horizontal)
                                         fontSize = 18, # Font size
                                         fontFamily = "Arial",
                                         linkDistance = networkD3::JS("function(d) { return 100*d.value; }"), # Function to determine distance between any two nodes, uses variables already defined in forceNetwork function (not variables from a data frame)
                                         linkWidth = networkD3::JS("function(d) { return d.value/5; }"),# Function to determine link/edge thickness, uses variables already defined in forceNetwork function (not variables from a data frame)
                                         opacity = 0.9, # opacity
                                         zoom = TRUE, # ability to zoom when click on the node
                                         opacityNoHover = 0.9, # opacity of labels when static
                                         linkColour = edges_col) # edge colors

# Plot network
D3_network_LM 



########################################################################### export
networkD3::saveNetwork(D3_network_LM, "results/FILENAME.html", selfcontained = TRUE)


