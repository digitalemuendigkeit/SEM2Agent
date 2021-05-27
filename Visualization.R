library(extrafont)
# extrafont::font_import("Fonts", pattern = "cmunss.ttf")
# extrafont::loadfonts(device="win")
# extrafont::loadfonts(device = "pdf")
library(tidyverse)
library(arrow)

# set theme
theme_update(text = element_text(size = 12, family = "CMU Sans Serif"),
             aspect.ratio = 0.5,
             axis.title.x=element_blank(),
             axis.title.y=element_blank(),
             legend.text = element_text(size=9),
             legend.title = element_text(size = 9),
             legend.key = element_blank(),
             plot.title = element_text(hjust = 0.5),
             panel.background = element_blank(),
             axis.line.x = element_line(colour = "black"),
             panel.grid.major.y = element_line(colour = "#DDDDDD"),
             axis.ticks.y = element_blank(),
             panel.grid.major.x = element_line(colour = "#DDDDDD"),
             axis.ticks.x = element_line(colour = "black"),
             axis.text = element_text(size = 9))

# Read data
testdf <- read_feather(here::here("ModelEmployeesSatMot", "data-output", "experiment-1_summary.arrow")) %>%
  as.data.frame()

testplot <- ggplot(testdf, aes(x=step)) + 
  geom_line(aes(y = EmployeeNiceness_mean), colour = "#0077BB", size = 1.5) +
  geom_line(aes(y = Stress_mean), colour = "#CC3311", size = 1.5) +
  geom_ribbon(aes(ymin = Stresslower, ymax = Stressupper), fill = "#CC3311", alpha = 0.15) +
  geom_line(aes(y = EmployeeMotivation_mean), colour = "#33BBEE", size = 1.5) +
  geom_ribbon(aes(ymin = EmployeeMotivationlower, ymax = EmployeeMotivationupper), fill = "#33BBEE", alpha = 0.15) +
  geom_line(aes(y = Success_mean), colour = "#009988", size = 1.5) +
  ylim(-1,1) +
  ggtitle("1. Employee motivation: Low stress reduction, neutral stress and success") +
  scale_color_identity(guide = "legend", 
                       labels = c("Fraction nice employees mean", "Stress mean", "Motivation mean", "Company success mean"),
                       breaks =  c("#0077BB", "#CC3311", "#33BBEE", "#009988"))
