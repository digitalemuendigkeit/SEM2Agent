using DataFrames
using Arrow
using CSV

dsraw = CSV.read("ModelEmployeesSatMot/data-input/descriptive_statistics.csv", DataFrame, decimal = ',')

#Tabelle zusammenfassen:
ds = combine(groupby(dsraw,:Variable), :Mean => mean => :Mean, "Standard Deviation" => mean => :SD)

Arrow.write("ModelEmployeesSatMot/data-input/sampleds.arrow", ds)
