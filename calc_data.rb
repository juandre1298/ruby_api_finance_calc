require 'csv'
require_relative 'utils'


TRM_data = CSV.parse(File.read("Bitcoin_Historical_Data.csv"), headers: true)

def calculate_relative_month_price(data, date1, date2)
  # This method takes the storical data and compare the difference between 2 dats each month 
  # It returns { diff: (data[date2] - date[date1])/date[date1], date: date2 - date1 }

  # generate a date array 
  start_date = data.last["Date"]
  finish_date = data.first["Date"]
  months = months_between_dates(start_date,finish_date)
  result = {}
  
  # calculate the diference of the days in each month
  data.each do |row|
    current_date = DateTime.parse(row['Date']).to_date
    month_key = current_date.strftime("%Y-%m")
    if result.has_key?(month_key)
      if result[month_key][:date].split("/")[0] == date2.to_s
        result[month_key]= {:dif => ((result[month_key][:dif] - row["Price"].to_f)/row["Price"].to_f), :date => "#{result[month_key][:date]} - #{row["Date"]}" }  
      end
    else
      result[month_key]= {:dif => row["Price"].to_f, :date => row["Date"] }
    end
  end

  months.map do |e|
    year, month = e.split("-").map(&:to_i)
    if valid_date?(year, month, date1) && valid_date?(year, month, date2)
      { 
        dif: result[e][:dif].round(6), 
        dates: [
          Date.new(year, month, date1), 
          Date.new(year, month, date2)
        ] 
      }
    end
  end.compact
end

# calculate

date_start = Date.new(2000, 01, 01) # "01/01/2024"
date_end =  Date.new(2024, 06, 25) # "25/06/2024"

# calcular todos losp untos posibles
matrix_dif = Array.new(31) {[]}
for i in 1..31 do
  for j in 1..31 do
    day1 = i
    day2 = j
    if day2 > day1
      puts "Displaying the frequency chart DAY1: #{day1} DAY2: #{day2}",""
    
      data = calculate_relative_month_price(filter_data_by_date(date_start, date_end, TRM_data, day1, day2), day1, day2)
      num_bins = 20

      # calculate freq chart
      freq_chart_data = frequency_chart(data, num_bins)
      matrix_dif[i][j] = freq_chart_data
      # Plot the frequency chart
      # plot_frequency_chart(**freq_chart_data)
    end
  end
end
puts "matrix de proporcion positiva"
export_to_csv(matrix_dif, "bitcoin_procesed_data.csv")




# analisis estadisito de hipotesis
