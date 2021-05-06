using Agents
using LightGraphs
using Random
using Statistics
using DataFrames
mutable struct FarmerAgent <: AbstractAgent
    id::Int
    pos::Int
    participates::Bool
end
function agent_step!(agent, model)
    neighbor_list = neighbors(model.space.graph, agent.pos)
    fraction_participates = mean([model.agents[i].participates for i in neighbor_list])
    if fraction_participates > 0.5
        agent.participates = true
    else
        agent.participates = false
    end
    return agent
end
function populate_model(model)
    for i in vertices(model.space.graph)
        add_agent!(FarmerAgent(i, i, bitrand(1)[1]), i, model)
    end
    return model
end
g = LightGraphs.grid((10, 10), periodic = true)
space = Agents.GraphSpace(g)
model = AgentBasedModel(FarmerAgent, space, scheduler = random_activation)
model = populate_model(model)
adata, _ = run!(model, agent_step!, 100, adata = [:participates])
summarydata = combine(groupby(adata, "step"), :participates => count)
