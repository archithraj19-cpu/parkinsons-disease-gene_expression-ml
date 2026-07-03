#tuning plot of best performing model
plot(rf_rf)

#extracting most important probes for gene mapping

imp<-importance(rf_rf$finalModel)
imp_table<-data.frame(
  probe=row.names(imp),
  MeanDecreaseGini=imp[,"MeanDecreaseGini"]
)
imp_table<-imp_table[
  order(imp_table$MeanDecreaseGini,decreasing = TRUE),
]
head(imp_table, 20)
rownames(imp_table) <- NULL

head(imp_table, 20)
write.csv(
  head(imp_table,50),
  "top_probes.csv",
  row.names = FALSE
)
varImpPlot(rf_rf$finalModel)