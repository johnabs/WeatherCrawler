require 'selenium-webdriver'
require 'fileutils'
require 'csv'
#Parse CSV to ruby Table
table = CSV.read("Fire.csv", headers: true)
sensors=["2-(hourly) - PRECIPITATION, ACCUMULATED", "4-(hourly) - TEMPERATURE, AIR", "9-(hourly) - WIND, SPEED", "10-(hourly) - WIND, DIRECTION", "11-(hourly) - FUEL MOISTURE, WOOD", "12-(hourly) - RELATIVE HUMIDITY", "13-(hourly) - FUEL TEMP,WOOD PROBE", "77-(hourly) - WIND, PEAK GUST", "78-(hourly) - WIND, DIRECTION OF PEAK GUST"]
#Open new browser
driver = Selenium::WebDriver.for :chrome 
index= ARGV[0]
index2= ARGV[1]
puts(index2.to_i)
#Pass website as command line argument
#Open Website and wait for it to load
driver.get("http://cdec.water.ca.gov/dynamicapp/wsSensorData")
sleep(1)
#Check to see if link contains the year 2012, as the web formatting is drastically different
for i in index.to_i..table.length - 1
  driver.find_element(:id, "STAID").send_keys(table[i]["ID"])
  driver.find_element(:id, "STAID").send_keys(:tab)
  for j in index2.to_i..sensors.length-1
    sleep(2)
    dl=driver.find_element(:id, "SENSOR")
    sleep(2)
    Selenium::WebDriver::Support::Select.new(dl).select_by(:text, sensors[j])
    sleep(1)
    driver.find_element(:id, "startInput").clear()
    driver.find_element(:id, "startInput").send_keys(table[i]["sd"])
    driver.find_element(:id, "STAID").send_keys(:tab)
    driver.find_element(:id, "endInput").clear()
    driver.find_element(:id, "endInput").send_keys(table[i]["ed"])
    driver.find_element(:id, "endInput").click()
    #If it won't download, try upping this number.
    sleep(6)
    driver.find_element(:xpath, "id('tableInputFields')/tbody[1]/tr[5]/td[2]/span[1]/input[1]").click()
  end
  index2=0
  driver.find_element(:id, "STAID").clear()
  dir = table[i]["Name"]
  FileUtils.mkdir_p dir 
  dir="mv ~/Downloads/*.xlsx " + dir.gsub(" ","\\ ")
  system(dir)
end
exit
