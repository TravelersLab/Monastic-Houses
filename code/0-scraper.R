# This file contains an implementation of a web scraper using `rvest`

library(rvest)
library(dplyr)
library(readr)

# this is the URL we're going to be scraping from
url <- "https://en.wikipedia.org/w/index.php?title=List_of_monastic_houses_in_England&action=info"

webpage <- read_html(url)

# scrapes out all of the links to pages that we're in turn trying to scrape
link_table_html <- html_nodes(webpage, "#mw-pageinfo-templates a")
links <- html_attr(link_table_html, 'href')
links <- data.frame(links)
links <- 
  links %>% rename(link=links)

#Filters the appropriate links, and then gets the global web link for the urls
monastic_links <-filter(links, substr(link, 1, 10) == "/wiki/List")
wiki_url <- "https://en.wikipedia.org"
monastic_links$link <- paste(wiki_url,monastic_links$link, sep="")

# Names of the columns we'll be using
colNames <- c("Foundation", "Image", "Communities", "FormalName", "Location", "Region")

# Initializes empty dataframe with our column names
monastaries <- data.frame(Foundation = character(0), Image = character(0), Communities = character(0),
           FormalName = character(0), Location = character(0), Region = character(0)) 

# For each link in all valid monastic_links, we scrape the data
for (i in 1:length(monastic_links[,1])) {
  webpage <- read_html(monastic_links[i,])
  current_Area <- substr(monastic_links[i, 1], 58, 100000)
  tables_in_monastic_link <- html_nodes(webpage, ".wikitable")
  monastic_table <- html_table(tables_in_monastic_link[4], fill = TRUE)[1]
  monastic_table <- data.frame(monastic_table)
  monastic_table <- mutate(monastic_table, region= current_Area) 
  colnames(monastic_table) <- colNames
  monastaries <- rbind(monastaries, monastic_table)
}
# We don't care about the image field
monastaries$Image <- NULL
# Removes those nasty "[1]" links that we're not using
monastaries$Location <- gsub("\\[[^\\]]*\\]", "", monastaries$Location, perl=TRUE)

write_csv(monastaries, "./data/monastaries.csv")
