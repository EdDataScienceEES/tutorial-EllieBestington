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
  * [Model 3- Adding an interactive term](#mod3)
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

To attempt this tutorial, it is recommended for learner who have some beginner experience in R and have a knowledge of building linear models in lmer, glm and glmer. If you have no idea what those cryptic words mean, then check out [this tutorial](https://ourcodingclub.github.io/tutorials/mixed-models/). 

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

Our intercept row simply states where the line will cross the y-axis. The Year row simply states the value in which y increases each year (or in otherwords, the gradient of the line). So, in our model above it would appear that our line crosses at x and increases by y per year. Or if we put it into the context of our data, in year 0 we have 1.71 hummingbirds and the population increases by 0.012 each year. 

However, like most things in ecology, it isn't that straightforward! 

__We need to take the exponential of these numbers__. Why? Well, it's because we have a poisson distribution. For the human brain we like straight lines, and in order to keep the graph have a straight line of best fit (instead of curved exponential), when R builds the model, it had to take a log of each count value. So when we interpret the output, we need to reverse what R did in the background and take an exponential of the values in the table. Luckily R has a lovely line of code to do this for us: 

```
exp(1.716395)  # how many hummingbirds at year 0
exp(0.012742)  # how much growth in hummingbirds per year
```
You should get 5.56 and 1.012 respectively. 

Now, one final step (I promise!). The value of the growth per year isn't our final number. We're going to take it back to some high school maths and the topic of percentage change. For example, if you had a change of 1.5, our percentage change would be 50% (as if we multiplied our orginal value by 1.5, it would increase by 50%). If we had a change of 1, our percentage change would be 0% (as we multiply our original value by 1 which would keep it the same). If we had a change of 0.5, our percentage change would be -50%. Get it? 

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




