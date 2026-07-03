#training logistic regression model for RF pipeline

set.seed(446)
logistic_rf<-train(
  diagnosis~.,
  data=rf_data,
  method="glm",
  family="binomial",
  metric="ROC",
  trControl=ctrl
)
logistic_rf$results


#training random forest model for RF pipeline

set.seed(446)
rf_grid <- expand.grid(
  mtry = seq(10, 200, by = 20)
)
rf_rf <- train(
  diagnosis ~ .,
  data = rf_data,
  method = "rf",
  metric = "ROC",
  trControl = ctrl,
  tuneGrid = rf_grid,
  importance = TRUE
)
rf_rf$results
rf_rf$bestTune


#training svm_radial model for RF pipeline

set.seed(446)
svm_grid <- expand.grid(
  sigma = c(0.001, 0.005, 0.01, 0.05, 0.1),
  C = c(0.1, 1, 10, 100)
)

svm_rf <- train(
  diagnosis ~ .,
  data = rf_data,
  method = "svmRadial",
  metric = "ROC",
  trControl = ctrl,
  tuneGrid = svm_grid
)
svm_rf$results
svm_rf$bestTune


#training logistic regression model for PCA pipeline

set.seed(446)
logistic_PCA<-train(
  diagnosis~.,
  data=pca_data,
  method="glm",
  family="binomial",
  metric="ROC",
  trControl=ctrl
  
)
logistic_PCA$results


#training Random Forest model for PCA pipeline

set.seed(446)
rf_grid_pca <- expand.grid(
  mtry = seq(10, 240, by = 20)
)
rf_PCA<-train(
  diagnosis~.,
  data=pca_data,
  method='rf',
  metric="ROC",
  trControl=ctrl,
  tuneGrid=rf_grid_pca,
  importance=TRUE
)
rf_PCA$results
rf_PCA$bestTune


#training svm_radial model for PCA pipeline

set.seed(446)
svm_grid_pca <- expand.grid(
  sigma = c(0.001, 0.005, 0.01, 0.05, 0.1),
  C = c(0.1, 1, 10, 100)
)
svm_PCA<-train(
  diagnosis~.,
  data=pca_data,
  method="svmRadial",
  metric="ROC",
  trControl=ctrl,
  tuneGrid=svm_grid_pca
)
svm_PCA$results
svm_PCA$bestTune