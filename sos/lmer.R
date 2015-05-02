sink("diagnostics/lmer.txt")

library(lme4)
library(nortest)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname="boxing")

query <- dbSendQuery(con, "
select
boxer_id as boxer,
opponent_id as opponent,
(case when outcome = 'W' then 1
      when outcome = 'L' then 0
      when outcome = 'D' then 0.5
end) as outcome
from boxrec.fights
where
    boxer_id is not null
and opponent_id is not null
and outcome in ('W','L','D')
--and (boxer_division='Welterweight' or fight_division='welterweight')

union all

select
opponent_id as boxer,
boxer_id as opponent,
(case when outcome = 'W' then 0
      when outcome = 'L' then 1
      when outcome = 'D' then 0.5
end) as outcome
from boxrec.fights

where
    boxer_id is not null
and opponent_id is not null
and outcome in ('W','L','D')
--and (boxer_division='Welterweight' or fight_division='welterweight')

;")

fights <- fetch(query,n=-1)

dim(fights)

attach(fights)

pll <- list()

boxer <- as.factor(boxer)
opponent <- as.factor(opponent)

rp <- data.frame(boxer,opponent)
rpn <- names(rp)

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("boxrec","_parameter_levels"),parameter_levels,row.names=TRUE)

f <- cbind(rp)

model <- outcome ~ -1+(1|boxer)+(1|opponent)
fit <- glmer(model, data=f, REML=FALSE, family=binomial(logit), verbose=TRUE)

fit
summary(fit)

#anova(fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r) 

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("boxrec","_basic_factors"),as.data.frame(combined),row.names=TRUE)

f <- fitted(fit) 
r <- residuals(fit)

# Jackknife - 4500 data points 1000 times

subs=4500
iter=1000

# Vector of results

pvals=rep(NA, iter)

# Sample p-values

for(i in 1:iter){
samp=sample(1:length(r),4500)
p.i=sf.test(r[samp])$p.value
pvals[i]=p.i
}

# Sampled p-value statistics

mean(pvals)
median(pvals)
sd(pvals)

# Graph p-values

jpeg("diagnostics/shapiro-francia.jpg")
hist(pvals,xlim=c(0,1))
abline(v=0.05,lty='dashed',lwd=2,col='red')
quantile(pvals,prob=seq(0,1,0.05))

# Examine residuals

jpeg("diagnostics/fitted_vs_residuals.jpg")
plot(f,r)
jpeg("diagnostics/q-q_plot.jpg")
qqnorm(r,main="Q-Q plot for residuals")

quit("no")
