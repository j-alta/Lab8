#  Gregory A. Bruich, Ph.D.
#  Economics 50, Harvard University
#  Send corrections and suggestions to gbruich@fas.harvard.edu
#
#  File: 	lab8_2023_starter_v1.R
#
#  Description:
#  
#  The following program starts by loading in the health data and dividing it
#  into a 10% training sample and a 90% test sample.  It then estimates
#  four random forests models that differ in the predictor variables includes
#  and the "label" or outcome variable that the models predict.  The next part
#  of the code computes RMSPEs for the four models.  The last part of the code
#  exports the predictions of the four models for the test sample as "lab8_2023_results.dta"
#
#  You will analyze the resulting "lab8_2023_results.dta" data set to answer questions
#  6-9 on the lab.  The starter code helps out for questions 1-5.
#
#  The code may have some typos -- please be on the look out for them -- and to 
#  receive credit for the lab you have to make edits to estimate your own 
#  random forests.  These are simply examples of what you might
#  want to  do in your analysis, but you are expected to make an effort to 
#  understand what you are doing with the code.
#
#  Inputs:  health.dta (download from canvas)
#           randomForest to estimate random forest models
#           tidyverse library for data manipulations
#           haven library to load stata data sets into R
#
#  Outputs: mod1_importance.png
#           mod2_importance.png
#           mod3_importance.png
#           mod4_importance.png
#           lab8_2023_results.dta

rm(list=ls()) # removes all objects from the environment
cat('\014') # clears the console

#Set seed for cross validation and random forests
HUID <- 50505050 #Replace with your HUID
set.seed(HUID)

# Install packages (if necessary) and load required libraries
if (!require(haven)) install.packages("haven"); library(haven)
if (!require(randomForest)) install.packages("randomForest"); library(randomForest)
if (!require(tidyverse)) install.packages("tidyverse"); library(tidyverse)

#-------------------------------------------------------------------------------
# Data set up
#-------------------------------------------------------------------------------

#Open stata data set
dat <- read_dta("health.dta")
head(dat)

#Store health variables from time t-1 which all end with _tm
all_predictors <- colnames(dat[,grep("^[tm1]", names(dat))])
all_predictors

#Store predictor variables which all start with P_*, but EXCLUDE race
race <- c("tm1_dem_black")
exclude_race <- setdiff(all_predictors,race)
exclude_race

#Define training and test data sets
#Use a uniformly distributed random number between 0 and 1
dat$random_number <- runif(length(dat$patient_id))

## Generate a training flag for 10% of the sample
dat$train_flag <- ifelse(dat$random_number<= 0.1, 1, 0) 

#Report number of observations in training and test samples
sum(dat$train_flag)
sum(1-dat$train_flag)

## Create some data frames that just contain the training and test data

#Data frame with training data (randomly selected 10% of the data)
training <- subset(dat, train_flag == 1)
summary(training)

#Data frame with test data (remaining 90% of the data)
test <- subset(dat, train_flag == 0)
summary(test)

#-------------------------------------------------------------------------------
# Model 1: Random forest trained to predict costs, using all predictors, 
# EXCLUDING patient's race 
#-------------------------------------------------------------------------------

#Reformulate allows us to write yvar ~ xvar1 + xvar2 + ... using a list of all
#the variables without writing them out
mod1 <- randomForest(reformulate(exclude_race, "cost_t"), 
                     ntree=100, 
                     mtry=149,
                     importance=TRUE, ## add importance=TRUE so that we store the variable importance information
                     data=training)

#Tuning parameters are ntree and mtry
#ntree is number of trees in your forest
#mtry is the number of predictors considered at each split (default is number of predictors divided by 3)

### Try changing mtry and ntree

mod1 #Review the Random Forest Results

### generate predictions for all observations in test and training samples
y_test_predictions_mod1 <- predict(mod1, newdata=test)
y_train_predictions_mod1 <- predict(mod1, newdata=training)

#Variable importance
importance(mod1)
varImpPlot(mod1, type=1) #Plot the Random Forest Results
dev.copy(png,'mod1_importance.png')
dev.off()

#type	is either 1 or 2, specifying the type of importance measure 
#(1=mean decrease in accuracy, 2=mean decrease in node impurity)




#-------------------------------------------------------------------------------
# Model 2: Random forest trained to predict costs, using all predictors, 
# INCLUDING patient's race 
#-------------------------------------------------------------------------------

#Reformulate allows us to write yvar ~ xvar1 + xvar2 + ... using a list of all
#the variables without writing them out
mod2 <- randomForest(reformulate(all_predictors, "cost_t"), 
                     ntree=100, 
                     mtry=150,
                     importance=TRUE, ## add importance=TRUE so that we store the variable importance information
                     data=training)

#Tuning parameters are ntree and mtry
#ntree is number of trees in your forest
#mtry is the number of predictors considered at each split (default is number of predictors divided by 3)

### Try changing mtry and ntree

mod2 #Review the Random Forest Results

### generate predictions for all observations in test and training samples
y_train_predictions_mod2 <- predict(mod2, newdata=training)
y_test_predictions_mod2 <- predict(mod2, newdata=test)

#Variable importance
importance(mod2)
varImpPlot(mod2, type=1) #Plot the Random Forest Results
dev.copy(png,'mod2_importance.png')
dev.off()


#type	is either 1 or 2, specifying the type of importance measure 
#(1=mean decrease in accuracy, 2=mean decrease in node impurity)

#-------------------------------------------------------------------------------
# Model 3: Random forest trained to predict health, using all predictors, 
# EXCLUDING patient's race 
#-------------------------------------------------------------------------------

#Reformulate allows us to write yvar ~ xvar1 + xvar2 + ... using a list of all
#the variables without writing them out
mod3 <- randomForest(reformulate(exclude_race, "gagne_sum_t"), 
                        ntree=100, 
                        mtry=149,
                        importance=TRUE, ## add importance=TRUE so that we store the variable importance information
                        data=training)

#Tuning parameters are ntree and mtry
#ntree is number of trees in your forest
#mtry is the number of predictors considered at each split (default is number of predictors divided by 3)

### Try changing mtry and ntree

mod3 #Review the Random Forest Results

### generate predictions for all observations in test and training samples
y_test_predictions_mod3 <- predict(mod3, newdata=test)
y_train_predictions_mod3 <- predict(mod3, newdata=training)


#Variable importance
importance(mod3)
varImpPlot(mod3, type=1) #Plot the Random Forest Results
dev.copy(png,'mod3_importance.png')
dev.off()

#type	is either 1 or 2, specifying the type of importance measure 
#(1=mean decrease in accuracy, 2=mean decrease in node impurity)

#-------------------------------------------------------------------------------
# Model 4: Random forest trained to predict health, using all predictors, 
# INCLUDING patient's race 
#-------------------------------------------------------------------------------

#Reformulate allows us to write yvar ~ xvar1 + xvar2 + ... using a list of all
#the variables without writing them out
mod4 <- randomForest(reformulate(all_predictors, "gagne_sum_t"), 
                     ntree=100, 
                     mtry=150,
                     importance=TRUE, ## add importance=TRUE so that we store the variable importance information
                     data=training)

#Tuning parameters are ntree and mtry
#ntree is number of trees in your forest
#mtry is the number of predictors considered at each split (default is number of predictors divided by 3)

### Try changing mtry and ntree

mod4 #Review the Random Forest Results

### generate predictions for all observations in test and training samples
y_train_predictions_mod4 <- predict(mod4, newdata=training)
y_test_predictions_mod4 <- predict(mod4, newdata=test)

#Variable importance
importance(mod4)
varImpPlot(mod4, type=1) #Plot the Random Forest Results
dev.copy(png,'mod4_importance.png')
dev.off()


#type	is either 1 or 2, specifying the type of importance measure 
#(1=mean decrease in accuracy, 2=mean decrease in node impurity)


#-------------------------------------------------------------------------------
# Compare RMSE for models 1-4
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Calculate and compare the mean squared error in the training sample: 
#-------------------------------------------------------------------------------

## Root mean squared prediction error in  the training sample.
p <- 4
RMSPE <- matrix(0, p, 1)

## Model 1
RMSPE[1] <- sqrt(mean((training$cost_t - y_train_predictions_mod1)^2, na.rm=TRUE))

## Model 2
RMSPE[2] <- sqrt(mean((training$cost_t - y_train_predictions_mod2)^2, na.rm=TRUE))

## Model 3 
RMSPE[3] <- sqrt(mean((training$gagne_sum_t - y_train_predictions_mod3)^2, na.rm=TRUE))

## Model 4
RMSPE[4] <- sqrt(mean((training$gagne_sum_t - y_train_predictions_mod4)^2, na.rm=TRUE))

#Display a table of the results
data.frame(algorithm = c("Model 1 - Costs (excl. race) ", 
                             "Model 2 - Costs (incl. race) ",
                             "Model 3 - Health (excl. race)",
                             "Model 4 - Health (incl. race)"),
           RMSPE)

#-------------------------------------------------------------------------------
# Calculate and compare the mean squared error in  the lock box data 
#-------------------------------------------------------------------------------

## Root mean squared prediction error in the test sample.
p <- 4
RMSPE_OOS <- matrix(0, p, 1)

## Model 1
RMSPE_OOS[1] <- sqrt(mean((test$cost_t - y_test_predictions_mod1)^2, na.rm=TRUE))

## Model 2
RMSPE_OOS[2] <- sqrt(mean((test$cost_t - y_test_predictions_mod2)^2, na.rm=TRUE))

## Model 3
RMSPE_OOS[3] <- sqrt(mean((test$gagne_sum_t - y_test_predictions_mod3)^2, na.rm=TRUE))

## Model 4
RMSPE_OOS[4] <- sqrt(mean((test$gagne_sum_t - y_test_predictions_mod4)^2, na.rm=TRUE))


#Display a table of the results
data.frame(algorithm = c("Model 1 - Costs (excl. race) ", 
                         "Model 2 - Costs (incl. race) ",
                         "Model 3 - Health (excl. race)",
                         "Model 4 - Health (incl. race)"),
           RMSPE_OOS)

#-------------------------------------------------------------------------------
# Export test data set with predictions
#-------------------------------------------------------------------------------

#Export data set with training data + predictions from the models
lab8 <- test

lab8$y_test_predictions_mod1 <- y_test_predictions_mod1
lab8$y_test_predictions_mod2 <- y_test_predictions_mod2
lab8$y_test_predictions_mod3 <- y_test_predictions_mod3
lab8$y_test_predictions_mod4 <- y_test_predictions_mod4

write_dta(lab8, "lab8_2023_results.dta")
