require 'csv'
require_relative 'utils'

calc_data_result = CSV.parse(File.read("bitcoin_procesed_data.csv"), headers: true)
# headers = [ "day1", "day2", "freq_date", "min", "max", "bin_width", "positive_proportion", "count", "num_bins", "average", "standard_deviation", "variance", "coefficient_of_variation"] 

array_posi = []
puts "Summary"
puts "| DAY1 |  DAY 2  |  % > 0 | Average |   SD  |"
calc_data_result.select{|e| e["positive_proportion"]}.each do |e|
  puts "|  #{ e["day1"].to_i > 9 ? e["day1"] : "0"+e["day1"]}  |    #{ e["day2"].to_i > 9 ? e["day2"] : "0"+e["day2"]}   | #{number_to_percentage e["positive_proportion"]} |  #{number_to_percentage e["average"]}  | #{number_to_percentage e["standard_deviation"]} |" 
  array_posi.push({:dif => e["positive_proportion"].to_f})
end


puts "ploting this de positive %"
# get the max value
max_value = calc_data_result.max_by{ |element| element["positive_proportion"].to_f }
puts max_value.inspect, ""
plot_frequency_chart(
  :freq_date => max_value["freq_date"].split(","), 
  :min => string_to_hash(max_value["min"]), 
  :max => string_to_hash(max_value["max"]),
  :bin_width => max_value["bin_width"], 
  :positive_proportion => max_value["positive_proportion"].to_f, 
  :count => max_value["count"].to_f, 
  :num_bins => max_value["num_bins"].to_f,
  :average => max_value["average"].to_f,
  :standard_deviation => max_value["standard_deviation"].to_f,
  :variance => max_value["variance"].to_f,
  :coefficient_of_variation => max_value["coefficient_of_variation"].to_f
  )

min_standard_deviation = calc_data_result.min_by{ |element| element["standard_deviation"].to_f }
puts min_standard_deviation.inspect, ""
plot_frequency_chart(
  :freq_date => min_standard_deviation["freq_date"].split(","), 
  :min => string_to_hash(min_standard_deviation["min"]), 
  :max => string_to_hash(min_standard_deviation["max"]),
  :bin_width => min_standard_deviation["bin_width"], 
  :positive_proportion => min_standard_deviation["positive_proportion"].to_f, 
  :count => min_standard_deviation["count"].to_f, 
  :num_bins => min_standard_deviation["num_bins"].to_f,
  :average => min_standard_deviation["average"].to_f,
  :standard_deviation => min_standard_deviation["standard_deviation"].to_f,
  :variance => min_standard_deviation["variance"].to_f,
  :coefficient_of_variation => min_standard_deviation["coefficient_of_variation"].to_f
  )

# histograma de % > 0
puts "histograma de % > 0",""
array_posi_summary = frequency_chart(array_posi,20)
puts(**array_posi_summary)
plot_frequency_chart(**array_posi_summary)