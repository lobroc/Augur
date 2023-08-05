# library(magrittr)
import::from(dplyr, full_join, rename_at, mutate)
library(Matrix)
library(tibble)
file <- commandArgs(trailingOnly = TRUE)[1]

dataset <- readRDS(file)
# dataset <- readRDS("data/merf-pseudo-labels.rds")

message("AUC")
auc_table <- dataset$AUC
auc_table <- full_join(dataset$AUC, rename_at(as.data.frame(table(dataset$cell_type)), "Var1", ~"cell_type"), by = "cell_type")
auc_table <- rename_at(auc_table, "Freq", ~"cell_count")

dummy_var = summary(dataset$X)

auc_table = as.data.frame(auc_table)

# Change row names, to make multi-line clearer
row.names(auc_table) = auc_table$cell_type
auc_table$cell_type = NULL


for (val in unique(dataset$cell_type)) {
  ctype_subset = dataset$cell_type == val
  within_cell_type = dataset$X[, ctype_subset] # [Genes, cells]. Subsetting cell type
  mean_within_cell_type = apply(within_cell_type, 1, mean) # Mean expression of genes, in this cell type
  auc_table[which(row.names(auc_table) == val), "X_mean_all_replicates"] = mean(mean_within_cell_type)
  auc_table[which(row.names(auc_table) == val), "X_median_all_replicates"] = median(mean_within_cell_type)
  auc_table[which(row.names(auc_table) == val), "X_sd_all_replicates"] = sd(within_cell_type)

  # Intra-repliacate stats
  for (rep in unique(dataset$replicate)) {
    rep_subset = dataset$replicate == rep
    within_replicate = dataset$X[, ctype_subset & rep_subset] # [Genes, cells]. Subsetting cell type and replicate
    mean_within_cell_and_replicate = apply(within_replicate, 1, mean) # Mean expression of genes, in this cell type and replicate
    auc_table[which(row.names(auc_table) == val), paste0("X_mean_replicate_", rep)] = mean(mean_within_cell_and_replicate)
    auc_table[which(row.names(auc_table) == val), paste0("X_median_replicate_", rep)] = median(mean_within_cell_and_replicate)
    auc_table[which(row.names(auc_table) == val), paste0("X_sd_replicate_", rep)] = sd(mean_within_cell_and_replicate)
  }
}

# auc_table = as_tibble(auc_table)
# print(auc_table, n = Inf, width = Inf)

auc_table = round(t(auc_table), 4)
# auc_table["cell_count"] = sapply(auc_table["cell_count"], as.integer)
auc_table

metrics = unique(dataset$results$metric)

# Get which metric is in which index for each in metrics
metrics.index <- lapply(1:length(metrics), function(x) which(dataset$results$metric == metrics[x]))

# Get the mean estimate of each metric in the results
estimations <- sapply(metrics.index, function(x) mean(dataset$results$estimate[x][complete.cases((dataset$results$estimate[x]))]))
NAs.proportion.excluded <- sapply(metrics.index, function(x) 1 - mean(complete.cases((dataset$results$estimate[x]))))

explanation = c("Global ACC", "How grouped predictions are", "True pos. rate among pred.", "Detection strength", "Tuned to only this?", "True neg. among neg", "True pos. among pos", "AUC")

message("Data metrics")
as_tibble(data.frame(metrics, estimations, NAs.proportion.excluded, explanation))

sensitivity = estimations[which(metrics == "sens")]
specificity = estimations[which(metrics == "spec")]

size = length(dataset$y)
num_true = table(dataset$y)[2]

prevalence = num_true / size

TP = sensitivity * num_true
TN = specificity * (size - num_true)
FP = (1 - specificity) * (size - num_true)
FN = num_true - TP

message("Confusion matrix")
round(data.frame(TP = TP, TN = TN, FP = FP, FN = FN))
