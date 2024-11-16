# CODE FOR TUTORIAL 
# Tutorial title: Interpreting linear models 
# Author: Ellie Bestington
# Contact: E.Bestington@sms.ed.ac.uk 


# Libraries----
library(tidyverse)
library(readr)
library(lme4)
library(DHARMa)
library(ggeffects)
library(stargazer)
library(ggpubr)

# LOAD DATA----
HummingBirds <- read_csv("Data/HummingBirds.csv")

# RESEARCH QUESTION----

# What are hummingbird numbers doing through time and across sites? 

# EXPLORE DATA----

# create plot of Count against Year with a panel for each site, points coloured by species
(PlotData <- ggplot(HummingBirds, aes(x = Year, y = Count, colour = Species)) +
   facet_wrap(~Site, nrow=2) +    
   geom_point(alpha = 0.5) +
   theme_classic())


# scale year to ensure starts at 1 -> EXPLAIN WHY 
YearScale<- HummingBirds$Year - min(HummingBirds$Year)

# INTERPRETING GLM MODEL - MODEL 1----

# build model 
mod1<- glm(Count~YearScale, data = HummingBirds, family = "poisson")
summary(mod1)

# exponential the results as use poisson 
exp(1.716395)  # how many hummingbirds at year 0
exp(0.012742)  # how much growth in hummingbirds per year 

# investigate confidence intervals (as better than standard error in table), can also plot these (see later)
ggpredict(mod1, terms = c("YearScale"))

# INTERPRETING GLM MODEL - MODEL 2----

# introduce site as another fixed effect 

# build model 
mod2<- glm(Count~ YearScale + Site, data = HummingBirds, family = "poisson")
summary(mod2)

ggpredict(mod2, terms = c("YearScale","Site"))

# where Arizona A gone? 
# exponentials again but explain extra thing do for other sites 
# explain how if we plotted this, each would have different intercept but would have slopes of same angle
# why? because assuming all sites going to exhbit same pattern of change

# orange box on what an interactive term is

# INTERPRETING GLM MODEL - MODEL 3----

# now let's add an interactive term to our model
mod3<- glm(Count~ YearScale*Site, data = HummingBirds, family = "poisson")
summary(mod3)

# lots of numbers but don't panic! Same principles as before apply
# but now we have the individual value for how each site's growth changes 
# as we have accounuted for fact that they will be different 

pred.mm<- ggpredict(mod3, terms = c("YearScale","Site"))

# INTERPRETING GLMER MODEL 

# add species as a random effect (as our question is looking at sites not species)
mod4<- glmer(Count~ YearScale*Site + (1|Species), data = HummingBirds, family = "poisson")
summary(mod4)

ggpredict(mod4, terms = c("YearScale", "Site", "Species"), type = "re")

FitData<- data.frame(ggpredict(mod4, terms = c("YearScale", "Site", "Species"), type = "re")) %>%
  rename(Site= group, Species= facet, YearScale= x, Count= predicted)

# PRESENTING RESULTS- Plots----

# what if we wanted to see how each species is doing in each site 

(PlotRibbons<- ggplot()+
  geom_ribbon(data = FitData, aes(x=YearScale, ymin = conf.low, 
                                  ymax = conf.high, 
                                  group = Species, 
                                  fill = Species), alpha= 0.2)+
  geom_point(data = HummingBirds, aes(x=YearScale, y=Count, 
                                      group = Species, 
                                      colour = Species))+
  geom_line(data = FitData, aes(x=YearScale, y=Count, group=Species, colour=Species))+
  facet_wrap(.~Site, scales = "free")+
  theme_classic()+
  theme(text = element_text(size = 8))
)



# what if we wanted to see how overall hummingbird numbers doing across each site 
names(pred.mm)[names(pred.mm) == 'group'] <- 'Site' # rename column name in pred.mm 

(Figure1<- ggplot(data = pred.mm, aes(x = x, y = predicted, fill = Site)) +
  facet_wrap(~Site)+
  geom_line() +  # plot the fitted line
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.3) +    # plot the confidence intervals
  geom_point(data = HummingBirds, aes(x = YearScale, y = Count, fill = Site),
             size = 2, shape = 21, alpha = 0.5)+  # plot the raw data
  labs(x = "Year",
       y = "Count",
       fill = "Site",
       caption = "The shaded region shows the 95% confidence interval.") +
  theme_pubr()+
  labs_pubr()+
  theme(legend.position = "right")
)
          
# PRESENTING RESULTS - Table----

stargazer(mod4, type = "text", 
          style = "default", 
          title = "How are hummingbirds doing?", 
          single.row = TRUE,
          covariate.labels = c("Year", "Arizona B", "Guatemala" "Intercept"))
