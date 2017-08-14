## setup
library(data.table)
library(stats)
path <- getwd()

## Download & unzip data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
srcfile <- "Dataset.zip"
if (!file.exists(path)) {dir.create(path)}
download.file(url, file.path(path, srcfile))
unzip(srcfile)
path_folder <- file.path(path, "UCI HAR Dataset")

## read files
X_train <- fread(file.path(path_folder, "train", "X_train.txt"))
y_train <- fread(file.path(path_folder, "train", "y_train.txt"))
subj_train <- fread(file.path(path_folder, "train", "subject_train.txt"))
X_test <- fread(file.path(path_folder, "test", "X_test.txt"))
y_test <- fread(file.path(path_folder, "test", "y_test.txt"))
subj_test <- fread(file.path(path_folder, "test", "subject_test.txt"))

## merge files
subject <- rbind(subj_train, subj_test)
setnames(subject, "V1", "subject")
activity_labels <- rbind(y_train, y_test)
setnames(activity_labels, "V1", "activitynumber")
X_data <- rbind(X_train, X_test)

## name X_data columns with features
features <- fread(file.path(path_folder, "features.txt"))
feature_names <- c(features$V2)
colnames(X_data) <- feature_names

## subset only columns having "mean()" or "std()" 
my_columns <- grepl("mean\\(\\)|std\\(\\)", names(X_data))
X_subset <- X_data[, c(my_columns), with=FALSE]

## merge columns of subject, activities and observations
X_subset <- cbind(subject, activity_labels, X_subset)

## read activity names
activity_names <- fread(file.path(path_folder, "activity_labels.txt"))
setnames(activity_names, names(activity_names), c("activitynumber", "activityname"))

## add activity names to the data file
X_subset <- merge(X_subset, activity_names, by="activitynumber", all.x = TRUE)

## rename feature names to descriptive
names(X_subset) <- gsub("-", "_", names(X_subset))
names(X_subset) <- gsub("\\(\\)", "", names(X_subset))
names(X_subset) <- gsub("^t", "time_", names(X_subset))
names(X_subset) <- gsub("^f", "frequency_", names(X_subset))
names(X_subset) <- gsub("BodyAcc", "bodyacceleration_", names(X_subset))
names(X_subset) <- gsub("GravityAcc", "gravityacceleration_", names(X_subset))
names(X_subset) <- gsub("Mag", "magnitude", names(X_subset))
names(X_subset) <- gsub("X$", "Xdirection", names(X_subset))
names(X_subset) <- gsub("Y$", "Ydirection", names(X_subset))
names(X_subset) <- gsub("Z$", "Zdirection", names(X_subset))
names(X_subset) <- gsub("BodyGyro", "bodygyroscope", names(X_subset))

## re-order columns
X_subset <- X_subset[, c(2, 69, 3:68)]

## create tidy dataset
tidy_dataset <- aggregate(. ~ subject + activityname, data = X_subset, mean)
write.table(tidy_dataset, "tidy_dataset.txt", row.names = FALSE)
