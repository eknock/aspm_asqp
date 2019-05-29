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
# get stnd_report from database
stnd_report <-  dbGetQuery(conn, "SELECT * FROM stnd_report")
stnd_report$`Average Delay Per Delayed Arrivals` <- as.numeric(stnd_report$`Average Delay Per Delayed Arrivals`)
stnd_report <- na.omit(stnd_report)

skewness(stnd_report$ASQP)

stnd_report$Date <- NULL
stnd_report$Facility <- NULL


# feature selection based on https://machinelearningmastery.com/feature-selection-with-the-caret-r-package/


correlationMatrix <- cor(stnd_report)

highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.50, names= TRUE)


# LIST OUT THE FEATURES TO BE REMOVED
print(highlyCorrelated)

# convert to numeric numbers



# feature selection
#print(listNotNeededFeatures(stnd_report))
# remove unwanted features
stnd_report$`Delayed Arrivals` <- NULL
stnd_report$`Actual Departures`<- NULL
stnd_report$`Actual Arrivals` <- NULL
stnd_report$`On-Time Arrivals`<- NULL
stnd_report$`Arrival Cancellations`<- NULL
stnd_report$`Percentage On-Time Gate Departures`<- NULL


outlierKD(stnd_report, `Departure Cancellations`)
stnd_report$`Departure Cancellations`[is.na(stnd_report$`Departure Cancellations`)] <- mean(stnd_report$`Departure Cancellations`, na.rm = T) 

outlierKD(stnd_report, `Percentage On-Time Gate Arrivals`)
stnd_report$`Percentage On-Time Gate Arrivals`[is.na(stnd_report$`Percentage On-Time Gate Arrivals`)] <- mean(stnd_report$`Percentage On-Time Gate Arrivals`, na.rm=T)

outlierKD(stnd_report, `Average Taxi Out Time`)
stnd_report$`Average Taxi Out Time`[is.na(stnd_report$`Average Taxi Out Time`)] <- mean(stnd_report$`Average Taxi Out Time`, na.rm=T)

outlierKD(stnd_report, `Average Taxi In Time`)
stnd_report$`Average Taxi In Time`[is.na(stnd_report$`Average Taxi In Time`)] <- mean(stnd_report$`Average Taxi In Time`, na.rm=T)

outlierKD(stnd_report, `Average Delay Per Delayed Arrivals`)
stnd_report$`Average Delay Per Delayed Arrivals`[is.na(stnd_report$`Average Delay Per Delayed Arrivals`)] <- mean(stnd_report$`Average Delay Per Delayed Arrivals`, na.rm=T)

# create separate three separate data frames for three predictive models
stnd_report_nn <- stnd_report
stnd_report_tree <- stnd_report
stnd_report_xgb <- stnd_report


my_formula <- ASQP~.

# =======================================================================
# models
# =======================================================================
# set seed
set.seed(34567)
# =======================================================================
# PREDICTIVE MODEL - ctree() & rpart()
# =======================================================================

stnd_report_tree$ASQP <- factor(stnd_report_tree$ASQP)
# trainging models for three predictive models
stnd_tree  <- sample(2,nrow(stnd_report_tree), replace = TRUE, prob = c(0.7,0.3))
train.tree.data <- stnd_report_tree[stnd_tree== 1,]
test.tree.data <- stnd_report_tree[stnd_tree == 2,]

# ctree()
stnd_tree_model <- ctree(my_formula, data=train.tree.data)

plot(stnd_tree_model)
# plot the simple model
plot(stnd_tree_model, type="simple",  drop_terminal = FALSE)

# Classification accuracy for training data
# ------------------------------------------

# create the confusion matrix with dimension names
table(predict(stnd_tree_model), train.tree.data$ASQP, 
      dnn=c("predicted", "actual")) 
# probability of a value being in the 9 boxes
prop.table(table(predict(stnd_tree_model), train.tree.data$ASQP))
# classification accuracy
sum(predict(stnd_tree_model)== train.tree.data$ASQP)/
  length(train.tree.data$ASQP)  
summary(stnd_tree_model)
# Test & Validate
# ----------------
# validate the model with with test data
testPred <- predict(stnd_tree_model, newdata = test.tree.data)

# create the confusion matrix with dimension names
table (testPred, test.tree.data$ASQP, dnn=c("predicted", "actual") )  
# classification accuracy
sum(testPred== test.tree.data$ASQP)/length(test.tree.data$ASQP)        

# rpart()
stnd_rpart_model <- rpart(my_formula, data=train.tree.data, method="class")
plot(stnd_rpart_model)
predict(stnd_rpart_model, train.tree.data, type="class")
# create the confusion matrix
table(predict(stnd_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP)
# create the confusion matrix with dimension names
table(predict(stnd_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP, 
      dnn=c("predicted", "actual")) 
# probability of a value being in the 9 boxes
prop.table(table(predict(stnd_rpart_model, train.tree.data, type="class"), train.tree.data$ASQP))
# classification accuracy
sum(predict(stnd_rpart_model, train.tree.data, type="class")== train.tree.data$ASQP)/length(train.tree.data$ASQP) 
#Test & Validate
# ----------------
# validate the model with with test data
testPredRPart <- predict(stnd_rpart_model, test.tree.data, type="class")
# confusion matrix
table(testPredRPart , test.tree.data$ASQP)
# create the confusion matrix with dimension names
table (testPredRPart , test.tree.data$ASQP, dnn=c("predicted", "actual") )  
# classification accuracy
sum(testPredRPart == test.tree.data$ASQP)/
  length(test.tree.data$ASQP)            

# Complex analysis with rpart

stnd_rpart_model $cptable
printcp(stnd_rpart_model )   #and alternative way to print complexity table
plotcp(stnd_rpart_model )    #plot complexity table.  x=tree size, y=x-val relatice error

# =========================================================================================
# xgboost()
# =========================================================================================

stnd_xgb  <- sample(2,nrow(stnd_report_xgb), replace = TRUE, prob = c(0.7,0.3))
train.xgb.data <- stnd_report_xgb[stnd_xgb  == 1,]
test.xgb.data <- stnd_report_xgb[stnd_xgb  == 2,]

my_formula <- ASQP~.

data.frame(train = dim(train.xgb.data), test = dim(test.xgb.data), row.names = c("row", "col"))
train.xgb.label <- as.matrix(train.xgb.data$ASQP)
test.xgb.label<- as.matrix(test.xgb.data$ASQP)

dtrain <- xgb.DMatrix(data = as.matrix(train.xgb.data), label=train.xgb.label)
dtest <- xgb.DMatrix(data = as.matrix(test.xgb.data), label=test.xgb.label)

watchlist <- list(train=dtrain, test=dtest)

#bst_tree didn't produce a big result
bst <- xgb.train(data=dtrain, booster = "gblinear", max_depth=2,eta=0.1, nthread = 2, nrounds=10, watchlist=watchlist, eval_metric = "error", eval_metric = "logloss", objective = "binary:logistic")

# identify the importance of the feature
importance_matrix <- xgb.importance(model = bst)
print(importance_matrix)
xgb.plot.importance(importance_matrix)




# PREDICTIVE MODEL - nn

stnd_nn  <- sample(2,nrow(stnd_report_nn), replace = TRUE, prob = c(0.7,0.3))
train.nn.data <- stnd_report_nn[stnd_nn  == 1,]
test.nn.data <- stnd_report_nn[stnd_nn  == 2,]


stnd_asqp_nn <- ASQP ~ `Departure Cancellations` + `Percentage On-Time Gate Arrivals` + `Average Taxi Out Time` + `Average Taxi In Time`+ `Average Delay Per Delayed Arrivals`

stnd_nn[1:6] <- scale(stnd_nn[1:6])
nnStnd <- neuralnet(formula= stnd_asqp_nn, data = train.nn.data, hidden = 3, err.fct = "ce",linear.output = FALSE)

plot(nnStnd)

#Model evaluation; Round the predicted probabilities
# compute creates predicted values for all neuron nodes given a trained neural network. No values
# for the hidden layer.
mypredict<-compute(nnStnd, nnStnd$covariate)$net.result
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
testPred <- compute(nnStnd, test.nn.data[, 0:5])$net.result
# apply method returns a list of class being 1 or 0;  If the value is greater or equal than 0.5 
# then it is 1; otherwise it's going to be zero.
testPred<-apply(testPred, c(1), round)

# print the predicted values
testPred
# confusion matrix for the test set
table(testPred, test.nn.data$ASQP, dnn =c("Predicted", "Actual"))
# find the accuracy of the test data
mean(testPred==test.nn.data$ASQP)

#=======================
