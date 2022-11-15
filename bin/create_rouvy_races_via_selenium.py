#! /usr/bin/python

import os
import selenium

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
import sys, getopt
import re
import time
import datetime
from dateutil import parser



#==============================================================
# Main
#==============================================================
def main(argv):



   # Process command line args
   #--------------------------
   date_string = ''
   route_string = ''
   password_string=''
   race_number_string=''
   try:
      opts, args = getopt.getopt(argv,"hd:r:p:n:",["date=","route=","password=","race_number="])
   except getopt.GetoptError:
      print('\nUsage:\ncreate_rouvy_races.py --date <date (dd.mm.yyyy)> --route <route> --password <password> --race_number <race_number>\n\nExample:\n ./create_rouvy_races_via_selenium.py --date 02.12.2022 --route "Passo dello Stelvio via Umbrailpass" --password "gumbo11" --race_number 19\n')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print('\nUsage:\ncreate_rouvy_races.py --date <date (dd.mm.yyyy)> --route <route> --password <password> --race_number <race_number>\n\nExample:\n ./create_rouvy_races_via_selenium.py --date 02.12.2022 --route "Passo dello Stelvio via Umbrailpass" --password "gumbo11" --race_number 19\n')
         sys.exit()
      elif opt in ("-r", "--route"):
         route_string = arg
      elif opt in ("-d", "--date"):
         date_string = arg
      elif opt in ("-p", "--password"):
         password_string = arg
      elif opt in ("-n", "--race_number"):
         race_number_string = arg


   # Check: all args must be specified      
   if (route_string==''):
       print('Specify route string with --route')
       sys.exit(2)
   if (date_string==''):
       print('Specify date string with --date')
       sys.exit(2)
   if (race_number_string==''):
       print('Specify race number string with --race_number')
       sys.exit(2)
   if (password_string==''):
       print('Specify password string with --password')
       sys.exit(2)

       
   # Check if specified date is valid
   date_is_valid = re.match('^\d{2}\.\d{2}\.\d{4}$',date_string)
   if date_is_valid:
       print("date is valid")
   else:
       print("date is invalid")
       sys.exit(2)

   # Tell us what we're doing     
   print('Route        is ', route_string)
   print('Date         is ', date_string)
   print('Race number  is ', race_number_string)


   # Default times (make adjustable)
   time_array=["07:00","15:00","18:00"]
   date_and_time_string_array=[]
   for my_time in time_array:
       date_and_time_string=date_string+" "+my_time
       date_and_time_string_array.append(date_and_time_string)

   # Nest day
   main_race_day=date_string[0:2]
   print('main_race_day =',main_race_day)
   
   main_race_month=date_string[3:5]
   print('main_race_month =',main_race_month)
   
   main_race_year=date_string[6:10]
   print('main_race_year =',main_race_year)
       
   main_race_date = datetime.datetime(int(main_race_year), int(main_race_month), int(main_race_day))
   print('main_race_date = ', main_race_date)

   day_after_main_race_date = main_race_date+datetime.timedelta(days=1)
   print('day_after_main_race_date = ', day_after_main_race_date)

   day_after_main_race_day=day_after_main_race_date.strftime("%d")
   day_after_main_race_month=day_after_main_race_date.strftime("%m")
   day_after_main_race_year=day_after_main_race_date.strftime("%Y")


   # Race times on next day
   time_array=["02:00"]
   for my_time in time_array:
       date_and_time_string=day_after_main_race_day+"."+day_after_main_race_month+"."+day_after_main_race_year+" "+my_time
       date_and_time_string_array.append(date_and_time_string)
   
   # Show us what we're going to do
   weekday_string=parser.parse(date_string).strftime("%a") 
   for date_and_time_string in  date_and_time_string_array:
       print("Creating race at: ",date_and_time_string)

   
   if ( (weekday_string != 'Wed') and (weekday_string != 'Sat') ) :
      print("\n=========================================================================")
      print("Warning! Race is on ",weekday_string,"! Are you sure this is correct?")
      print("=========================================================================\n")
      wait = input("Hit return to continue")

   
   # Race name (later modified with upper case letter to identify sub-race for different time-zones
   specified_race_name="rvy_racing race "+race_number_string+ " "


   #print("done");
   #sys.exit()


   # Now start the actual web stuff
   #-------------------------------

   # Fire it up
   #-----------
   driver = webdriver.Chrome('/usr/bin/chromedriver')

   #sys.exit()
   
   driver.get('https://my.rouvy.com/en')
   driver.maximize_window()

   # Log in
   #-------
   if password_string == '':
      print("I'm not logging in. Password string: --",password_string,"--")
   else:
      print("I'm logging in with password: --",password_string,"--")

      # Login
      email_field_for_login = By.XPATH,("/html/body/div[3]/div/div/div[1]/div[1]/div/form/div[1]/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(email_field_for_login)).send_keys("M.Heil@maths.manchester.ac.uk")


      password_field_for_login = (By.XPATH,"/html/body/div[3]/div/div/div[1]/div[1]/div/form/div[2]/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(password_field_for_login)).send_keys(password_string)
      
      login_button_on_homepage = (By.XPATH,"/html/body/div[3]/div/div/div[1]/div[1]/div/form/input[1]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(login_button_on_homepage)).click()


   # Go to race page
   #----------------
      
   # Should be able to bypass this but the subsequent xpaths get confused; not sure why
   go_there_by_clicking=1
   if go_there_by_clicking:

      # Drop down menu "Explore"; choose "Races" option
      #------------------------------------------------
      
      explore_drop_down_menu = (By.XPATH,"/html/body/nav/div/div[2]/ul[2]/li[2]/a")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(explore_drop_down_menu)).click()
      
      race_option_in_explore_drop_down_menu =  (By.XPATH,"/html/body/nav/div/div[2]/ul[2]/li[2]/ul/li[5]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(race_option_in_explore_drop_down_menu)).click()
      
      print("CURRENT URL (AFTER CLICKING): ",driver.current_url)
      
   else:

      # Go there directly
      driver.get('https://my.rouvy.com/onlinerace')
      print("CURRENT URL (DIRECT): ",driver.current_url)



   # Now loop over the races
   #------------------------

   # Click on "Create online race" button:
   create_online_race_button = (By.XPATH,"/html/body/div[3]/div/div/div/div[2]/div/div[2]/div/a")
   WebDriverWait(driver,20).until(EC.element_to_be_clickable(create_online_race_button)).click()
      
   race_number=1
   for current_date_and_time_string in  date_and_time_string_array:
       print("About to create race at: ",date_and_time_string)
   
       if 1==1:
          
           print("CURRENT URL at start of creating the actual race",driver.current_url)
           
           smart_trainers_only_tick = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[1]/div[2]/div[1]/label/span")
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(smart_trainers_only_tick)).click()

           # Race name
           race_name=specified_race_name+chr(64+race_number)
           print("Race name: ",race_name)
           race_number += 1
           race_name_field = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[1]/div[1]/div[1]/div[2]/input")
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(race_name_field)).send_keys(race_name)

           date_and_time_string = current_date_and_time_string # date_and_time_string_array[0] # "22.09.2022 07:00"
           date_and_time_field = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[1]/div[1]/div[2]/div/div[2]/input")
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(date_and_time_field)).send_keys(date_and_time_string)

           done_date_and_time_button = (By.XPATH,"/html/body/div[5]/div[3]/button[2]")
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(done_date_and_time_button)).click()

           route_name = route_string # "Tuttensee 1st trial ever"
           route_keywords_field = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[2]/div[2]/div[2]/input")
           WebDriverWait(driver,40).until(EC.element_to_be_clickable(route_keywords_field)).send_keys(route_name)

           route_select_button = (By.XPATH,"/html/body/ul[1]")
           WebDriverWait(driver,40).until(EC.element_to_be_clickable(route_select_button)).click()

           old_url=driver.current_url

           # Not really sure why it needs that wait, but sleep is better than remembering
           # to hit return...
           #wait = input("Hit return to click on create race button")
           time.sleep(5)

           create_race_button = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[7]/div/input[3]")
           WebDriverWait(driver,40).until(EC.element_to_be_clickable(create_race_button)).click()
           
           # wait = input("Have clicked on create race button; hit return to continue")

           #new_url=driver.current_url
           #print("old url: ",old_url)
           #print("new url: ",new_url)
           #while (new_url == old_url):
           #    print("clicking again")
           #    #WebDriverWait(driver,20).until(EC.element_to_be_clickable(create_race_button)).click()
           #    new_url=driver.current_url
           #    print("new url: ",new_url)

           print("Done race ",race_name)

           driver.get('https://my.rouvy.com/onlinerace/create')
           #print("CURRENT URL (should be race create page): ",driver.current_url)




   print("Done setting up races; now extract urls")
   # wait = input("Hit return to shut down")
   #print("Shutting down")
   #wait = input("Extract urls")

   ############################################################################
   # start from here

   # Go there directly (subsequent xpaths don't work, even though they seem to be correct
   driver.get('https://my.rouvy.com/onlinerace')
   
   
   # Locate table that contains the future events
   table_xpath="/html/body/div[3]/div/div/div/div[2]/div/div[1]/div/div/table/tbody"
   
   # Get number of rows
   tr_xpath=table_xpath+"/tr"
   
   # Note plural in call.
   elements=driver.find_elements(By.XPATH,tr_xpath)
   nrow = len(elements)
   
   # Get number of columns
   #td_xpath=table_xpath+"/tr[2]/td"
   #elements=driver.find_elements(By.XPATH,td_xpath)
   #ncol = len(elements)
   
   # Prepare list of race urls
   race_url_list=[]
   
   # Loop over all entries in table (until it gets itself confused; this is almost
   # certainly when it hits the separator "Invitations"; I only want to read the
   # the ones listed under "MY registrations to events"
   irow=1
   while True:
      irow=irow+1
      
      # Race title is in column 2
      race_title_xpath="/html/body/div[3]/div/div/div/div[2]/div/div[1]/div/div/table/tbody/tr["+str(irow)+"]/td[2]"
      
      # Link to race is in column 4
      race_link_xpath ="/html/body/div[3]/div/div/div/div[2]/div/div[1]/div/div/table/tbody/tr["+str(irow)+"]/td[4]/a"
      
      # Read the swine
      try:
         
         # Get race title
         
         # Note singular in call
         race_title=driver.find_element(By.XPATH,race_title_xpath).text
         
         # "in" strips out the postfix that enumerates the specific instance
         # of the race
         if specified_race_name in race_title:
            print("race name matches: ",race_title," = ",specified_race_name)
            race_url_direct=driver.find_element(By.XPATH,race_link_xpath).get_attribute("href")
            print("URL OF RACE INTO FILE2: ",race_url_direct)
            race_url_list.append(race_url_direct)
            print("number of entries: ",len(race_url_list))
            print(race_url_list)
            
      except:
         break
      
   print("---------master_race_list:------------")
   race_url_list.reverse()
   for url in race_url_list:
      print(url)
   print("---------master_race_list:------------")
      
      
   print("Scanned all races")
   print("Shutting down")
   
   
   sys.exit()


   # end here
   ############################################################################
        

if __name__ == "__main__":
   main(sys.argv[1:])

   # Table
   #/html/body/div[3]/div/div/div/div[3]/div/div[2]/div[1]

   # name of race (in row 3)
   #/html/body/div[3]/div/div/div/div[3]/div/div[2]/div[1]/table/tbody/tr[3]/td[3]

   # associated link (in row 3)
   #/html/body/div[3]/div/div/div/div[3]/div/div[2]/div[1]/table/tbody/tr[3]/td[9]/a

