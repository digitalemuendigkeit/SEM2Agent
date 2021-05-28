library(extrafont)
library(tidyverse)
library(arrow)

# Reports theme
theme_update(
  #text = element_text(size = 20),
  aspect.ratio = 0.5,
  #axis.title.x=element_text(size=9),
  axis.title.y=element_blank(),
  #legend.text = element_text(size=9),
  #legend.title = element_text(size = 9),
  legend.position = "bottom",
  legend.box = "vertical",
  legend.key = element_blank(),
  plot.title = element_text(hjust = 0),
  panel.background = element_blank(),
  axis.line.x = element_line(colour = "black"),
  panel.grid.major.y = element_line(colour = "#DDDDDD"),
  axis.ticks.y = element_blank(),
  panel.grid.major.x = element_line(colour = "#DDDDDD"),
  axis.ticks.x = element_line(colour = "black")
  #axis.text = element_text(size = 9)
  )



farmerplot <- function(df) {
ggplot(df, aes(x=step)) + 
  geom_line(aes(y = wateravailability, colour = "#0077BB"), size = 1.5, linetype = "dotted") +
  geom_line(aes(y = ppexperience_mean, color = "#EE3377"), size = 1.5) +
  geom_ribbon(aes(ymin = ppexperiencelower, ymax = ppexperienceupper, fill = "#EE3377"), alpha = 0.15) +
  geom_line(aes(y = ccexperience_mean, color = "#EE7733"), size = 1.5) +
  geom_ribbon(aes(ymin = ccexperiencelower, ymax = ccexperienceupper, fill = "#EE7733"), alpha = 0.15) +
  geom_line(aes(y = participation_mean, color = "#009988"), size = 1.5) +
  ylim(-1,1) +
  xlab("Steps") +
  scale_color_identity(guide = "legend",
                       name = "",
                       labels = c("Water availability", "Policy experience mean", "Climate change experience mean", "Participating fraction mean"),
                       breaks =  c("#0077BB", "#EE3377", "#EE7733", "#009988")
                       ) +
  scale_fill_identity(guide = "legend",
                       name = "",
                       labels = c("Policy experience 2. & 3. quartile", "Climate change experience 2. & 3. quartile"),
                       breaks =  c("#EE3377", "#EE7733")
                        ) +
  scale_x_continuous(breaks=seq(0, 10, 1)) 
}

employeeplot <- function(df) {
  ggplot(df, aes(x=step)) + 
    geom_line(aes(y = EmployeeNiceness_mean, colour = "#0077BB"), size = 1.5) +
    geom_line(aes(y = Stress_mean, color = "#CC3311"), size = 1.5) +
    geom_ribbon(aes(ymin = Stresslower, ymax = Stressupper, fill = "#CC3311"), alpha = 0.15) +
    geom_line(aes(y = EmployeeMotivation_mean, color = "#33BBEE"), size = 1.5) +
    geom_ribbon(aes(ymin = EmployeeMotivationlower, ymax = EmployeeMotivationupper, fill = "#33BBEE"), alpha = 0.15) +
    geom_line(aes(y = Success_mean, color = "#009988"), size = 1.5, linetype = "longdash") +
    ylim(-1,1) +
    xlab("Steps") +
    scale_color_identity(guide = "legend",
                         name = "",
                         labels = c("Fraction nice employees mean", "Stress mean", "Motivation mean", "Company success mean"),
                         breaks =  c("#0077BB", "#CC3311", "#33BBEE", "#009988")
    ) +
    scale_fill_identity(guide = "legend",
                        name = "",
                        labels = c("Stress 2. & 3. quartile", "Motivation 2. & 3. quartile"),
                        breaks =  c("#CC3311", "#33BBEE")
    )
}


# One time only
# modify plot fn
employeeplot2 <- function(df) {
ggplot(df, aes(x=step)) + 
  geom_line(aes(y = EmployeeNiceness_mean, colour = "#0077BB"), size = 1.5) +
  geom_line(aes(y = Stress_mean, color = "#CC3311"), size = 1.5) +
  geom_ribbon(aes(ymin = Stresslower, ymax = Stressupper, fill = "#CC3311"), alpha = 0.15) +
  geom_line(aes(y = EmployeeMotivation_mean, color = "#33BBEE"), size = 1.5) +
  geom_ribbon(aes(ymin = EmployeeMotivationlower, ymax = EmployeeMotivationupper, fill = "#33BBEE"), alpha = 0.15) +
  geom_line(aes(y = Success_mean, color = "#009988"), size = 1.5, linetype = "longdash") +
  ylim(-1,1) +
  xlab("Steps") +
  scale_color_identity(guide = "legend",
                       name = "",
                       labels = c("Fraction nice\nemployees mean", "Stress mean", "Motivation mean", "Company\nsuccess mean"),
                       breaks =  c("#0077BB", "#CC3311", "#33BBEE", "#009988")
  ) +
  scale_fill_identity(guide = "legend",
                      name = "",
                      labels = c("Stress 2. & 3. quartile", "Motivation 2. & 3. quartile"),
                      breaks =  c("#CC3311", "#33BBEE")
  )
}
farmerplot2 <- function(df) {
  ggplot(df, aes(x=step)) + 
    geom_line(aes(y = wateravailability, colour = "#0077BB"), size = 1.5, linetype = "dotted") +
    geom_line(aes(y = ppexperience_mean, color = "#EE3377"), size = 1.5) +
    geom_ribbon(aes(ymin = ppexperiencelower, ymax = ppexperienceupper, fill = "#EE3377"), alpha = 0.15) +
    geom_line(aes(y = ccexperience_mean, color = "#EE7733"), size = 1.5) +
    geom_ribbon(aes(ymin = ccexperiencelower, ymax = ccexperienceupper, fill = "#EE7733"), alpha = 0.15) +
    geom_line(aes(y = participation_mean, color = "#009988"), size = 1.5) +
    ylim(-1,1) +
    xlab("Steps") +
    scale_color_identity(guide = "legend",
                         name = "",
                         labels = c("Water\navailability", "Policy\nexperience mean", "Climate change\nexperience mean", "Participating\nfraction mean"),
                         breaks =  c("#0077BB", "#EE3377", "#EE7733", "#009988")
    ) +
    scale_fill_identity(guide = "legend",
                        name = "",
                        labels = c("Policy experience\n2. & 3. quartile", "Climate change experience\n2. & 3. quartile"),
                        breaks =  c("#EE3377", "#EE7733")
    ) +
    scale_x_continuous(breaks=seq(0, 10, 1)) 
}
# set theme
theme_update(
  text = element_text(size = 9, family = "CMU Sans Serif"),
  axis.title.x=element_text(size=9),
  axis.title.y=element_blank(),
  legend.text = element_text(size=9),
  legend.title = element_blank(),
  legend.position = "bottom",
  legend.box = "vertical",
  legend.key = element_blank(),
  plot.title = element_text(hjust = 0.5),
  panel.background = element_blank(),
  axis.line.x = element_line(colour = "black"),
  panel.grid.major.y = element_line(colour = "#DDDDDD"),
  axis.ticks.y = element_blank(),
  panel.grid.major.x = element_line(colour = "#DDDDDD"),
  axis.ticks.x = element_line(colour = "black"),
  axis.text = element_text(size = 8))

# Employee plot
empplot <- read_feather(here::here("ModelEmployeesSatMot", "data-output", "experiment-9_summary.arrow")) %>%
  as.data.frame() %>% employeeplot2() +
  ggtitle("9. Employee motivation: High stress reduction,\nhigh stress, low success and niceness\n")
ggsave(here::here("reports", "figures", "Plot_Employee-Motivation.pdf"), empplot, device = cairo_pdf, 
       width = 122, height = 90, units = "mm")

# Farmer plot
farplot <- read_feather(here::here("model_yolo-farming", "data-output", "experiment-1_summary.arrow")) %>%
  as.data.frame() %>% farmerplot2() +
  ggtitle("1. Program participation: Default parameters\n")
ggsave(here::here("reports", "figures", "Plot_Yolo-farming.pdf"), farplot, device = cairo_pdf, 
       width = 122, height = 90, units = "mm")
