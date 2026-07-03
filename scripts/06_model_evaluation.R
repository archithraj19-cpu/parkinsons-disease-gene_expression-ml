#testing the chosen model
rf_probs<-predict(rf_rf,newdata = rf_test_data,type = "prob")
rf_pred<-predict(rf_rf,newdata = rf_test_data)

#confusion matrix

cm<-confusionMatrix(rf_pred,rf_test_data$diagnosis,positive = "IPD")
precision<-cm$byClass["Pos Pred Value"]
recall<-cm$byClass["Sensitivity"]
f1score<-2 * precision * recall / (precision + recall)
f1score<-as.numeric(f1score)
f1score

write.csv(as.data.frame(cm$table),
          "Confusion_Matrix_RF.csv",
          row.names = FALSE)
metrics <- data.frame(
  Metric = c("Accuracy","Sensitivity","Specificity","Precision","F1"),
  Value = c(
    cm$overall["Accuracy"],
    cm$byClass["Sensitivity"],
    cm$byClass["Specificity"],
    cm$byClass["Pos Pred Value"],
    as.numeric(f1score)
  )
)

write.csv(metrics,
          "RF_Test_Metrics.csv",
          row.names = FALSE)

#ROC-AUC 
library(pROC)
roc_rf<-roc(
  response=rf_test_data$diagnosis,
  predictor=rf_probs$IPD,
  levels=c("CONTROL","IPD")
)
plot(
  roc_rf,
  col = "blue",
  lwd = 2,
  main = "ROC Curve - Random Forest")
auc_rf<-auc(roc_rf)
auc_rf


