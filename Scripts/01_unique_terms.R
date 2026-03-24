## unique terms
library(RPostgreSQL)
library(tidyverse)

mypassword <- rstudioapi::askForPassword()

## Connect to database
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname="aact",host="aact-db.ctti-clinicaltrials.org",
                 port=5432, user="dmcalli",
                 password=mypassword)
tbls <- RPostgreSQL::dbListTables(con)

reported_events <- dbGetQuery(con, "SELECT * from reported_events limit 5")
unq_terms <- dbGetQuery(con, 
"SELECT 
    vocab, 
    organ_system, 
    adverse_event_term, 
    COUNT(DISTINCT nct_id) AS trial_count
FROM 
    reported_events
GROUP BY 
    vocab, 
    organ_system, 
    adverse_event_term
ORDER BY 
    trial_count DESC;")
saveRDS(unq_terms, "Data/unique_reported_events.Rds")
dbDisconnect(con)
unq_terms <- as_tibble(unq_terms)
unq_terms %>% 
  slice(1:10) %>% 
  write_csv("Outputs/example_unq_terms.csv")
