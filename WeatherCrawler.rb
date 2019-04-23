require 'selenium-webdriver'
require 'fileutils'
require 'csv'
#Parse CSV to ruby Table
table = CSV.read("Fire.csv", headers: true)
# List of desired sensor information
sensors=["2-(hourly) - PRECIPITATION, ACCUMULATED", "4-(hourly) - TEMPERATURE, AIR", "9-(hourly) - WIND, SPEED", "10-(hourly) - WIND, DIRECTION", "11-(hourly) - FUEL MOISTURE, WOOD", "12-(hourly) - RELATIVE HUMIDITY", "13-(hourly) - FUEL TEMP,WOOD PROBE", "77-(hourly) - WIND, PEAK GUST", "78-(hourly) - WIND, DIRECTION OF PEAK GUST"]
#Open new browser
driver = Selenium::WebDriver.for :chrome 
#Pass starting points for coarse and smooth grain adjustments in case of crashes, index 0 lets you select the Fire you want to start on if it crashes, and index 1 lets you select the file you want to try first.
index= ARGV[0]
index2= ARGV[1]
#Open Website and wait for it to load
driver.get("http://cdec.water.ca.gov/dynamicapp/wsSensorData")
sleep(1)
#2d loop, one for table length, the other for list of sensors
for i in index.to_i..table.length - 1
  # Sets Station ID. This website sucks and needs to be loaded in a specific order with very dealayed timing. That's why this is ordered the way it is with the excessive sleep statements.
  driver.find_element(:id, "STAID").send_keys(table[i]["ID"])
  driver.find_element(:id, "STAID").send_keys(:tab)
  for j in index2.to_i..sensors.length-1
    sleep(2)
    dl=driver.find_element(:id, "SENSOR")
    sleep(2)
    Selenium::WebDriver::Support::Select.new(dl).select_by(:text, sensors[j])
    sleep(1)
    # These values MUST be set after the STAID and the dropdown box, as the website has a nasty habit of auto-correcting to the current date.
    driver.find_element(:id, "startInput").clear()
    driver.find_element(:id, "startInput").send_keys(table[i]["sd"])
    driver.find_element(:id, "STAID").send_keys(:tab)
    driver.find_element(:id, "endInput").clear()
    driver.find_element(:id, "endInput").send_keys(table[i]["ed"])
    driver.find_element(:id, "endInput").click()
    #If it won't download, try upping this number; sometimes the website just refuses if you don't give it enough time to update its search query for your specific ranges.
    sleep(6)
    driver.find_element(:xpath, "id('tableInputFields')/tbody[1]/tr[5]/td[2]/span[1]/input[1]").click()
  end
  #Set index 2 to 0 to allow the next fire to carry on unaffected by the user-defined starting point.
  index2=0
  driver.find_element(:id, "STAID").clear()
  #Moves .xlsx files to a directory named after the fire, as I cannot change their names using ruby itself before they download.
  dir = table[i]["Name"]
  FileUtils.mkdir_p dir 
  dir="mv ~/Downloads/*.xlsx " + dir.gsub(" ","\\ ")
  system(dir)
end
exit
