##### Gather all data sets
activityLabels <- read.table(file="UCI HAR Dataset/activity_labels.txt")
features <- read.table(file="UCI HAR Dataset/features.txt")
subjectsTrain <- read.table(file="UCI HAR Dataset/train/subject_train.txt")
trainData <- read.table(file="UCI HAR Dataset/train/X_train.txt")
trainLabels <- read.table(file="UCI HAR Dataset/train/y_train.txt")
subjectsTest <- read.table(file="UCI HAR Dataset/test/subject_test.txt")
testData <- read.table(file="UCI HAR Dataset/test/X_test.txt")
testLabels <- read.table(file="UCI HAR Dataset/test/y_test.txt")
###### complete training set
#### this column wil simply add subjects as part of training set.
#### name of column should be the same as test
trainData$subject <- subjectsTrain$V1
### add classificationCode to train data
trainData$classificationCode <- trainLabels$V1
#### add subjects to test data
testData$subject <- subjectsTest$V1
#### add classificationCode to test
testData$classificationCode <- testLabels$V1
#### change the rownames for uniqueness 
s1 <- as.numeric(rownames(trainData))
s2 <- seq(from=nrow(trainData)+1, length.out=nrow(testData))
s3 <- c(s1, s2)
com <- rbind(trainData, testData)
rownames(com) <- s3
colnames(com) <- c(as.character(features$V2), "subject", "classificationCode")
### remove special chars
colnames(com) <- gsub("-|\\(|\\)", "", colnames(com))
com$activity <- factor(com$classificationCode, activityLabels$V1, activityLabels$V2)
##### get the column indexes with matching 'mean' and 'std'
meanIdx <- features[grep("mean", features$V2), 1]
stdIdx <- features[grep("std", features$V2), 1]
comFiltered <- com[, c(meanIdx, stdIdx
                       , length(colnames(com))-2
                       , length(colnames(com))-1
                       , length(colnames(com)))]
#### lets split it by activity
splitComFiltered <- split(comFiltered, list(comFiltered$activity
                                            , comFiltered$subject))
measured <- lapply(splitComFiltered, FUN = function(x) apply(x[,1:79], 2, mean))
#### for each activity, redo the new data set into data frames
#### unslplit wont work here as we changed the filtered data set into a list
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
