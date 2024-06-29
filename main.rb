require 'csv'
# TRM_data = CSV.read("./TRM-1991-2024.csv")
TRM_data = CSV.parse(File.read("TRM-1991-2024.csv"), headers: true)
# puts TRM_data[3]["UNIDAD"]
date_start = Date.new(2000, 01, 01) # "01/01/2024"
date_end =  Date.new(2024, 06, 25) # "25/06/2024"

def extract_data(
  start =  Date.new(2022, 01, 01),
  finish =  Date.new(2024, 06, 25),
  data = TRM_data)

  return data.select { |row| DateTime.parse(row['VIGENCIADESDE']).to_date >= start && DateTime.parse(row['VIGENCIAHASTA']).to_date <= finish }
end

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

# puts extract_data(date_start,date_end).inspect
def calculate_relative_month_price(data)
  start_date = data.last["VIGENCIADESDE"]
  finish_date = data.first["VIGENCIAHASTA"]
  months = months_between_dates(start_date,finish_date)
  data_per_month = months.map{ |m|
    month = m.split("-")[1].to_i
    year = m.split("-")[0].to_i
    current_month = extract_data(Date.new(year, month, 01),Date.new( month == 12 ? year + 1 : year, month == 12 ? 01 : month+1, 01), data)
    first_value = current_month.last["VALOR"].to_f
    current_month.map{ |row| [row["VIGENCIADESDE"],first_value,row["VALOR"].to_f/first_value,(row["VALOR"].to_f/first_value-1)*1600*first_value] }
  }
end

def search_by_day(array_of_arrays, target_day)
  result = []
  array_of_arrays.each do |sub_array|
    sub_array.each do |row|
      day = row[0].split("/")[0]
      result << row[2] if day.to_f == target_day.to_f
    end
  end
  result
end


def number_to_percentage(number)
  sprintf("%.2f%%", number * 100)
end
def calcular_media_y_desviacion_estandar(numeros)
  # Calcular la media
  media = numeros.sum.to_f / numeros.size

  # Calcular la varianza
  sum_of_squares = numeros.reduce(0) { |sum, x| sum + (x - media)**2 }
  varianza = sum_of_squares / (numeros.size - 1)

  # Calcular la desviación estándar
  desviacion_estandar = Math.sqrt(varianza)

  return :media => number_to_percentage(media), :desviacion_estandar =>  number_to_percentage(desviacion_estandar), :CV => number_to_percentage(desviacion_estandar/media) , :n => numeros.size
end

def get_average_per_day(parametrization_data)
  day_array =  (1..31).to_a
  puts "desviacion_estandar:"
  day_array.map{ |day| 
    day_array = search_by_day(parametrization_data, day)
    calc = [day,calcular_media_y_desviacion_estandar(day_array)] 
    puts day, calc.inspect, ""
  }
end

parametrization = calculate_relative_month_price extract_data(date_start,date_end)
# puts parametrization.inspect
parametrization.each { |m_data| puts DateTime.parse(m_data.last[0]).month, m_data.reverse.inspect, "" }

get_average_per_day(parametrization)