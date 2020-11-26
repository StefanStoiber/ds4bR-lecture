# setup
if (!require("dplyr")) install.packages("dplyr"); library(dplyr)
if (!require("tidyverse")) install.packages("tidyverse"); library(tidyverse)
# loading of data
raw_data = rio::import(file = here::here
                       ("Data", "never_use_4R.csv"))
# cleaning data (dplyr style)
cleaned_data = raw_data %>% 
  select_if(function(x){!all(is.na(x))}) %>%
  select(c(-Date,-Whatever)) %>%
  dplyr::rename(Age = "Age (or some other number)") %>%
  dplyr::mutate(
    ID = as.character(ID),
    Name = as.factor(Name),
    Outcome = as.factor(Outcome),
    ID_old = ID,
    ID = openssl::sha1(ID),
    Age = stringr::str_replace(string = Age,
                               pattern = ",",
                               replacement = "."),
    Age = as.numeric(Age)
    ) %>%
  subset(Age<120.0)


rio::export(x = cleaned_data,
            file = here::here("data", 
                              "never_use_CLEANED.Rds"))
data_import = rio::import(file = here::here("data",
                                            "never_use_CLEANED.Rds"))

# compare the serialzied exported data to original cleaned data 
if(digest::digest(cleaned_data, algo = "sha1") == digest::digest(data_import, algo = "sha1")){
  print("OK")
} else {
  print("PROBLEM!")
}  

# plotting data - differences between "dead" and "alive" in age

ggplot(data = cleaned_data,
       mapping = aes(x = Outcome,
                     y = Age))+
  geom_boxplot()+
  ggtitle("Relation between Age and Outcome", subtitle = paste0("n = ", nrow(cleaned_data)))
ggsave(here::here("data","Relation_between_Age_and_Outcome.pdf"))

