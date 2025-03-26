# police-armory
qbcore police armory


this is built on top of another free release from someone else
https://forum.cfx.re/t/free-police-armory-ui/5241674

original code
https://github.com/NoonDevelopments/qb-policearmory

Usage Instructions

Run the SQL from setup folder query to create the database table
Use the admin commands to add items to the armory:
/addarmoryitem [job] [grade] [item] [label] [price] [description]
Example: /addarmoryitem police 0 WEAPON_PISTOL "Service Pistol" 100 "Standard issue service pistol"
To list all items in the armory: /listarmoryitems
To remove an item from the armory: /removearmoryitem [id]
This implementation will store all armory items in the database, making it easier to manage and modify without changing code files.
