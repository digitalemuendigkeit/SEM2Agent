using Agents
using Plots
using Statistics
using Arrow
using Measures
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
adata1, mdata1 = run!(model1, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 500)
# create summary data
summarydata1 = sumdata(adata1, mdata1)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
plotgraph(summarydata1)
plot!(title = "Experiment 1: Default conditions")
# save plot
savefig("model_yolo-farming/data-output/experiment-1_figure.svg")
savefig("model_yolo-farming/data-output/experiment-1_figure.pdf")

summarydata1 = Arrow.Table("model_yolo-farming/data-output/experiment-1_summary.arrow")
#plot data for paper
plotgraphpaper(summarydata1)
plot!(title = "Experiment 1: Default conditions")
savefig("model_yolo-farming/data-output/experiment-1_figure_paper.pdf")

# Experiment 2
# For the second experiment, we set the social threshold to 1.
# This means that all neighbors have to participate for an agent to be
# influenced socially to participate.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model2 = initialize(; socialthreshold = 1)
# collect data
adata2, mdata2 = run!(model2, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata2 = sumdata(adata2, mdata2)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-2_summary.arrow", summarydata2)
# plot data
plotgraph(summarydata2)
plot!(title = "Experiment 2: High social threshold")
# save plot
savefig("model_yolo-farming/data-output/experiment-2_figure.svg")
savefig("model_yolo-farming/data-output/experiment-2_figure.pdf")

# Experiment 3
# For the third experiment, we set the initial number of program participants
# to 0.5.
# Initialize model
model3 = initialize(; participatefract = 0.5)
# collect data
adata3, mdata3 = run!(model3, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata3 = sumdata(adata3, mdata3)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-3_summary.arrow", summarydata3)
# plot data
# plot data
plotgraph(summarydata3)
plot!(title = "Experiment 3: Many initial participants")
# save plot
savefig("model_yolo-farming/data-output/experiment-3_figure.svg")
savefig("model_yolo-farming/data-output/experiment-3_figure.pdf")

# Experiment 4
# For the third experiment, we set the program quality to -0.5.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model4 = initialize(; programquality = -0.4)
# collect data
adata4, mdata4 = run!(model4, agent_step!, model_step!, agents_first=false, 10,
adata = agentdata, mdata = [:stepcounter], replicates = 100)
# create summary data
summarydata4 = sumdata(adata4, mdata4)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-4_summary.arrow", summarydata4)
# plot data
plotgraph(summarydata4)
plot!(title = "Experiment 4: Low program quality")
# save plot
savefig("model_yolo-farming/data-output/experiment-4_figure.svg")
savefig("model_yolo-farming/data-output/experiment-4_figure.pdf")


# Make summary graph
sdatalist = [summarydata1, summarydata2, summarydata3, summarydata4]

plot(plotsumgraph(summarydata1), plotsumgraph(summarydata2),
plotsumgraph(summarydata3), plotsumgraph(summarydata4),
title = ["Experiment 1: Default conditions" "Experiment 2: High social threshold" "Experiment 3: Many initial participants" "Experiment 4: Low program quality"],
size = (1000,750), margin = 5mm)

#save plot
savefig("model_yolo-farming/data-output/experiments-summary_figure.svg")
savefig("model_yolo-farming/data-output/experiments-summary_figure.pdf")
