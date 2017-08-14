This repo contains files required for the "Getting and cleaning data" course project.
The R script is called "run_analysis.R", it does the following:
1. downloads data from
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
to the working directory
2. unzips the archive file
for details about the original dataset please refer to the "readme" file in the "UCI HAR Dataset" directory.
3. reads the several data files, merges them into a single dataset, subsets only the required variables (for details of maniputations with data see the "codebook")
4. changes the variable labels to descriptive names. Please note that the criteria for "descriptive names" were not strictly defined in the project requirements. The labels we used were created by transforming short notations into readable  descriptions so that "tBodyAcc-mean()-X" becomes "time_bobyacceleration_mean_Xdimention", etc.
5. creates a new dataset that complies with tidy data principles and contains means for each variable for each activity and each subject.  The dataset is named "tidy_dataset.txt" ; it is included in this repo.