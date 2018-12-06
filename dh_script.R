# Set Working Directory
setwd("~/dunnhumby_Carbo-Loading/dunnhumby - Carbo-Loading CSV")

################
### Packages ###
################
require("data.table")
require("sqldf")

#################
### Data Load ###
#################
causal <- read.csv("dh_causal_lookup.csv", header = T)
prod <- read.csv("dh_product_lookup.csv", header = T)
store <- read.csv("dh_store_lookup.csv", header = T)
trans <- read.csv("dh_transactions.csv", header = T,
                  colClasses= c("character",
                                rep("numeric",2),
                                rep("character",8)
                                ))

##################
### Formatting ###
##################

prod$upc <- as.character(prod$upc)

################
### Analysis ###
################
# 3a. What are the top 5 products in each commodity?

trans_prod <- sqldf("
                   select a.*
                          , b.commodity
                          , b.brand
                          , b.product_description
                          , b.product_size
                    from trans a
                    join prod b
                    on a.upc = b.upc
                   ")

trans_agg <- sqldf("
                   select commodity
                          , upc
                          , sum(dollar_sales) as dollar_sales
                    from trans_prod
                    group by commodity, upc
                    order by commodity, dollar_sales desc
                   ")

top_5 <- data.frame(1:5)
names(top_5) <- "Rank"
for(commodity in unique(trans_agg$commodity)){
x <- trans_agg[which(trans_agg$commodity == commodity),]
y <- x[1:5,"upc"]
top_5[commodity] <- y
}

print(top_5)

# 3b. What are the top 5 brands in each commodity?
trans_agg_brand <- sqldf("
                   select commodity
                   , brand
                   , sum(dollar_sales) as dollar_sales
                   from trans_prod
                   group by commodity, brand
                   order by commodity, dollar_sales desc
                   ")

top_5_brands <- data.frame(1:5)
names(top_5_brands) <- "Rank"
for(commodity in unique(trans_agg_brand$commodity)){
  x <- trans_agg_brand[which(trans_agg_brand$commodity == commodity),]
  y <- x[1:5,"brand"]
  top_5_brands[commodity] <- y
}
print(top_5_brands)

# 3c.What drives my sales? Which brands and which customers

