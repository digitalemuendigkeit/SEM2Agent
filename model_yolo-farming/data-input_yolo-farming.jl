using DataFrames
using CSV

# Prepare water availability dataframe
wa_raw = CSV.read("model_yolo-farming\\data-input\\USDM-Yolo-CA.csv", DataFrame)
wa_raw.Year = SubString.(string.(wa_raw.MapDate), 1, 4)
wa = combine(groupby(wa_raw, :Year), :D0 => mean, :D1 => mean, :D2 => mean,
:D3 => mean, :D4 => mean)
wa = sort!(wa)
# Sum up different drought levels to drought index
select!(wa, :, AsTable(Not(:Year)) => sum => :droughtindex)
# Define water availability (1 - droughtindex/500)
wa.wateravailability = broadcast(-, 1, broadcast(/, wa.droughtindex, 500))
# Add change in water availability from year to year
wa.wachange = append!([0.0], -diff(wa.wateravailability))
wacounter = repeat([0], 22)

wacounter2 = for i in length(wacounter)
    # wa.wachange[i] >= 0 ? wacounter[i] == wacounter[i-1] + 1 : wacounter[i] == wacounter[i-1]
        wa.wachange[i] >= 0 ? wacounter[i] == 2 : wacounter[i] == 3
        return wacounter
    end
