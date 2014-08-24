---
title: "README.txt"
author: "karun"
date: "08/24/2014"
output: html_document
---

This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this:
# What is where in this project?
run_analysis.R: main script that churns data out as explained in the assignment
steps

tidyds.txt: final data set that clips all 30 subjects by activity and lists mean for all variables mean and std. there are 6 activities and 30 subjects.

tidyds_observations.txt: all observations (variables)

tidyds_features.txt : all features in the new data set. activity and subject

## Gather All Datasets
```{r}
activityLabels <- read.table(file="UCI HAR Dataset/activity_labels.txt")
features <- read.table(file="UCI HAR Dataset/features.txt")
subjectsTrain <- read.table(file="UCI HAR Dataset/train/subject_train.txt")
trainData <- read.table(file="UCI HAR Dataset/train/X_train.txt")
trainLabels <- read.table(file="UCI HAR Dataset/train/y_train.txt")
subjectsTest <- read.table(file="UCI HAR Dataset/test/subject_test.txt")
testData <- read.table(file="UCI HAR Dataset/test/X_test.txt")
testLabels <- read.table(file="UCI HAR Dataset/test/y_test.txt")
```

## Set the respective columns subject and classification 
```{r}
trainData$subject <- subjectsTrain$V1
### add classificationCode to train data
trainData$classificationCode <- trainLabels$V1
### add subjects to test data
testData$subject <- subjectsTest$V1
### add classificationCode to test
testData$classificationCode <- testLabels$V1
```

## Change the rownames to preserver uniqueness
```{r}
s1 <- as.numeric(rownames(trainData))
s2 <- seq(from=nrow(trainData)+1, length.out=nrow(testData))
s3 <- c(s1, s2)
s
com <- rbind(trainData, testData)
rownames(com) <- s3
colnames(com) <- c(as.character(features$V2), "subject", "classificationCode")
### remove special chars
colnames(com) <- gsub("-|\\(|\\)", "", colnames(com))
```

## Add Factor to the classification code. the y data that is
```{r}
com$activity <- factor(com$classificationCode, activityLabels$V1, activityLabels$V2)
```

## Filter the desired features
```{r}
meanIdx <- features[grep("mean", features$V2), 1]
stdIdx <- features[grep("std", features$V2), 1]
comFiltered <- com[, c(meanIdx, stdIdx
                       , length(colnames(com))-2
                       , length(colnames(com))-1
                       , length(colnames(com)))]
```

## Split by activity and subject
```{r}
splitComFiltered <- split(comFiltered, list(comFiltered$activity
                                            , comFiltered$subject))
```

## Calculate mean of all features for the split
```{r}
measured <- lapply(splitComFiltered, FUN = function(x) apply(x[,1:79], 2, mean))
```

## Generate final data set by converting all list variables into data frame and write into files
### There are 79 rows and 180 columns. Each row is an observation for each feature in the assignment and each column is a feature in the new data set for each activity and subject 
```{r}
finalDF <- data.frame(NA, row.names=NULL)
for(n in names(measured))
{
  df <- as.data.frame(measured[[n]])
  colnames(df) <- n
  finalDF <- cbind(finalDF, df)
}
finalDF$NA. <- NULL
write.table(finalDF, file="tidyds.txt", row.name=FALSE)
write.table(rownames(finalDF), file="tidyds_observations.txt")
write.table(colnames(finalDF), file="tidyds_features.txt")
```

### tidyds_features.txt
columns are marked ad activity.subject form
WALKING.1 => For activity WALKING and Subject 1, each row is a variable mean.
the order of the varible (rows) are in tidyds_observations.txt
there are 79 of them.

### tidyds_observations.txt
each row in tidyds.txt is the mean of the feature from the assignment.
for e.g. 
WALKING.1 column of the data set in row 1 is mean of tBodyAccmeanX
WALKING.1 column of the data set in row 2 is mean of tBodyAccmeanY
WALKING.1 column of the data set in row 3 is mean of tBodyAccmeanZ
and so on...

