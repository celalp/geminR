#! /bin/bash


# This assumes that there is a table called jobs
# when geminR starts it will check for that and create it if it does not
# exists, you should not run this from the command line, this is for 
# geminR to use. 

# this is not for the desktop use of GeminR it is for shinyproxy only
# depending on the machine geminR is running you can adjust the number of jobs

if [ -e scheduler.log ] 
  then
    echo $(date) "Found log file" >> ./scheduler.log
  else
    echo $(date) "Creating scheduler log for the first time" >> ./scheduler.log
fi

echo $(date) "Scheduler Starting" >> ./scheduler.log

DB=$1
MAX_JOBS=$2

parse_job(){
  local db=$1
  JOB_PARAMS=$(sqlite3 -separator ':' $db "SELECT * FROM jobs WHERE status=\"waiting\" LIMIT 1" )
  if [ ${#JOB_PARAMS} -eq 0 ]
    then
      echo $(date) "There are no pendig jobs" >> ./scheduler.log
      exit
    else 
      JOB_NAME=$(echo $JOB_PARAMS | cut -d ':' -f 2 )
      JOB_COMMAND=$(echo $JOB_PARAMS | cut -d ':' -f 3)
      sqlite3 $db "UPDATE jobs SET status = 'running' where job_name = \"$JOB_NAME\""
  fi
}


while true
  do 
  RUNNING=$(sqlite3 -separator ':' $DB "SELECT count(*) FROM jobs WHERE status=\"running\"" )
  #echo ${#RUNNING}
  if [ ${RUNNING} -lt $MAX_JOBS ]
  then
    parse_job $DB
    echo $(date) "$JOB_COMMAND for $JOB_NAME submitted" >> ./scheduler.log
    bash job_submit.sh "$JOB_COMMAND" "$JOB_NAME" "$DB" &
  else 
    sleep 10
  fi
done





  
  
  
  