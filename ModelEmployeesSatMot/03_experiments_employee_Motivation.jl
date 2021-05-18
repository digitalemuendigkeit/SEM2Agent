using Agents
using Plots
using Statistics
using Arrow

include("02_abm_yolo-farming-social.jl")

# Experiment 1
# For the first experiment, we use the default conditions.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model1 = initialize()
# collect data
adata, _ = run!(model1, agent_step!, model_step!, agents_first=false, 10,
adata = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention,
:participation])
# create summary data
summarydata1 = combine(groupby(adata, "step"), :ccexperience => mean,
:ppexperience => mean, :ccbelief => mean, :ccrisk => mean, :ppintention
=> mean, :participation => mean)
# append water availability data
summarydata1.wateravailability = wateravailability.wateravailability[model1.stepcounter-nrow(summarydata1)+1:model1.stepcounter]
summarydata1.year = wateravailability.Year[model1.stepcounter-nrow(summarydata1)+1:model1.stepcounter]
# reorder summary data
summarydata1 = summarydata1[!,[1,9,8,2,3,4,5,6,7]]
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
# define x axis
plotx = summarydata1.year
# define y axis
plot1y = Matrix(summarydata1[:,[3,4,5,9]])
plotlabels = ["Water availability" "CC experience" "Policy experience" "Program participation"]
plot(plotx, plot1y, label = plotlabels, legend = :bottomleft)

# Experiment 2
# For the second experiment, we set the social threshold to 1.
# This means that all neighbors have to participate for an agent to be
# influenced socially to participate.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model2 = initialize(; socialthreshold = 1)
# collect data
adata, _ = run!(model2, agent_step!, model_step!, agents_first=false, 10,
adata = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention ,
:participation])
# create summary data
summarydata2 = combine(groupby(adata, "step"), :ccexperience => mean,
:ppexperience => mean, :ccbelief => mean, :ccrisk => mean, :ppintention
=> mean, :participation => mean)
# append water availability data
summarydata2.wateravailability = wateravailability.wateravailability[model2.stepcounter-nrow(summarydata1)+1:model2.stepcounter]
summarydata2.year = wateravailability.Year[model2.stepcounter-nrow(summarydata1)+1:model2.stepcounter]
# reorder summary data
summarydata2 = summarydata2[!,[1,9,8,2,3,4,5,6,7]]
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-2_summary.arrow", summarydata1)
# plot data
# define y axis
plot2y = Matrix(summarydata2[:,[3,4,5,6,7,9]])
plotlabels = ["Water availability" "CC experience" "Policy experience" "CC belief" "Perceived CC risk" "Program participation"]
plot(plotx, plot2y, label = plotlabels, legend = :bottomleft)

# Experiment 3
# For the third experiment, we set the initial number of program participants
# to 0.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model3 = initialize(; participatefract = 0, startyear = 2003)
# collect data
adata, _ = run!(model3, agent_step!, model_step!, agents_first=false, 17,
adata = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention ,
:participation])
# create summary data
summarydata3 = combine(groupby(adata, "step"), :ccexperience => mean,
:ppexperience => mean, :ccbelief => mean, :ccrisk => mean, :ppintention
=> mean, :participation => mean)
# append water availability data
summarydata3.wateravailability = wateravailability.wateravailability[model3.stepcounter-nrow(summarydata3)+1:model3.stepcounter]
summarydata3.year = wateravailability.Year[model3.stepcounter-nrow(summarydata3)+1:model3.stepcounter]
# reorder summary data
summarydata3 = summarydata3[!,[1,9,8,2,3,4,5,6,7]]
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-3_summary.arrow", summarydata1)
# plot data
# define x axis
plotx = summarydata3.year
# define y axis
plot3y = Matrix(summarydata3[:,[3,4,5,6,7,9]])
plotlabels = ["Water availability" "CC experience" "Policy experience" "CC belief" "Perceived CC risk" "Program participation"]
plot(plotx, plot3y, label = plotlabels, legend = :bottomleft)

# Experiment 4
# For the third experiment, we set the program quality to -1.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model4 = initialize(; programquality = -1)
# collect data
adata, _ = run!(model4, agent_step!, model_step!, agents_first=false, 10,
adata = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention ,
:participation])
# create summary data
summarydata4 = combine(groupby(adata, "step"), :ccexperience => mean,
:ppexperience => mean, :ccbelief => mean, :ccrisk => mean, :ppintention
=> mean, :participation => mean)
# append water availability data
summarydata4.wateravailability = wateravailability.wateravailability[model4.stepcounter-nrow(summarydata4)+1:model4.stepcounter]
summarydata4.year = wateravailability.Year[model4.stepcounter-nrow(summarydata4)+1:model4.stepcounter]
# reorder summary data
summarydata4 = summarydata4[!,[1,9,8,2,3,4,5,6,7]]
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-4_summary.arrow", summarydata1)
# plot data
# define y axis
plot4y = Matrix(summarydata4[:,[3,4,5,6,7,9]])
plot(plotx, plot4y, label = plotlabels, legend = :bottomleft)
