using Agents
using AgentsPlots
using Distributions
using Random

mutable struct TrashPanda <: AbstractAgent
    id::Int64
    pos::Tuple{Int64, Int64}
    recbeh::Bool
    BI::Float64
    AT::Float64
    SN::Float64
    PBC::Float64
    PMO::Float64
    SRB::Float64
    PNB::Float64
    SNB::Float64
    SE::Float64
    FC::Float64
end

#variable abbreviations as keys for the dicts
VarKeys = ["BI", "AT", "SN", "PBC", "PMO", "SRB", "PNB", "SNB", "SE", "FC"]

#normalized mean values from descriptive statistics
MVals = [
0.78
0.87
0.84
0.83
0.91
0.85
0.75
0.83
0.69
0.69]

#normalized sd values from descriptive statistics
SDVals = [
0.26
0.17
0.22
0.20
0.14
0.18
0.16
0.16
0.21
0.20
]

#ave (R²) for different variables
AVEVars = [
0.9
0.85
0.8
0.86
0.81
0.9
0.8
0.9
0.9
0.68
]

#normalized means for variables
MVar = Dict(VarKeys .=> MVals)

# MVar["BI"]

#normalized standard deviations for variables
SDVar = Dict(VarKeys .=> SDVals)

# SDVar[VarKeys[1]]

#AVE for variables
AVEVar = Dict(VarKeys .=> AVEVars)

#variable abbreviations as keys for the dicts
BetaKeys = ["BIrecbeh", "ATBI", "SNBI", "PBCBI", "PMOBI", "SRBAT", "PNBSN", "SNBSN", "SEPBC", "FCPBC"]

#beta values, normalized to a sum of 1 per successor
BetaVals = [
1
0.245762712
0.161016949
0.449152542
0.144067797
1
0.508196721
0.491803279
0.426966292
0.573033708
]

Betas = Dict(BetaKeys .=> BetaVals)

Random.seed!(123)



# poop = for m in 1:10
#     println(rand(truncated(Normal(MVar[VarKeys[m]], SDVar[VarKeys[m]]), 0, 1)))
# end
#
# poop
#
# minipoop = for m in 1:10
#     println(MVar[VarKeys[m]], SDVar[VarKeys[m]])
#     end
#
#     for m in 1:10
#         println(string(rand(truncated(Normal(MVar[VarKeys[m]], SDVar[VarKeys[m]]), 0, 1)), ","))
#     end

function initialize(; numagents = 320, griddims = (20, 20), min_to_recycle = 0.75)
    space = GridSpace(griddims, moore = true)
    properties = Dict(:min_to_recycle => min_to_recycle)
    model =
        ABM(TrashPanda, space; properties = properties, scheduler = random_activation)
    for n in 1:numagents
        # arguments are agent properties, first is id, second is pos, 3rd is recbeh and so on normal distribution
        agent = TrashPanda(
        #id
        n,
        #pos
        (1, 1),
        #recbeh
        n < numagents / 2 ? true : false,
        #other variables
        # for m in 1:10
        #     rand(truncated(Normal(MVar[VarKeys[m]], SDVar[VarKeys[m]]), 0, 1)),
        #     string(",")
        # end
        #BI
        rand(truncated(Normal(MVar["BI"], SDVar["BI"]), 0, 1)),
        #AT
        rand(truncated(Normal(MVar[VarKeys[2]], SDVar[VarKeys[2]]), 0, 1)),
        #SN
        rand(truncated(Normal(MVar[VarKeys[3]], SDVar[VarKeys[3]]), 0, 1)),
        #PBC
        rand(truncated(Normal(MVar[VarKeys[4]], SDVar[VarKeys[4]]), 0, 1)),
        #PMO
        rand(truncated(Normal(MVar[VarKeys[5]], SDVar[VarKeys[5]]), 0, 1)),
        #SRB
        rand(truncated(Normal(MVar[VarKeys[6]], SDVar[VarKeys[6]]), 0, 1)),
        #PNB
        rand(truncated(Normal(MVar[VarKeys[7]], SDVar[VarKeys[7]]), 0, 1)),
        #SNB
        rand(truncated(Normal(MVar[VarKeys[8]], SDVar[VarKeys[8]]), 0, 1)),
        #SE
        rand(truncated(Normal(MVar[VarKeys[9]], SDVar[VarKeys[9]]), 0, 1)),
        #FC
        rand(truncated(Normal(MVar[VarKeys[10]], SDVar[VarKeys[10]]), 0, 1)),
        )
        add_agent_single!(agent, model)
    end
    return model
end

# in the agent step, three regression equations have to be expressed
# subjective norm = interaction with other agents
# observe all neighbouring agents and adjust sn value
# behavioral intention
# behavior

model = initialize()

function agent_step!(agent, model)
    minrecycle = model.min_to_recycle
    neighbor_cells = node_neighbors(agent, model)
    count_neighbors_rec = 0
    count_neighbors_trash = 0
    for neighor_cell in neighbor_cells
        node_contents = get_node_contents(neighor_cell, model)
        # skip iteration if the node is empty
        length(node_contents) == 0 && continue
        #otherwise, get first agent in the node
        agent_id = node_contents[1]
        # and increment count_neighbors_rec if neighbor is recycling
        neighbor_agent_rec = model[agent_id].recbeh
        if neighbor_agent_rec == true
            count_neighbors_rec += 1
        elseif neighbor_agent_rec == false
            count_neighbors_trash += 1
        end
    end
    # after counting the recycling neighbors, compute subjective norm
    # The old PNB is kept for 1-AVE
    agent.PNB = agent.PNB * (1 - AVEVar["PNB"]) + AVEVar["PNB"] * count_neighbors_rec / (count_neighbors_trash + count_neighbors_rec)
    agent.SN = agent.SN * (1 - AVEVar["SN"]) + AVEVar["SN"] * (agent.PNB * Betas["PNBSN"] + agent.SNB * Betas["SNBSN"])
    agent.BI = agent.BI * (1 - AVEVar["BI"]) + AVEVar["BI"] * (agent.AT * Betas["ATBI"] + agent.SN * Betas["SNBI"] + agent.PBC * Betas["PBCBI"] + agent.PMO * Betas["PMOBI"])
    if agent.BI * Betas["BIrecbeh"] ≥ minrecycle
        agent.recbeh = true
    else
        agent.recbeh = false
    end
    # this is probably not a very efficient way to do this...
end

d = Normal()
rand(truncated(Normal(0.5, 0.25), 0, 1))


function agent_random_step!(agent, model)
    minrecycle = model.min_to_recycle
    neighbor_cells = node_neighbors(agent, model)
    count_neighbors_rec = 0
    count_neighbors_trash = 0
    for neighor_cell in neighbor_cells
        node_contents = get_node_contents(neighor_cell, model)
        # skip iteration if the node is empty
        length(node_contents) == 0 && continue
        #otherwise, get first agent in the node
        agent_id = node_contents[1]
        # and increment count_neighbors_rec if neighbor is recycling
        neighbor_agent_rec = model[agent_id].recbeh
        if neighbor_agent_rec == true
            count_neighbors_rec += 1
        elseif neighbor_agent_rec == false
            count_neighbors_trash += 1
        end
    end
    # after counting the recycling neighbors, compute subjective norm
    # The old PNB is kept for 1-AVE
    agent.PNB = rand(truncated(Normal(0.5, 0.25), 0, 1)) * (1 - AVEVar["PNB"]) + AVEVar["PNB"] * count_neighbors_rec / (count_neighbors_trash + count_neighbors_rec)
    agent.SN = rand(truncated(Normal(0.5, 0.25), 0, 1)) * (1 - AVEVar["SN"]) + AVEVar["SN"] * (agent.PNB * Betas["PNBSN"] + agent.SNB * Betas["SNBSN"])
    agent.BI = rand(truncated(Normal(0.5, 0.25), 0, 1)) * (1 - AVEVar["BI"]) + AVEVar["BI"] * (agent.AT * Betas["ATBI"] + agent.SN * Betas["SNBI"] + agent.PBC * Betas["PBCBI"] + agent.PMO * Betas["PMOBI"])
    if agent.BI * Betas["BIrecbeh"] ≥ minrecycle
        agent.recbeh = true
    else
        agent.recbeh = false
    end
end

step!(model, agent_step!)

adata = [:pos, :recbeh]

model = initialize()
data, _ = run!(model, agent_step!, 10; adata = adata)
data[1:10, :]

model = initialize()
reccolor(a) = a.recbeh == true ? :green : :red
plotabm(model; ac = reccolor, as = 4)

anim = @animate for i in 0:10
    p1 = plotabm(model; ac = reccolor, as = 4)
    title!(p1, "step$(i)")
    step!(model, agent_step!, 1)
end

gif(anim, "trashpanda.gif", fps = 2)

animrandom = @animate for i in 0:10
    p1 = plotabm(model; ac = reccolor, as = 4)
    title!(p1, "step$(i)")
    step!(model, agent_random_step!, 1)
end

gif(animrandom, "randomtrashpanda.gif", fps = 2)
