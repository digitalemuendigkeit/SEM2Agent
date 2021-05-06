using Agents
using LightGraphs
using Random
using DataFrames
using Statistics
using StatsBase
using Arrow
# using CSV
# using Distributions
# using StatsPlots
using Plots

# Load input data
# Water availability
wateravailability = DataFrame(Arrow.Table("model_yolo-farming\\data-input\\water-availability.arrow"))
# Climate change belief
sample_cb = DataFrame(Arrow.Table("model_yolo-farming\\data-input\\sample-cb.arrow"))
# Climate change experience
sample_ce = DataFrame(Arrow.Table("model_yolo-farming\\data-input\\sample-ce.arrow"))
# Perceived climate change risk
sample_cr = DataFrame(Arrow.Table("model_yolo-farming\\data-input\\sample-cr.arrow"))
# Policy experience
sample_pe = DataFrame(Arrow.Table("model_yolo-farming\\data-input\\sample-pe.arrow"))
# Program participation intention
sample_pi = DataFrame(Arrow.Table("model_yolo-farming\\data-input\\sample-pw.arrow"))


# Define space
# Use LightGraphs to define space
# torus with 100 vertices and 200 edges
g = LightGraphs.grid((10, 10), periodic = true)
space = Agents.GraphSpace(g)

# Define agent
@agent  farmer GraphAgent begin
    # experience with climate change
    ccexperience::Float64
    # counts years the agent has participated in the program
    ppcounter::Int
    # past policy experience
    ppexperience::Float64
    # climate change belief
    ccbelief::Float64
    # climate change risk
    ccrisk::Float64
    # program participation intention
    ppintention::Float64
    # counts years of participation intention
    ppintcounter::Int
    # whether the agent participates in the program
    participation::Bool
end

# Define function to initialize model
# properties are:
# socialthreshold = how many neighbors have to participate to influence the agent
# participatefract = fraction of agents participating initially
# policyquality = "true" quality of the new program
function initialize(; socialthreshold = 0.5, participatefract = 0.5, programquality = 0.5)
    properties = Dict(:socialthreshold => socialthreshold,
                      :participatefract => participatefract,
                      :programquality => programquality,
                      :stepcounter => 1)
    model = AgentBasedModel(farmer, space; properties = properties, scheduler = random_activation)
    for i in vertices(model.space.graph)
        add_agent!(
        farmer(
        # id
        i,
        # position
        i,
        # ccexperience
        sample(sample_ce[:,1], Weights(sample_ce[:,2])),
        # policy participation counter
        0,
        # past policy experience - probably overcomplicated haha
        sum(sample(sample_pe[1:2,3], Weights(sample_pe[1:2,4])) +
            sample(sample_pe[1:2,5], Weights(sample_pe[1:2,6])) +
            sample(sample_pe[3:4,3], Weights(sample_pe[3:4,4])) +
            sample(sample_pe[3:4,5], Weights(sample_pe[3:4,6])) +
            sample(sample_pe[5:6,3], Weights(sample_pe[5:6,4])) +
            sample(sample_pe[5:6,5], Weights(sample_pe[5:6,6])) +
            sample(sample_pe[7:8,3], Weights(sample_pe[7:8,4])) +
            sample(sample_pe[7:8,5], Weights(sample_pe[7:8,6])))/8,
        # climate change belief
        sample(sample_cb[:,1], Weights(sample_cb[:,2])),
        # climate change risk
        sample(sample_cr[:,1], Weights(sample_cr[:,2])),
        # program participation intention
        sample(sample_pi[:,1], Weights(sample_pi[:,2])),
        # program participation intention counter
        0,
        # program participation
        sample([true, false],
        Weights([participatefract, 1-participatefract]))),
        i,
        model
        )
    end
    return model
end


# Define agent step function
function agent_step!(agent, model)
    # Update climate change experience
    if wateravailability.wacounter[model.stepcounter] > 1 && agent.ccexperience < 1
        agent.ccexperience = agent.ccexperience + 0.1
    elseif wateravailability.wacounter[model.stepcounter] < -1 && agent.ccexperience > 0
        agent.ccexperience = agent.ccexperience - 0.1
    else
        agent.ccexperience = agent.ccexperience
    end
    # Update program participation counter
    agent.participation == true ? agent.ppcounter = agent.ppcounter + 1 : agent.ppcounter = 0
    # Update past policy experience
    if agent.participation == false
        if agent.ppexperience < 0.70
            agent.ppexperience = agent.ppexperience + 0.01
        else
            agent.ppexperience = agent.ppexperience
        end
    else
        agent.ppexperience = (agent.ppexperience +
                                model.programquality * agent.ppcounter /
                                (agent.ppcounter + 2) ) / 2
    end
    # Update climate change belief
    agent.ccbelief = 0.39 * agent.ccbelief + 0.61 * (0.24 * agent.ccexperience + 0.76 * agent.ppexperience)
    # Update climate change risk
    agent.ccrisk = 0.2 * agent.ccrisk + 0.8 * (0.88 * agent.ccbelief + 0.12 * agent.ccexperience - 0.14*agent.ppexperience)
    # get list of the neighbors
    neighbor_list = neighbors(model.space.graph, agent.pos)
    # calculate the fraction of them participating
    fraction_participation = mean([model.agents[i].participation for i in neighbor_list])
    # Update program participation intention
    fraction_participation >= model.socialthreshold ?
     agent.ppintention = 0.25 + 1.69 * (0.72 * agent.ccrisk - 0.13 * agent.ccexperience) :
     agent.ppintention = 1.69 * (0.72 * agent.ccrisk - 0.13 * agent.ccexperience)
    # Update participation intention counter
     if agent.ppintention >= 0.75
         agent.ppintcounter = agent.ppintcounter + 1
     elseif agent.ppintention < 0.5
         agent.ppintcounter = agent.ppintcounter - 1
     else
         agent.ppintcounter = agent.ppintcounter
     end
     # Update participation status
     if agent.ppintcounter > 1
         agent.participation = true
     elseif agent.ppintcounter < -1
         agent.participation = false
     else
         agent.participation = agent.participation
     end
    return agent
end

function model_step!(model)
    model.stepcounter = model.stepcounter + 1
    return model
end

model = initialize()
adata, _ = run!(model, agent_step!, model_step!, 10, adata = [:ccexperience,
:ppexperience, :ccbelief, :ccrisk, :ppintention ,:participation])
summarydata = combine(groupby(adata, "step"), :participation => count)
obsdatasumm = combine(groupby(adata, "step"), :ccexperience => mean,
:ppexperience => mean, :ccbelief => mean, :ccrisk => mean, :ppintention
=> mean, :participation => mean)
obsdatasumm.wateravailability = wateravailability.wateravailability[1:11]
# Plots!
plotx = obsdatasumm.step
#ploty = [obsdatasumm.W_A obsdatasumm.C_E_mean obsdatasumm.P_E_mean obsdatasumm.C_B_mean obsdatasumm.C_R_mean obsdatasumm.P_I_mean obsdatasumm.P_P_perc]
ploty = Matrix(obsdatasumm[:,[8,2,3,4,5,6,7]])
plotlabels = ["Water availability" "CC Experience" "Policy Experience" "CC Belief" "Perceived CC Risk" "Participation Intention" "Participation"]
plot(plotx, ploty, label = plotlabels, legend = :topright)
