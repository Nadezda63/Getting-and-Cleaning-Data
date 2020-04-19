# Getting and Cleaning Data Project 

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Load Libraries
library(data.table)
library(dplyr)
library(reshape2)

##### Step 1: Download zipfiles
if(!file.exists("./data")){dir.create("./data")}
fileUrl1 = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl1,destfile="./data/dataFiles.zip")
# unzip the file
unzip(zipfile = "./data/dataFiles.zip")
# Unzipped files are in UCI HAR in "data"

##### Step 2: Download train and test data
# train data
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

# test data
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# merge train and test data data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

##### Step 3: Download feature and activity labels 
# feature info
featureLabels <- read.table("./data/UCI HAR Dataset/features.txt")
# activity labels
activityLabels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(a_label[,2])

# Names of features only with mean() and std() nedded 
# extract feature cols & names named 'mean, std'
featureSet <- grep("-(mean|std).*", as.character(featureLabels[,2])) # index featureLabels with mena or std
selectedColNames <- featureLabels[featureSet, 2] # matches index of featureSet to featureLabels
selectedColNames <- gsub("-mean", "Mean", selectedColNames) 
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)

##### Step 4: Extract the cols using fetureSet index 
x_data <- x_data[featureSet] # index featureSet 
combinedData <- cbind(subject_data, y_data, x_data)
colnames(combinedData) <-c("Subject","Activity",selectedColNames )
combinedData$Activity <- factor(combinedData$Activity, levels = activityLabels[,1], labels = activityLabels[,2])
combinedData$Subject <- as.factor(combinedData$Subject)

##### Step 5: Generate tidy data set
meltedData <- melt(combinedData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./data/tidy_dataSet.txt", row.names = FALSE, quote =FALSE)

