# This file contains helper functions for the experiments
# Summarize agentdata
function sumdata(adata, mdata)
    summarydata = combine(groupby(adata, "step"), :ccexperience => mean,
                :ccexperience => std, :ppexperience => mean,
                :ppexperience => std, :ccbelief => mean, :ccbelief => std,
                :ccrisk => mean, :ccrisk => std, :ppintention => mean,
                :ppintention=> std, :participation => mean, :participation => std,
                :ppexperience => (x -> quantile(x, 0.25)) => :ppexperiencelower,
                :ppexperience => (x -> quantile(x, 0.75)) => :ppexperienceupper,
                :ccexperience => (x -> quantile(x, 0.25)) => :ccexperiencelower,
                :ccexperience => (x -> quantile(x, 0.75)) => :ccexperienceupper)
    stepcounter = combine(groupby(mdata, "step"),
                :stepcounter => minimum => :stepcounter).stepcounter
    summarydata.wateravailability = wateravailability.wateravailability[stepcounter[1]:stepcounter[length(stepcounter)]]
    summarydata.year = wateravailability.Year[stepcounter[1]:stepcounter[length(stepcounter)]]
    return summarydata
end

# Plotting function
function plotgraph(summarydata)
    plot(summarydata.year, summarydata.wateravailability,
    label = "Water availability", linecolor = "#0077BB", ylims = [-1,1],
    legend = :bottom,
    # dpi = 300,
    xlabel = "Years = steps")
    plot!(summarydata.year, summarydata.ppexperience_mean, linecolor = "#EE3377",
    label = "Policy experience mean")
    plot!(summarydata.year, summarydata.ppexperiencelower, linealpha = 0,
    fillrange = summarydata.ppexperienceupper, fillcolor ="#EE3377",
    fillalpha = 0.15, label = "Policy experience Q2&Q3")
    plot!(summarydata.year, summarydata.ccexperience_mean, linecolor = "#EE7733",
    label = "Climate change experience mean")
    plot!(summarydata.year, summarydata.ccexperiencelower, linealpha = 0,
    fillrange = summarydata.ccexperienceupper, fillcolor ="#EE7733",
    fillalpha = 0.15, label = "Climate change experience Q2&Q3")
    plot!(summarydata.year, summarydata.participation_mean, linecolor = "#009988",
    fillalpha = 0.15, label = "Participating fraction mean")
end

xticks = ["2010" "" "" "" "" "2015" "" "" "" "" "2020"]
function plotsumgraph(summarydata)
    # for i in 1:length(arraylist)
    plot(summarydata.year, summarydata.wateravailability,
    label = "Water availability", linecolor = "#0077BB", ylims = [-1,1],
    legend = :bottomright,
    # dpi = 300,
    xlabel = "Years = steps",
    xticks = (1:10, xticks))
    plot!(summarydata.year, summarydata.ppexperience_mean, linecolor = "#EE3377",
    label = "Policy experience mean")
    plot!(summarydata.year, summarydata.ppexperiencelower, linealpha = 0,
    fillrange = summarydata.ppexperienceupper, fillcolor ="#EE3377",
    fillalpha = 0.15, label = "Policy experience Q2-Q3")
    plot!(summarydata.year, summarydata.ccexperience_mean, linecolor = "#EE7733",
    label = "Climate change experience mean")
    plot!(summarydata.year, summarydata.ccexperiencelower, linealpha = 0,
    fillrange = summarydata.ccexperienceupper, fillcolor ="#EE7733",
    fillalpha = 0.15, label = "Climate change experience Q2-Q3")
    plot!(summarydata.year, summarydata.participation_mean, linecolor = "#009988",
    fillalpha = 0.15, label = "Participating fraction mean")
end
