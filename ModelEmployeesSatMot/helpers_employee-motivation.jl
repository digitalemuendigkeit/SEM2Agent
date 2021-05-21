# This file contains helper functions for the experiments
# Summarize agentdata
function sumemployeedata(adata, mdata)
    summarydata = combine(groupby(adata, "step"), :Stress => mean,
                :Stress => std, :EmployeeNiceness => mean,
                :EmployeeNiceness => std, :EmployeeRelations => mean,
                :EmployeeRelations => std, :EmployeeSatisfaction => mean,
                :EmployeeSatisfaction => std, :EmployeeMotivation => mean,
                :EmployeeMotivation => std,
                :Stress => (x -> quantile(x, 0.25)) =>  :Stresslower,
                :Stress => (x -> quantile(x, 0.75)) => :Stressupper,
                :EmployeeMotivation => (x -> quantile(x, 0.25)) => :EmployeeMotivationlower,
                :EmployeeMotivation => (x -> quantile(x, 0.75)) => :EmployeeMotivationupper)
    mdatasumm = combine(groupby(mdata, "step"), :Success => mean)
    summarydata = innerjoin(summarydata, mdatasumm, on = :step)
    return summarydata
end

# Plotting function
function plotemployeegraph(summarydata)
    plot(summarydata.step, summarydata.Stress_mean,
    label = "Stress mean", linecolor = "#0077BB", ylims = [-1,1],
    legend = :bottom,
    xlabel = "steps")
    plot!(summarydata.step, summarydata.Stresslower, linealpha = 0,
    fillrange = summarydata.Stressupper, fillcolor ="#0077BB",
    fillalpha = 0.15, label = "Stress Q2-Q3")
    plot!(summarydata.step, summarydata.EmployeeNiceness_mean, linecolor = "#009988",
    # ribbon = summarydata.EmployeeNiceness_std, fillalpha = 0.15,
    label = "Fraction nice mean")
    plot!(summarydata.step, summarydata.EmployeeRelations_mean, linecolor = "#EE3377",
    #ribbon = summarydata.EmployeeRelations_std, fillalpha = 0.15,
    label = "Perceived relations mean")
    plot!(summarydata.step, summarydata.EmployeeSatisfaction_mean, linecolor = "#33BBEE",
    label = "Satisfaction mean")
    plot!(summarydata.step, summarydata.EmployeeMotivation_mean, linecolor = "#EE7733",
    # ribbon = summarydata.EmployeeMotivation_std, fillalpha = 0.15,
    label = "Motivation mean")
    plot!(summarydata.step, summarydata.EmployeeMotivationlower, linealpha = 0,
    fillrange = summarydata.EmployeeMotivationupper, fillcolor ="#EE7733",
    fillalpha = 0.15, label = "Motivation Q2-Q3")
    plot!(summarydata.step, summarydata.Success_mean, linecolor = "#CC3311",
    #ribbon = summarydata.EmployeeMotivation_std, fillalpha = 0.15,
    label = "Success mean")
end
