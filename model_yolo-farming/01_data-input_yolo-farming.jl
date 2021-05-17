using DataFrames
using CSV
using Statistics
using Arrow

# Prepare water availability dataframe
# Load data from U.S. Drought Monitor
wa_raw = CSV.read("model_yolo-farming\\data-input\\USDM-Yolo-CA.csv", DataFrame, ignoreemptylines=true)
# Extract years for grouping
wa_raw.Year = SubString.(string.(wa_raw.MapDate), 1, 4)
# Group years
wa = combine(groupby(wa_raw, :Year), :D0 => mean, :D1 => mean, :D2 => mean,
:D3 => mean, :D4 => mean)
# Sort by year
wa = sort!(wa)
# Sum up different drought levels to drought index
select!(wa, :, AsTable(Not(:Year)) => sum => :droughtindex)
# Define water availability (1 - droughtindex/500)
wa.wateravailability = broadcast(-, 1, broadcast(/, wa.droughtindex, 500))
# Add change in water availability from year to year
wa.wachange = append!([0.0], diff(wa.wateravailability))
# Count years with negative and positive changes
wacounter = zeros(Int, size(wa,1))
for i in 2:length(wacounter)
        if wa.wachange[i] > 0
                wacounter[i] = wacounter[i-1] + 1
        elseif wa.wachange[i] < 0
                wacounter[i] = wacounter[i-1] - 1
        else
                wacounter[i] = wacounter[i-1]
        end
end
# Add to dataframe
wa.wacounter = wacounter
# Save dataframe to arrow
Arrow.write("model_yolo-farming\\data-input\\water-availability.arrow", wa)

# Prepare sample data
# Climate change experience data - 0 = no experience
# weight is number of agreements
ce = DataFrame(value = [-1, 0, 1], weight = [1, 74, 68])
# Save dataframe
Arrow.write("model_yolo-farming\\data-input\\sample-ce.arrow", ce)

# Policy experience data - 1 = good experience
pe = DataFrame(
        # short name of the policy
        policy = ["pesticide", "pesticide", "rice", "rice", "water", "water",
                "diesel", "diesel"],
        # how old the policy was at the time of the survey
        age = [21, 21, 19, 19, 8, 8, 4, 4],
        #  positive environmental impact: 1 = agree
        envvalue = repeat([1,-1], 4),
        # percentage of agreement
        envweight = [46, 54, 43, 57, 24, 76, 36, 64],
        # policy is too costly: 0 = agree
        costvalue = repeat([1,-1], 4),
        # percentage of agreement
        costweight = [83, 17, 80, 20, 73, 27, 49, 51]
)
# Save dataframe
Arrow.write("model_yolo-farming\\data-input\\sample-pe.arrow", pe)

# Climate change belief data: 0 = no belief, 1 = belief
# Agreement with "Average temperatures are increasing" gathered from figure
cb = DataFrame(value = [-1, -0.5, 0, 0.5, 1],
                weight = [15, 15, 31, 23, 16])
# Save dataframe
Arrow.write("model_yolo-farming\\data-input\\sample-cb.arrow", cb)

# Climate change risk data: 0 = no risk
# Agreement with "Climate change poses risks to agriculture globally"
# Gathered from figure
cr = DataFrame(value = [-1, -0.5, 0, 0.5, 1],
                weight = [11, 8, 27, 27, 27])
# Save dataframe
Arrow.write("model_yolo-farming\\data-input\\sample-cr.arrow", cr)

# Program participation intention/willingness: 0.8 - 1 = would participate
# 48 % would participate
pw = DataFrame(value = [-1, -0.5, 0, 0.5, 1],
                weight = [17, 18, 17, 24, 24])
# Save dataframe
Arrow.write("model_yolo-farming\\data-input\\sample-pw.arrow", pw)
