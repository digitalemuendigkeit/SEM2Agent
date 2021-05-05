using Agents
using LightGraphs
using Random
using DataFrames
using Statistics
using StatsBase
# using CSV
# using Distributions
# using StatsPlots
# using Plots

# Define space
# Use LightGraphs to define space
# torus with 100 vertices and 200 edges
g = LightGraphs.grid((10, 10), periodic = true)
space = Agents.GraphSpace(g)

# Define agent
@agent  farmer GraphAgent begin
    # whether the agent participates in the policy
    participation::Bool
end

# Define function to intialize model
# properties are:
# socialthreshold = how many neighbors have to participate to influence the agent
# participatefract = fraction of agents participating initially
function initialize(; socialthreshold = 0.5, participatefract = 0.5)
    properties = Dict(:socialthreshold => socialthreshold,
                      :participatefract => participatefract)
    model = AgentBasedModel(farmer, space; properties = properties, scheduler = random_activation)
    for i in vertices(model.space.graph)
        add_agent!(
        farmer(
        # id
        i,
        # position
        i,
        # participation
        #bitrand(1)[1]
        sample(
        [true, false],
        Weights(
        [participatefract, 1-participatefract]
        ))
        ),
        i,
        model
        )
    end
    return model
end

# Define agent step function
function agent_step!(agent, model)
    # get list of the neighbors
    neighbor_list = neighbors(model.space.graph, agent.pos)
    # calculate the fraction of them participating
    fraction_participation = mean([model.agents[i].participation for i in neighbor_list])
    # if its more than the social threshold, participate
    fraction_participation > model.socialthreshold ? agent.participation = true : agent.participation = false
    return agent
end

model = initialize(; socialthreshold = 0.9, participatefract = 0.4)
adata, _ = run!(model, agent_step!, 10, adata = [:participation])
summarydata = combine(groupby(adata, "step"), :participation => count)


obsdatasumm.W_A = 1 .- W_A[1:21,2]
obsdatasumm.P_P_perc = obsdatasumm.P_P_count./maximum(obsdata.id)
# Plots!
plotx = obsdatasumm.step
#ploty = [obsdatasumm.W_A obsdatasumm.C_E_mean obsdatasumm.P_E_mean obsdatasumm.C_B_mean obsdatasumm.C_R_mean obsdatasumm.P_I_mean obsdatasumm.P_P_perc]
ploty = Matrix(obsdatasumm[:,[9,2,5,4,3,6,10]])
plotlabels = ["Water availability" "CC Experience" "Policy Experience" "CC Belief" "Perceived CC Risk" "Participation Intention" "Participation"]
plot(plotx, ploty, label = plotlabels, legend = :bottomright)











# Define farmer agent
@agent  farmer GridAgent{2} begin
    part::Bool
   # yc::Int64       # year counter
   # W_A_C::Int64    # water availability counter,
   #                 # both W_A_C_ and yc should not be in the agent lol
   # C_E::Float64    # Perception of water availability change
   # P_P_C::Int64    # Number of years the farmer has participated in program
   # P_E::Float64    # Evaluation of past policies
   # C_B::Float64    # Belief in climate change
   # C_R::Float64    # Perception of climate change risk
   # P_I::Float64    # Program participation intention
   # P_I_C::Int64    # Counts years of intention
end



# Define water availability
# W_A = CSV.read("model_yolo-farming\\data\\yolo-wa-change.csv", DataFrame, types = [Int64, Float64, Float64])

# Policy characteristics are part of the model experiment
# They can be set to anything between 0 (very bad) and 1 (excellent)

# Initialize function
function initialize(; numagents = 100, propparticipants = 0,  P_C = 0.5)
    properties = Dict(:P_C => P_C, :propparticipants => propparticipants)
    model =
        ABM(farmer, space; properties = properties, scheduler = random_activation)
    for n in 1:numagents
        # arguments are agent properties
        agent = farmer(
        # id
        n,
        # pos
        (1, 1),
        # # yc - year counter
        # 0,
        # # W_A_C - water availability counter
        # 0,
        # # C_E: replace with "random" sampling
        # if n < .43*numagents
        #     1
        # elseif n < .99*numagents
        #     0.5
        # else
        #     0
        # end,
        # # P_P_C: numbers of years participated = 0 at the beginning
        # 0,
        # # P_E
        # rand(truncated(Normal(0.54, 0.341), 0, 1)),
        # # C_B: replace with "random sampling"
        # if n < .20*numagents
        #     1
        # elseif n < .40*numagents
        #     0.75
        # elseif n < .70*numagents
        #     0.5
        # elseif n < .90*numagents
        #     0.25
        # else
        #     0
        # end,
        # # C_R:
        # rand(truncated(Normal(0.5, 0.341), 0, 1)),
        # #P_I: replace with "random sampling"
        # if n < .48*numagents
        #     rand((0.8,1))
        # else
        #     rand((0,0.2,0.4,0.6))
        # end,
        # #P_I_C
        # 0,
        #P_P
        # let's say we have half the farmers participating
        n < numagents*propparticipants ? true : false
        end,
        )
        add_agent_single!(agent, model)
    end
    return model
end

model = initialize()

function agent_step!(agent, model)
    #P_C = model.P_C
    neighbor_agents = nearby_agents(agent, model)
    # update year counter
    # agent.yc = agent.yc + 1
    # # update water availability counter
    # if W_A[agent.yc+1,3] < 0
    #     agent.W_A_C = agent.W_A_C + 1
    # else
    #     agent.W_A_C = agent.W_A_C - 1
    # end
    # # # update climate change experience
    # if agent.W_A_C > 1 && agent.C_E < 1
    #     agent.C_E = agent.C_E + 0.1
    # elseif agent.W_A_C < -1 && agent.C_E > 0
    #     agent.C_E = agent.C_E - 0.1
    # else agent.C_E = agent.C_E
    # end
    # # update climate change experience
    # # if W_A[agent.yc+1,3] < 0 && agent.C_E < 1
    # #     agent.C_E = agent.C_E + 0.1
    # # elseif W_A[agent.yc+1,3] > 0 && agent.C_E > 0
    # #     agent.C_E = agent.C_E - 0.1
    # # else
    # #     agent.C_E = agent.C_E
    # # end
    # # updated policy participation counter
    # if agent.P_P == false
    #     agent.P_P_C = 0
    # else
    #     agent.P_P_C = agent.P_P_C + 1
    # end
    # # update past policy experience
    # if agent.P_P == false && agent.P_E < 0.70
    #     agent.P_E = agent.P_E + 0.01
    # elseif agent.P_P == false && agent.P_E >= 0.70
    #     agent.P_E = agent.P_E
    # else
    #     agent.P_E = (agent.P_E + model.P_C  * agent.P_P_C / (agent.P_P_C + 2) ) / 2
    # end
    # # calculate climate change belief
    # agent.C_B = 0.39 * agent.C_B + 0.61 * (0.24 * agent.C_E + 0.76 * agent.P_E)
    # # calculate perceived climate change risk
    # agent.C_R = 0.2 * agent.C_R + 0.8 * (0.88 * agent.C_B + 0.12 * agent.C_E - 0.14*agent.P_E)
    # # calculate program participation intention
    # # model social interaction here
    # # idea: if neighbor is similar in cc exp and policy exp
    # # model pi after their participation
    # # else do the opposite
    # # agent.P_I = - 0.18 * agent.C_E + agent.C_R
    # f_n = rand(neighbor_agents)
    # neighbor_agent_C_B = f_n.C_B
    # neighbor_agent_P_P = f_n.P_P
    # if abs(C_B - neighbor_agent_C_B) <= 0.5 && neighbor_agent_P_P == true
    #     agent.P_I = 0.28 - 0.13 * agent.C_E + 0.72 * agent.C_R
    # elseif abs(C_B - neighbor_agent_C_B) >= 0.5 && neighbor_agent_P_P == false
    #     agent.P_I = 0.28 - 0.13 * agent.C_E + 0.72 * agent.C_R
    # else
    #     agent.P_I = - 0.13 * agent.C_E + 0.72 * agent.C_R
    # end
    # agent.P_I = 0.28 * agent.P_I - 0.13 * agent.C_E + 0.72 * agent.C_R
    # # update participation intention counter
    # if agent.P_I >= 0.8
    #     agent.P_I_C = agent.P_I_C + 1
    # elseif agent.P_I <= 0.4
    #     agent.P_I_C = agent.P_I_C - 1
    # else
    #     agent.P_I_C = agent.P_I_C
    # end
    # # update program participation
    # if agent.P_I_C > 1
    #     agent.P_P = true
    # elseif agent.P_I_C < -1
    #     agent.P_P = false
    # else
    #     agent.P_P = agent.P_P
    # end
    f_n = rand(neighbor_agents)
    neighbor_agent_P_P = f_n.P_P
    if neighbor_agent_P_P == true
        agent.P_P = true
    else
        agent.P_P = false
    end
end


#observe = [:yc, :W_A_C, :C_E, :C_R, :C_B, :P_E, :P_I, :P_I_C, :P_P]
model = initialize(numagents = 100, propparticipants = 0, griddims = (15,15), P_C = 0.5)
run!(model, agent_step!, 10)
obsdata, _ = run!(model, agent_step!, 20; adata = observe)
obsdatasumm = combine(groupby(obsdata, "step"), :C_E => mean, :C_R => mean,
:C_B => mean, :P_E => mean, :P_I => mean, :P_I_C => mean, :P_P => count)
obsdatasumm.W_A = 1 .- W_A[1:21,2]
obsdatasumm.P_P_perc = obsdatasumm.P_P_count./maximum(obsdata.id)
# Plots!
plotx = obsdatasumm.step
#ploty = [obsdatasumm.W_A obsdatasumm.C_E_mean obsdatasumm.P_E_mean obsdatasumm.C_B_mean obsdatasumm.C_R_mean obsdatasumm.P_I_mean obsdatasumm.P_P_perc]
ploty = Matrix(obsdatasumm[:,[9,2,5,4,3,6,10]])
plotlabels = ["Water availability" "CC Experience" "Policy Experience" "CC Belief" "Perceived CC Risk" "Participation Intention" "Participation"]
plot(plotx, ploty, label = plotlabels, legend = :bottomright)
