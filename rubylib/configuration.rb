
# I just wanted an easy conf object that didn't need parsing out of
# a markup file, but needs to be excludable from git repo so that 
# cuttlefish passwords etc weren't world-shared. 
# 
# Also handy to use for updating different directories where stuff
# is read from and stored to, probably good as a reference for anyone
# trying to read along from home... 
# 
# 


module PIPEConf

  # Login details for Cuttlefish... 
  EMAIL_SERVER = "cuttlefish.oaf.org.au"
  EMAIL_PORT = 2525
  SENDING_DOMAIN = "pipeproject.info"
  USERNAME = "pipeproject_test_29"
  PASSWORD = "Ov9wAqjbmHvtSus2EHzH"
  AUTHTYPE = :plain

  ADMIN_EMAIL =  "ali.keen@gmail.com" 
  FROM_ADDRESS = "no-reply@pipeproject.info"
  FROM_NAME = "PIPE Project"

  LOG_FILE_DIR = "/var/www/pipeproject/sa/logs/"
  JSON_INDEX_DIR = "/var/www/pipeproject/sa/json/"
  XML_TOC_DIR = "/var/www/pipeproject/sa/xmldata/"
  SUMMARY_OUTPUT_DIR = "/var/www/pipeproject/sa/summaries/"


end
