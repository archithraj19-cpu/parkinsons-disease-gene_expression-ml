# Setting up Pipelines 

#Random Forest Importance(RF) Pipeline

set.seed(446)
x <- subset(expr_train, select = -diagnosis)
y <- expr_train$diagnosis



# KEEP NUMERIC ONLY (CLEAN FEATURE SPACE EARLY)


x <- x[, sapply(x, is.numeric)]



#NEAR ZERO VARIANCE FILTER


nzv <- nearZeroVar(x)

if(length(nzv) > 0){
  x <- x[, -nzv]
}

nzv_cols <- colnames(x)


#GLOBAL MEDIAN IMPUTATION (SINGLE SOURCE)


global_medians <- apply(x, 2, median, na.rm = TRUE)

for(j in seq_along(x)){
  x[is.na(x[, j]), j] <- global_medians[j]
}



#VARIANCE FILTER (RF PIPELINE ONLY)


vars <- apply(x, 2, var)

vars[is.na(vars)] <- 0
vars[is.nan(vars)] <- 0

cutoff <- quantile(vars, 0.75, na.rm = TRUE)

x <- x[, vars > cutoff]

var_cols <- colnames(x)



#RANDOM FOREST FEATURE SELECTION

rf_model <- randomForest(x, y, importance = TRUE)

imp <- importance(rf_model)[, 1]

top_genes <- names(sort(imp, decreasing = TRUE))[
  1:min(length(imp), 200)
]

x_rf <- x[, top_genes]



#SCALE RF FEATURES


scale_rf <- preProcess(x_rf, method = c("center", "scale"))

x_rf <- predict(scale_rf, x_rf)

rf_data <- data.frame(x_rf, diagnosis = y)



#PCA PIPELINE INPUT (INDEPENDENT FROM RF)


x2 <- subset(expr_train, select = -diagnosis)
y2 <- expr_train$diagnosis



#KEEP NUMERIC ONLY


x2 <- x2[, sapply(x2, is.numeric)]



#APPLY SAME GLOBAL MEDIANS (CONSISTENT IMPUTATION)


for(j in seq_along(x2)){
  x2[is.na(x2[, j]), j] <- global_medians[j]
}



#PCA-SAFE VARIANCE FILTER (FIX #3)


pca_vars <- apply(x2, 2, var)

pca_vars[is.na(pca_vars)] <- 0

x2 <- x2[, pca_vars > 0]
pca_cols <- colnames(x2)



#SCALE PCA INPUT


sc_pca <- preProcess(x2, method = c("center", "scale"))

x2_scaled <- predict(sc_pca, x2)

stopifnot(ncol(x2_scaled) > 1)



#PCA


pca <- prcomp(x2_scaled)

var_exp <- cumsum(pca$sdev^2 / sum(pca$sdev^2))

k <- which(var_exp >= 0.95)[1]

pca_data <- data.frame(pca$x[, 1:k], diagnosis = y2)


#visualization


#Scree plot
p <- fviz_eig(pca, addlabels = TRUE)
print(p)


#variance contribution plot
plot(
  var_exp,
  type = "b",
  xlab = "Principal Component",
  ylab = "Cumulative Variance Explained"
)

abline(h = 0.95, col = "red", lty = 2)


#pc1vspc2 plot
fviz_pca_ind(
  pca,
  habillage = y2,
  addEllipses = TRUE,
  geom = "point",
  pointsize = 2.5,
  label = "none",
  legend.title = "Diagnosis"
)


#pc1 contribution plot
fviz_contrib(
  pca,
  choice = "var",
  axes = 1,
  top = 30
)


#pc2 contribution plot
fviz_contrib(
  pca,
  choice = "var",
  axes = 2,
  top = 30
)


#saving top 20 contributers to pc1

pc1_contrib <- get_pca_var(pca)$contrib[,1]

pc1_table <- data.frame(
  probe = names(pc1_contrib),
  Contribution = pc1_contrib
)

pc1_table <- pc1_table[
  order(pc1_table$Contribution, decreasing = TRUE),
]

head(pc1_table, 20)
write.csv(
  head(pc1_table,20),
  "Top_PC1_Genes.csv",
  row.names = FALSE
)


#saving top 20 contributers to pca2
pca2_contrib<-get_pca_var(pca)$contrib[,2]
pc2_table<-data.frame(
  probe=names(pca2_contrib),
  contribution=pca2_contrib
)
write.csv(
  head(pc2_table,20),
  "Top_pc2_Genes.csv",
  row.names = FALSE
)


#SAVE EVERYTHING FOR TEST SET


model_objects <- list(
  nzv_cols = nzv_cols,
  global_medians = global_medians,
  var_cols = var_cols,
  cutoff = cutoff,
  top_genes = top_genes,
  scale_rf = scale_rf,
  sc_pca = sc_pca,
  pca_model = pca,
  n_components = k,
  rf_model = rf_model,
  pca_cols=pca_cols
)

saveRDS(model_objects, "ml_pipeline_objects.rds")