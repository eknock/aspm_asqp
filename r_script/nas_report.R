# DATA 670 Capstone project
# Problem statement: Using machine learning (supervised or unsupervised), 
# identify the airport based on metrics.  This way the machine can identify
# a specific airport or airports based on the desired metrics.  This 
# approach will enable FAA planners to focus on the specific airports 
# and see why certain airports have the desired metrics. It could be:
# --Procedures,
# No. of ATCs
# No. of runways 
# Types of traffic,
# Etc.,  
#######################################################################
# =================================================================================
# installing various packages
# =================================================================================
# code by vikram b baliga 
# http://www.vikram-baliga.com/blog/2015/7/19/a-hassle-free-way-to-verify-that-r-packages-are-installed-and-loaded
# START CODE OF VIKRAM'S CODE
# =================================================================================
# specify the packages of interest
packages = c("car","caret","data.table", "dplyr","e1071", "imputeTS", "mlbench", "neuralnet", "party","partykit","rattle", "RColorBrewer","rpart", "rpart.plot", "RPostgreSQL","xgboost","DiagrammeR","zoo")

# car = for outlierTest
# caret = for feature selection
# data.table = 
# dplyr = 
# e1071 = skewness function
# mlbench = for feature selection
# neuralnet package is needed for backprogration neural network
# party = to use the ctree() for regression trees
# partykit = Convert rpart object to BinaryTree
# RColorBrewer = Color selection for fancy tree plot
# rpart = to use the rpart() for regression trees
# rpart.plot = Enhanced tree plots
# RPostgreSQL = to interface with an PostgreSQL RDBMS
# zoo = to manipulate date strings


# use this function to check if each package is on the local machine
# if a package is installed, it will be loaded
# if any are not, the missing package(s) will be installed and loaded
package.check <- lapply(packages, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }else{
    library(x, character.only = TRUE) # the else statement added by Enoch Moses
  }
})

#verify they are loaded
search()
# =================================================================================
# END OF VIKRAM'S CODE
# =================================================================================

# =================================================================================
# OUTLIER CODE FROM https://datascienceplus.com/rscript/outlier.R
# =================================================================================
# Outlier removal by the Tukey rules on quartiles +/- 1.5 IQR
# 2017 Klodian Dhana


outlierKD <- function(dt, var) {
  var_name <- eval(substitute(var),eval(dt))
  tot <- sum(!is.na(var_name))
  na1 <- sum(is.na(var_name))
  m1 <- mean(var_name, na.rm = T)
  par(mfrow=c(2, 2), oma=c(0,0,3,0))
  boxplot(var_name, main="With outliers")
  hist(var_name, main="With outliers", xlab=NA, ylab=NA)
  outlier <- boxplot.stats(var_name)$out
  mo <- mean(outlier)
  var_name <- ifelse(var_name %in% outlier, NA, var_name)
  boxplot(var_name, main="Without outliers")
  hist(var_name, main="Without outliers", xlab=NA, ylab=NA)
  title("Outlier Check", outer=TRUE)
  na2 <- sum(is.na(var_name))
  message("Outliers identified: ", na2 - na1, " from ", tot, " observations")
  message("Proportion (%) of outliers: ", (na2 - na1) / tot*100)
  message("Mean of the outliers: ", mo)
  m2 <- mean(var_name, na.rm = T)
  #message("Mean without removing outliers: ", m1)
  #message("Mean if we remove outliers: ", m2)
  
  #response <- readline(prompt="Do you want to remove outliers and to replace with NA? [yes/no]: ")
  #if(response == "y" | response == "yes"){
   # dt[as.character(substitute(var))] <- invisible(var_name)
    #assign(as.character(as.list(match.call())$dt), dt, envir = .GlobalEnv)
    #message("Outliers successfully removed", "\n")
    #return(invisible(dt))
  #} else{
    #message("Nothing changed", "\n")
    #return(invisible(var_name))
  #}
  # modification by Enoch Moses
  dt[as.character(substitute(var))] <- invisible(var_name)
  assign(as.character(as.list(match.call())$dt), dt, envir = .GlobalEnv)
  return(invisible(dt))
}
# check for outliers and return with a mean
replace_na_with_means <- function(data_frame){
 
  data_frame <- na.omit(data_frame)
  data_frame <- mean(data_frame)
  return(data_frame)
}
  
# =================================================================================
# END OF OUTLIER CODE
# =================================================================================
# function to load CSV file
loadCsvFile <- function(file_name,skip_number,newheader, remove_bottom_number){
  data_frame <- read.csv(file_name,skip=skip_number,header=FALSE, sep=",", na.strings = c("","NA"))
  # puts the header name
  names(data_frame) <- newheader
  
  # removes all columns with NA values
  data_frame = data_frame[newheader]
  
  # remove tail - routine
  # #####################
  # get total number of rows in the data frame
  total_rows = nrow(data_frame)
  # reduce the total number by removing the undesired tail
  total_rows = total_rows - remove_bottom_number
  # remove the tail
  data_frame = head(data_frame,total_rows)
  
  # returrn the data frame
  return(data_frame)
}
# function to standardize date
getFormattedDate <- function(old_date){
  inner_date <- old_date
  new_date <- as.yearmon(inner_date,"%b-%y")
  return(new_date)
}

getFormattedDateOther <- function(old_date){
  inner_date <- old_date
  dash_index <- regexpr("-",inner_date)
  year <- substr(inner_date,0,dash_index-1)
  month <- substr(inner_date,dash_index, dash_index+3)
  month <- substr(month,2,4)
  inner_date <- paste(month,year,sep="-")
  new_date <- getFormattedDate(inner_date)
  return(new_date)
  
}

# function moveDataToDB
moveDataToDB <- function(conn, data_frame_name, data_frame){
  if(!dbExistsTable(conn, data_frame_name)){
    dbWriteTable(conn,data_frame_name, data_frame)
  }
}

# create the connection
conn <- dbConnect(PostgreSQL(), user=rstudioapi::askForPassword("Database user"), password=rstudioapi::askForPassword("Database password"),dbname="aspm_db")

#=======================================================================================
# Actual modeling
# ======================================================================================
# get nas_report from database

# get nas_report from database
nas_report <-  dbGetQuery(conn, "SELECT * FROM nas_report")

nas_report$Date <- NULL
nas_report$Facility <- NULL



# feature selection based on https://machinelearningmastery.com/feature-selection-with-the-caret-r-package/

set.seed(3456)
dim(nas_report)

correlationMatrix <- cor(nas_report)

highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.50, verbose = TRUE, names= TRUE)

# LIST OUT THE FEATURES TO BE REMOVED
print(highlyCorrelated)

nas_report$`NAS Causes: Total Flt`<- NULL
nas_report$`NAS Causes: Total Min` <- NULL
nas_report$`Cancellation NAS Causes: Total`<- NULL
nas_report$`Delay NAS Causes - Causes: Wx Flt` <- NULL
nas_report$`Delay NAS Causes - Causes: Wx Min` <- NULL
nas_report$`Delay NAS Causes - Causes: Vol Min` <- NULL
nas_report$`Delay NAS Causes - No Match: Delay After Gate Dep >15 Flt` <- NULL
nas_report$`Delay NAS Causes - No Match: Delay After Gate Dep >15 Min` <- NULL
nas_report$`Delay NAS Causes - No Match: NAS <15 Min` <- NULL
nas_report$`Delay NAS Causes - No Match: Gate Dep Delay<6 Min` <- NULL
nas_report$`Cancellation NAS Causes: Vol` <- NULL
nas_report$`Delay NAS Causes - No Match: Other Carr Reported NAS Flt`<- NULL
nas_report$`Delay NAS Causes - Causes: Oth Flt` <- NULL
nas_report$`Delay NAS Causes - Causes: Rwy Flt`<- NULL
nas_report$`Delay NAS Causes - Causes: Rwy Min` <- NULL
nas_report$`Delay NAS Causes - No Match: NAS Delays Requiring Val Min`<- NULL
nas_report$`Delay NAS Causes - No Match: NAS Delays Requiring Val Flt`<- NULL
nas_report$`Delay NAS Causes - Causes: Eqpt Flt` <- NULL
nas_report$`Cancellation NAS Causes: Eqpt` <- NULL
nas_report$`Delay NAS Causes - No Match: Other Carr Reported Non-NAS Min` <- NULL
nas_report$`Delay NAS Causes - No Match: No Other Carr Reported Delays Flt` <- NULL

#check for skewness


# remove outliers
outlierKD(nas_report, `Cancellation NAS Causes: Wx`)
nas_report$`Cancellation NAS Causes: Wx` <- replace_na_with_means(nas_report$`Cancellation NAS Causes: Wx`)

outlierKD(nas_report, `Cancellation NAS Causes: Rwy`)
nas_report$`Cancellation NAS Causes: Rwy` <- replace_na_with_means(nas_report$`Cancellation NAS Causes: Rwy`)

outlierKD(nas_report, `Cancellation NAS Causes: Oth`)
nas_report$`Cancellation NAS Causes: Oth` <- replace_na_with_means(nas_report$`Cancellation NAS Causes: Oth`)

outlierKD(nas_report, `Delay NAS Causes - Causes: Vol Flt`)
nas_report$`Delay NAS Causes - Causes: Vol Flt` <- replace_na_with_means(nas_report$`Delay NAS Causes - Causes: Vol Flt`)

outlierKD(nas_report, `Delay NAS Causes - Causes: Eqpt Min`)
nas_report$`Delay NAS Causes - Causes: Eqpt Min` <- replace_na_with_means(nas_report$`Delay NAS Causes - Causes: Eqpt Min`)

outlierKD(nas_report, `Delay NAS Causes - Causes: Oth Min`)
nas_report$`Delay NAS Causes - Causes: Oth Min` <- replace_na_with_means(nas_report$`Delay NAS Causes - Causes: Oth Min`)

outlierKD(nas_report, `Delay NAS Causes - No Match: NAS <15 Flt`)
nas_report$`Delay NAS Causes - No Match: NAS <15 Flt` <- replace_na_with_means(nas_report$`Delay NAS Causes - No Match: NAS <15 Flt`)

outlierKD(nas_report, `Delay NAS Causes - No Match: Gate Dep Delay<6 Flt`)
nas_report$`Delay NAS Causes - No Match: Gate Dep Delay<6 Flt` <- replace_na_with_means(nas_report$`Delay NAS Causes - No Match: Gate Dep Delay<6 Flt`)

outlierKD(nas_report, `Delay NAS Causes - No Match: Other Carr Reported NAS Min`)
nas_report$`Delay NAS Causes - No Match: Other Carr Reported NAS Min` <- replace_na_with_means(nas_report$`Delay NAS Causes - No Match: Other Carr Reported NAS Min`)

outlierKD(nas_report, `Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt`)
nas_report$`Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt` <- replace_na_with_means(nas_report$`Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt`)

outlierKD(nas_report, `Delay NAS Causes - No Match: No Other Carr Reported Delays Min`)
nas_report$`Delay NAS Causes - No Match: No Other Carr Reported Delays Min`<- replace_na_with_means(nas_report$`Delay NAS Causes - No Match: No Other Carr Reported Delays Min`)

# create separate three separate data frames for three predictive models
nas_report_nn <- nas_report
nas_report_tree <- nas_report
nas_report_xgb <- nas_report


# =======================================================================
# models
# =======================================================================
# set seed
set.seed(34567)
# =======================================================================
# PREDICTIVE MODEL - ctree() & rpart()
# =======================================================================
nas_report_tree$ASQP <- factor(nas_report_tree$ASQP)

# formulas for the three models
my_formula <- ASQP~.


# trainging models for three predictive models
nas_tree  <- sample(2,nrow(nas_report_tree), replace = TRUE, prob = c(0.7,0.3))
train.tree.data <- nas_report_tree[nas_tree  == 1,]
test.tree.data <- nas_report_tree[nas_tree  == 2,]


# PREDICTIVE MODEL - ctree()
nas_tree_model <- ctree(my_formula, data=train.tree.data)
plot(nas_tree_model)
nas_tree_model


# plot the simple model
plot(nas_tree_model, type="simple",  drop_terminal = FALSE)

# Classification accuracy for training data
# ------------------------------------------

# create the confusion matrix with dimension names
table(predict(nas_tree_model), train.tree.data$ASQP, 
      dnn=c("predicted", "actual")) 
# probability of a value being in the 9 boxes
prop.table(table(predict(nas_tree_model), train.tree.data$ASQP))
# classification accuracy
sum(predict(nas_tree_model)== train.tree.data$ASQP)/
  length(train.tree.data$ASQP)  

# Test & Validate
# ----------------
# validate the model with with test data
testPred <- predict(nas_tree_model, newdata = test.tree.data)

# create the confusion matrix with dimension names
table (testPred, test.tree.data$ASQP, dnn=c("predicted", "actual") )  
# classification accuracy
sum(testPred== test.tree.data$ASQP)/length(test.tree.data$ASQP)        

# rpart()
nas_rpart_model <- rpart(my_formula, data=train.tree.data, method="class")
fancyRpartPlot(nas_rpart_model)

plot(nas_rpart_model)
predict(nas_rpart_model, train.tree.data, type="class")
# create the confusion matrix
table(predict(nas_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP)
# create the confusion matrix with dimension names
table(predict(nas_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP, 
      dnn=c("predicted", "actual")) 
# probability of a value being in the 9 boxes
prop.table(table(predict(nas_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP))
# classification accuracy
sum(predict(nas_rpart_model, train.tree.data, type="class")== train.tree.data$ASQP)/length(train.tree.data$ASQP) 
#Test & Validate
# ----------------
# validate the model with with test data
testPredRPart <- predict(nas_rpart_model, test.tree.data, type="class")
# confusion matrix
table(testPredRPart , test.tree.data$ASQP)
# create the confusion matrix with dimension names
table (testPredRPart , test.tree.data$ASQP, dnn=c("predicted", "actual") )  
# classification accuracy
sum(testPredRPart == test.tree.data$ASQP)/
  length(test.tree.data$ASQP) 

printcp(nas_rpart_model)
plotcp(nas_rpart_model)
nas_prune_rpart_model <- prune(nas_rpart_model, cp= nas_rpart_model$cptable[which.min(nas_rpart_model$cptable[,"xerror"]),"CP"])
fancyRpartPlot(nas_prune_rpart_model)
# create the confusion matrix with dimension names
table(predict(nas_prune_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP, 
      dnn=c("predicted", "actual")) 
# probability of a value being in the 9 boxes
prop.table(table(predict(nas_prune_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP))
# classification accuracy
sum(predict(nas_prune_rpart_model, train.tree.data, type="class")== train.tree.data$ASQP)/length(train.tree.data$ASQP) 
#Test & Validate
# ----------------
# validate the model with with test data
testPredRPart <- predict(nas_prune_rpart_model, test.tree.data, type="class")
# confusion matrix
table(testPredRPart , test.tree.data$ASQP)
# create the confusion matrix with dimension names
table (testPredRPart , test.tree.data$ASQP, dnn=c("predicted", "actual") )  
# classification accuracy
sum(testPredRPart == test.tree.data$ASQP)/
  length(test.tree.data$ASQP) 

# PREDICTIVE MODEL - xgboost()
# =========================================================================================
# xgboost()
# =========================================================================================


nas_xgb  <- sample(2,nrow(nas_report_xgb), replace = TRUE, prob = c(0.7,0.3))
train.xgb.data <- nas_report_xgb[nas_xgb  == 1,]
test.xgb.data <- nas_report_xgb[nas_xgb  == 2,]

#nas_asqp_xgb <- ASQP ~ `Cancellation NAS Causes: Wx`+ `Cancellation NAS Causes: Rwy`+ `Cancellation NAS Causes: Oth`+ `Cancellation NAS Causes: No Match Other Carrier Reported NAS`+ `Cancellation NAS Causes: No Match Required Validation`+ `Cancellation NAS Causes: No Match Required Validation` + `Delay NAS Causes - Causes: Vol Flt`+ `Delay NAS Causes - Causes: Eqpt Min`+ `Delay NAS Causes - Causes: Oth Min`+ `Delay NAS Causes - No Match: NAS <15 Flt`+ `Delay NAS Causes - No Match: Gate Dep Delay<6 Flt`+ `Delay NAS Causes - No Match: Other Carr Reported NAS Min`+ `Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt`+`Delay NAS Causes - No Match: No Other Carr Reported Delays Min`


data.frame(train = dim(train.xgb.data), test = dim(test.xgb.data), row.names = c("row", "col"))
train.xgb.label <- as.matrix(train.xgb.data$ASQP)
test.xgb.label<- as.matrix(test.xgb.data$ASQP)

dtrain <- xgb.DMatrix(data = as.matrix(train.xgb.data), label=train.xgb.label)
dtest <- xgb.DMatrix(data = as.matrix(test.xgb.data), label=test.xgb.label)

watchlist <- list(train=dtrain, test=dtest)

bst <- xgb.train(data=dtrain, booster = "gblinear", max_depth=2, nthread = 2, nrounds=10, watchlist=watchlist, eval_metric = "error", eval_metric = "logloss", objective = "binary:logistic")

# identify the importance of the feature
importance_matrix <- xgb.importance(model = bst)
print(importance_matrix)
xgb.plot.importance(importance_matrix)

c2 <- chisq.test(train.xgb.data$ASQP, train.xgb.label)
print(c2)


# PREDICTIVE MODEL - nn


nas_nn  <- sample(2,nrow(nas_report_nn), replace = TRUE, prob = c(0.7,0.3))
train.nn.data <- nas_report_nn[nas_nn  == 1,]
test.nn.data <- nas_report_nn[nas_nn  == 2,]

nas_asqp_nn <- ASQP ~ `Cancellation NAS Causes: Wx`+ `Cancellation NAS Causes: Rwy`+ `Cancellation NAS Causes: Oth`+ `Cancellation NAS Causes: No Match Other Carrier Reported NAS`+ `Cancellation NAS Causes: No Match Required Validation`+ `Cancellation NAS Causes: No Match Required Validation` + `Delay NAS Causes - Causes: Vol Flt`+ `Delay NAS Causes - Causes: Eqpt Min`+ `Delay NAS Causes - Causes: Oth Min`+ `Delay NAS Causes - No Match: NAS <15 Flt`+ `Delay NAS Causes - No Match: Gate Dep Delay<6 Flt`+ `Delay NAS Causes - No Match: Other Carr Reported NAS Min`+ `Delay NAS Causes - No Match: Other Carr Reported Non-NAS Flt`+`Delay NAS Causes - No Match: No Other Carr Reported Delays Min`

nnNas <- neuralnet(formula = nas_asqp_nn, data = train.nn.data, hidden = 3, err.fct = "sse",linear.output = FALSE)

plot(nnNas)

#Model evaluation; Round the predicted probabilities
# compute creates predicted values for all neuron nodes given a trained neural network. No values
# for the hidden layer.
mypredict<-compute(nnNas, nnNas$covariate)$net.result
# apply method returns a list of class being 1 or 0;  If the value is greater or equal than 0.5 
# then it is 1; otherwise it's going to be zero.
mypredict<-apply(mypredict, c(1), round)
# print the predicted values
mypredict
# confusion matrix for the training set
table(mypredict, train.nn.data$ASQP, dnn =c("Predicted", "Actual"))
# find the accuracy of the training data
mean(mypredict==train.nn.data$ASQP)


# compute creates predicted values with the test data
testPred <- compute(nnNas, test.nn.data[, 0:13])$net.result
# apply method returns a list of class being 1 or 0;  If the value is greater or equal than 0.5 
# then it is 1; otherwise it's going to be zero.
testPred<-apply(testPred, c(1), round)

# print the predicted values
testPred
# confusion matrix for the test set
table(testPred, test.nn.data$ASQP, dnn =c("Predicted", "Actual"))
# find the accuracy of the test data
mean(testPred==test.nn.data$ASQP)

