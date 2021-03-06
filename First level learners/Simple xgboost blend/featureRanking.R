# Feature importance ranking by considering the importance ranking in multiple
# xgboost models.

# Clear the workspace
rm(list=ls())

# Set working directory
setwd("C:/Users/Tom/Documents/Kaggle/Facebook/First level learners/Simple XGBoost blend")

# Load the required libraries
library(data.table)
library(bit64)
library(xgboost)

# Target date
targetDate <- "23-05-2016"

# Train range: 26:40
trainIds <- 26:45 #14
nbTrainIds <- length(trainIds)

# Xgboost model folder
# modelFolder <- file.path(getwd(), targetDate, "Test prediction")
modelFolder <- file.path(getwd(), targetDate, "Test prediction")

# What ranks receive importance points
topRank <- 215


######################################################################

# Extract the models
combinedModels <- vector(mode = "list", length = nbTrainIds)
for(i in 1:nbTrainIds){
  # Load the model
  trainId <- trainIds[i]
  fn <- paste0("xgboost - Random batch - ", trainId, ".rds")
  combinedModels[[i]] <- readRDS(file.path(modelFolder, fn))
}

# Create a feature-importance pair
features <- combinedModels[[1]]$importanceMatrix$Feature
nbFeatures <- length(features)
rankImportance <- rep(0, nbFeatures)
names(rankImportance) <- features
for(i in 1:nbTrainIds){
  # Match the importance matrix with the features vector
  matchIds <- match(combinedModels[[i]]$importanceMatrix$Feature,
                    features)[1:topRank]
  
  # Increment the ranking sum
  rankImportance[matchIds] <- rankImportance[matchIds] + seq(topRank,1,-1)
}

# Rank the features
sort(rankImportance, decreasing = TRUE)

# List the features that appeared in the top topRank at least once
topFeatures <- names(rankImportance)[rankImportance>0]
