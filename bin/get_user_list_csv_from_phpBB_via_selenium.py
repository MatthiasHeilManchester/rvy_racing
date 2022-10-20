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
import datetime
import time

#==============================================================
# Main
#==============================================================
def main(argv):

   # Process command line args
   #--------------------------
   password_string=''
   try:
      opts, args = getopt.getopt(argv,"hp:",["password="])
   except getopt.GetoptError:
      print('get_user_list_csv_from_phpBB_via_selenium.py --password <password> ')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print('get_user_list_csv_from_phpBB_via_selenium.py --password <password> ')
         sys.exit()
      elif opt in ("-p", "--password"):
         password_string = arg

   # Check: all args must be specified      
   if (password_string==''):
       print('Specify password string with --password')
       sys.exit(2)
       

   # Now start the actual web stuff
   #-------------------------------
   sleep_time=0.05
   
   # Fire it up
   #-----------
   driver = webdriver.Chrome('/usr/bin/chromedriver')
   driver.get('https://www.matthias-heil.co.uk/phpbb/adm/index.php')
   driver.maximize_window()

   # Log in
   #-------
   password_string = password_string.strip()
   if password_string == '':
      print("I'm not logging in. Password string: --",password_string,"--")
   else:
      print("I'm logging in with password: --",password_string,"--")

      
      # phpBB Login
      username_field_for_login = By.XPATH,("/html/body/div[1]/div[2]/form/fieldset/label[1]/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(username_field_for_login)).send_keys("matthias")
  
      time.sleep(sleep_time)

      password_field_for_login = (By.XPATH,"/html/body/div[1]/div[2]/form/fieldset/label[2]/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(password_field_for_login)).send_keys(password_string)
      
      time.sleep(sleep_time)
      
      login_button_on_homepage = (By.XPATH,"/html/body/div[1]/div[2]/form/fieldset/input[1]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(login_button_on_homepage)).click()

      time.sleep(sleep_time)

      # ACP login
      acp_login_button = By.XPATH,("/html/body/div[1]/div[1]/div[2]/div/ul[1]/li[3]/a/span")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(acp_login_button)).click()

      password_field_for_login2 = (By.XPATH,"/html/body/div[1]/div[2]/form/div/div/div/fieldset/dl[2]/dd/input")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(password_field_for_login2)).send_keys(password_string)

      login_button_on_homepage2 = (By.XPATH,"/html/body/div[1]/div[2]/form/div/div/div/fieldset/dl[3]/dd/input[3]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(login_button_on_homepage2)).click()

      
      # Select user panel
      user_panel = (By.XPATH,"/html/body/div/div[2]/div[1]/ul/li[4]/a")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(user_panel)).click()
            
      user_extension_option = (By.XPATH,"/html/body/div/div[2]/div[2]/div/div[1]/div[4]/ul/li/a/span")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(user_extension_option)).click()


      # Get CSV file
      csv_export_button = (By.XPATH,"/html/body/div/div[2]/div[2]/div/div[2]/div/form[1]/div[1]/div/input[2]")
      WebDriverWait(driver,20).until(EC.element_to_be_clickable(csv_export_button)).click()

      print("done should now be logged in")
      wait = input("Hit return to shut down")
      

   

if __name__ == "__main__":
   main(sys.argv[1:])
