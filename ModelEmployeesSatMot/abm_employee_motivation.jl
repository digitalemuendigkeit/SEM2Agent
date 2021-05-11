using Agents
using LightGraphs
using Random
using Statistics
using DataFrames
using StatsBase
using Arrow
using Plots

# Load input data
# wenn Daten vorbereitet
using DataFrames
using Arrow
using CSV
using Distributions

dsraw = CSV.read("ModelEmployeesSatMot/data-input/descriptive_statistics.csv", DataFrame, decimal = ',')

#Tabelle zusammenfassen:
ds = combine(groupby(dsraw,:Variable), :Mean => mean => :Mean, "Standard Deviation" => mean => :SD)

# Define space
# Use LightGraphs to define space
# Scale-free network with 100 vertices and 200 edges
# Space als erstes: dann kann man Agenten basierend darauf erstellen mit Macro

# Anzahl Agenten: 100, Anzahl Verbindungen: hintere 8
g = LightGraphs.barabasi_albert(100, 8, 8)
space = Agents.GraphSpace(g)

# Define agent
mutable struct employee <: AbstractAgent
    id::Int
    pos::Int
    Stress::Float64
    EmployeeRelations::Float64
    EmployeeNiceness::Bool
    EmployeeSatisfaction::Float64
    EmployeeMotivation::Float64
end

# Define function to initialize model
# properties are:
# Stress =
# StressResistence =
# NicenessFraction = how many agents are nice in the beginning
function initialize(; NicenessFraction = 0.5)
    properties = Dict(:NicenessFraction => NicenessFraction)
    model = AgentBasedModel(employee, space; properties = properties, scheduler = random_activation)
    for i in vertices(model.space.graph)
        add_agent!(
        employee(i,
                 i,
                 rand(Normal(ds[1,2], ds[1,3])), # Stress
                 rand(Normal(ds[2,2], ds[2,3])), # Relations
                 sample([true, false], Weights([NicenessFraction, 1 - NicenessFraction])), # Niceness
                 rand(Normal(ds[3,2], ds[3,3])), # Satisfaction
                 rand(Normal(ds[4,2], ds[4,3]))), # Motivation
                 i,
                 model)
    end
    return model
end

function agent_step!(agent, model)
    #update stress (später wollen wir es realistischer gestalten z.B. 5 verschiedene Stressstufen)
    agent.Stress = rand(Float64)
    #update niceness > später in Abhängigkeit von Stressresistenz
    #Kurzform von if else loop
    agent.Stress > 0.7 ? agent.EmployeeNiceness = false : agent.EmployeeNiceness = true
    #update employee relations
    neighbor_list = neighbors(model.space.graph, agent.pos)
    fraction_nice = mean([model.agents[i].EmployeeNiceness for i in neighbor_list])
    agent.EmployeeRelations = -0.713 * agent.Stress + (fraction_nice + agent.EmployeeRelations)/2
    agent.EmployeeSatisfaction = 0.262 * agent.EmployeeSatisfaction -0.192 * agent.Stress + 0.738 * agent.EmployeeRelations
    agent.EmployeeMotivation = 0.333 * agent.EmployeeRelations + 0.667 * agent.EmployeeSatisfaction
end

model = initialize()
adata, _ = run!(model, agent_step!, 10, adata = [:Stress,
:EmployeeNiceness, :EmployeeRelations, :EmployeeSatisfaction, :EmployeeMotivation])
summarydata = combine(groupby(adata, "step"), :EmployeeMotivation => mean)
obsdatasumm = combine(groupby(adata, "step"), :Stress => mean,
:EmployeeNiceness => mean, :EmployeeRelations => mean, :EmployeeSatisfaction => mean, :EmployeeMotivation
=> mean)
# Plots!
plotx = obsdatasumm.step
#ploty = [obsdatasumm.W_A obsdatasumm.C_E_mean obsdatasumm.P_E_mean obsdatasumm.C_B_mean obsdatasumm.C_R_mean obsdatasumm.P_I_mean obsdatasumm.P_P_perc]
ploty = Matrix(obsdatasumm[:,2:6])
plotlabels = ["Stress" "EmployeeNiceness" "EmployeeRelations" "EmployeeSatisfaction" "EmployeeMotivation"]
plot(plotx, ploty, label = plotlabels, legend = :topright)
