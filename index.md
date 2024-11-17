---
layout: tutorial 
title: Interpreting Linear Models 
banner: "../Figures & Images/banner_image.jpg"
date: 2024-11-17
author: Ellie Bestington
tags: modelling 
---

# Tutorial sections: ----

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

