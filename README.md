############################################################################
### an 'el cheapo' approach to display CCY values from coinmarketcap.com ###
############################################################################

initial release.

This software fetches data from coinmarketcap via a shell script.
It has two outputs:
1.)
Data is displayed in terminal window, so copy and paste into xls is easy.
2.)
an html file with some JavaScript is created, that can be loaded into a web browser.
In the web browser you can enter amounts, and see a total over your investment. 
(It works with cookies to store the sessions)

The currencies that are fetched are "hard coded" in the script. Just duplicate the lines, and choose the currency of interest. I have tested up to 12 currencies, don't know the hard limits yet.

The "use case":
===============
The shell script was written to provide data to load into a back office database.
The shell script runs as a cron job (like once a day or every hour).
Later on data was requested to go into xls sheets. Instead of building a database connector, data is displayed in the terminal (or sent to file), and can be cut&pasted into an xls sheet. 
For sure cut&paste was not enough, data should be displayed in a web page.
Easy! 

"Can we have another column to put actual values in?"
- sure!

"Can we have another column to show the totals per coin and an overall total?"
- yes ...

"When I close my browser, I need to retype all values again... can't it store data?"
- ugh. Here cookies come into the game. 

The next question will be:
"Can there be a button to update values from coinmarketcap.com?"
- grrr. This is how my back office data collector got converted into a front office tool.
Maybe one day this feature will be added :-)


Todos:
======
many :-)
but log files and html output file are "flying" around. Need to get this sorted into home directory of user. Proper way would be to create a subdir ".ccy_values", and drop file there. 



