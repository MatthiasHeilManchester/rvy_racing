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

#==============================================================
# Main
#==============================================================
def main(argv):



   # Process command line args
   #--------------------------
   date_string = ''
   route_string = ''
   password_string=''
   try:
      opts, args = getopt.getopt(argv,"hd:r:p:",["date=","route=","password="])
   except getopt.GetoptError:
      print('create_rouvy_races.py --date <date (dd.mm.yyyy)> --route <route> --password <password>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print('create_rouvy_races.py --date <date (dd.mm.yyyy)> --route <route> --password <password>')
         sys.exit()
      elif opt in ("-r", "--route"):
         route_string = arg
      elif opt in ("-d", "--date"):
         date_string = arg
      elif opt in ("-p", "--password"):
         password_string = arg


   # Check: route and date must be specified      
   if (route_string==''):
       print('Specify route string with --route')
       sys.exit(2)
   if (date_string==''):
       print('Specify date string with --date')
       sys.exit(2)

       
   # Check if specified date is valid
   date_is_valid = re.match('^\d{2}\.\d{2}\.\d{4}$',date_string)
   if date_is_valid:
       print("date is valid")
   else:
       print("date is invalid")
       sys.exit(2)

   # Tell us what we're doing     
   print('Route is ', route_string)
   print('Date  is ', date_string)


   # Default times (make adjustable)
   time_array=["07:00","15:00","18:00"]
   date_and_time_string_array=[]
   for time in time_array:
       date_and_time_string=date_string+" "+time
       date_and_time_string_array.append(date_and_time_string)

   # Show us what we're going to do    
   for date_and_time_string in  date_and_time_string_array:
       print("Creating race at: ",date_and_time_string)


   # hierher read in; this should be something like "rvy_racing race n" or just the number?   
   specified_race_name="dummy_ignore"

   # Now start the actual web stuff
   #-------------------------------

   # Fire it up
   #-----------
   driver = webdriver.Chrome('/usr/bin/chromedriver')
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
            
   else:

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

      
   print("Scanned all invited races")
   wait = input("Hit return to shut down")
   print("Shutting down")

   
   sys.exit()

   
