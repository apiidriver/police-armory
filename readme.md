Usage Instructions
Run the SQL query to create the database table
Use the admin commands to add items to the armory:
/addarmoryitem [job] [grade] [item] [label] [price] [description]
Example: /addarmoryitem police 0 WEAPON_PISTOL "Service Pistol" 100 "Standard issue service pistol"
To list all items in the armory: /listarmoryitems
To remove an item from the armory: /removearmoryitem [id]
This implementation will store all armory items in the database, making it easier to manage and modify without changing code files.