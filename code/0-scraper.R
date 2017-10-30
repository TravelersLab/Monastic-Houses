# This file contains an implementation of a web scraper using `rvest`

library(rvest)
library(dplyr)

# this is the URL we're going to be scraping from
url <- "https://en.wikipedia.org/w/index.php?title=List_of_monastic_houses_in_England&action=info"

webpage <- read_html(url)

# scrapes out all of the links to pages that we're in turn trying to scrape
link_table_html <- html_nodes(webpage, "#mw-pageinfo-templates a")
links <- html_attr(link_table_html, 'href')
links <- data.frame(links)
links <- 
  links %>% rename(link=links)
monastic_links <-filter(links, substr(link, 1, 10) == "/wiki/List")

# Defines a function to scrape the details of the monastic houses from a given
# Wikipedia link