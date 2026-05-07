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

MIT License

Copyright (c) 2026 apiidriver

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
