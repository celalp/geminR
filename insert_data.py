# this is written in python 3.5
# the purpose of this script is to get the result of the gemini or sql
# and then re-import it back to the database
# this is not be used by itself but is a part of the job scheduler.

# geminR will do the checking if the table already exists otherwise
# will continue with the process

import datetime as dat
import pandas as pd
import optparse as opt
from sqlalchemy import create_engine


# get the options here,
# one thing to note here is that we are using the same chunksize to read and
# write to sql so the chunksize should be 1/2 of the max value of the system

parser = opt.OptionParser()

parser.add_option("-f", dest="filename", action="store", type="string")
parser.add_option("-d", dest="database", action="store", type="string")
parser.add_option("-c", dest="chunksize", action="store", type="int")
parser.add_option("-t", dest="tablename", action="store", type="string")
(options, args) = parser.parse_args()

print(dat.datetime.now(), "initializing importer")

print(options.tablename, options.database, options.chunksize, options.filename)

db = "sqlite:///"+options.database


# connect to db otherwise throw a tantrum
try:
    engine = create_engine(db)
    print(dat.datetime.now(), "connected to database")
except ConnectionError:
    print(dat.datetime.now(), "Error connecting to database", options.database)

# need to read and import in chunks
try:
    for chunk in pd.read_csv(options.filename, sep="\t", chunksize=options.chunksize):
        chunk.to_sql(options.tablename, engine, chunksize=options.chunksize)
    print(dat.datetime.now(), "finished writing to", options.tablename)
except Exception:
    print(dat.datetime.now(), "file error") #I can do better than this I might need to call logger in
                                            # other iterations there needs to some error printing when
                                            # it actually fails.

print("Closing importer for", options.database, options.tablename)






