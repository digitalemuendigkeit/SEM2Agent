# This file contains helper functions for the experiments
# Summarize agentdata
function sumdata(model, adata)
    summarydata = combine(groupby(adata, "step"), :ccexperience => mean,
                :ccexperience => std, :ppexperience => mean,
                :ppexperience => std, :ccbelief => mean, :ccbelief => std,
                :ccrisk => mean, :ccrisk => std, :ppintention => mean,
                :ppintention=> std, :participation => mean)
    summarydata.wateravailability = wateravailability.wateravailability[model.stepcounter-nrow(summarydata)+1:model.stepcounter]
    summarydata.year = wateravailability.Year[model.stepcounter-nrow(summarydata)+1:model.stepcounter]
    return summarydata
end

# Plotting function
function plotgraph(summarydata)
    plot(summarydata.year, summarydata.wateravailability,
    label = "Water availability", ylims = [-1,1],
    legend = :bottomright, xlabel = "Years = steps")
    plot!(summarydata.year, summarydata.ppexperience_mean,
    ribbon = summarydata.ppexperience_std, fillalpha = 0.15,
    label = "Policy experience")
    plot!(summarydata.year, summarydata.ccexperience_mean,
    ribbon = summarydata.ccexperience_std, fillalpha = 0.15,
    label = "CC experience")
    plot!(summarydata.year, summarydata.participation_mean, fillalpha = 0.15,
    label = "Participation fraction")
end
