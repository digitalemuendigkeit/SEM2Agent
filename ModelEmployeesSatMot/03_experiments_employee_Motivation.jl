8using Agents
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
# The model runs for 50 steps.
# Initialize model
model1 = initialize()
# collect data
adata1, mdata1 = run!(model1, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata1 = sumemployeedata(adata1, mdata1)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-1_summary.arrow", summarydata1)
# plot data
# define x axis
plotemployeegraph(summarydata1)
plot!(title = "Experiment 1")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-1_figure.png")

# Experiment 2
# Neutral starting conditions with medium employee valuation
# Initialize model
model2 = initialize(; EmployeeValuation = "medium")
# collect data
adata2, mdata2 = run!(model2, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata2 = sumemployeedata(adata2, mdata2)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-2_summary.arrow",
summarydata2)
# plot data
plotemployeegraph(summarydata2)
plot!(title = "Experiment 2")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-2_figure.png")

# Experiment 3
# Neutral starting conditions with high employee valuation
# Initialize model
model3 = initialize(; EmployeeValuation = "high")
# collect data
adata3, mdata3 = run!(model3, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata3 = sumemployeedata(adata3, mdata3)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-3_summary.arrow",
summarydata3)
# plot data
plotemployeegraph(summarydata3)
plot!(title = "Experiment 3")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-3_figure.png")

# Experiment 4
# Positive starting conditions with low employee valuation
# Initialize model
model4 = initialize(; NicenessFraction = 0.75, Stress = -0.5, Success = 0.5,
EmployeeValuation = "low")
# collect data
adata4, mdata4 = run!(model4, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata4 = sumemployeedata(adata4, mdata4)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-4_summary.arrow",
summarydata4)
# plot data
plotemployeegraph(summarydata4)
plot!(title = "Experiment 4")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-4_figure.png")


# Experiment 5
# Positive starting conditions with medium employee valuation
# Initialize model
model5 = initialize(; NicenessFraction = 0.75, Stress = -0.5, Success = 0.5,
EmployeeValuation = "medium")
# collect data
adata5, mdata5 = run!(model5, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata5 = sumemployeedata(adata5, mdata5)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-5_summary.arrow",
summarydata5)
# plot data
plotemployeegraph(summarydata5)
plot!(title = "Experiment 5")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-5_figure.png")


# Experiment 6
# Positive starting conditions with high employee valuation
# Initialize model
model6 = initialize(; NicenessFraction = 0.75, Stress = -0.5, Success = 0.5,
EmployeeValuation = "high")
# collect data
adata6, mdata6 = run!(model6, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata6 = sumemployeedata(adata6, mdata6)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-6_summary.arrow",
summarydata6)
# plot data
plotemployeegraph(summarydata6)
plot!(title = "Experiment 6")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-6_figure.png")

# Experiment 7
# Negative starting conditions with low employee valuation
# Initialize model
model7 = initialize(; NicenessFraction = 0.25, Stress = 0.5, Success = -0.5,
EmployeeValuation = "low")
# collect data
adata7, mdata7 = run!(model7, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata7 = sumemployeedata(adata7, mdata7)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-7_summary.arrow",
summarydata7)
# plot data
plotemployeegraph(summarydata7)
plot!(title = "Experiment 7")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-7_figure.png")

# Experiment 8
# Negative starting conditions with medium employee valuation
# Initialize model
model8 = initialize(; NicenessFraction = 0.25, Stress = 0.5, Success = -0.5,
EmployeeValuation = "medium")
# collect data
adata8, mdata8 = run!(model8, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata8 = sumemployeedata(adata8, mdata8)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-8_summary.arrow",
summarydata8)
# plot data
plotemployeegraph(summarydata8)
plot!(title = "Experiment 8")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-8_figure.png")

# Experiment 9
# Negative starting conditions with high employee valuation
# Initialize model
model9 = initialize(; NicenessFraction = 0.25, Stress = 0.5, Success = -0.5,
EmployeeValuation = "high")
# collect data
adata9, mdata9 = run!(model9, agent_step!, model_step!, 50, adata = agentdata,
mdata = [:Success], replicates = 500)
# create summary data
summarydata9 = sumemployeedata(adata9, mdata9)
# save summary data
Arrow.write("ModelEmployeesSatMot/data-output/experiment-9_summary.arrow",
summarydata9)
# plot data
plotemployeegraph(summarydata9)
plot!(title = "Experiment 9")
# save plot
png("ModelEmployeesSatMot/data-output/experiment-9_figure.png")
