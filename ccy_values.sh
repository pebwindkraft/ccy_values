#!/bin/sh
############################################################################
### an 'el cheapo' approach to display CCY values from coinmarketcap.com ###
############################################################################

###########################################################
### we store some date and time references in variables ###
###########################################################
today="`date '+%y%m%d%H%M'`"
today_d="`date '+%Y-%B-%d'`"
today_h="`date '+%H:%M'`"

tmp_fn=/Data/tmp/tmp_$today.tmp
html_output_fn=ccy_index.html
log_fn=ccy_values.log

######################
#### here we start ###
######################
echo "$today_d"  > $log_fn
echo "$today_h" >> $log_fn
echo "running ccy_values.sh on `hostname -s`"  >> $log_fn
echo " " >> $log_fn

wget -q -O - https://api.coinmarketcap.com/v1/ticker/bitcoin/?convert=EUR      > $tmp_fn
wget -q -O - https://api.coinmarketcap.com/v1/ticker/ethereum/?convert=EUR    >> $tmp_fn
wget -q -O - https://api.coinmarketcap.com/v1/ticker/aeon/?convert=EUR        >> $tmp_fn
wget -q -O - https://api.coinmarketcap.com/v1/ticker/siacoin/?convert=EUR     >> $tmp_fn
wget -q -O - https://api.coinmarketcap.com/v1/ticker/storj/?convert=EUR       >> $tmp_fn
wget -q -O - https://api.coinmarketcap.com/v1/ticker/storjcoin-x/?convert=EUR >> $tmp_fn
cat $tmp_fn | grep -e "symbol" -e "price_btc" -e "price_eur" | sed -e 's/"//g' -e 's/,/ /g' > $log_fn

# create terminal output 
tail -n 18 $log_fn | awk 'BEGIN { print "Currency (source: coinmarketcap.com)\tConversion Rate (Bitcoin)\tin EUR"} { ORS=""; print $2; if( NR % 3 == 0) print "\n"; else print "\t";}'

# create http output file
echo "<HTML>\n<HEAD>" > $html_output_fn
echo " <title>Crypto Currency Overview</title>" >> $html_output_fn

echo "<style>" >> $html_output_fn
echo "body {" >> $html_output_fn
echo " font-family: verdana,arial,helvetica;" >> $html_output_fn
echo " background-color: darkslategrey;" >> $html_output_fn
echo " color: azure;" >> $html_output_fn
echo " }" >> $html_output_fn
echo ".TableTXT { " >> $html_output_fn
echo " color: azure;" >> $html_output_fn
echo " }" >> $html_output_fn
echo ".TableTOTAL { " >> $html_output_fn
echo " font-weight: bold;" >> $html_output_fn
echo " }" >> $html_output_fn
echo ".LastUpdated { " >> $html_output_fn
echo " font-size:x-small;" >> $html_output_fn
echo " }" >> $html_output_fn
echo "</style>" >> $html_output_fn

echo "</HEAD>" >> $html_output_fn
echo "<BODY onload=\"initload()\">" >> $html_output_fn
echo " <script>" >> $html_output_fn
echo "  function getCookie(name) {" >> $html_output_fn
echo "   var nameEQ = name + \"=\";" >> $html_output_fn
echo "   var ca = document.cookie.split(';');" >> $html_output_fn
echo "   for(var i=0;i < ca.length;i++) {" >> $html_output_fn
echo "    var c = ca[i];" >> $html_output_fn
echo "    while (c.charAt(0)==' ') c = c.substring(1,c.length);" >> $html_output_fn
echo "     if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);" >> $html_output_fn
echo "   }" >> $html_output_fn
echo "   return null;" >> $html_output_fn
echo "  }" >> $html_output_fn
echo "  function initload() {" >> $html_output_fn
tail -n 18 $log_fn | awk '{ ORS=""; \
 if( NR % 3 == 1)
  {
   ccy=$2;
   print "   var "ccy"_qty=getCookie(\""ccy"_qty\");\n"
   print "   document.getElementById(\""ccy"_qty\").value="ccy"_qty;\n"
  };
}' >> $html_output_fn
echo "   document.getElementById(\"CCY_total\").innerHTML = 0;" >> $html_output_fn
echo "   calculate();" >> $html_output_fn
echo "  }" >> $html_output_fn
echo "  function calculate() {" >> $html_output_fn
echo "   var c_expires=\"; expires=Thu, 01 Feb 2027 00:00:00 UTC\";" >> $html_output_fn
tail -n 18 $log_fn | awk '{ ORS=""; \
 if( NR % 3 == 1)
  {
   ccy=$2;
   print "   var "ccy"_qty = document.getElementById(\""ccy"_qty\").value;\n"
   print "   var "ccy"_conv = document.getElementById(\""ccy"_conv\").value;\n"
   print "   var "ccy"_result = "ccy"_qty * "ccy"_conv;\n"
   print "   document.cookie = \""ccy"_qty=\"+"ccy"_qty+c_expires+\"; path=/;\";\n"
   print "   document.getElementById(\""ccy"_result\").innerHTML = "ccy"_result.toFixed(2);\n\n"

  };
}' >> $html_output_fn
echo "   var CCY_total = SJCX_result + STORJ_result + SC_result + AEON_result + ETH_result + BTC_result;" >> $html_output_fn
echo "   document.getElementById(\"CCY_total\").innerHTML = CCY_total.toFixed(2);" >> $html_output_fn
echo "  }" >> $html_output_fn
echo " </script>" >> $html_output_fn

echo "<h1>source: coinmarketcap.com</h1>" >> $html_output_fn
echo " <form action=\"ccy_index.html\" onsubmit=\"return calculate()\">" >> $html_output_fn
echo "  <table border=\"0\" cellspacing=\"7\" cellpadding=\"1\" class=\"TableTXT\">" >> $html_output_fn
echo "   <colgroup>" >> $html_output_fn
echo "    <col width=\"80\">\n    <col width=\"60\">\n    <col width=\"227\">\n    <col width=\"127\">\n    <col width=\"177\">" >> $html_output_fn
echo "   </colgroup>" >> $html_output_fn
echo "   <tr align=left>" >> $html_output_fn
echo "    <th>Quantity</th>\n    <th>Currency</th>\n    <th>Conversion Rate (BTC)</th>\n    <th>in EUR</th>\n    <th align=\"right\">Value in Euro</th>" >> $html_output_fn
echo "   </tr>" >> $html_output_fn
echo "   <tr align=left>" >> $html_output_fn

tail -n 18 $log_fn | awk '{ ORS=""; \
 if( NR % 3 == 1) 
  { 
   ccy=$2; 
   print "    <td><input type=\"text\" id=\""ccy"_qty\" size=\"4\" value=\"0\"></td>\n"
   print "    <td>"ccy"</td>\n"
  }; 
 if( NR % 3 == 2) 
  { 
   print "    <td>"$2"</td>\n"
  }; 
 if( NR % 3 == 0) 
  {
   print "    <td><input type=\"hidden\" id=\""ccy"_conv\" value=\""$2"\">"$2"</td>\n" 
   print "    <td align=\"right\"><span id=\""ccy"_result\"></span></td>\n   </tr>\n   <tr>\n"
  }
}' >> $html_output_fn

echo "   <tr>" >> $html_output_fn
echo "    <td></td><td></td><td></td><td></td><td align="right">=========</td>" >> $html_output_fn
echo "   </tr>" >> $html_output_fn
echo "   <tr class=\"TableTOTAL\">" >> $html_output_fn
echo "    <td>Total</td><td></td><td></td><td></td>" >> $html_output_fn
echo "    <td align=\"right\"><span id=\"CCY_total\"></span></td>" >> $html_output_fn
echo "   </tr>" >> $html_output_fn
echo "  </table>" >> $html_output_fn
echo "  <input type=\"button\" onclick=\"calculate();\" value=\"go!\"/>" >> $html_output_fn
echo " </form>" >> $html_output_fn
echo " <p class="LastUpdated">Last updated: <span id="LastUpdated">$today_d, $today_h</span></p>" >> $html_output_fn
echo "</font>" >> $html_output_fn
echo "</BODY>"  >> $html_output_fn
echo "</HTML>"  >> $html_output_fn

# clean up and bye 
rm $tmp_fn

