# load the libraries
library(readr)
library(data.table)

# set the name of the downloaded file
filename <- "UCI HAR Dataset.zip"

# Download and unzip the dataset: If the download file doesn't exist, then download it.
if (!file.exists(filename)){
      fileURL <- "http://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
      download.file(fileURL, filename, method="curl")
}  
# If the folder doesn't exist, then unzip the downloaded file
if (!file.exists("UCI HAR Dataset")) { 
      unzip(filename) 
}

# Load activity labels and features using read_table2 from the readr package
activitylabels <- read_table2("UCI HAR Dataset/activity_labels.txt", col_names = FALSE)
names(activitylabels) <- c("activityindex","activity")
features <- read_table2("UCI HAR Dataset/features.txt", col_names = FALSE)
names(features) <- c("index","value")

# Rename the features to standardize the names. Per the feature_info.txt, features 
# originally named with a "Mean" suffix are:
#     "Additional vectors obtained by averaging the signals in a signal window sample. 
#     These are used on the angle() variable"
# So we won't include those features.

# Extract the row numbers of the features, from column 2, that have -mean and -std 
# in their names
featureRows <- grep("(-mean|-std)", features$value)
# Change -mean to Mean, -std to Std, and remove other extra characters 
features$value <- gsub("-mean", "Mean", features$value)
features$value <- gsub("-std", "Std", features$value)
features$value <- gsub("[-(),]", "", features$value)

# get only the proper feature names based on the "featureRows" found above
featureNames <- features[featureRows,2]

# Load the all the data and column bind them together, but only the data from the 
# proper rows "featureRows" that were found above.

# Loads the training data, labels, and subjects
training <- read_table2("UCI HAR Dataset/train/X_train.txt", col_names = FALSE)[featureRows]
trainingLabels <- read_table2("UCI HAR Dataset/train/y_train.txt", col_names = FALSE)
trainingSubjects <- read_table2("UCI HAR Dataset/train/subject_train.txt", col_names = FALSE)
# Bind them all together into one dataset
training <- cbind(trainingSubjects, trainingLabels, training)
# clean up memory
rm("trainingLabels", "trainingSubjects", "filename")

# Load the test data, labels, and subjects
test <- read_table2("UCI HAR Dataset/test/X_test.txt", col_names = FALSE)[featureRows]
testLabels <- read_table2("UCI HAR Dataset/test/y_test.txt", col_names = FALSE)
testSubjects <- read_table2("UCI HAR Dataset/test/subject_test.txt", col_names = FALSE)
# Bind them all together into one dataset
test <- cbind(testSubjects, testLabels, test)
# clean up memory
rm("testLabels","testSubjects","featureRows")

# Merge the training data and test data, using rbind, and add column names to the 
# complete dataset
completeData <- rbind(training, test)
colnames(completeData) <- c("subject", "activityindex", unlist(featureNames, use.names=FALSE))

# clean up memory
rm("test", "training")

# change to data tables
completeData <- data.table(completeData)
activitylabels <- data.table(activitylabels)

# set the ON clause as keys of the tables:
setkey(activitylabels, activityindex)
setkey(completeData, activityindex)
# defining the result columns, substitute activityindex by activity
leftCols <- colnames(completeData)
leftCols <- sub("activityindex","activity",leftCols)

# here is the result of joining activitylabels to completeData on activityindex and replacing activityindex 
# values with activity values
result <- activitylabels[completeData][,leftCols, with=FALSE]
# clean up memory
rm("leftCols","completeData","activitylabels", "featureNames", "features")

# melt the data keeping only subject and activity columns and make it tidy
result <- melt.data.table(result, id = c("subject", "activity"))
# dcast the result calculating the mean of each variable
result <- dcast.data.table(result, subject + activity ~ variable, mean)

# output the tidy data to a text file
write.table(result, "tidy.txt", row.names = FALSE, quote = FALSE)

# you can view the result if you wish
#View(result)

