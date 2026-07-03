#Transforming test set for RF pipeline
set.seed(446)
x_test<-subset(expr_test,select = -diagnosis)
y_test<-expr_test$diagnosis

#keep numeric columns

x_test <- x_test[, sapply(x_test, is.numeric)]

#applying nzv filter

x_test<-x_test[,nzv_cols,drop=FALSE]

#applying median impute

for(j in seq_along(x_test)){
  x_test[is.na(x_test[, j]), j] <- global_medians[j]
}

#applying variance filter
x_test <- x_test[, var_cols, drop = FALSE]

#keeping same rf features
x_rf_test <- x_test[, top_genes, drop = FALSE]

#same scaling as training set
x_rf_test <- predict(scale_rf, x_rf_test)

#final rf_test set

rf_test_data<-data.frame(x_rf_test,diagnosis=y_test)
dim(rf_data)
dim(rf_test_data)
setdiff(colnames(rf_test_data), colnames(rf_data))
setdiff(colnames(rf_data), colnames(rf_test_data))
x_rf_test$diagnosis <- NULL

rf_test_data <- data.frame(
  x_rf_test,
  diagnosis = y_test
)
dim(rf_test_data)
identical(colnames(rf_data), colnames(rf_test_data))
dim(rf_data)

#transforming the test set for PCA pipeline

x_test2<-subset(expr_test,select = -diagnosis)
y_test2<-expr_test$diagnosis

#keeping only numeric columns
x_test2<-x_test2[,sapply(x_test2,is.numeric)]

#applying same median imputation 

for(j in seq_along(x_test2)){
  x_test2[is.na(x_test2[, j]), j] <- global_medians[j]
}

#applying same variance filter as training set
x_test2 <- x_test2[, pca_cols, drop = FALSE]

#applying same scaling as training set
x_test2_scaled <- predict(sc_pca, x_test2)

#fitting training pca onto testset
pca_scores_test <- predict(pca, x_test2_scaled)

#keep same number of PCs
x_pca_test <- data.frame(
  pca_scores_test[, 1:k, drop = FALSE]
)

#final PCA test DATA

pca_test_data <- data.frame(
  x_pca_test,
  diagnosis = y_test2
)

#sanity checks

dim(pca_data)
dim(pca_test_data)
identical(colnames(pca_data), colnames(pca_test_data))
sum(is.na(rf_data))
sum(is.na(rf_test_data))

sum(is.na(pca_data))
sum(is.na(pca_test_data))
table(rf_data$diagnosis)
table(rf_test_data$diagnosis)

table(pca_data$diagnosis)
table(pca_test_data$diagnosis)