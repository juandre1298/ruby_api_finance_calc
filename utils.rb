require 'json'

def months_between_dates(start_date, finish_date)
  start_date = Date.parse(start_date)
  finish_date = Date.parse(finish_date)

  months = []
  current_date = start_date
  while current_date <= finish_date do
    months << current_date.strftime("%Y-%m")
    current_date = current_date.next_month
  end
  months
end

def valid_date?(year, month, day)
  Date.valid_date?(year, month, day)
end

def number_to_percentage(number)
    sprintf("%.2f%%", number.to_f * 100)
end

def string_to_hash(str)
  JSON.parse(str)
end

def calculate_statistics(numeros)
  # Calcular la media
  media = numeros.sum.to_f / numeros.size

  # Calcular la varianza
  sum_of_squares = numeros.reduce(0) { |sum, x| sum + (x - media)**2 }
  varianza = sum_of_squares / (numeros.size - 1)

  # Calcular la desviación estándar
  desviacion_estandar = Math.sqrt(varianza)

  return :average => media, :standard_deviation =>  desviacion_estandar, :variance => varianza, :coefficient_of_variation => desviacion_estandar/media , :count => numeros.size
end

def frequency_chart(data, num_bins)
  just_dif = data.map {|x| x[:dif]} 
  
  min_value_row = data.min_by { |element| element[:dif] }
  max_value_row = data.max_by { |element| element[:dif] }
  min_value = min_value_row[:dif] 
  max_value = max_value_row[:dif] 

  bin_width = (max_value - min_value) / num_bins.to_f
  overCero = just_dif.count {|x| x > 0}
  frequencies = Array.new(num_bins, 0)

  data.each do |row|
    bin_index = ((row[:dif] - min_value) / bin_width).floor
    bin_index = [bin_index, num_bins - 1].min  # Ensure bin_index does not exceed num_bins - 1
    frequencies[bin_index] += 1
  end

  calculate_statistics_result = calculate_statistics(just_dif)

  {
    "freq_date": frequencies,
    "min": min_value_row,
    "max": max_value_row,
    "bin_width": bin_width,
    "positive_proportion": overCero.to_f / data.length,
    "num_bins": num_bins,
    "count": calculate_statistics_result[:count],
    "average": calculate_statistics_result[:average],
    "standard_deviation": calculate_statistics_result[:standard_deviation],
    "variance": calculate_statistics_result[:variance],
    "coefficient_of_variation": calculate_statistics_result[:coefficient_of_variation]
  } 
end


def filter_data_by_date( start, finish, data, day1, day2)
  return data.select { |row| DateTime.parse(row['Date']).to_date.day == day1 || DateTime.parse(row['Date']).to_date.day == day2 }
end

def get_element_by_date(data,day1,day2,data_key = nil)
  if data_key
    return data.select { |row| row['day1'].to_i == day1 && row['day2'].to_i == day2 }[0][data_key]
    
    
  else
    return data.select { |row| row['day1'].to_i == day1 && row['day2'].to_i == day2 }[0]
  end
end


def plot_frequency_chart(
  freq_date:,
  min:,
  max:,
  bin_width:,
  positive_proportion:,
  num_bins:,
  count:,
  average: nil,
  standard_deviation:,
  variance:,
  coefficient_of_variation:)

  puts "frequency chart summary", ""

  puts "count: #{count}"
  puts "average: #{number_to_percentage average}"
  puts "standard_deviation: #{number_to_percentage standard_deviation}"
  puts "variance: #{variance}"
  puts "coefficient_of_variation: #{coefficient_of_variation}"
  puts "min_value: #{min[:dif]}"
  puts "max_value: #{max[:dif]}"
  puts "bin_width: #{bin_width}"
  puts "positive val: #{(positive_proportion*count).to_i} / #{count} => #{positive_proportion}",""
  
  puts "histogram"
  freq_date.each_with_index do |frequency, bin_index|
    range_start = min[:dif].to_f + bin_index * ((max[:dif].to_f - min[:dif].to_f) / num_bins)
    range_end = min[:dif].to_f + (bin_index + 1) * ((max[:dif].to_f - min[:dif].to_f) / num_bins)
    puts "Bin #{bin_index + 1}: #{range_start.round(2)} - #{range_end.round(2)} | Frequency: #{frequency}"
  end
  puts ""
end

def export_to_csv(nested_data, file_path)
  puts nested_data.inspect
  CSV.open(file_path, "wb") do |csv|
    # Define the headers
    headers = [
      "day1",
      "day2",
      "freq_date",
      "min",
      "max",
      "bin_width",
      "positive_proportion",
      "count",
      "num_bins",
      "average",
      "standard_deviation",
      "variance",
      "coefficient_of_variation"
    ]
    csv << headers

    # Add data rows
    nested_data.each_with_index do |day1_data, day1_index|
      if !day1_data.nil? && !day1_data.empty?
        day1_data.each_with_index do |day2_data, day2_index|
          # Check if day2_data is nil or empty
          if day2_data.is_a?(Array)
            day2_data = day2_data.to_h
          end

          # Check if day2_data is a hash
          if day2_data.is_a?(Hash)
            csv << [
              day1_index,
              day2_index,
              day2_data[:freq_date]&.join(', '),  # Convert array to comma-separated string for CSV
              JSON.generate(day2_data[:min]),
              JSON.generate(day2_data[:max]),
              day2_data[:bin_width],
              day2_data[:positive_proportion],
              day2_data[:count],
              day2_data[:num_bins],
              day2_data[:average],
              day2_data[:standard_deviation],
              day2_data[:variance],
              day2_data[:coefficient_of_variation] 
            ]
          else
            # Add an empty row to the CSV
            csv << [day1_index, day2_index] + Array.new(headers.length - 2)
          end
        end
      end
    end
  end
end

