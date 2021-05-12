using Agents
using Plots

include("02_abm_yolo-farming-social.jl")

# Experiment 1
# For the first experiment, we use the default conditions.
# The model runs for 10 years, from 2011 to 2021
# Initialize model
model1 = initialize()
# collect data
adata, _ = run!(model1, agent_step!, model_step!, agents_first=false, 10,
adata = [:ccexperience, :ppexperience, :ccbelief, :ccrisk, :ppintention ,
:participation])
summarydata1 = combine(groupby(adata, "step"), :ccexperience => mean,
:ppexperience => mean, :ccbelief => mean, :ccrisk => mean, :ppintention
=> mean, :participation => mean)
summarydata1.wateravailability = wateravailability.wateravailability[model1.stepcounter-nrow(summarydata1)+1:model1.stepcounter]
# Plots!
plotx = summarydata1.step
#ploty = [obsdatasumm.W_A obsdatasumm.C_E_mean obsdatasumm.P_E_mean obsdatasumm.C_B_mean obsdatasumm.C_R_mean obsdatasumm.P_I_mean obsdatasumm.P_P_perc]
ploty = Matrix(summarydata1[:,[8,2,3,4,5,6,7]])
plotlabels = ["Water availability" "CC Experience" "Policy Experience" "CC Belief" "Perceived CC Risk" "Participation Intention" "Participation"]
plot(plotx, ploty, label = plotlabels, legend = :bottomright)
