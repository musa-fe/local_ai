The problem seems to be related to the use of multiple JOINs in your SQL query, which are causing performance issues. To optimize this, you can try several strategies:

1. **Partitioning and Clustering**: If possible, partition or cluster your tables based on columns that will be used in WHERE clause or JOIN conditions. This will reduce the amount of data scanned during a query execution.

2. **Use Subqueries**: Instead of using multiple joins, try to use subqueries which can improve performance and readability of the SQL code.

3. **Avoid Using Functions on Columns in WHERE Clause**: If you are using functions like DATE_ADD or DATETIME during JOIN conditions or WHERE clause, it may slow down your query because BigQuery needs to calculate these values for every row before executing the join or where condition.

4. **Use EXISTS instead of JOIN**: If possible, use an EXISTS statement rather than a JOIN on large tables as it can be more efficient and faster in some cases.
5. **Use Appropiate Data Types**: Make sure you are using appropriate data types for your columns. For example, if you don't need to store time information with TIMESTAMP type.
6. **Indexing**: If possible, create indexes on the columns that will be used in WHERE clause or JOIN conditions.
7. **Use WITH Clause**: Use a WITH clause to break down complex queries into smaller, more manageable pieces.
8. **Partial Partitioning**: If possible, use partial partitioning instead of full table scan.
9. **Denormalize Data**: Sometimes denormalizing data can improve query performance as it reduces the number of joins required to get the final result set.
10. **Use WHERE Clause Filters Early**: Try to use WHERE clause filters early in your SQL queries.

Remember, the best optimization strategy will depend on the specific structure and content of your tables. Always test different strategies with a subset of your data first before applying them to your entire dataset.