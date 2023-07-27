# library(magrittr)
file <- commandArgs(trailingOnly = TRUE)[1]

dataset <- readRDS(file)
# dataset <- readRDS("data/merf-pseudo-labels.rds")

print("AUC")
dataset$AUC

metrics = unique(dataset$results$metric)

# Get which metric is in which index for each in metrics
metrics.index <- lapply(1:length(metrics), function(x) which(dataset$results$metric == metrics[x]))

# Get the mean estimate of each metric in the results
estimations <- sapply(metrics.index, function(x) mean(dataset$results$estimate[x][complete.cases((dataset$results$estimate[x]))]))
NAs.proportion.excluded <- sapply(metrics.index, function(x) 1 - mean(complete.cases((dataset$results$estimate[x]))))

explanation = c("Global ACC", "How grouped predictions are", "True pos. rate among pred.", "Detection strength", "Tuned to only this?", "True neg. among neg", "True pos. among pos", "AUC")

print("Data metrics")
data.frame(metrics, estimations, NAs.proportion.excluded, explanation)

sensitivity = estimations[which(metrics == "sens")]
specificity = estimations[which(metrics == "spec")]

size = length(dataset$y)
num_true = table(dataset$y)[2]

prevalence = num_true / size

TP = sensitivity * num_true
TN = specificity * (size - num_true)
FP = (1 - specificity) * (size - num_true)
FN = num_true - TP

print("Confusion matrix")
round(data.frame(TP = TP, TN = TN, FP = FP, FN = FN))
