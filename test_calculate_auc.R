# --------------------------------------------
# Load from Augur package

# import::from(Seurat, UpdateSeuratObject)
# library(Augur)
# data("sc_sim")
# sc_sim <- UpdateSeuratObject(sc_sim)
# head(sc_sim@meta.data)
# output <- calculate_auc(sc_sim, show_progress = T, classifier = "rf")
# output$AUC

# --------------------------------------------
# My version, directly load

import::from(dplyr, do, sample_n, group_by, ungroup, tibble, mutate, select, bind_rows,
             pull, rename, n_distinct, arrange, desc, filter, summarise)

import::from(tibble, repair_names, rownames_to_column)

import::from(purrr, map, map2, map_lgl, pmap, map2_df)

import::from(magrittr, `%>%`, `%<>%`, extract, extract2, set_rownames, set_colnames)

import::from(parsnip, set_engine, logistic_reg, rand_forest, fit, translate)

import::from(rsample, assessment, analysis)

import::from(recipes, prepper, bake, recipe)

import::from(yardstick, metric_set, accuracy, precision, recall, sens, spec, npv,
             ppv, roc_auc, ccc, huber_loss_pseudo, huber_loss, mae, mape, mase,
             rpd, rpiq, rsq_trad, rsq, smape, rmse)

import::from(stats, setNames, predict, sd)

import::from(methods, is)

import::from(sparseMatrixStats, colVars)

import::from(pbmcapply, pbmclapply)

import::from(parallel, mclapply)

import::from(tester, is_numeric_matrix, is_numeric_dataframe)

import::from(Matrix)

import::from(Seurat, UpdateSeuratObject)

import::from(rsample, vfold_cv)

import::from(Augur, select_variance, select_random) # Necessary, since we're only running the individual file, and not the whole package.

# --------------------------------------------------
# END OF IMPORTS
# --------------------------------------------------

source("R/calculate_auc.R")
data("sc_sim")
sc_sim <- UpdateSeuratObject(sc_sim)
head(sc_sim@meta.data)
output <- calculate_auc(sc_sim, show_progress = T, classifier = "rf")
output$AUC