#############################################################
########          POC R Studio on MS Azure           ########
########            CMS HCC Risk Score Model         ######## 
########                January 2022                 ######## 
#############################################################

#Access Azure Portal - Storage Account and Read files
#Data Wrangling and Predictive Model
#Step 1 - Include Azure profile
source("C:/dev/Rprofile.R")
#Step 2 - Invoke necessary libraries for analyses and modeling.
library(AzureStor)    #Manage storage in Microsoft's 'Azure' cloud
library(AzureRMR)     #Interface to 'Azure Resource Manager'
library(psych)        #A general purpose toolbox for personality, psychometric theory and experimental psychology. Functions are primarily for multivariate analysis. 
library(ggplot2) 	    #A system for creating graphics, based on "The Grammar of Graphics". 
library(caret) 		    #Misc functions for training and plotting classification and regression models.
library(rpart) 		    #Recursive partitioning for classification, regression and survival trees.  
library(rpart.plot) 	#Plot 'rpart' models. Extends plot.rpart() and text.rpart() in the 'rpart' package.
library(RColorBrewer) #Provides color schemes for maps (and other graphics). 
library(party)		    #A computational toolbox for recursive partitioning.
library(partykit)	    #A toolkit with infrastructure for representing, summarizing, and visualizing tree-structure.
library(pROC) 		    #Display and Analyze ROC Curves.
library(ISLR)		      #Collection of data-sets used in the book 'An Introduction to Statistical Learning with Applications in R.
library(randomForest)	#Classification and regression based on a forest of trees using random inputs.
library(dplyr)		    #A fast, consistent tool for working with data frame like objects, both in memory and out of memory.
library(ggraph)		    #The grammar of graphics as implemented in ggplot2 is a poor fit for graph and network visualizations.
library(igraph)		    #Routines for simple graphs and network analysis.
library(mlbench) 	    #A collection of artificial and real-world machine learning benchmark problems, including, e.g., several data sets from the UCI repository.
library(GMDH2)		    #Binary Classification via GMDH-Type Neural Network Algorithms.
library(apex)		      #Toolkit for the analysis of multiple gene data. Apex implements the new S4 classes 'multidna'.
library(mda)		      #Mixture and flexible discriminant analysis, multivariate adaptive regression splines.
library(WMDB)		      #Distance discriminant analysis method is one of classification methods according to multiindex.
library(klaR)		      #Miscellaneous functions for classification and visualization, e.g. regularized discriminant analysis, sknn() kernel-density naive Bayes...
library(kernlab)	    #Kernel-based machine learning methods for classification, regression, clustering, novelty detection.
library(readxl)    	  #n Import excel files into R. Supports '.xls' via the embedded 'libxls' C library.                                                                                                                                                                 
library(GGally)  	    #The R package 'ggplot2' is a plotting system based on the grammar of graphics.                                                                                                                                                                  
library(mctest)		    #Package computes popular and widely used multicollinearity diagnostic measures.
library(sqldf)		    #SQL for dataframe wrangling.
library(reshape2)     #Pivoting table
library(anytime)      #Caches TZ in local env
library(survey)       #Summary statistics, two-sample tests, rank tests, glm.... 
library(mice)         #Library for multiple imputation
library(MASS)         #Functions and datasets to support Venables and Ripley
library(rjson)        #Load the package required to read JSON files.

#Apply credentials from profile
az <- create_azure_login(tenant=Azure_tenantID)
#rg <- az$get_subscription(Azure_SubID)$get_resource_group(Azure_ResourceGrp)

#retrieve storage account
#stor <- rg$get_storage_account("olastorageac")
#stor$get_blob_endpoint()
#stor$get_file_endpoint()

# same as above
blob_endp <- blob_endpoint("https://olastorageac.blob.core.windows.net/",key=Azure_Storage_Key)
file_endp <- file_endpoint("https://olastorageac.file.core.windows.net/",key=Azure_Storage_Key)

# shared access signature: read/write access, container+object access and set expiry date
sas <- AzureStor::get_account_sas(blob_endp, permissions="rwcdl", expiry=as.Date("2030-01-01"))
# create an endpoint object with a SAS, but without an access key
#blob_endp <- stor$get_blob_endpoint(sas=sas)

#An existing container
cms_csv <- blob_container(blob_endp, "cmsdata")

# list blobs inside a blob container
list_blobs(cms_csv)

#Temp download of files needed for data wrangling
storage_download(cms_csv, "CMS_MUP_D_Subset.csv", "~/CMS_MUP_D_Subset.csv")

#Read csv in memory
prov_data<-read.csv("CMS_MUP_D_Subset.csv")

#Delete Temp downloaded of files
file.remove("CMS_MUP_D_Subset.csv")

#Data cleaning and wrangling to get features required for modeling
#Number of columns
ncol(prov_data)
#Number of rows
nrow(prov_data)
#View fields in files
names(prov_data)
#View subset of file
head(prov_data,2)
#View structure of file
str(prov_data)

#Step 3
#Descriptive Statistics 
summary(prov_data)

#Select Specific Data Elements from Patients, Encounters and Conditions 
model_prov_data<-sqldf("select * from prov_data")

Final_Result_CMS<-model_prov_data

#Write output of prediction to csv 
write.csv(Final_Result_CMS, file = "Final_Result_CMS.csv")

#No need to upload again in Azure
#Upload Model results data into container in Azure
#cont_upload <- blob_container(blob_endp, "modeloutput")
#upload_blob(cont_upload, src="C:\\Users\\olajideajayi\\OneDrive - Microsoft\\Documents\\Final_Result_CMS.csv")

#Remove Azure Credentials from environment after use 
rm(Azure_SubID) 
rm(Azure_Storage_Key)
rm(Azure_tenantID)
rm(Azure_ResourceGrp)