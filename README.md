# Fetch - Senior Analytics Engineer - Take Home Exercise
This public repo contains the code and information for Fetch's Senior Analytics Engineer interview exercise

## PART 1: Review Existing Unstructured Data and Diagram a New Structured Relational Data Model
If you have a [Lucid Charts Account](https://www.lucidchart.com/) you can view the ERD diagram [here]([url](https://lucid.app/lucidchart/eac1e424-dc01-49a0-8448-c81d8b272314/edit?viewport_loc=-452%2C-363%2C3473%2C1779%2C7csK~ME78NlJ&invitationId=inv_e3eb63c6-acf1-476f-9ae7-94612efaee18))

If you don't have an account please refer to [Fetch ERD pdf](https://github.com/murphmeister4000/fetch_senior_analytics_engineer/blob/main/fetch_erd_diagram.pdf) in the repo.

## PART 2: Write queries that directly answer predetermined questions from a business stakeholder
### Environment Setup
In order to get up and running quickly and easily I used **Snowflake** (and AWS) to run my SQL queries.

If you have a cloud provider account (AWS, GCP, Azure) you can quickly create a Snowflake account, and you can even create a **30-day free trial account** if you'd like.

To setup your environment...
1. Create Snowflake account (and Cloud provider account) if you do not already have one.
2. Upload JSON files locally using the "Upload local files" functionality on the [Web Interface](https://docs.snowflake.com/en/user-guide/data-load-web-ui)
   * This helps us get up and running quickly rather than storing the file in our Cloud Provider account (e.g. S3 bucket) and then having to configure permissions between the provider and snowflake.
3. Run the code in
