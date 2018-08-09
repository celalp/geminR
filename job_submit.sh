# !/bin/bash

COMMAND=$1
NAME=$2
DB=$3

eval "$COMMAND 1> $NAME.csv 2> $JOB_NAME.err"
CODE=$?

if [ $CODE -eq 0 ]
  then 
    sqlite3 $DB "UPDATE jobs SET status = 'done' where job_name = \"$NAME\""
    sqlite3 $DB "UPDATE jobs SET exit_code = $CODE where job_name = \"$NAME\""
    python3 insert_data.py -f $NAME.tsv -d $DB -t $NAME -c 1000 2> $NAME.err
    rm $JOB_NAME.err
    echo $(date) "$NAME done" >> ./scheduler.log
  else 
    sqlite3 $DB "UPDATE jobs SET status = 'error' where job_name = \"$NAME\""
    sqlite3 $DB "UPDATE jobs SET exit_code = $CODE where job_name = \"$NAME\""
    echo $(date) "There was an error in running the command see errlog $NAME.err" >> ./scheduler.log
fi
