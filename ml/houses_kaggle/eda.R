#!/usr/bin/env Rscript

###### Setting libraries and functions ######

set.seed(410)

library(tidyverse)
library(ggthemes)
library(DataExplorer)
library(DAAG)
library(MASS)
library(broom)

partition_data <- function(data, train = 0.6, test = 0.2){
  validation <- 1 - (train + test)
  n <- nrow(data)
  n_train <- floor(n * train)
  n_test <- ceiling(n * test)
  n_validation <- n - (n_train + n_test)
  random_idx <- sample(1:n) 
  idx_train <- random_idx[1:n_train]
  idx_test <- random_idx[(n_train+1) : (x <- (n_train+1 + n_test-1))]
  idx_validation <- random_idx[ (x+1) : n]
  idx_train <- sort(idx_train)
  idx_test <- sort(idx_test)
  idx_validation <- sort(idx_validation)
  data_train <- data[idx_train,]
  data_test <- data[idx_test,]
  data_val <- data[idx_validation,]
  partitions <- list(data_train, data_test, data_val)
  names(partitions) <- c('train', 'test', 'val')
  return(partitions) 
}

plot_Missing <- function(data_in, title = NULL){
  temp_df <- as.data.frame(ifelse(is.na(data_in), 0, 1))
  temp_df <- temp_df[,order(colSums(temp_df))]
  data_temp <- expand.grid(list(x = 1:nrow(temp_df), y = colnames(temp_df)))
  data_temp$m <- as.vector(as.matrix(temp_df))
  data_temp <- data.frame(x = unlist(data_temp$x), y = unlist(data_temp$y), m = unlist(data_temp$m))
  ggplot(data_temp) + geom_tile(aes(x=x, y=y, fill=factor(m))) + scale_fill_manual(values=c("white", "black"), name="Missing\n(0=Yes, 1=No)") + theme_light() + ylab("") + xlab("") + ggtitle(title)
}

###### Loading Data ######

file <- 'data/train.csv'
raw_casas <- read.csv( file = file, stringsAsFactors = FALSE, header = TRUE )
casas <- as.tibble(raw_casas)

# plot_str(casas)
# plot_missing(casas)
# plot_histogram(casas)
# plot_density(casas)
# 
# # A little time intensive and memory intensive
# plot_correlation(casas)
# plot_bar(casas)
# 
# # Time intensive and memory Intensive
# create_report(casas)

plot_Missing(casas)

###### LM ######

# Get columns that have less that 10% of missing values
p <- plot_missing(casas)
keep_col_t <- as.character( p$feature[which(p$pct_missing < 0.10)] )
keep_col <- keep_col_t[ 2:length(keep_col_t) ]

# Get the rows that have missing values
complete_rows <- casas[ keep_col ] %>%
  complete.cases()
table(complete_rows)

# Removing columns and rows with NAs
casas2 <- casas[ keep_col ] [complete_rows,]

# Getting the categorical var
type_casas2 <- sapply(casas2, class)
cat_col <- names( type_casas2[  type_casas2 == 'character' ] )

# Getting the numeric variables
( num_col <- names( type_casas2[  type_casas2 != 'character' ] ) )

# The tables of all the categorical
lapply( casas2[ cat_col ], table )

###### Just numeric ######
# LM toy example

num_houses <- casas2[ num_col ]
num_parts <- partition_data(num_houses, train = 0.8, test = 0)

val_num_houses <- num_parts$val
train_num_house <- num_parts$train

names( train_num_house )


# # Multiple Linear Regression Example
# fit <- lm(SalePrice ~ MSSubClass + LotArea + OverallQual + OverallCond, data = train_num_house)
# summary(fit) # show results
# 
# # Other useful functions
# coefficients(fit) # model coefficients
# confint(fit, level=0.95) # CIs for model parameters 
# 
# fitted(fit) # predicted values
# residuals(fit) # residuals
# anova(fit) # anova table
# vcov(fit) # covariance matrix for model parameters
# influence(fit) # regression diagnostics 

# # diagnostic plots
# layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
# plot(fit)

# # compare models
# fit1 <- lm(SalePrice ~ MSSubClass + LotArea + OverallQual, data = train_num_house)
# fit2 <- lm(SalePrice ~ LotArea + OverallQual, data = train_num_house)
# anova( fit1, fit2 )

# # K-fold cross-validation
# cv.lm(data = train_num_house, fit, m = 3) # 3 fold cross-validation


###### Stepwise Regression ######

# # Stepwise Regression
# step <- stepAIC(fit, direction="both")
# step$anova # display results

# String to formulae object
# formula('y ~ x1 + x2')

# df <- data.frame( y=rnorm(10),x1=rnorm(10),x2=rnorm(10) )
# lm( y ~ . + .^2 , df )

# Builging the formula as character
n <- ncol(train_num_house)
( ivs <- names(train_num_house)[ 1: (n - 1) ] )
( dv <- names(train_num_house)[n] )
( iv_string <- paste(ivs, collapse = " + ") )
( reg_formula <- formula( paste(dv, iv_string, sep = " ~ " )) )

fit <- lm(formula = reg_formula, data = train_num_house)

# Converting the model to a tidy table
tab_fit <- tidy( fit )
tab_fit

# diagnostic plots
layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
plot(fit)

# Stepwise Regression
step <- stepAIC(fit, direction="both")
# step$anova # display results

tab_step <- tidy( step )
tab_step <- arrange(tab_step, desc( estimate ) )
tab_step$p.value.sig <- cut(tab_step$p.value, breaks=c(-Inf, 0.05, Inf), labels=c("sig","no_sig"))

qplot(data = filter(tab_step, estimate > 0), x = std.error, y = estimate, color = p.value.sig) +
  geom_text( aes(label=term) ) + ggtitle('Positive Influence') +
  theme_bw()
ggsave('pos_influ.svg')

qplot(data = filter(tab_step, estimate <= 0, term != '(Intercept)'), x = std.error, y = estimate, color = p.value.sig) +
  geom_text( aes(label=term) ) + ggtitle('Negative Influence') +
  theme_bw()
ggsave('neg_influ.svg')

summary(step)
train_num_house
val_num_houses

# Predicting the Price of the House
val2 <- val_num_houses
val2$pred_sale <- predict(step, newdata = val2)

View(tab_step)

n <- nrow(tab_step)
( important_cols <- c (tab_step[1:3 , ]$term,
                  tab_step[ (n-3):(n-1)  , ]$term,
                  'SalePrice',
                  'pred_sale') )

val3 <- arrange( val2[ import_cols], desc(SalePrice) )
View(val3)

# root_mean_squared_error
rmse <- function(predicted , observed){
  if( length(predicted) != length (observed) ){
    return( print('Error: Vectors of Different size') )
  }
  n <- length( predicted )
  RMSD <- sqrt ( sum( ( predicted - observed )^2 / n ) )
  return( RMSD )
}

rmse( predicted = val3$pred_sale, observed = val3$SalePrice )

# Probably the log is over e
rmse( predicted = log( val3$pred_sale ), observed = log( val3$SalePrice ) )
rmse( predicted = log10( val3$pred_sale ), observed = log10( val3$SalePrice ) )
rmse( predicted = log2( val3$pred_sale ), observed = log2( val3$SalePrice ) )













