library(tidyverse)

setwd("C:/Users/asbarros/OneDrive - FUNDAÇÃO GIMM - GULBENKIAN INSTITUTE FOR MOLECULAR MEDICINE/ADA/BSSantos/TRANS_017/")

Universal = read.csv("docs/AbInfo/TotalSeqC_Human_UniversalCocktail_CellRanger.csv",sep=",")
Hashtags = read.csv("docs/AbInfo/TotalSeqC_Human_HashtagAntibodies.csv",sep=",") %>%
  mutate(feature_type="Multiplexing Capture")

WorkSet = read.csv("data/98_miscellaneous/TRANS_017_Antibodies.csv",sep=";") %>%
  mutate(AbName = iconv(AbName, from = "latin1", to = "UTF-8")) %>%
  mutate(AbName =str_remove_all(AbName, "\u0099"))

Ab_IDs=str_extract(WorkSet$AbName, "C\\d{4}")
Ab_IDs_singlestring=paste0(Ab_IDs,collapse = "|")

WorkSet_CellRanger = bind_rows(
  Universal %>% filter(grepl(Ab_IDs_singlestring,id)==T),
  Hashtags %>% filter(grepl(Ab_IDs_singlestring,id)==T)
) %>% select(-X)

write.csv(WorkSet_CellRanger,"data/98_miscellaneous/TRANS_017_feature_type.csv",row.names = F)