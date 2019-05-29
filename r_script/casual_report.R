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
#######################################################################################
# =====================================================================================
# installing various packages
# =====================================================================================
# code by vikram b baliga 
# http://www.vikram-baliga.com/blog/2015/7/19/a-hassle-free-way-to-verify-that-r-packages-are-installed-and-loaded
# START CODE OF VIKRAM'S CODE
# =================================================================================
# specify the packages of interest
packages = c("caret","data.table", "dplyr","e1071","mlbench", "neuralnet", "party","partykit","rattle", "RColorBrewer","rpart", "rpart.plot", "RPostgreSQL","xgboost","zoo")

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
# create the connection
conn <- dbConnect(PostgreSQL(), user=rstudioapi::askForPassword("Database user"), password=rstudioapi::askForPassword("Database password"),dbname="aspm_db")


#=======================================================================================
# Actual modeling
# ======================================================================================
# get the casual report from the database
casual_report <- dbGetQuery(conn, "SELECT * FROM casual_report")

casual_report$Date <- NULL
casual_report$Facility <- NULL
casual_report <- na.omit(casual_report)


skewness(casual_report$ASQP)
set.seed(3456)
dim(casual_report)
# convert to numeric numbers
casual_report$`Delay Causes: Carrier Flt`<- as.numeric(casual_report$`Delay Causes: Carrier Flt`)
casual_report$`Delay Causes: Weather Flt`<- as.numeric(casual_report$`Delay Causes: Weather Flt`)
casual_report$`Delay Causes: NAS Flt` <- as.numeric(casual_report$`Delay Causes: NAS Flt`)
casual_report$`Delay Causes: Security Flt` <- as.numeric(casual_report$`Delay Causes: Security Flt`)
casual_report$`Delay Causes: Late Arrival Flt`<- as.numeric(casual_report$`Delay Causes: Late Arrival Flt`)
casual_report$`Delay Causes: Total Flt` <- as.numeric(casual_report$`Delay Causes: Total Flt`)
casual_report$ASQP <- as.numeric(casual_report$ASQP)

casual_report <- na.omit(casual_report)


correlationMatrix <- cor(casual_report)

highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.50, verbose = TRUE, names= TRUE)


# LIST OUT THE FEATURES TO BE REMOVED
print(highlyCorrelated)

casual_report$`Delay Causes: Total Min` <- NULL
casual_report$`Gate Arrival Delay Minutes` <- NULL
casual_report$`Delay Causes: Carrier Flt` <- NULL
casual_report$`Delay Causes: Carrier Min` <- NULL
casual_report$`Delay Causes: Late Arrival Min` <- NULL
casual_report$`Delay Causes: Late Arrival Flt` <- NULL
casual_report$`Delay Causes: NAS Flt` <- NULL
casual_report$`Delay Causes: Total Flt` <- NULL
casual_report$`Delay Causes: NAS Min` <- NULL
casual_report$`Actual Arrivals` <- NULL
casual_report$`Actual Departures`<- NULL
casual_report$`Delay Causes: Weather Flt` <- NULL
casual_report$`Delay Causes: Weather Min`<- NULL
casual_report$`Cancellations Causes: Carrier` <- NULL
casual_report$Cancellations <- NULL
casual_report$`Delay Causes: Security Flt` <- NULL

# remove outliers
outlierKD(casual_report,`Cancellations Causes: Weather`)
casual_report$`Cancellations Causes: Weather`[is.na(casual_report$`Cancellations Causes: Weather`)] <- mean(casual_report$`Cancellations Causes: Weather`, na.rm = T)

outlierKD(casual_report, `Cancellations Causes: NAS`)
casual_report$`Cancellations Causes: NAS`[is.na(casual_report$`Cancellations Causes: NAS`)] <- mean(casual_report$`Cancellations Causes: NAS`, na.rm = T)

# is not an outlier
#outlierKD(casual_report, `Cancellations Causes: Security`)
#casual_report$`Cancellations Causes: Security`[is.na(casual_report$`Cancellations Causes: Security`)] <- mean(casual_report$`Cancellations Causes: Security`, na.rm = T)

outlierKD(casual_report, `Delay Causes: Security Min`)
casual_report$`Delay Causes: Security Min`[is.na(casual_report$`Delay Causes: Security Min`)] <- mean(casual_report$`Delay Causes: Security Min`, na.rm = T)


# create separate three separate data frames for three predictive models
casual_report_nn <- casual_report
casual_report_tree <- casual_report

casual_report_xgb <- casual_report

# formulas for the three models
my_formula <- ASQP~.


# trainging models for three predictive models
casual_tree  <- sample(2,nrow(casual_report_tree), replace = TRUE, prob = c(0.7,0.3))
train.tree.data <- casual_report_tree[casual_tree  == 1,]
test.tree.data <- casual_report_tree[casual_tree  == 2,]



# PREDICTIVE MODEL - ctree()
casual_tree_model <- ctree(my_formula, data=train.tree.data)
plot(casual_tree_model)
# plot the simple model
plot(casual_tree_model, type="simple",  drop_terminal = FALSE)
casual_tree_model

# Classification accuracy for training data
# ------------------------------------------

# create the confusion matrix with dimension names
table(predict(casual_tree_model), train.tree.data$ASQP, 
      dnn=c("predicted", "actual")) 
# probability of a value being in the 9 boxes
prop.table(table(predict(casual_tree_model), train.tree.data$ASQP))
# classification accuracy
sum(predict(casual_tree_model)== train.tree.data$ASQP)/
  length(train.tree.data$ASQP)  
summary(casual_tree_model)
# Test & Validate
# ----------------
# validate the model with with test data
testPred <- predict(casual_tree_model, newdata = test.tree.data)

# create the confusion matrix with dimension names
table (testPred, test.tree.data$ASQP, dnn=c("predicted", "actual") )  
# classification accuracy
sum(testPred== test.tree.data$ASQP)/length(test.tree.data$ASQP)

casual_rpart_model <- rpart(my_formula, data=train.tree.data, method="class")
fancyRpartPlot(casual_rpart_model)

# PREDICTIVE MODEL - xgboost()
casual_nn  <- sample(2,nrow(casual_report_nn), replace = TRUE, prob = c(0.7,0.3))
train.nn.data <- casual_report_nn[casual_nn  == 1,]
test.nn.data <- casual_report_nn[casual_nn  == 2,]

casual_xgb  <- sample(2,nrow(casual_report_xgb), replace = TRUE, prob = c(0.7,0.3))
train.xgb.data <- casual_report_xgb[casual_xgb  == 1,]
test.xgb.data <- casual_report_xgb[casual_xgb  == 2,]

my_formula <- ASQP~.

data.frame(train = dim(train.xgb.data), test = dim(test.xgb.data), row.names = c("row", "col"))
train.xgb.label <- as.matrix(train.xgb.data$ASQP)
test.xgb.label<- as.matrix(test.xgb.data$ASQP)

dtrain <- xgb.DMatrix(data = as.matrix(train.xgb.data), label=train.xgb.label)
dtest <- xgb.DMatrix(data = as.matrix(test.xgb.data), label=test.xgb.label)

watchlist <- list(train=dtrain, test=dtest)

#bst_tree didn't produce a big result
bst <- xgb.train(data=dtrain, booster = "gblinear", max_depth=2,eta=0.1, nthread = 2, nrounds=51, watchlist=watchlist, eval_metric = "error", eval_metric = "logloss", objective = "binary:logistic")

# identify the importance of the feature
importance_matrix <- xgb.importance(model = bst)
print(importance_matrix)
xgb.plot.importance(importance_matrix)
# PREDICTIVE MODEL - nn

my_casual_report_nn <- ASQP ~ `Cancellations Causes: Weather`+`Cancellations Causes: NAS`+`Cancellations Causes: Security`+ `Delay Causes: Security Min`
casual_nn[1:4] <- scale(casual_nn[1:4])
dim(casual_report_nn)
nnCasual <- neuralnet(formula = mycasual_report_nn, data = train.nn.data, hidden = 3, err.fct = "sse",linear.output = FALSE)
plot(nnCasual)
#Model evaluation; Round the predicted probabilities
# compute creates predicted values for all neuron nodes given a trained neural network. No values
# for the hidden layer.
mypredict<-compute(nnCasual, nnCasual$covariate)$net.result
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
testPred <- compute(nnCasual, test.nn.data[,0:4])$net.result
# apply method returns a list of class being 1 or 0;  If the value is greater or equal than 0.5 
# then it is 1; otherwise it's going to be zero.
testPred<-apply(testPred, c(1), round)

# print the predicted values
testPred
# confusion matrix for the test set
table(testPred, test.nn.data$ASQP, dnn =c("Predicted", "Actual"))
# find the accuracy of the test data
mean(testPred==test.nn.data$ASQP)

casual_lm <- lm(my_formula, data=casual_report)
casual_lm_1 <- lm(my_formula, data=train.nn.data)
anova(casual_lm, casual_lm_1)
