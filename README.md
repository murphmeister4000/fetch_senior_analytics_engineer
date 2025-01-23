# Fetch - Senior Analytics Engineer - Take Home Exercise
This public repo contains the code and information for Fetch's Senior Analytics Engineer interview exercise.

Thank you for taking the time to review my submission! :)

## PART 1: Review Existing Unstructured Data and Diagram a New Structured Relational Data Model
If you have a [Lucid Charts Account](https://www.lucidchart.com/) you can view the ERD diagram [here](https://lucid.app/lucidchart/eac1e424-dc01-49a0-8448-c81d8b272314/edit?viewport_loc=-452%2C-363%2C3473%2C1779%2C7csK~ME78NlJ&invitationId=inv_e3eb63c6-acf1-476f-9ae7-94612efaee18)

If you don't have an account please refer to [Fetch ERD pdf](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/fetch_erd_diagram.pdf) in the repo.

## PART 2: Write queries that directly answer predetermined questions from a business stakeholder
### Environment Setup
In order to get up and running quickly and easily I used **Snowflake** (and AWS) to run my SQL queries.

If you have a cloud provider account (AWS, GCP, Azure) you can quickly create a Snowflake account, and you can even create a **30-day free trial account** if you'd like.

To setup your environment...
1. Create Snowflake account (and Cloud provider account) if you do not already have one.
2. Follow the steps and run the code outlined in the [snowflake setup](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/snowflake_data_setup.sql) sql file in the repo.
    1. Initialize the databases and schemas
    2. Upload JSON files locally using the "Upload local files" functionality on the [Web Interface](https://docs.snowflake.com/en/user-guide/data-load-web-ui)
        * This helps us get up and running quickly rather than storing the files in our Cloud Provider account (e.g. S3 bucket) and then having to configure permissions between the provider and snowflake.
    3. Create structured tables from the JSON files

### Run Queries to Answer the Questions
Run the code in the [SQL Queries](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/sql_queries.sql) file in the repo

Assumptions and answers for each question are commented in the code

## PART 3: Evaluate Data Quality Issues in the Data Provided
There are two files that contain code for data evaluation
1. [Data Quality Python Checks](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/data_quality_python_checks.py)
    * This is for a quick general overview of each file using pandas.
    * The data could be more modularized, but again for simplicity's sake and for a quick analysis I left it as is.
2. [Data Quality SQL Checks](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/data_quality_sql_checks.sql)
    * This is first used as a sanity check to make sure the uploaded data was uploaded properly
    * Next this is used for more specific data checks related to some of the questions in part 2
        * Are unique keys unique?
        * Do join keys have a high match rate between tables?
        * How is pricing evaluated between receipts and items?
        * Do some columns have gaps only in certain months?

## PART 4: Communicate with Stakeholders
Please see the markdown file [Message To Stakeholders](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/message_to_stakeholders.md)
