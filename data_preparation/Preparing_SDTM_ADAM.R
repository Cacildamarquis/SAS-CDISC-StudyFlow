install.packages("devtools")

devtools::install_github("sas2r/clinical_fd")
library(clinicalfd)
ls("package:clinicalfd")
library(dplyr)
install.packages("haven")
library(haven)

#SDTM domains
head(dm)     
head(ae)     

#ADaM domains
head(adsl)     
head(adae)     


# Check structure
str(dm)
summary(dm)

# Function to remove labels
clean_datasets <- function(df) {
  df <- haven::zap_labels(df)
  df <- df %>% mutate(across(where(is.labelled), as.character))
  df <- df[, colSums(!is.na(df)) > 0]  # remove columns with all NA
  return(df)
}

ae <-  zap_labels(clinicalfd::ae)  
dm <-  zap_labels(clinicalfd::dm)
adsl <-  zap_labels(clinicalfd::adsl) 

ae <-  clean_datasets(ae)  
adsl <-  clean_datasets(adsl)  
dm <-  clean_datasets(dm) 

names(ae)
names(dm)
names(adsl)

# CSV
write.csv(ae, "ae.csv", row.names = FALSE)
write.csv(adsl, "adsl.csv", row.names = FALSE)
write.csv(dm, "dm.csv", row.names = FALSE)

