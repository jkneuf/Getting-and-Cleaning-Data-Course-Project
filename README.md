Getting and Cleaning Data - Course Project
======
This is the course project for the Getting and Cleaning Data Coursera course.
The R script, [run_analysis.R](../master/run_analysis.R), does the following:

1. Downloads the dataset from a website if the dataset does not already exist in the working directory
2. Loads the activitylabels and features information and renames both files' columns
3. Selects the rows in features that have -mean and -std in their values using `grep`
4. Renames the features to standardize the names using `gsub` and select only the proper Mean and Std feature names
5. Loads the training data, labels, and subjects; then column bind them together, but only the data from the proper rows that were found above
6. Loads the test data, labels, and subjects; then column bind them together, but only the data from the proper rows that were found above
7. Merges the training and test datasets into one dataset called "completeData"
8. Transforms both the "completeData" and the "activitylabels" datasets into tables
9. Sets join keys using `setkey` in order to join these two datasets together on the "activityindex" column
10. Joins the two datasets into one dataset called "result" 
11. Creates a tidy dataset that consists of the mean value of each variable for each subject and activity pair.

The end result is shown in the file [tidy.txt](../master/tidy.txt).

You can read about the variable names in [tidy.txt](../master/tidy.txt) in the [Code Book](../master/CodeBook.md)
