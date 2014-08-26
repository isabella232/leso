#!/bin/bash

echo "Generate raw CSV tables"
mkdir -p export/db
psql leso -c "COPY (
    select * from population
) to '`pwd`/export/db/population.csv' WITH CSV HEADER;"
psql leso -c "COPY (
    select * from codes
) to '`pwd`/export/db/codes.csv' WITH CSV HEADER;"
psql leso -c "COPY (
    select * from fips
) to '`pwd`/export/db/fips.csv' WITH CSV HEADER;"
psql leso -c "COPY (
    select * from data
) to '`pwd`/export/db/data.csv' WITH CSV HEADER;"
psql leso -c "COPY (
    select * from acs
) to '`pwd`/export/db/acs.csv' WITH CSV HEADER;"
psql leso -c "COPY (
    select * from general
) to '`pwd`/export/db/general.csv' WITH CSV HEADER;"
psql leso -c "COPY (
    select * from tactical
) to '`pwd`/export/db/tactical.csv' WITH CSV HEADER;"

echo "Export state data"
mkdir -p export/states
psql leso -t -A -c "select distinct(state) from data" | while read STATE; do
  echo "Creating export/states/$STATE.csv"
  psql leso -c "COPY (
    select d.state,
        d.county,
        f.fips,
        d.nsn,
        d.item_name,
        d.quantity,
        d.ui,
        d.acquisition_cost,
        d.quantity * d.acquisition_cost as total_cost,
        d.ship_date,
        d.federal_supply_category,
        d.federal_supply_class,
        c.full_name as federal_supply_class_name
      from data as d
      join fips as f on d.state = f.state and d.county = f.county
      join codes as c on d.federal_supply_class = c.code
      where d.state='$STATE'
    ) to '`pwd`/export/$STATE.csv' WITH CSV HEADER;"
done

echo "Creating export/states/all_states.csv"
psql leso -c "COPY (
  select d.state,
    d.county,
    f.fips,
    d.nsn,
    d.item_name,
    d.quantity,
    d.ui,
    d.acquisition_cost,
    d.quantity * d.acquisition_cost as total_cost,
    d.ship_date,
    d.federal_supply_category,
    d.federal_supply_class,
    c.full_name as federal_supply_class_name
  from data as d
  join fips as f on d.state = f.state and d.county = f.county
  join codes as c on d.federal_supply_class = c.code
) to '`pwd`/export/all_states.csv' WITH CSV HEADER;"
