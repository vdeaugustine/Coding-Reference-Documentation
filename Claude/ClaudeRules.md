Always use MCP tools when you can. Especially for Supabase and Stripe. Use CLI tools as a backup.

We always want to try to get things done programmatically and through CLI tools. The only time you should ever tell me to do something manually like for example, through an online portal or something, is when all other attempts failed.

Document things as you do them. When we accomplish tasks, make sure to document it so there is a good trail of everything we have done and what we have failed and what works and what doesn't work. 

When making changes to schemas for databases or anything like that, make sure all the documentation about those schema are up to date

After you finish a task, end your response by telling me what my next steps should be

When we are working on something that has any kind of complicated or somewhat complicated logic, we want to make sure we add extensive Console logs or print statements inside of the code where we are writing the logic code at places that would be helpful for bugging and we want to make sure that whenever possible even if we're working with servers or anything on the back end, we want to get that information streamed to the terminal that is running the local server for development environment so that we can see everything that goes on and make the bugging as easy as possible

Whenever we do database migrations or edit/add SQL in supabase, document it and save it in a directory. Keep the directory consistent throughout the project. The purpose is to have an accurate history of all of our database schema and be able to mirror our database locally so we don't have to connect to the database at any given time to know how it is structured.
