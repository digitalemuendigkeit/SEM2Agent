using Agents
using Plots
using Statistics
using Arrow

# Include scripts for functions
include("02_abm_employee_motivation.jl")
include("helpers_employee-motivation.jl")

# Which data to collect
agentdata = [:Stress, :EmployeeNiceness, :EmployeeRelations,
:EmployeeSatisfaction, :EmployeeMotivation]

# Experiment 1
# For the first experiment, we use the default conditions.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model1 = initialize()
# collect data
adata, mdata = run!(model1, agent_step!, model_step!, 20, adata = agentdata,
mdata = [:Stress, :Success], replicates = 100)
# create summary data
summarydata1 = sumemployeedata(adata, mdata)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
# define x axis
plotemployeegraph(summarydata1)
plotx = summarydata1.step
# define y axis
plot1y = Matrix(summarydata1[:, 2:6])
plotlabels = ["Stress" "EmployeeNiceness" "EmployeeRelations" "EmployeeSatisfaction" "EmployeeMotivation"]
plot(plotx, plot1y, label = plotlabels, legend = :bottomleft)

# Experiment 2
# For the second experiment, we set the social threshold to 1.
# This means that all neighbors have to participate for an agent to be
# influenced socially to participate.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model2 = initialize(; NicenessFraction = 0.0, Stress = -1.0, Success = +1.0)
# collect data
adata, mdata = run!(model2, agent_step!, model_step!, 20, adata = agentdata,
mdata = [:Stress, :Success], replicates = 100)
# create summary data
summarydata2 = sumemployeedata(adata, mdata)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-1_summary.arrow", summarydata1)
# plot data

# define x axis
plotx = summarydata1.step
# define y axis
plot1y = Matrix(summarydata1[:, 2:6])
plotlabels = ["Stress" "EmployeeNiceness" "EmployeeRelations" "EmployeeSatisfaction" "EmployeeMotivation"]
plot(plotx, plot1y, label = plotlabels, legend = :bottomleft)

# Experiment 3
# For the third experiment, we set the initial number of program participants
# to 0.
# The model runs for 10 years, from 2010 to 2020
# Initialize model
model3 = initialize(;NicenessFraction = 0.25, Stress = "sine")
# collect data
adata, _ = run!(model3, agent_step!, model_step!, 20,
adata = agentdata, replicates = 100)
# create summary data
summarydata3 = sumdata(adata)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
# define x axis
plotemployeegraph(summarydata3)
# define y axis
plot1y = Matrix(summarydata1[:, 2:6])
plotlabels = ["Stress" "EmployeeNiceness" "EmployeeRelations" "EmployeeSatisfaction" "EmployeeMotivation"]
plot(plotx, plot1y, label = plotlabels, legend = :bottomleft)



model4 = initialize(;NicenessFraction = 0.25, Stress = "rise")
# collect data
adata, _ = run!(model4, agent_step!, model_step!, 20, adata = agentdata,
replicates = 100)
# create summary data
summarydata4 = sumdata(adata)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
# define x axis
plotemployeegraph(summarydata4)
# define y axis
plot1y = Matrix(summarydata1[:, 2:6])
plotlabels = ["Stress" "EmployeeNiceness" "EmployeeRelations" "EmployeeSatisfaction" "EmployeeMotivation"]
plot(plotx, plot1y, label = plotlabels, legend = :bottomleft)
