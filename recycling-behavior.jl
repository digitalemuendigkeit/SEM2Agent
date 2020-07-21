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

VarKeys = ["BI", "AT", "SN", "PBC", "PMO", "SRB", "PNB", "SNB", "SE", "FC"]
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

MVar["BI"]

#normalized standard deviations for variables
SDVar = Dict(VarKeys .=> SDVals)

SDVar[VarKeys[1]]

#AVE for variables
AVEVar = Dict(VarKeys .=> AVEVars)

Random.seed!(123)

poop = for m in 1:10
    println(rand(Normal(MVar[VarKeys[m]], SDVar[VarKeys[m]])))
end

poop

minipoop = for m in 1:10
    println(MVar[VarKeys[m]], SDVar[VarKeys[m]])
    end



function initialize(; numagents = 320, griddims = (20, 20), min_to_recycle = 0.5)
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
        for m in 1:10
            rand(Normal(MVar[VarKeys[m]], SDVar[VarKeys[m]]))
        end
        # #BI
        # rand(Normal(0.78, 0.26)),
        # #AT
        # rand(Normal(0.87, 0.17)),
        # #SN
        # rand(Normal(0.84, 0.22)),
        # #PBC
        # rand(Normal(0.83, 0.20)),
        # #PMO
        # rand(Normal(0.91, 0.14)),
        # #SRB
        # rand(Normal(0.85, 0.18)),
        # #PNB
        # rand(Normal(0.72, 0.14)),
        # #SNB
        # rand(Normal(0.83, 0.16)),
        # #SE
        # rand(Normal(0.69, 0.21)),
        # #FC
        # rand(Normal(0.69, 0.20))
        )
        add_agent_single!(agent, model)
    end
    return model
end

function agent_step!(agent, model)
    agent.PBC = 0.61 * (0)
    count_neighbors_rec = 0
    count_neighbors_trash = 0

end

model = initialize()
