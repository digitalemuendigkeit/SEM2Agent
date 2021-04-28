using Agents
using CSV
using DataFrames
using Distributions
using Random
using StatsPlots

Random.seed!(123)

# Define farmer agent
mutable struct Farmer <: AbstractAgent
    id::Int64       # Agent ID
    yc::Int64       # year counter
    W_A_C::Int64    # water availability counter,
                    # both W_A_C_ and yc should not be in the agent lol
    C_E::Float64    # Perception of water availability change
    P_P_C::Int64    # Number of years the farmer has participated in program
    P_E::Float64    # Evaluation of past policies
    C_B::Float64    # Belief in climate change
    C_R::Float64    # Perception of climate change risk
    P_I::Float64    # Program participation intention
    P_I_C::Int64    # Counts years of intention
    P_P::Bool       # Current program participation
end

# Define water availability
W_A = CSV.read("model_yolo-farming\\data\\yolo-wa-change.csv", DataFrame, types = [Int64, Float64, Float64])

# Policy characteristics are part of the model experiment
# They can be set to anything between 0 (very bad) and 1 (excellent)

# Initialize function
function initialize(; numagents = 100, P_C = 0.5)
    properties = Dict(:P_C => P_C)
    model =
        ABM(Farmer; properties = properties, scheduler = random_activation)
    for n in 1:numagents
        # arguments are agent properties
        agent = Farmer(
        # id
        n,
        # yc
        0,
        # W_A_C
        0,
        # C_E: replace with "random" sampling
        if n < 43*100/numagents
            1
        elseif n < 99*100/numagents
            0.5
        else
            0
        end,
        # P_P_C: numbers of years participated = 0 at the beginning
        0,
        # P_E
        rand(truncated(Normal(0.54, 0.341), 0, 1)),
        # C_B: replace with "random sampling"
        if n < 20*100/numagents
            1
        elseif n < 40*100/numagents
            0.75
        elseif n < 70*100/numagents
            0.5
        elseif n < 90*100/numagents
            0.25
        else
            0
        end,
        # C_R:
        rand(truncated(Normal(0.5, 0.341), 0, 1)),
        #P_I: replace with "random sampling"
        if n < 48*100/numagents
            rand((0.8,1))
        else
            rand((0,0.2,0.4,0.6))
        end,
        #P_I_C
        0,
        #P_P
        false,
        )
        add_agent!(agent, model)
    end
    return model
end

function agent_step!(agent, model)
    P_C = model.P_C
    # update year counter
    agent.yc = agent.yc + 1
    # update water availability counter
    if W_A[agent.yc+1,3] < 0
        agent.W_A_C = agent.W_A_C + 1
    else
        agent.W_A_C = agent.W_A_C - 1
    end
    # update climate change experience
    if agent.W_A_C > 2 && agent.C_E < 1
        agent.C_E = agent.C_E + 0.5
    elseif agent.W_A_C < 1 && agent.C_E > 0
        agent.C_E = agent.C_E - 0.5
    else agent.C_E = agent.C_E
    end
    # updated policy participation counter
    if agent.P_P == false
        agent.P_P_C = 0
    else
        agent.P_P_C = agent.P_P_C + 1
    end
    # update past policy experience
    if agent.P_P_C == 0 && agent.P_E < 0.70
        agent.P_E = agent.P_E + 0.01
    elseif agent.P_P_C == 0 && agent.P_E >= 0.70
        agent.P_E = agent.P_E
    else
        agent.P_E = (agent.P_E + agent.P_C  * agent.P_P_C / (agent.P_P_C + 2) ) / 2
    end
    # calculate climate change belief
    agent.C_B = 0.39 * agent.C_B + 0.61 * (0.24 * agent.C_E + 0.76 * agent.P_E)
    # calculate perceived climate change risk
    agent.C_R = 0.2 * agent.C_R + 0.8 * (0.88 * agent.C_B + 0.12 * agent.C_E - 0.14*agent.P_E)
    # calculate program participation intention
    agent.P_I = - 0.18 * agent.C_E + agent.C_R
    # update participation intention counter
    if agent.P_I >= 0.8
        agent.P_I_C = agent.P_I_C + 1
    elseif agent.P_I <= 0.4
        agent.P_I_C = agent.P_I_C - 1
    else
        agent.P_I_C = agent.P_I_C
    end
    # update program participation
    if agent.P_I_C > 1
        agent.P_P = true
    elseif agent.P_I_C < 1
        agent.P_P = false
    else
        agent.P_P = agent.P_P
    end
end

model = initialize()
run!(model, agent_step!, 10)
observe = [:yc, :W_A_C, :P_E, :P_I, :P_I_C, :P_P]
obsdata, _ = run!(model, agent_step!, 10; adata = observe)
