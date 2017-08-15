This codebook describes the "run_analysis.R" script under requirements for the "Getting and cleaning data" course project
## Short description of the project

The tasks for the project are as follows
1. Download the data from
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
2. Merge the training and the test sets to create one data set.
3. Extract only the measurements on the mean and standard deviation for each measurement.
4. Use descriptive activity names to name the activities in the data set.
5. Appropriately label the data set with descriptive variable names.
6. From the data set in step 5, create a second, independent tidy data set with the average of each variable for each activity and each subject. 

## Collection of the raw data. Description of how the data was collected.

General and R packages setup

```
library(data.table)
library(stats)
path <- getwd()
```

The data is downloaded from the source link provided in the course requirements (see above) by the following procedure

```
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
srcfile <- "Dataset.zip"
if (!file.exists(path)) {dir.create(path)}
download.file(url, file.path(path, srcfile))
unzip(srcfile)
path_folder <- file.path(path, "UCI HAR Dataset")
```

The description of the raw data set is provided in the "readme" file in the "UCI HAR Dataset" directory.

## Merging and cleaning data

the following files from the raw dataset are used in the project:
1. "X_train.txt", "y_train.txt", "subject_train.txt" in the  "UCI HAR Dataset\train" folder
2. "X_test.txt", "y_test.txt", "subject_test.txt" in the "UCI HAR Dataset\train" folder
3. "features.txt" and "activity_labels.txt" in the "UCI HAR Dataset" folder

Other files are not used.

The raw data files are read and combined into one dataset, columns are renamed according to the feature names contained in "features.txt"

**Read files**
```
X_train <- fread(file.path(path_folder, "train", "X_train.txt"))
y_train <- fread(file.path(path_folder, "train", "y_train.txt"))
subj_train <- fread(file.path(path_folder, "train", "subject_train.txt"))
X_test <- fread(file.path(path_folder, "test", "X_test.txt"))
y_test <- fread(file.path(path_folder, "test", "y_test.txt"))
subj_test <- fread(file.path(path_folder, "test", "subject_test.txt"))
```

**Merge files**
```
subject <- rbind(subj_train, subj_test)
setnames(subject, "V1", "subject")
activity_labels <- rbind(y_train, y_test)
setnames(activity_labels, "V1", "activitynumber")
X_data <- rbind(X_train, X_test)

```
**Name X_data columns with features**
```
features <- fread(file.path(path_folder, "features.txt"))
feature_names <- c(features$V2)
colnames(X_data) <- feature_names
```

## Creating the tidy datafile

According to the project requirements we subset the dataset to the features containing only values for mean and standard deviation for eqch measurements. Such features contain "mean()" and "std()" in their labels.

**subset only columns having "mean()" or "std()"**

``` 
my_columns <- grepl("mean\\(\\)|std\\(\\)", names(X_data))
X_subset <- X_data[, c(my_columns), with=FALSE]
```

We then add columns containing subjects and activities to the dataset with measurements, we also add activity names from "activity_labels.txt"

**merge columns of subject, activities and observations**
```
X_subset <- cbind(subject, activity_labels, X_subset)
```

**read activity names**
```
activity_names <- fread(file.path(path_folder, "activity_labels.txt"))
setnames(activity_names, names(activity_names), c("activitynumber", "activityname"))
```

**add activity names to the data file**

```
X_subset <- merge(X_subset, activity_names, by="activitynumber", all.x = TRUE)
```

According to the project requirements we rename variable labels to descriptive names.  The criteria for "descriptive names" were not strictly defined in the project requirements. We renamed the feature labels by transforming short notations into readable  descriptions so that "tBodyAcc-mean()-X" becomes "time_bobyacceleration_mean_Xdimention", etc.  We also replaced "-" symbols to "_" and eliminated "()" symbols.  The full list of changes is in the following strings of code:

**rename feature names to descriptive**

```
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
```

We subset and reorder columns in the following order: subject, activity name, feature names

```
X_subset <- X_subset[, c(2, 69, 3:68)]
```

Finally, the new "tidy" dataset is created and saved to a text file:
**create tidy dataset**
```
tidy_dataset <- aggregate(. ~ subject + activityname, data = X_subset, mean)
write.table(tidy_dataset, "tidy_dataset.txt", row.names = FALSE)
```

The new dataset contains means for each variable for each activity and each subject.
It is the data.table object with 180 observations of 68 variables.

## The variables in the dataset

[1] "subject"   - number of the person who took part in the research, values from 1 to 30                                        
 
[2] "activityname" - values "WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"

Other variables [3 to 68] are named based on specific measurements as described in "UCI HAR Dataset/README.txt"
The main classes of measurements incorporated in the featurenames are the following
a) time or frequency, 
b) accelerometer of gyroscope, 
c) acceleration signal - body or gravity, 
d) Jerk signal, 
e) Magnitude of the signal, 
f) directions of measurements - X, Y or Z 

[3] "time_bodyacceleration__mean_Xdirection"           
[4] "time_bodyacceleration__mean_Ydirection"           
[5] "time_bodyacceleration__mean_Zdirection"           
[6] "time_bodyacceleration__std_Xdirection"            
[7] "time_bodyacceleration__std_Ydirection"            
[8] "time_bodyacceleration__std_Zdirection"            
[9] "time_gravityacceleration__mean_Xdirection"        
[10] "time_gravityacceleration__mean_Ydirection"        
[11] "time_gravityacceleration__mean_Zdirection"        
[12] "time_gravityacceleration__std_Xdirection"         
[13] "time_gravityacceleration__std_Ydirection"         
[14] "time_gravityacceleration__std_Zdirection"         
[15] "time_bodyacceleration_Jerk_mean_Xdirection"       
[16] "time_bodyacceleration_Jerk_mean_Ydirection"       
[17] "time_bodyacceleration_Jerk_mean_Zdirection"       
[18] "time_bodyacceleration_Jerk_std_Xdirection"        
[19] "time_bodyacceleration_Jerk_std_Ydirection"        
[20] "time_bodyacceleration_Jerk_std_Zdirection"        
[21] "time_bodygyroscope_mean_Xdirection"               
[22] "time_bodygyroscope_mean_Ydirection"               
[23] "time_bodygyroscope_mean_Zdirection"               
[24] "time_bodygyroscope_std_Xdirection"                
[25] "time_bodygyroscope_std_Ydirection"                
[26] "time_bodygyroscope_std_Zdirection"                
[27] "time_bodygyroscopeJerk_mean_Xdirection"           
[28] "time_bodygyroscopeJerk_mean_Ydirection"           
[29] "time_bodygyroscopeJerk_mean_Zdirection"           
[30] "time_bodygyroscopeJerk_std_Xdirection"            
[31] "time_bodygyroscopeJerk_std_Ydirection"            
[32] "time_bodygyroscopeJerk_std_Zdirection"            
[33] "time_bodyacceleration_magnitude_mean"             
[34] "time_bodyacceleration_magnitude_std"              
[35] "time_gravityacceleration_magnitude_mean"          
[36] "time_gravityacceleration_magnitude_std"           
[37] "time_bodyacceleration_Jerkmagnitude_mean"         
[38] "time_bodyacceleration_Jerkmagnitude_std"          
[39] "time_bodygyroscopemagnitude_mean"                 
[40] "time_bodygyroscopemagnitude_std"                  
[41] "time_bodygyroscopeJerkmagnitude_mean"             
[42] "time_bodygyroscopeJerkmagnitude_std"              
[43] "frequency_bodyacceleration__mean_Xdirection"      
[44] "frequency_bodyacceleration__mean_Ydirection"      
[45] "frequency_bodyacceleration__mean_Zdirection"      
[46] "frequency_bodyacceleration__std_Xdirection"       
[47] "frequency_bodyacceleration__std_Ydirection"       
[48] "frequency_bodyacceleration__std_Zdirection"       
[49] "frequency_bodyacceleration_Jerk_mean_Xdirection"  
[50] "frequency_bodyacceleration_Jerk_mean_Ydirection"  
[51] "frequency_bodyacceleration_Jerk_mean_Zdirection"  
[52] "frequency_bodyacceleration_Jerk_std_Xdirection"   
[53] "frequency_bodyacceleration_Jerk_std_Ydirection"   
[54] "frequency_bodyacceleration_Jerk_std_Zdirection"   
[55] "frequency_bodygyroscope_mean_Xdirection"          
[56] "frequency_bodygyroscope_mean_Ydirection"          
[57] "frequency_bodygyroscope_mean_Zdirection"          
[58] "frequency_bodygyroscope_std_Xdirection"           
[59] "frequency_bodygyroscope_std_Ydirection"           
[60] "frequency_bodygyroscope_std_Zdirection"           
[61] "frequency_bodyacceleration_magnitude_mean"        
[62] "frequency_bodyacceleration_magnitude_std"         
[63] "frequency_Bodybodyacceleration_Jerkmagnitude_mean"
[64] "frequency_Bodybodyacceleration_Jerkmagnitude_std" 
[65] "frequency_Bodybodygyroscopemagnitude_mean"        
[66] "frequency_Bodybodygyroscopemagnitude_std"         
[67] "frequency_BodybodygyroscopeJerkmagnitude_mean"    
[68] "frequency_BodybodygyroscopeJerkmagnitude_std"
