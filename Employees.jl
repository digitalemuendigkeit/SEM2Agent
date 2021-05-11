using Agents
using LightGraphs
using Random
using Statistics
using DataFrames
using StatsBase
using Arrow
using Plots


mutable struct employee <: AbstractAgent
    Stress::Float64
    EmployeeRelations::Float64
    EmployeeNiceness::Bool
    EmployeeSatisfaction::Float64
    EmployeeMotivation::Float64
end


# weitere Eigenschaft ist EmployeeNiceness


#variable abbreviations as keys for the dicts
VarKeys = ["S", "ER", "ES", "EM"]


#normalized mean values from descriptive statistics
MVals = [0.44, 0.7475, 0.6325, 0.6025]


#normalized sd values from descriptive statistics
SDVals = [0.2557, 0.2125, 0.2522, 0.26255]
#normalized means for variables
MVar = Dict(VarKeys .=> MVals)


#normalized standard deviations for variables
SDVar = Dict(VarKeys .=> SDVals)



mutable struct EmployeeAgent <: AbstractAgent
    id::Int
    pos::Int
    niceness::Bool
end


function agent_step!(agent, model)
    neighbor_list = neighbors(model.space.graph, agent.pos)
    fraction_niceness = mean([model.agents[i].niceness for i in neighbor_list])
    if fraction_niceness > 0.5
        agent.niceness = true
    else
        agent.niceness = false
    end
    return agent
end


function populate_model(model)
    for i in vertices(model.space.graph)
        add_agent!(EmployeeAgent(i, i, bitrand(1)[1]), i, model)
    end
    return model
end

g = LightGraphs.grid((10, 10), periodic = true)
space = Agents.GraphSpace(g)
model = AgentBasedModel(EmployeeAgent, space, scheduler = random_activation)
model = populate_model(model)

adata, _ = run!(model, agent_step!, 100, adata = [:niceness])






#space = GridSpace((10,10))

# Define agents
# nur Float würde den größtmöglichen Platz nehmen; Float64 ist die Genauigkeit, die wir oft nehmen
#@agent employee GridAgent{2} begin
#niceness::Float64
#end

# Define initialize function
function initialize(; numagents = 1013)





# model initialization with empirical properties
# hier eher Modellparameter und nicht Startvariablen...
# z.B. Skala, ab wann Stress als negativ wahrgenommen wird
function initialize(; numagents = 1013, S = 0.44, ER = 0.7475, ES = 0.6325, EM = 0.6025)
    space = GridSpace(griddims, metric = true)
    properties = Dict(:S => )
    model =
        ABM(employee, space; properties = properties, scheduler = random_activation)
    for n in 1:numagents



#space oder
#network
