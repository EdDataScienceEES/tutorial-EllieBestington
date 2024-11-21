## Adding another fixed effect 

For this next model we are going to add another fixed effect of `Site`. In other words, we care about `Site` as a variable in our model. We still have no random effects, so we remain using a `glm`. 

```
mod2<- glm(Count~ YearScale + Site, data = HummingBirds, family = "poisson")
summary(mod2)
```
And we should get this output: 

[[https://github.com/EdDataScienceEES/tutorial-EllieBestington/blob/master/Figures_Images/model_2_summary.png]]


