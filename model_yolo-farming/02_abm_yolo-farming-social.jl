using Agents
using LightGraphs
using Random
using DataFrames
using Statistics
using StatsBase
using Arrow

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

# set random seed
Random.seed!(123)

# Define space
# Use LightGraphs to define space
# torus with 100 vertices and 200 edges
g = LightGraphs.grid((10, 10), periodic = true)
space = Agents.GraphSpace(g)

# Define agent
@agent farmer GraphAgent begin
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
# startyear = year the simulation starts
function initialize(; socialthreshold = 0.5, participatefract = 0.5,
    programquality = 0.5, startyear = 2010)
    properties = Dict(:socialthreshold => socialthreshold,
                      :participatefract => participatefract,
                      :programquality => programquality,
                      :stepcounter .=> startyear-1999)
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
        # program participation counter
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
    # agent.ccexperience = agent.ccexperience + mean(wateravailability.wachange[model.stepcounter : model.stepcounter + 2])
    # if mean(wateravailability.wachange[model.stepcounter : model.stepcounter + 2]) < 0
    #     agent.ccexperience < 1 ?
    #     agent.ccexperience = agent.ccexperience + 0.1 :
    #     agent.ccexperience = agent.ccexperience
    # else
    #     agent.ccexperience >= 0.1 ?
    #     agent.ccexperience = agent.ccexperience - 0.1 :
    #     agent.ccexperience = agent.ccexperience
    # end
    # if wateravailability.wachange[model.stepcounter] < 0
    #     agent.ccexperience == 1 ?
    #     agent.ccexperience = 1 :
    #     agent.ccexperience = agent.ccexperience + 0.05
    # else
    #     agent.ccexperience == 0 ?
    #     agent.ccexperience = 0 :
    #     agent.ccexperience = agent.ccexperience - 0.05
    # end
    agent.ccexperience = (2*agent.ccexperience + wateravailability.wachange[model.stepcounter])/3
    # Update program participation counter
    agent.participation == true ? agent.ppcounter = agent.ppcounter + 1 : agent.ppcounter = 0
    # Update past policy experience
    # This is roughly the yearly increase in policy approval based on
    # previous policies
    base_ppexperience = agent.ppexperience + 0.04
    if agent.participation == false
    # If they do not participate in the new program
    # Their perceptions of old policies/programs dominates
        # Increase incrementally until a max of about 0.4
        # which is the middle between the oldest two policies
        agent.ppexperience < 0.40 ?
        agent.ppexperience = base_ppexperience :
        agent.ppexperience = agent.ppexperience
    # If they do participate their perception of the quality increases as
    # they participate longer
    else
        agent.ppexperience = (base_ppexperience +
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
     # agent.ppintention = 0.25 + 1.69 * (0.72 * agent.ccrisk - 0.13 * agent.ccexperience) :
     # agent.ppintention = 1.69 * (0.72 * agent.ccrisk - 0.13 * agent.ccexperience)
     agent.ppintention = 0.5 + agent.ccrisk - 0.18 * agent.ccexperience :
     agent.ppintention = agent.ccrisk - 0.18 * agent.ccexperience
    # Update participation intention counter
     if agent.ppintention >= 0.5
         agent.ppintcounter = agent.ppintcounter + 1
     elseif agent.ppintention < 0
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

# Define model step
function model_step!(model)
    model.stepcounter = model.stepcounter + 1
    return model
end
