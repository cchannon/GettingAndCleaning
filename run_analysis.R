##---------------------------------------------------##
## run_analysis.R

## This procedure pulls in, evaluates, and cleans data from the UCI HAR Dataset.
## Please be sure your working directory is set to the location of the 
## UCI HAR Dataset foler (not inside that folder) before executing this function.

## Please refer to the README file for execution instructions and the 
## CODEBOOK for detailed information on the variables and data source
##---------------------------------------------------##

run_analysis <- function(){
    ## Pull in datasets - Features, Activities, Training and Test data with labels
    Features <- readLines("UCI HAR Dataset/Features.txt")
    Activities <- readLines("UCI HAR Dataset/activity_labels.txt")
    XTrain <- readLines("UCI HAR Dataset/train/X_train.txt") #Training set values
    YTrain <- readLines("UCI HAR Dataset/train/y_train.txt") #Training set labels
    subjectTrain <- readLines("UCI HAR Dataset/train/subject_train.txt") #Training set subjects
    XTest <- readLines("UCI HAR Dataset/test/X_test.txt") #Test set values
    YTest <- readLines("UCI HAR Dataset/test/y_test.txt") #Test set labels
    subjectTest <- readLines("UCI HAR Dataset/test/subject_test.txt") #Test set subjects
    
    ## Merge Training and Testing sets
    TotalX <- c(XTrain, XTest)
    TotalY <- c(YTrain, YTest)
    TotalSubject <- c(subjectTrain, subjectTest)
    # Cleanup
    rm(XTrain)
    rm(XTest)
    rm(YTrain)
    rm(YTest)
    rm(subjectTrain)
    rm(subjectTest)
    
    ## Assign descriptive Activity names to TotalY vector
    for (i in 1:6) {
        activitySubset <- TotalY == as.character(i)
        TotalY[activitySubset] <- Activities[i]
    }
    # Cleanup
    rm(Activities)
    rm(activitySubset)
    rm(i)
    
    ## Determine the Mean and StdDev measurements
    meanFeatures <- grep("mean()", Features) # Index positions of features on Mean
    stdFeatures <- grep("std()", Features) # Index positions of features on StdDev
    keepFeatures <- sort(c(meanFeatures, stdFeatures)) # concatenate and sort numerically
    Features <- Features[keepFeatures]
    # Cleanup
    rm(meanFeatures)
    rm(stdFeatures)
    
    ## Split X values into a list of measurements by Activity/Feature
    # (lapply doesn't appear to be very efficient for this, but I wanted to experiment with it)
    TotalX <- lapply(TotalX, function(chunk){
        chunk <- strsplit(chunk, " ") # Split on spaces
        chunk <- chunk[[1]] # narrow to values
        removesubset <- chunk != "" # Identify empty values created by double spaces in strsplit
        chunk <- chunk[removesubset] # remove empty values
        chunk <- chunk[keepFeatures] # remove all columns but mean() and std()
        chunk <- as.numeric(chunk) # convert to numeric values
    })
    # Cleanup
    rm(keepFeatures)
    
    # Structure and label List to present data
    names(TotalX) <- TotalY # assign list items names according to Activity
    TotalX <- split(TotalX, TotalSubject) # Split list by Subject

    ##---------------------------------------##
    ## Break Point.  Alternate methodology for remainder of operation
    ## presented in comments at the bottom of this file.
    ##---------------------------------------##
    
    subjectNames <- names(TotalX)
    library(crayon)
    subjectNames <- "subject " %+% subjectNames
    FRnames <- vector("character", length = 0L)
    
    for (i in 1:length(TotalX)){ # loop through list items as subjects
        chunk <- TotalX[[i]]
        for(j in unique(TotalY)){ # loop through unique Activity values
            activity <- names(chunk) == j
            subChunk <- as.data.frame(chunk[activity])
            subChunk <- rowMeans(subChunk)
            if(!exists("resultset")){ # create or append to the data frame, "resultset"
                resultset <- data.frame(subChunk)
            } else resultset <- cbind(resultset, subChunk)
            FRnames <- c(FRnames, as.character(j))
        }
    }
    # Assign names to rows and columns
    rownames(resultset) <- Features
    colnames(resultset) <- FRnames
    subjectRow <- vector("character")
    for (i in 1:length(subjectNames)){
        subjectRow <- c(subjectRow, rep(subjectNames[i], times = 6))
    }
    resultset <- rbind(Subject = subjectRow, resultset)
    resultset <- cbind(Variable = rownames(resultset), resultset)
    # Cleanup
    rm(chunk)
    rm(activity)
    rm(Features)
    rm(i)
    rm(j)
    rm(subChunk)

    write.table(resultset, file = "UCI HAR Tidy Data.txt", row.name = FALSE)
    verify <- read.table("UCI HAR Tidy Data.txt")
    View(verify)
}

# The tidy data is now prepared and written to a table for submission and review.

##-------------------------------------------------------------##

## What follow below is an alternate approach to producing tidy data NOT in long form.
## This method returns the data in a List - the top level of items representing Subjects
## with a data frame of Activity/Feature for each subject.

## This is the easiest form for working with the data in R (in my opinion), but it doesn't 
## write well using write.table() because the List structure gets dropped and there is 
## no designation for which Subject a given row represents.

## The code below would replace all code after the "Break Point" noted above.

#FRnames <- names(TotalX)
#for (i in 1:length(TotalX)){ # loop through list items as subjects
#    chunk <- TotalX[[i]]
#    for (j in unique(TotalY)){ # loop through unique Activity values
#        activity <- names(chunk) == j
#        subChunk <- as.data.frame(chunk[activity])
#        subChunk <- rowMeans(subChunk)
#        if(!exists("resultset")){ # create or append to the data frame, "resultset"
#            resultset <- data.frame(subChunk)
#        } else resultset <- cbind(resultset, subChunk)
#    }
#    colnames(resultset) <- unique(TotalY) # set column names to Activities
#    rownames(resultset) <- Features # set row names to features
#    if(!exists("finalResult")){
#        finalResult <- list(resultset) # for first loop, create a list to store complete results
#    } else {
#        resultset <- list(resultset) # cast as a list in order to concatenate correctly
#        finalResult <- c(finalResult, resultset) # concatenate list objects
#    }
#    rm(resultset) #clear resultset
#}
#library(crayon)
#FRnames <- "subject " %+% FRnames
#names(finalResult) <- FRnames

##cleanup
#rm(chunk)
#rm(activity)
#rm(Features)
#rm(i)
#rm(j)
#rm(subChunk)
#rm(FRnames)

## The tidy data is now in the List Object finalResult.

#View(finalResult)
##write.table(finalResult, file = "UCI HAR Tidy Data.txt", row.name = TRUE)
