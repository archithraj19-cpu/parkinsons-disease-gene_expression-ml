# Load Dataset

data<-read.delim(
  "data/GSE99039_series_matrix.txt",
  comment.char = "!",
  check.names = FALSE)
str(data)
head(data,10)
library(tidyverse)
view(data)
dim(data)
colnames(data[1:10])


# Extract disease labels

raw<-read_lines("data/GSE99039_series_matrix.txt")
head(raw,50)
grep("disease", raw, value = TRUE, ignore.case = TRUE)
grep("diagnosis", raw, value = TRUE, ignore.case = TRUE)
grep("^!Sample", raw, value = TRUE)[1:20]
grep("^!Sample_characteristics", raw, value = TRUE)
grep("^!Sample_title", raw, value = TRUE)
grep("disease label", raw, value = TRUE)
disease_lines <- grep("disease label:", raw, value = TRUE)
length(disease_lines)
cat(disease_lines, sep = "\n\n")
labels <- strsplit(disease_lines[2], "\t")[[1]]
labels <- labels[-1]
labels <- gsub("\"", "", labels)
labels <- gsub("disease label: ", "", labels)
table(labels)
length(labels)


# Filter CONTROL and IPD samples

which(grepl("^batch:", labels))
keep <- labels %in% c("CONTROL", "IPD")
table(keep)
expr <- data[, c(TRUE, keep)]
labels <- labels[keep]
dim(expr)
length(labels)
table(labels)
view(expr)
dim(data)


#Transpose expression matrix

expr_matrix <- expr[, -1]
expr_t <- as.data.frame(t(expr_matrix))
colnames(expr_t) <- expr$ID_REF
expr_t$label <- labels
str(expr_t)
view(expr_t)
length(labels)
nrow(expr_t)
expr_t$diagnosis <- as.factor(labels)
str(expr_t)
view(expr_t)
tail(names(expr_t))
table(expr_t$diagnosis)


#Data quality checks

sum(is.na(data))
colSums(is.na(data))
any(data == "")
sum(duplicated(data))
sum(is.infinite(as.matrix(data)))
expr_t$diagnosis
expr_t$diagnosis<-factor(expr_t$diagnosis,c("CONTROL","IPD"))


#Train-test split

library(caret)
library(factoextra)
library(ggplot2)
set.seed(446)
trainidx<-createDataPartition(expr_t$diagnosis,p=0.7,list=FALSE)
expr_train<-expr_t[trainidx,]
expr_train_labels<-expr_t$diagnosis[trainidx]
expr_test<-expr_t[-trainidx,]
expr_test_labels<-expr_t$diagnosis[-trainidx]
levels(expr_train_labels)
levels(expr_test_labels)
table(expr_t$diagnosis)

#Cross-validation setup

ctrl<-trainControl(
  method = "repeatedcv",
  number=10,
  repeats = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = TRUE
  
)


library(randomForest)
class(expr_t[,1])
class(expr_train[,1])
expr_train$diagnosis<-factor(expr_train$diagnosis,levels = c("CONTROL","IPD"))