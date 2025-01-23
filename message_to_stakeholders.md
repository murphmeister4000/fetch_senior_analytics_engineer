### Subject: Rewards Project - Questions and Observations About Rewards Data

Hey [product stakeholder name/group],

I’ve been working on a high priority project with the Rewards team surrounding some common reporting questions they'd like to streamline for Leadership. I've been reviewing the data to better understand the relationships between receipts, products, users, and brands as I build out models for analysis. While doing so, I came across some data quality issues and have a few questions that I'd like to run by you.

For reference, the data I've been working with is the `receipts.json`, `users.json`, and `brands.json` data set files that I was told is straight from the Rewards product. I received files from your team that contain only the past few months of data in order to do some initial analyses and modeling work.

### Key Observations and Questions:
1. **Data Quality Issues**
    * **Non-unique Primary Keys:** For example, `user_id` in the users table isn’t unique, which complicates identifying distinct users.
    * **NULL Values:** Some columns have significant gaps. For instance, `brand_code` is NULL for all dates except January 2021. Is this expected?
    * **Missing Brand Information:** Some brands listed on receipts do not exist in the brands table. Should we expect a match between receipts and brands for all brand codes, or are there brands not tracked in the brands table?
    * **Pricing Complexity:** There are multiple price fields at both the receipt and item levels, but it’s unclear how they are calculated or intended to relate to one another. Is there documentation or guidance on this?
    * **Questions:**
        * Are these issues known or expected?
        * If so, is there a timeline for addressing them? If there are Jira tickets feel free to send me the links.
2. **Additional Data Sources**
    * Are there other datasets I could leverage to supplement the current rewards, brands, and users data?
    * For instance, is there a table that connects brand codes to external metadata, or a dataset that tracks product-level pricing rules?
3. **Data Ingestion**
    * Is the data currently being ingested in real-time or through batch processing?
    * Where and how is the data stored?
    * What is the average volume of incoming data? I’d like to ensure my models can scale to accommodate this.
4. **Next Steps**
    * Resolving these issues would really help improve the speed, accuracy, and reliability of the insights the Rewards team provides to Leadership. If any of these concerns are expected, knowing the rationale or timeline for resolution will help me design these models with those constraints and requirements in mind.

Let me know if a quick chat or follow-up documentation would help clarify these points.

Thanks so much for your time!

**- Ryan Murphy, Data Solutions - Senior Analytics Engineer**

