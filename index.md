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

Let's start by loading the data and the libraries we around going to need for this session. 
