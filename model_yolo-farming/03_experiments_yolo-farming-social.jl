using Agents
using Plots
using Statistics
using Arrow

include("02_abm_yolo-farming-social.jl")
include("helpers.jl")
# Which data do we collect?
datatocollect = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention,
:participation]

# Experiment 1
# For the first experiment, we use the default conditions.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model1 = initialize()
# collect data
adata, _ = run!(model1, agent_step!, model_step!, agents_first=false, 10,
adata = datatocollect)
# create summary data
summarydata1 = sumdata(model1, adata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
plotgraph(summarydata1)
plot!(title = "Experiment 1")
# save plot
png("model_yolo-farming/data-output/experiment-1_figure.png")

# Experiment 2
# For the second experiment, we set the social threshold to 1.
# This means that all neighbors have to participate for an agent to be
# influenced socially to participate.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model2 = initialize(; socialthreshold = 1)
# collect data
adata, _ = run!(model2, agent_step!, model_step!, agents_first=false, 10,
adata = datatocollect)
# create summary data
summarydata2 = sumdata(model2, adata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-2_summary.arrow", summarydata1)
# plot data
plotgraph(summarydata2)
plot!(title = "Experiment 2")
# save plot
png("model_yolo-farming/data-output/experiment-2_figure.png")

# Experiment 3
# For the third experiment, we set the initial number of program participants
# to 0.
# Initialize model
model3 = initialize(; participatefract = 0.25, startyear = 2010)
# collect data
adata, _ = run!(model3, agent_step!, model_step!, agents_first=false, 10,
adata = datatocollect)
# create summary data
summarydata3 = sumdata(model3, adata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-3_summary.arrow", summarydata1)
# plot data
# plot data
plotgraph(summarydata3)
plot!(title = "Experiment 3")
# save plot
png("model_yolo-farming/data-output/experiment-3_figure.png")

# Experiment 4
# For the third experiment, we set the program quality to -1.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model4 = initialize(; programquality = -0.5)
# collect data
adata, _ = run!(model4, agent_step!, model_step!, agents_first=false, 10,
adata = datatocollect)
# create summary data
summarydata4 = sumdata(model4, adata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-4_summary.arrow", summarydata1)
# plot data
plotgraph(summarydata4)
plot!(title = "Experiment 4")
# save plot
png("model_yolo-farming/data-output/experiment-4_figure.png")
