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
