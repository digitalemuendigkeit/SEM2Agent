using Agents
using AgentsPlots
using Distributions
using Random
using DataFrames

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

normie = truncated(Normal(0.5, 0.17), 0, 1)

# model initialization with empirical properties
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

# model initialization with properties drawn from
# a normal distribution from 0 to 1 (with mu = 0.5, sigma = 0.17)
function norminitialize(; numagents = 320, griddims = (20, 20), min_to_recycle = 0.75)
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
        rand(normie),
        #AT
        rand(normie),
        #SN
        rand(normie),
        #PBC
        rand(normie),
        #PMO
        rand(normie),
        #SRB
        rand(normie),
        #PNB
        rand(normie),
        #SNB
        rand(normie),
        #SE
        rand(normie),
        #FC
        rand(normie),
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

# the agent uses its previous properties as for the part not accounted for by R²
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
    # take out beta
    # if agent.BI * Betas["BIrecbeh"] ≥ minrecycle
    #     agent.recbeh = true
    # else
    #     agent.recbeh = false
    # end
    if agent.BI ≥ minrecycle
        agent.recbeh = true
    else
        agent.recbeh = false
    end
    # this is probably not a very efficient way to do this...
end

# the agent uses its previous properties as for the part not accounted for by R²
function agent_amnesiac_step!(agent, model)
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
    agent.PNB = rand(normie) * (1 - AVEVar["PNB"]) + AVEVar["PNB"] * count_neighbors_rec / (count_neighbors_trash + count_neighbors_rec)
    agent.SN = rand(normie) * (1 - AVEVar["SN"]) + AVEVar["SN"] * (agent.PNB * Betas["PNBSN"] + agent.SNB * Betas["SNBSN"])
    agent.BI = rand(normie) * (1 - AVEVar["BI"]) + AVEVar["BI"] * (agent.AT * Betas["ATBI"] + agent.SN * Betas["SNBI"] + agent.PBC * Betas["PBCBI"] + agent.PMO * Betas["PMOBI"])
    # take out beta
    # if agent.BI * Betas["BIrecbeh"] ≥ minrecycle
    #     agent.recbeh = true
    # else
    #     agent.recbeh = false
    # end
    if agent.BI ≥ minrecycle
        agent.recbeh = true
    else
        agent.recbeh = false
    end
end

adata = [:pos, :recbeh, :BI, :SN, :PNB]

# model = norminitialize()
# data, _ = run!(model, agent_step!, 10; adata = adata)
# data[1:10, :]

function recrate(df::DataFrame, x::Int64)
    stepdf = filter(row -> row[:step] == x, df)
    number_rec = length(findall(stepdf.recbeh.==1))
    return number_rec/length(stepdf.recbeh)
end
recrate(data, 0)

reccolor(a) = a.recbeh == true ? :blue : :red

# recbeginning = recrate(data, 0)
# recend = recrate(data, 10)

empmodel = initialize(numagents = 320, griddims = (20, 20), min_to_recycle = 0.75)
empdata, _ = run!(empmodel, agent_step!, 10; adata = adata)
emprecrate = (recrate(empdata, 0), recrate(empdata, 10))
empmodel = initialize(numagents = 320, griddims = (20, 20), min_to_recycle = 0.75)
empanim = @animate for i in 0:10
    p1 = plotabm(empmodel; ac = reccolor, as = 4)
    title!(p1, "Empirical Trash Panda with great memory, step $(i)")
    step!(empmodel, agent_step!, 10)
end
gif(empanim, "emptrashpanda.gif", fps = 2)

empammodel = initialize()
empamdata, _ = run!(empammodel, agent_amnesiac_step!, 10; adata = adata)
empammodel = initialize()
empamrecrate = (recrate(empamdata, 0), recrate(empamdata, 10))
empanim = @animate for i in 0:10
    p1 = plotabm(empammodel; ac = reccolor, as = 4)
    title!(p1, "Empirical Trash Panda with amnesia, step $(i)")
    step!(empammodel, agent_amnesiac_step!, 1)
end
gif(empanim, "empamtrashpanda.gif", fps = 2)

normmodel = norminitialize(numagents = 320, griddims = (20, 20), min_to_recycle = 0.5)
normdata, _ = run!(normmodel, agent_step!, 10; adata = adata)
normmodel = norminitialize(numagents = 320, griddims = (20, 20), min_to_recycle = 0.5)
normrecrate = (recrate(normdata, 0), recrate(normdata, 10))
normanim = @animate for i in 0:10
    p1 = plotabm(normmodel; ac = reccolor, as = 4)
    title!(p1, "Normal Trash Panda with great memory, step $(i)")
    step!(normmodel, agent_step!, 1)
end
gif(normanim, "normtrashpanda.gif", fps = 2)

normammodel = norminitialize(numagents = 320, griddims = (20, 20), min_to_recycle = 0.5)
normamdata, _ = run!(normammodel, agent_amnesiac_step!, 10; adata = adata)
normammodel = norminitialize(numagents = 320, griddims = (20, 20), min_to_recycle = 0.5)
normamrecrate = (recrate(normamdata, 0), recrate(normamdata, 10))
normamanim = @animate for i in 0:10
    p1 = plotabm(normammodel; ac = reccolor, as = 4)
    title!(p1, "Normal Trash Panda with amnesia, step $(i)")
    step!(normammodel, agent_amnesiac_step!, 1)
end
gif(normamanim, "normamtrashpanda.gif", fps = 2)
