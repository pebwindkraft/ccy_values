############################################################################
### an 'el cheapo' approach to display CCY values from coinmarketcap.com ###
############################################################################

initial release.

This software fetches data from coinmarketcap and blockchain.info via a shell script.

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
- ugh. Ok, yes. Here cookies come into the game. 

The next question will be:
"Can there be a button to update values from coinmarketcap.com?"
- grrr. This is how my back office data collector got converted into a front office tool.
Maybe one day this feature will be added :-)

"Can it also show several bitcoin addresses from blockchain.info?"
- yes ... 


So basically this script loads data from two web pages, and displays it in a terminal and as a webpage in the users home directory. 


COINMARKETCAP
=============

This part has two outputs:
1.)
Data is displayed in terminal window, so copy and paste into xls is easy.
2.)
an html file with some JavaScript is created, that can be loaded into a web browser.
In the web browser you can enter amounts, and see a total over your investment. 
(It works with cookies to store the sessions)

The currencies that are fetched are "hard coded" in the script. Just duplicate the lines, and choose the currency of interest. I have tested up to 12 currencies, don't know the hard limits yet.


BLOCKCHAIN.INFO
===============

This part reads data from a file "bc_addresses.txt", which contains a bitcoin address and a description, separated by blanks. 

1Q7aaagd5B9iobbbh83kSXVr7WWccc9g87 wallet_test_01

1Q8aaagCEqMxobbbSeds5LK9MMRcccPWVc wallet_test_02

1QEaaar4jr9AtbbbTXXRSEntZQFcccmTni wallet_test_03

1QGaaazt57toRbbb5b5k64b52ZdccczKjS wallet_test_04

1QHaaajaUmYS1bbbCM4psHbNVhvcccyoSN wallet_test_05

1QKaaa6on2Fv7bbbgLkoaJzJY6dcccv7Nc wallet_test_06

1QKaaaTi96gwUbbb45uivR6zbikcccBdVN wallet_test_07

1QKaaaoaDksMebbbUndbg658RFQcccVhgo wallet_test_08

1QKaaabKX1rN7bbbmEcUTMVvLDAccc8jFi wallet_test_09

1QLaaa9ZCRiejbbbcsvpDjvNS6ZcccLuVP wallet_test_10


I haven’t tried more than 15, don’t know the limits yet. BLOCKCHAIN.INFO has a 10 sec delay between each request.
It will show the bitcoins on each address, fetched from blockchain.info:

Bitcoin Address                     Description       Amount     in Euro

===============                     ===========       ======     =======

1Q7aaagd5B9iobbbh83kSXVr7WWccc9g87  wallet_test_01    4050          0.25

1Q8aaagCEqMxobbbSeds5LK9MMRcccPWVc  wallet_test_02    0             0.00

1QEaaar4jr9AtbbbTXXRSEntZQFcccmTni  wallet_test_03    12213         0.76

1QGaaazt57toRbbb5b5k64b52ZdccczKjS  wallet_test_04    211313       13.23

...


Todos:
======
many :-)

