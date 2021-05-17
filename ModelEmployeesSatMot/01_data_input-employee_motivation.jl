using DataFrames
using Arrow
using CSV
using Statistics

dsraw = CSV.read("ModelEmployeesSatMot/data-input/descriptive_statistics.csv",
DataFrame, decimal = ',')

#Tabelle zusammenfassen:
ds = combine(groupby(dsraw,:Variable), :Mean => (x -> (mean(x.-1)/2)-1) => :Mean,
"Standard Deviation" => (x -> mean(x)/2) => :SD)

Arrow.write("ModelEmployeesSatMot/data-input/sampleds.arrow", ds)
