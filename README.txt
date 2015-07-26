## run_analysis.R
## README

run_analysis is an R file which enables you to load and process data from the UCI HAR Dataset (Motoroloa data) and outputs a single tidy dataset.  The tidy data represents the average value for 79 Feature measurements found in the UCI HAR dataset (mean() and std() measurements only) for each of 30 Subjects (participants) and each of 6 Activities (Sitting, Standing, Walking, laying, walking upstairs, walking downstairs).

To review this data:
- Ensure the UCI HAR Dataset folder (with all files and subfolders inside) is saved in your working directory (to test this, type, "list.files()").
- Source the run_analysis.R file into R and call the function run_analysis() - no input parameters are required.

The function will open a view() of the tidy dataset for your review.

--------

Optional:
The run_analysis.R code also contains code which has been commented out so that it does not run by default, but can be enabled for additional analysis.  This includes code which writes the tidy data to a txt file using write.table and an alternate approach to generating the tidy data as a List object instead of a data.frame.  Additional information on the List Object alternative is provided in detailed comments in the run_analysis.R file.