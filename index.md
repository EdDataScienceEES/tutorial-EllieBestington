---
layout: tutorial 
title: Interpreting Linear Models 
banner: "../Figures & Images/banner_image.jpg"
date: 2024-11-17
author: Ellie Bestington
tags: modelling 
---

## Tutorial Aims

#### <a href="#section1"> 1. To interpret the glm and glmer summary.</a>

#### <a href="#section2"> 2. To understand the use of an interactive term.</a>

#### <a href="#section3"> 3. To explore the different methods of looking at confidence in our results.</a>

#### <a href="#section4"> 4. To present our results in a plot and table.</a>


## Tutorial sections

1. [Introduction](#intro)
2. [Load libraries and data](#load)
3. [Explore the data](#explore)
4. [Interpreting glm models](#interpreting)
  * [Model 1- no groups](#mod1)
  * [Model 2- Adding another fixed effect](#mod2)
  * [Model 3- Adding an interaction term](#mod3)
5. [Interpreting glmer models](#glmer)
6. [Confidence in our results](#conf)
7. [Presenting our results](#pres)
	  

{% capture callout %}
To get all you need for this session, __go to [the repository for this tutorial](https://github.com/EdDataScienceEES/tutorial-EllieBestington/tree/master), click on `Clone/Download/Download ZIP` to download the files and then unzip the folder. Alternatively, fork the repository to your own Github account, clone the repository on your computer and start a version-controlled project in RStudio. For more details on how to do this, please check out our [Intro to Github for Version Control tutorial]({{ site.baseurl }}/tutorials/git/index.html).__ 
{% endcapture %}
{% include callout.html content=callout colour=alert %}

# Introduction 
{: #intro}

In the previous tutorial, we looked at what linear models are, how to build them and then produced a rather busy summary table with lots of numbers. Pretty overwhelming! In this tutorial we will look at what those numbers actually mean and what this means for our investigation. 

This is useful stuff to know, especially when looking at count data and we want to see by how much a species abundance is changing over time. 

To attempt this tutorial, it is recommended for learners who have some beginner experience in R and have a knowledge of building linear models in lmer, glm and glmer. If you have no idea what those cryptic words mean, then check out [this tutorial](https://ourcodingclub.github.io/tutorials/mixed-models/). 

Up to speed? Now let's begin!!

# Load libraries and data we need
{: #load}

We are going to focus on some data about Hummingbird abundances in countries across North America. The data is taken from the Christmas Bird Count which is a volunteer led survey and has been going on for over 100 years! The data is publically available (you just need to register for free) so if you are interested then [click here](https://www.audubon.org/community-science/christmas-bird-count) to find out more. 

Let's start by loading the data and the libraries we around going to need for this session. Open a new script in R Studio and write down a header, author name, contact details and date (this is just good practise when working on any script). 

Remember, if you don't already have any of these packages downloaded onto your device, ensure to `install.packages("PACKAGE NAME")`

```
# CODE FOR TUTORIAL 
# Interpreting linear models 
# Author: Ellie Bestington
# Contact: E.Bestington@sms.ed.ac.uk
# Date: 17/11/2024


# Libraries----
library(tidyverse) # includes packages such as dyplr and ggplot for data wrangling and visualisation
library(readr) # allows us to load our data 
library(lme4)  # package containing glm, glmer models
library(DHARMa) # useful for analysis of our linear models 
library(ggeffects)  # models predictions 
library(stargazer) # generate table of results 
library(ggpubr) # cool theme to play with- makes plot theme as 'published'

# LOAD DATA
HummingBirds <- read_csv("Data/HummingBirds.csv")  # if you cloned the repo use this, if not then remember to change the filepath
```

# Explore the data
{: #explore}

Now we've loaded the data into our environment, we can look at the basic structure of the dataframe to get some idea of the different variables it contains. 

```
head(HummingBirds) # produces first few rows of dataframe
length(unique(HummingBirds$Species))  # number of species in dataset
length(unique(HummingBirds$Site)) # number of sites in dataset

```
From this we can see we have 5 species measured for their abundance across 6 sites. This can help us shape the research question we want to ask. In this tutorial, we will answer the question of: __What are Hummingbird numbers doing through time and across sites?__

Now let's create a plot to visualise our data. If you are unfamiliar with `ggplot` package, head to [this tutorial](https://ourcodingclub.github.io/tutorials/datavis/).

```
(PlotData <- ggplot(HummingBirds, aes(x = Year, y = Count, colour = Species)) +
   facet_wrap(~Site, nrow=2) +    
   geom_point(alpha = 0.5) +
   theme_classic())
```

And you should get something like this. 
![plotdata general](https://github.com/user-attachments/assets/5a2e1b10-2c48-400d-9aca-8d13493aa0ad)

As you can see, there's lots of variation in abundance of each species in each site. Some are more abundant than others! 

Now, I've already ran the numbers to identify that this dataset violates the assumptions of a linear model, and our data in fact has a poisson distribution. But if you want to have a go and practise yourself then by all means! If you've forgot how to do this, head back to the [previous tutorial](https://ourcodingclub.github.io/tutorials/mixed-models/). 

# Interpreting GLM models 
{: #interpreting}

Great, now that we have a better understanding of what we are working with and the research question we are wanting to answer, let's start building some models. 

## No groups 
{: #mod1}

For this first model we are going to keep it basic, just so we can break the summary table down a bit easier for you to understand.

First we are going to change the scale of our `Year` variable. This is so our year starts at 1. We do this by creating an object called `YearScale`. 
```
YearScale<- HummingBirds$Year - min(HummingBirds$Year)
```
Awesome, now let's create a model that simply investigates `Count~YearScale`, no groups. Then run a `summary()`. 

```
mod1<- glm(Count~YearScale, data= HummingBirds, family= "poisson")
summary(mod1)
```
And you should get an output like this: 

<img width="464" alt="Model_1_summary" src="https://github.com/user-attachments/assets/cdcf4fc1-6afa-460d-926e-41309c79b3bf">

We are mainly focusing on the coefficients table and specifically the 'estimate' column. Let's break it down. 

Our intercept row simply states where the line will cross the y-axis. The Year row simply states the value in which y increases each year (or in otherwords, the gradient of the line). So, in our model above it would appear that our line crosses at 1.71 and increases by 0.012 per year. Or if we put it into the context of our data, in year 0 we have 1.71 hummingbirds and the population increases by 0.012 each year. 

However, like most things in ecology, it isn't that straightforward! 

__We need to take the exponential of these numbers__. Why? Well, it's because we have a poisson distribution. For the human brain we like straight lines, and in order to keep the graph having a straight line of best fit (instead of curved exponential), when R builds the model, it had to take a log of each count value. So when we interpret the output, we need to reverse what R did in the background and take an exponential of the values in the table. Luckily R has a lovely line of code to do this for us: 

```
exp(1.716395)  # how many hummingbirds at year 0
exp(0.012742)  # how much growth in hummingbirds per year
```
You should get 5.56 and 1.012 respectively. 

Now, one final step (I promise!). The value of the growth per year isn't our final number. We're going to take it back to some high school maths and the topic of percentage change. For example, if you had a change of 1.5, our percentage change would be 50% (as if we multiplied our orginal value by 1.5, it would increase by 50%). If we had a change of 1, our percentage change would be 0% (as we multiply our original value by 1 which would keep it the same). If we had a change of 0.5, our percentage change would be -50%. Put another way, multiply the value by 100, then subtract from 100 to get your % increase or decrease. 

So for our output, it means out percentage change is __+1.2%__ (as if we take our original value and mulitply it by 1.012, it would increase by 1.2%).

If we plot the all the data, ignoring species and site, this is what we get. Looks like our line would interceot at 5.56 and increases by 1.2% per year. 

![all data plot](https://github.com/user-attachments/assets/d20f6f80-1284-4a31-87f1-989c040917a6)


Phew, that was a lot. Take a break and make sure you understand the above as next we will add a bit more complexity. 

## Adding another fixed effect 
{: #mod2}

For this next model we are going to add another fixed effect of `Site`. In other words, we care about `Site` as a variable in our model. We still have no random effects, so we remain using a `glm`. 

```
mod2<- glm(Count~ YearScale + Site, data = HummingBirds, family = "poisson")
summary(mod2)
```
And we should get this output: 

<img width="505" alt="model_2_summary" src="https://github.com/user-attachments/assets/4525aaed-5f8b-4173-8f13-633150364b31">

Hang on a minute! What are those extra rows? Because we've introduced another effect (`Site`), we can now look at the change in growth of hummingbirds at each site! Yipee!

But wait? Where is the Arizona A site? Don't panic, it's just hiding in the intercept. The intercept and YearScale rows represent the values for Arizona A. For this site, we do the exact same thing as before. Take the exponentials and for the YearScale, make as a percentage change (follow the steps again above). 

For the other sites, we do something a little different. We have Arizona B's estimate of -0.578, but this is __relative__ to Arizona A. Because of this we need to __add__ the two estimates together, then take the exponential of that. 

<img width="515" alt="model 2_edits" src="https://github.com/user-attachments/assets/99a097b6-cc0d-43f4-8575-9459cd8fa9de">

```
exp(1.463403 + -0.578096)  # how many hummingbirds at year  0 in Arizona B
```
This gives us 2.42 intercept for Arizona B. 

We then repeat this method for each site! But what about how much each site grows per year? Well, because we have only accounted for site as a fixed effect, the growth is the same for each site. To visualise that, think of it as the line of best fit for each site intercept the y axis at different points but all have the same gradient. Because we have just added `site` as a fixed effect, we assume all sites exhibit the same growth. 

But what if we expect each site to exhibit different growth? 

{% capture callout %}
## Interaction Terms

If we expect each group to experience different levels of growth in our model, we can introduce an interaction term. To do this we simply replace the `+` before our grouping variable with `*`. Let's do an example below. 

{% endcapture %}
{% include callout.html content=callout colour="important" %}

## Adding an interaction term 
{: #mod3} 

Now let's assume we expect our sites to exhibit different rates of growth over time by introducing an interaction term to our model. How does this change the model output? 
```
mod3<- glm(Count~ YearScale*Site, data = HummingBirds, family = "poisson")
summary(mod3)
```
And we should get this output: 

<img width="497" alt="model_3_summary" src="https://github.com/user-attachments/assets/9e4b4401-7399-440e-8673-20c6211a0d90">

Wow! A lot more numbers! But let's break it down. We already know what the first 2 rows show (the intercept and growth for Arizona A), the next 5 rows starting with `Site` show the intercept for each site and the new additions simply represent the growth per year for each site stated.

And guess what? We interpret it the exact same way as above. Let's do an example for Mexico B. 

1. Add estimate value for `SiteMexicoB` to `Intercept` and take an exponential 
```
exp(-2.552914 + 5.078519)
```
2. Repeat for `YearScale:SiteMexicoB` with `YearScale`
```
exp(0.111682 +  -0.117649)
```
3. Calculate % change
Given output for change in abundance of hummingbirds in Mexico B is  0.994. This means population is decreasing by 0.6% (remember, multiply by 100, then subtract from 100).

4. Overall result...
For Mexico B site, the population of hummingbirds starts at 12.5 and decreases by 0.6% per year.

We would then repeat this for each site! Try it yourself by calculating the intercept value and % change per year for the other sites. 

## Interpreting GLMER models
{: #glmer}

Okay, now that we feel confident with glm models and interpreting fixed effects, let's look at introducing the random effect of `species`. In other words, we do not care about the growth over time of each species group, but we still want the model to account for that. Ypu may get a warning message, but don't worry about that for now. 

```
mod4<- glmer(Count~ YearScale*Site + (1|Species), data = HummingBirds, family = "poisson")
summary(mod4)
```
And we should get this output: 

<img width="432" alt="model_4_summary" src="https://github.com/user-attachments/assets/ffebd233-a643-4ceb-a93b-3efa17438265">

Now, this is only a snapshot of a long output that we receive. But, we only want to focus again on the fixed effects table of the output. 

Luckily for you, the interpretation is exactly like Model 3. Give it a go and answer these questions. I've provided the answers, let's see if you get the same as me! 

__1. How many hummingbirds are in Arizona A at year 0?__ Answer: 0.042

__2. What is the growth per year in hummingbirds for Arizona A?__ Answer: +1.12%

__3. How many hummingbirds are in Mexico C at year 0?__ Answer: 22.4

__4. What is the growth per year in hummingbirds for Mexico C?__ Answer: +4.81%

If you're interested in what the rest of the output means, follow [this link](https://www.simonqueenborough.info/R/statistics/lessons/Mixed_Effects_Models.html) to a handy website that gives you the low down. 


## Confidence in our results 
{: #conf}

Perfect, so now that we know how to interpret our model output, it is important to be able to state how confident we are in these results. There are two main ways we can do this. 

### 1. Standard error 

In the fixed effects table of the model output, there is a column of `St. Error`. In general terms, the smaller the value, the better. The standard error indicates how much the estimated value varies from the true value. 

However, it is not the best method. The main reason is because it is only reliable in large datasets, as it is based on large sample approximations. 

So instead we use...

### 2. Confidence intervals

The 95% confidence intervals is a much better method. This is usually what you see on a plot with ribbons- that ribbon is the 95% confidence i.e. the range of values that is likely to contain the true value. It can be more visually appealing to interpret, as a closer range of values indicates you estimated value is more likely to be the true value. 

Luckily for you, R has a package called `ggpredict()`, that allows us to calculate the confidence interval. Let's try it below for our models. 

```
ggpredict(mod1, terms = c("YearScale")) # Model 1

ggpredict(mod2, terms = c("YearScale","Site")) # Model 2

ggpredict(mod3, terms = c("YearScale","Site")) # Model 3

ggpredict(mod4, terms = c("YearScale", "Site", "Species"), type = "re") # Model 4
```
Note how for models 2 and 3 you get the confidence interval table for each site and for model 4, you get it for each species within each site. Pretty cool! Now let's have a look at visualising and presenting these results. 

## Presenting your results 
{: #pres}

Now that we have our results, let's think about how we can present them in two ways: plot and table. 

### Plot 

There are many ways to present your results as a plot and it all depends on your research questions and what you're wanting to show. I'm going to provide a few example here but if you need to brush up on your `ggplot` then head to [this tutorial](https://ourcodingclub.github.io/tutorials/datavis/) on data visualisation. 

Say we wanted to see how overall hummingbird numbers are doing across each site. This is how we would do it. 

First we need to assign our `ggpredict()` for model 4 to an object. Let's call it `pred.mm`. 
```
pred.mm<- ggpredict(mod4, terms = c("YearScale", "Site", "Species"), type = "re")
```
If you view `pred.mm` you will see the column of sites is named `group`. Let's change that to `Site`. 
```
names(pred.mm)[names(pred.mm) == 'group'] <- 'Site' # rename column name in pred.mm
```

Perfect. Now we can plot our results. 
```
(Figure1<- ggplot(data = pred.mm, aes(x = x, y = predicted, fill = Site)) +
  facet_wrap(~Site)+  # creates plot for each site
  geom_line() +  # plot the fitted line
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.3) +    # plot the confidence intervals
  geom_point(data = HummingBirds, aes(x = YearScale, y = Count, fill = Site),
             size = 2, shape = 21, alpha = 0.5)+  # plot the raw data
  labs(x = "Year",
       y = "Count",
       fill = "Site",
       caption = "The shaded region shows the 95% confidence interval.") +
  theme_pubr()+  # change theme of plot to published
  labs_pubr()+
  theme(legend.position = "right")
)
```

And you should get this figure: 
![Figure_1](https://github.com/user-attachments/assets/bd9d3860-8487-4b14-b1e6-0a0402324923)

Looking good! Now let's say we want to know how each species is doing in each site over time. Run the following: 

```
pred.mm<- ggpredict(mod4, terms = c("YearScale", "Site", "Species"), type = "re")

FitData<- data.frame(ggpredict(mod4, terms = c("YearScale", "Site", "Species"), type = "re")) %>%
  rename(Site= group, Species= facet, YearScale= x, Count= predicted)  # renaming each column to fit to our dataset
```

And plot the figure: 
```
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
```
And you should get this figure: 
![Figure 2](https://github.com/user-attachments/assets/96d77d00-e10f-4a2f-82da-d66da7f7122c)

Quite a lot going on, but it means we can see the confidence intervals for each species across each site! Pretty cool!

### Table of results

To present your results as a table, we need to use the `stargazer` package. Run the following code. 

```
stargazer(mod4, type = "text", 
          style = "default", 
          title = "How are hummingbirds doing?", 
          single.row = TRUE,
          covariate.labels = c("Year", "Arizona B", "Guatemala", "Mexico A", 
          "Mexico B", "Mexico C", "YearScale:Arizona B", "YearScale:Guatamala", 
          "YearScale:Mexico A", "YearScale:Mexico B", "YearScale:Mexico C", "Intercept"))
```
And you should get this output: 

<img width="322" alt="table_output" src="https://github.com/user-attachments/assets/52329f2d-a6a0-40c7-93cf-7c013d0f4329">


And it will produce a table of results in your console! The `covariate.labels` function is simply renaming the row names. In the output, you can see we have the orginal fixed effect output. 

If you wanted to upload this table to a markdown file, like that on GitHub, simply change the `type= "text"` to `type="html"`. Then copy the output from the console to a GitHub markdown file and it should look something like this: 

<table style="text-align:center"><caption><strong>How are hummingbirds doing?</strong></caption>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="1" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td>Count</td></tr>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Year</td><td>0.111<sup>***</sup> (0.007)</td></tr>
<tr><td style="text-align:left">Arizona B</td><td>4.786<sup>***</sup> (0.422)</td></tr>
<tr><td style="text-align:left">Guatemala</td><td>8.943<sup>***</sup> (0.667)</td></tr>
<tr><td style="text-align:left">Mexico A</td><td>-9.184<sup>**</sup> (3.938)</td></tr>
<tr><td style="text-align:left">Mexico B</td><td>5.254<sup>***</sup> (0.331)</td></tr>
<tr><td style="text-align:left">Mexico C</td><td>6.269<sup>***</sup> (1.192)</td></tr>
<tr><td style="text-align:left">YearScale:Arizona B</td><td>-0.116<sup>***</sup> (0.010)</td></tr>
<tr><td style="text-align:left">YearScale:Guatamala</td><td>-0.163<sup>***</sup> (0.015)</td></tr>
<tr><td style="text-align:left">YearScale:Mexico A</td><td>0.164<sup>*</sup> (0.084)</td></tr>
<tr><td style="text-align:left">YearScale:Mexico B</td><td>-0.116<sup>***</sup> (0.008)</td></tr>
<tr><td style="text-align:left">YearScale:Mexico C</td><td>-0.160<sup>***</sup> (0.028)</td></tr>
<tr><td style="text-align:left">Intercept</td><td>-3.161<sup>***</sup> (0.450)</td></tr>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>269</td></tr>
<tr><td style="text-align:left">Log Likelihood</td><td>-1,497.745</td></tr>
<tr><td style="text-align:left">Akaike Inf. Crit.</td><td>3,021.489</td></tr>
<tr><td style="text-align:left">Bayesian Inf. Crit.</td><td>3,068.221</td></tr>
<tr><td colspan="2" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
</table>


And there you go! You can now interpret your `glm` and `glmer` model output and beautifully present your results! 
