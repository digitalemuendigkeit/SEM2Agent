using Agents
using Plots
using Statistics
using Arrow
#using AgentsPlots

# Include functions
include("02_abm_yolo-farming-social.jl")
include("helpers_yolo-farming.jl")
# Which data do we collect?
agentdata = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention,
:participation]

# Experiment 1
# For the first experiment, we use the default conditions.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model1 = initialize()
# collect data
adata, mdata = run!(model1, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata1 = sumdata(adata, mdata)
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
model2 = initialize(; socialthreshold = 0.75)
# collect data
adata, _ = run!(model2, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata2 = sumdata(adata, mdata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-2_summary.arrow", summarydata1)
# plot data
plotgraph(summarydata2)
plot!(title = "Experiment 2")
# save plot
png("model_yolo-farming/data-output/experiment-2_figure.png")

# Experiment 3
# For the third experiment, we set the initial number of program participants
# to 0.5.
# Initialize model
model3 = initialize(; participatefract = 0.5)
# collect data
adata, _ = run!(model3, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata3 = sumdata(adata, mdata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-3_summary.arrow", summarydata1)
# plot data
# plot data
plotgraph(summarydata3)
plot!(title = "Experiment 3")
# save plot
png("model_yolo-farming/data-output/experiment-3_figure.png")

# Experiment 4
# For the third experiment, we set the program quality to -0.5.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model4 = initialize(; programquality = -0.5)
# collect data
adata, _ = run!(model4, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata4 = sumdata(adata, mdata)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-4_summary.arrow", summarydata1)
# plot data
plotgraph(summarydata4)
plot!(title = "Experiment 4")
# save plot
png("model_yolo-farming/data-output/experiment-4_figure.png")
