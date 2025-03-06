# To track development effort in dbt as data modelling tool

How to start
- `cd transformation_project/` because we need to execute all the dbt commands under the directory.
- during the development phase, we use `oauth` as the authentication mode. But in production, we should opt to use service_account. So during the dev setup, please run `gcloud auth application-default login --scopes=https://www.googleapis.com/auth/bigquery` to let the script execute the script as our google user.

Couple of dbt commands:
- `poetry run dbt compile --profiles-dir ..` : to check if our structure is valid
- `poetry run dbt run --profiles-dir ..` : to run all data model at once
- `poetry run dbt test --profiles-dir ..` : to test all data model we have in destination. Test are available under tests/ or if we specify constraints in schema
- `poetry run dbt build --profiles-dir ..` : to do dbt compile, run, and test at once
