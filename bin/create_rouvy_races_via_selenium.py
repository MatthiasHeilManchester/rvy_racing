#! /usr/bin/python

import os
import selenium

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC

from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait


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
   route_id = ''
   password_string=''
   race_number_string=''
   try:
      opts, args = getopt.getopt(argv,"hd:r:p:n:",["date=","route_id=","password=","race_number="])
   except getopt.GetoptError:
      print('\nUsage:\ncreate_rouvy_races.py --date <date (dd.mm.yyyy)> --route_id <route_id> --password <password> --race_number <race_number>\n\nExample:\n ./create_rouvy_races_via_selenium.py --date 02.12.2022 --route_id 94865 --password "my_fancy_password" --race_number 19\n')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print('\nUsage:\ncreate_rouvy_races.py --date <date (dd.mm.yyyy)> --route_id <route_id> --password <password> --race_number <race_number>\n\nExample:\n ./create_rouvy_races_via_selenium.py --date 02.12.2022 --route_id 94865 --password "my_fancy_password" --race_number 19\n')
         sys.exit()
      elif opt in ("-r", "--route_id"):
         route_id = arg
      elif opt in ("-d", "--date"):
         date_string = arg
      elif opt in ("-p", "--password"):
         password_string = arg
      elif opt in ("-n", "--race_number"):
         race_number_string = arg


   # Check: all args must be specified      
   if (route_id==''):
       print('Specify route_id with --route_id')
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
   print('Route ID     is ', route_id)
   print('Date         is ', date_string)
   print('Race number  is ', race_number_string)


   # Default times (make adjustable)
   time_array=["07:00","15:00","18:00"]
   date_and_time_string_array=[]
   main_race_hour_array=[]
   main_race_minutes_array=[]
   for my_time in time_array:
       date_and_time_string=date_string+" "+my_time
       date_and_time_string_array.append(date_and_time_string)
       print("My time: ",my_time)
       main_race_hour_array.append(my_time[0:2])
       main_race_minutes_array.append(my_time[3:5])

   
   # Next day
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
       print("My time: ",my_time)
       main_race_hour_array.append(my_time[0:2])
       main_race_minutes_array.append(my_time[3:5])
       
   # Show us what we're going to do
   weekday_string=parser.parse(date_string).strftime("%a")
   count=0
   for date_and_time_string in  date_and_time_string_array:
       print("Creating race at: ",date_and_time_string)
       print("At hour:",main_race_hour_array[count]);
       print("At mins:",main_race_minutes_array[count]);
       count=count+1
   
   if ( (weekday_string != 'Wed') and (weekday_string != 'Sat') ) :
      print("\n=========================================================================")
      print("Warning! Race is on ",weekday_string,"! Are you sure this is correct?")
      print("=========================================================================\n")
      wait = input("Hit return to continue")

   
   # Race name (later modified with upper case letter to identify sub-race for different time-zones
   # dummy during development specified_race_name="tmp_dummy ignore race "+race_number_string+ " "
   specified_race_name="rvy_racing race "+race_number_string+ " "
   


   #print("done");
   #sys.exit()


   # Now start the actual web stuff
   #-------------------------------

   # Fire it up
   #-----------
   driver = webdriver.Chrome('/usr/bin/chromedriver')

   #sys.exit()
   
   driver.get('https://riders.rouvy.com/')
   driver.maximize_window()

   # Log in
   #-------
   if password_string == '':
      print("I'm not logging in. Password string: --",password_string,"--")
   else:
      print("I'm logging in with password: --",password_string,"--")


      ########################################################################
      # Procedure for obtaining xpath on raspberry pi:
      # Go to webpage
      # Ctrl-shift-i
      # click on select button in tool
      # click on html object on wepage; gets highlighted in source code
      # click on highlighted source code
      # Copy as "full xpath"
      # paste here
      ########################################################################


      # New (Dec. 2023: cookie)
      cookie_button = (By.XPATH,"/html/body/div[1]/div[1]/div/a[3]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(cookie_button)).click()
      
      # Login
      # email_field_for_login = By.XPATH,("/html/body/div[3]/div/div/div[1]/div[1]/div/form/div[1]/input")
      #email_field_for_login = By.XPATH,("/html/body/div[2]/div/div/div[1]/div[1]/div/form/div[1]/input")
      #email_field_for_login = By.XPATH,("/html/body/div[3]/div/div/div[1]/div[1]/div/form/div[1]/input")
      email_field_for_login = By.XPATH,("/html/body/div/div/div/div[2]/div/form/div/div[1]/div/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(email_field_for_login)).send_keys("M.Heil@maths.manchester.ac.uk")

      #password_field_for_login = (By.XPATH,"/html/body/div[3]/div/div/div[1]/div[1]/div/form/div[2]/input")
      #password_field_for_login = (By.XPATH,"/html/body/div[2]/div/div/div[1]/div[1]/div/form/div[2]/input")
      #password_field_for_login = (By.XPATH,"/html/body/div[3]/div/div/div[1]/div[1]/div/form/div[2]/input")
      password_field_for_login = (By.XPATH,"/html/body/div/div/div/div[2]/div/form/div/div[2]/div/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(password_field_for_login)).send_keys(password_string)

      #login_button_on_homepage = (By.XPATH,"/html/body/div[3]/div/div/div[1]/div[1]/div/form/input[1]")
      #login_button_on_homepage = (By.XPATH,"/html/body/div[2]/div/div/div[1]/div[1]/div/form/input[1]")
      #login_button_on_homepage = (By.XPATH,"/html/body/div[3]/div/div/div[1]/div[1]/div/form/input[1]")
      login_button_on_homepage = (By.XPATH,"/html/body/div/div/div/div[2]/div/form/div/button")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(login_button_on_homepage)).click()


   # Go to race page
   #----------------
      
   # Should be able to bypass this but the subsequent xpaths get confused; not sure why
   go_there_by_clicking=0
   if go_there_by_clicking:

      # Drop down menu "Explore"; choose "Races" option
      #------------------------------------------------
      print("Going to race generation page by clicking ",driver.current_url)

      explore_drop_down_menu = (By.XPATH,"/html/body/nav/div/div[2]/ul[2]/li[2]/a")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(explore_drop_down_menu)).click()
      
      race_option_in_explore_drop_down_menu =  (By.XPATH,"/html/body/nav/div/div[2]/ul[2]/li[2]/ul/li[4]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(race_option_in_explore_drop_down_menu)).click()
      
      #print("CURRENT URL (AFTER CLICKING): ",driver.current_url)
      
   else:

      # Go there directly
      print("Going to race generation page directly ",driver.current_url)


      # Dunno why I need to load this twice
      create_event_url="https://riders.rouvy.com/events/setup?route="+route_id
      print("Info: create_event_url: ",create_event_url)

      driver.get(create_event_url);
      driver.get(create_event_url);


      #print("CURRENT URL (DIRECT): ",driver.current_url)


   #wait = input("Hit return to continue")

   # Now loop over the races
   #------------------------

   # Click on "Race" (rather than group ride) button; 
   #create_online_race_button = (By.XPATH,"/html/body/div[3]/div/div/div/div[2]/div/div[2]/div/a")
   #create_online_race_button = (By.XPATH,"/html/body/div[1]/main/div/form/div/div[1]/div/div[1]/div/div/button[2]")
   create_online_race_button = (By.XPATH,"/html/body/div[1]/main/div/div/form/div[1]/div/div[1]/div/div/button[2]/span")

#    press it a few times...
   #print("Info: create_online_race_button: ",create_online_race_button);

   # hierher giving up on this for now
   #WebDriverWait(driver,20).until(EC.element_to_be_clickable(create_online_race_button)).click()
   #WebDriverWait(driver,20).until(EC.element_to_be_clickable(create_online_race_button)).click()
   #WebDriverWait(driver,20).until(EC.element_to_be_clickable(create_online_race_button)).click()

   #wait = input("Hit return to continue. (race button clicked?)")

   race_number=1
   count=0
   for current_date_and_time_string in  date_and_time_string_array:
       print("About to create race at: ",date_and_time_string)
   
       if 1==1:
          
           print("CURRENT URL at start of creating the actual race",driver.current_url)

           # Race name
           race_name=specified_race_name+chr(64+race_number)
           print("Race name: ",race_name)
           race_number += 1
           #race_name_field = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[1]/div[1]/div[1]/div[2]/input")
           #race_name_field = (By.XPATH,"/html/body/div[1]/main/div/form/div/div[1]/div/div[2]/div/input")
           race_name_field = (By.XPATH,"/html/body/div[1]/main/div/div/form/div[1]/div/div[2]/div/input")
           
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(race_name_field)).send_keys(race_name)

           date_and_time_string = current_date_and_time_string # date_and_time_string_array[0] # "22.09.2022 07:00"
           #date_and_time_field = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[1]/div[1]/div[2]/div/div[2]/input")
           #date_and_time_field = (By.XPATH,"/html/body/div[1]/main/div/form/div/div[1]/div/div[3]/div/input")
           date_and_time_field = (By.XPATH,"/html/body/div[1]/main/div/div/form/div[1]/div/div[3]/div/input") # guessed


           # new format hierher read in
           date_and_time_string=main_race_day # "23" # 09 2025\t07 00"
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(date_and_time_field)).send_keys(date_and_time_string)
           
           date_and_time_string=main_race_month # "09" # 09 2025\t07 00"
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(date_and_time_field)).send_keys(date_and_time_string)
           
           date_and_time_string=main_race_year # "2045" # 09 2025\t07 00"
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(date_and_time_field)).send_keys(date_and_time_string)
           
           date_and_time_string="\t"+main_race_hour_array[count]   # "\t07" # 09 2025\t07 00"
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(date_and_time_field)).send_keys(date_and_time_string)
           
           date_and_time_string=main_race_minutes_array[count] # "15" # 09 2025\t07 00"
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(date_and_time_field)).send_keys(date_and_time_string)

           count+=1
           
           #wait = input("Hit return to continue. (date entered?)")

           # advanced_options_button = (By.XPATH,"/html/body/div[1]/main/div/form/div/div[1]/div/div[5]/button")
           advanced_options_button = (By.XPATH,"/html/body/div[1]/main/div/div/form/div[1]/div/div[5]/button/svg") # chevron

           # hierher giving up on this for now
           #WebDriverWait(driver,20).until(EC.element_to_be_clickable(advanced_options_button)).click()
           
           #smart_trainers_button =(By.XPATH,"/html/body/div[1]/main/div/form/div/div[1]/div/div[5]/div/div[1]/div[1]/button")
           smart_trainers_button =(By.XPATH,"/html/body/div[1]/main/div/div/form/div[1]/div/div[5]/div/div[1]/div[1]/button") # guessed
           # hierher giving up on this now
           #WebDriverWait(driver,20).until(EC.element_to_be_clickable(smart_trainers_button)).click()

           # hierher do we even need this?
           #search_route_button = (By.XPATH,"/html/body/div[1]/main/div/form/div/div[2]/button")
           #WebDriverWait(driver,20).until(EC.element_to_be_clickable(search_route_button)).click()

           # hierher do we even need this?
           #route_name = route_string # "Tuttensee 1st trial ever"
           #route_keywords_field = (By.XPATH,"/html/body/div[3]/div/div/div[2]/form/div[2]/div[2]/div[2]/input")
           #route_keywords_field = (By.XPATH,"/html/body/div[1]/main/div/div[2]/div[1]/div/input")
           #WebDriverWait(driver,40).until(EC.element_to_be_clickable(route_keywords_field)).send_keys(route_name)

           # hierher kill 
           #first_route_offered_button = (By.XPATH,"/html/body/div[1]/main/div/div[2]/div[4]/div/div/div")
           #first_route_offered_button = (By.XPATH,"/html/body/div[1]/main/div/div[2]/div[4]/div/div/div/article/div[1]");
           #WebDriverWait(driver,20).until(EC.element_to_be_clickable(first_route_offered_button)).click()



           # Coming back from this, it claims that we can't 
           # background_to_click_on = (By.XPATH,"//html/body/div[1]/main/div/form/div/div[1]


           # hierher can't guess
           #create_race_button = (By.XPATH,"/html/body/div[1]/main/div/form/div/button")
           create_race_button = (By.XPATH,"/html/body/div[1]/main/div/div/div/button")
           
           WebDriverWait(driver,20).until(EC.element_to_be_clickable(create_race_button)).click()

           # hierher displays error clicking on field fixes it and can then create race
           # by pressing onbutton again. However, currently races can't be deleted!
           wait = input("Hit return to continue. (race created?)")


           print("Done race ",race_name)

           #driver.get('https://my.rouvy.com/onlinerace/create')
           #print("CURRENT URL (should be race create page): ",driver.current_url)


           driver.get(create_event_url);
           driver.get(create_event_url);


   print("Done setting up races")
   sys.exit()










##################################################

















   
   wait = input("Please kill me")
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

