# shell-utils

### Various utilities for usage in shell script and cron

- command-timeout.sh
  - Ability to lock a command out until a certain time is passed 
  - Usecase: Run daily cron jobs without having to rely on the specific cron job time   
    Instead of: `0 2 * * * my_backup_run.sh # Expects the server to be turned on at 02:00`  
    Do this: `*/10 * * * * command-timeout.sh "my_backup_run" 86400 # Attempts a run every 10 minutes, but locks on the command out for 24 hrs.`  
