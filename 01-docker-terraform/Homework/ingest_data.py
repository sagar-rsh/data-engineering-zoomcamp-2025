#!/usr/bin/env python
# coding: utf-8

import os
from time import time
import pandas as pd
from sqlalchemy import create_engine
import argparse

def main(params):
    user = params.user
    password = params.password
    host = params.host 
    port = params.port 
    db = params.db
    table_name = params.table_name
    url = params.url

    if url.endswith('.csv.gz'):
        csv_name = 'output.csv.gz'
    else:
        csv_name = 'output.csv'
    
    # Download the csv
    os.system(f"wget {url} -O {csv_name}")

    # Create database connection
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')

    # Set iteration chunk size
    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)

    # Move to next iteration
    df = next(df_iter)

    # Convert pickup and dropoff datetime to datetime object
    df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
    df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

    # Create empty table in database with just header row
    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    # Upload data
    df.to_sql(name=table_name, con=engine, if_exists='append')


    # While loop to keep inserting chunks of data into the database
    while True:
        try:
          t_start = time()

          df = next(df_iter)

          df.lpep_pickup_datetime = pd.to_datetime(df.lpep_pickup_datetime)
          df.lpep_dropoff_datetime = pd.to_datetime(df.lpep_dropoff_datetime)

          df.to_sql(name=table_name, con=engine, if_exists='append')

          t_end = time()
          print('Inserted another chunk... took %.3f second' % (t_end - t_start))
        except StopIteration:
          print('Finished ingesting data into database')
          break
        

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', required=True, help='user name for postgres')
    parser.add_argument('--password', required=True, help='password for postgres')
    parser.add_argument('--host', required=True, help='host for postgres')
    parser.add_argument('--port', required=True, help='port for postgres')
    parser.add_argument('--db', required=True, help='database name for postgres')
    parser.add_argument('--table_name', required=True, help='name of the table where we will write the results to')
    parser.add_argument('--url', required=True, help='url of the csv file')

    args = parser.parse_args()

    main(args)
