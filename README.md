# Etiquette_Application
#### :ticket: Ticket System Using NFT for Fair and Transparent Transactions

### :mega: Purpose of planning this project
:arrow_forward: There is a need for a system to resolve consumers' complaints about ticket refund fees and to prevent fraudulent damage that may occur during transactions by presenting transparency in transaction details.  
:arrow_forward: By more clearly guaranteeing the ownership of tickets, it aims to establish a trading platform that can efficiently solve problems occurring in the current ticket trading market.  

### :page_with_curl: Database structure
<p align="center"><img src = "https://github.com/NFTIsland/Etiquette_Application/assets/83128226/6314a466-d318-4f3d-bb4f-a3f1ea0f986a" width="70%" height="70%"></p> 

:arrow_forward: The database is constructed by separately setting additional tables for performing major functions such as auctions, focusing on the 'users' table that stores user information and the 'tickets' table that stores ticket information.

### :pencil: Main Functions
- **_Login & Sign Up_**  
- **_Find ID or PW by sending a randomly generated password_**  
- **_Buying a ticket from a ticket vendor_**  
- **_Ticket transactions through auction among users_**  
- **_Ticket Trading Based On KLAY And NFT_**  
<p align="center"><img src = "https://github.com/NFTIsland/Etiquette_Application/assets/83128226/b2a3020e-df23-4988-9d89-98917b22a3c1" width="70%" height="70%"></p>  

:bookmark: Through drawer, you can see **_tickets you have, tickets you are interested in, tickets you are selling, tickets you are bidding, and expired tickets_** by listing.

### :bulb: Features
:pencil2: Basically, it consists of **_four main tabs_**, and the market is configured to carry out used ticket transactions between users as well as ticketing from ticket vendors.  
:pencil2: When signing up as a member, you have to go through Firebase mobile phone authentication and set passwords and nicknames.  
:pencil2: **_Individuals are given KAS addresses_** so that they can make transactions based on Klay in the app, and if they already have KAS addresses, they can also enter them directly.  
:pencil2: You can modify your personal information through Drawer, or check the list of tickets you have, and the Klay you have.  
:pencil2: **_Tickets with TokenID can be freely traded in Klay currency._**

### :briefcase: Auction
**_Using the uniqueness of NFT, the flow of tickets can be tracked, improving transparency in transaction history._**  
With this in mind, there is an auction function that allows free transactions between users to solve the problem of refund fees arising from the current ticket system.  
<p align="center"><img src = "https://github.com/NFTIsland/Etiquette_Application/assets/83128226/a256e1ff-0afc-48e5-8149-ac3fb6b01a7a" width="20%" height="20%"></p>  

:exclamation: **_In order to upload a ticket to Auction, the following three conditions must be met._**  
- The starting price of the auction must be less than or equal to the cost of the ticket.
- The immediate transaction price must be less than or equal to the cost of the ticket.  
- The starting price of the auction shall be divided into units of bidding.

### :bar_chart: Test
- Ubuntu 22.04
- Android Studio based on Windows
- MySQL Workbench 8.0 CE

**This project is the result of the 2022 Hanium Mentoring Contest.**
