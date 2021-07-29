using Agents
using Statistics
using Arrow
using AgentsPlots

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
# plot
agentplotdata = sort(adata1, ["id"])
function plotgraph(agentplotdata)
    p = plot(agentplotdata.step[1:11], agentplotdata.participation[1:11])
    for i in 2:100
        p = plot!(agentplotdata.step[(11*i-10):11*i], agentplotdata.participation[(11*i-10):11*i])
    end
    return p
end

function plotgraph2(agentplotdata)
    p = plot(agentplotdata.step[1:11], agentplotdata.ccexperience[1:11])
    for i in 2:100
        p = plot!(agentplotdata.step[(11*i-10):11*i], agentplotdata.ccexperience[(11*i-10):11*i])
    end
    return p
end

plotgraph(one)
plotgraph2(one)

one = agentplotdata[agentplotdata.replicate .== 1, :]
one[one.step .== 0, :]
# create summary data
summarydata1 = sumdata(adata1, mdata1)
# save summary data
Arrow.write("model_yolo-farming/data-output/experiment-1_summary.arrow", summarydata1)

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
