library(reshape2)

filename <- "getdata-projectfiles-UCI HAR Dataset.zip"

# Download and unzip the dataset
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Get activity labels and features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
features_cleaned <- grep(".*mean.*|.*std.*", features[,2])
features_cleaned.names <- features[features_cleaned,2]
features_cleaned.names = gsub('-mean', '_Mean', features_cleaned.names)
features_cleaned.names = gsub('-std', '_Std', features_cleaned.names)
features_cleaned.names <- gsub('[-()]', '', features_cleaned.names)

# Load the train data set
train <- read.table("UCI HAR Dataset/train/X_train.txt")[features_cleaned]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

# Load the test data set
test <- read.table("UCI HAR Dataset/test/X_test.txt")[features_cleaned]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge two datasets and add labels
dataset_cleaned <- rbind(train, test)
colnames(dataset_cleaned) <- c("subject", "activity", features_cleaned.names)

# turn activities and subjects into factors
dataset_cleaned$activity <- factor(dataset_cleaned$activity, levels = activityLabels[,1], labels = activityLabels[,2])
dataset_cleaned$subject <- as.factor(dataset_cleaned$subject)

dataset_cleaned_melted <- melt(dataset_cleaned, id = c("subject", "activity"))
dataset_cleaned_mean <- dcast(dataset_cleaned_melted, subject + activity ~ variable, mean)

write.table(dataset_cleaned, "tidy_dataset.txt", row.names = FALSE, quote = FALSE)