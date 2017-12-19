#!/bin/sh
############################################################
### an 'el cheapo' approach to display CCY values        ###
############################################################
###                                                      ###
### ...                                                  ###
### nov2017 svn updated to use HTML5 localStorage Object ###
### dec2017 svn updated to use file for coinmarketcap    ###
###                                                      ###
############################################################

#################################################################
### date and time references for use in filenames and webpage ###
#################################################################
today="`date '+%y%m%d%H%M'`"
today_d="`date '+%Y-%B-%d'`"
today_h="`date '+%H:%M'`"

######################
### some filenames ###
######################
typeset -r log_fn=~/.ccy_values/ccy_values.log
typeset -r html_output_fn=~/ccy_index.html

# coin market cap 
typeset -r cmc_values_fqfn=~/.ccy_values/cmc_ccys.txt
typeset -r tmp_cmc_fn=~/.ccy_values/tmp_cmc_$today.tmp

# blockchain.info
typeset -r bc_addresses_fqfn=~/.ccy_values/bc_addresses.txt
typeset -r tmp_bci_fn=~/.ccy_values/tmp_bci_$today.tmp

######################
### some variables ###
######################
typeset -r num_of_greps=5
typeset -i num_of_ccys=0
typeset -i num_of_lines=0
typeset -i sleeptime=11

####################################################
### procedure to fetch data from blockchain.info ###
####################################################
bci_values() {
  echo " "
  printf "%-35s %-17s %-10s %7s\n" "Bitcoin Address" Description Amount "in Euro" 
  printf "%-35s %-17s %-10s %7s\n" "===============" "===========" "======" "=======" 
  while read line
   do
    bc_addr=$( echo $line | cut -d " " -f 1 )
    bc_desc=$( echo $line | cut -d " " -f 2 )
    cur_val=$( curl -s https://blockchain.info/de/q/addressbalance/$bc_addr )
    in_Eur=$( echo "scale=2; $btc2eur * $cur_val / 100000000" | bc )
    env -i LC_ALL=C printf "%-35s %-17s %-10s %7.2f\n" $bc_addr $bc_desc $cur_val $in_Eur | tee -a $tmp_bci_fn 
    echo "  <tr align=left>" >> $html_output_fn
    echo "   <td>$cur_val</td>\n   <td>$bc_addr</td>\n   <td>$bc_desc </td>\n   <td align=\"right\">$in_Eur</td>" >> $html_output_fn
    echo "  </tr>" >> $html_output_fn
    sleep $sleeptime
   done < $bc_addresses_fqfn
  }

######################################################
### procedure to fetch data from coinmarketcap.com ###
######################################################
cmc_values() {
  num_of_ccys=0
  if [ -f $tmp_cmc_fn ] ; then
    rm $tmp_cmc_fn
  fi
  while read line
   do
    cur_val=$( echo $line | cut -d " " -f 1 )
    curl -s https://api.coinmarketcap.com/v1/ticker/$cur_val/?convert=EUR >> $tmp_cmc_fn
    cur_val=$( echo $line | cut -d " " -f 2 )
    printf "\n%s\n" $cur_val >> $tmp_cmc_fn
    num_of_ccys=$(( $num_of_ccys + 1 ))
    sleep .1
   done < $cmc_values_fqfn
  }

###########################################################
### here we start                                       ###
### Adding a currency means duplicating two lines below ###
### (curl -w https:// ... ), and replacing the ccy name ###
###########################################################
if [ ! -d ~/.ccy_values ]; then mkdir ~/.ccy_values; fi
if [ ! -f $cmc_values_fqfn ] ; then 
  echo "file $cmc_values_fqfn missing, please create :-)"
  echo "exiting gracefully..."
  exit 1
fi
if [ ! -f $bc_addresses_fqfn ] ; then
  echo "file $bc_addresses_fqfn missing, please create :-)"
  echo "exiting gracefully..."
  exit 1
fi

echo "$today_d"  > $log_fn
echo "$today_h" >> $log_fn
echo "running ccy_values.sh on `hostname -s`"  >> $log_fn
echo " " >> $log_fn

echo "##############################################"
echo "### processing data from coinmarketcap.com ###"
echo "##############################################"

cmc_values

# extract the interesting part(s) 
grep -e "id\":" -e "symbol" -e "price_btc" -e "price_eur" -e "https" $tmp_cmc_fn | sed -e 's/"//g' -e 's/,/ /g' > $log_fn

# need to extract data later on from coinmarketcap file ($tmp_cmc_fn) with tail ...
num_of_lines=$(( $num_of_ccys * $num_of_greps ))

# create terminal output 
# tail -n $num_of_lines $log_fn | awk 'BEGIN { print "Currency (source: coinmarketcap.com)\tConversion Rate (Bitcoin)\tin EUR"} { ORS=""; if( NR % 4 != 1) print $2; if( NR % 4 == 0) print "\n"; else if( NR % 4 != 1) print "\t";}'

awk 'BEGIN { print "Currency (source: coinmarketcap.com)\tConversion Rate (Bitcoin)\tin EUR"} { ORS=""; if( NR % 5 != 1) print $2; if( NR % 5 == 0) print "\n"; else if( NR % 5 != 1) print "\t";}' $log_fn

btc2eur=$( head -n4 $log_fn | tail -n1 | cut -c 20-30 )

###############################
### create http output file ### 
###############################
echo "<HTML>\n<HEAD>" > $html_output_fn
echo " <title>Crypto Currency Overview</title>" >> $html_output_fn

echo "<style>" >> $html_output_fn
echo "body {" >> $html_output_fn
echo " font-family: verdana,arial,helvetica;" >> $html_output_fn
echo " background-color: darkslategrey;" >> $html_output_fn
echo " color: azure;" >> $html_output_fn
echo " }" >> $html_output_fn
echo ".h3 { color: orange; }" >> $html_output_fn
echo ".TableTXT { color: azure; }" >> $html_output_fn
echo ".TableTOTAL { font-weight: bold; }" >> $html_output_fn
echo ".LastUpdated { font-size:x-small; }" >> $html_output_fn
echo "a:link { color: azure; text-decoration: none; }" >> $html_output_fn
echo "a:visited { color: cadetblue; text-decoration: none; }" >> $html_output_fn
# echo "a:hover { color: orange; text-decoration: underline; font-weight:bold; }" >> $html_output_fn
echo "a:hover { color: orange; text-decoration: underline; }" >> $html_output_fn
echo "</style>" >> $html_output_fn
echo "   " >> $html_output_fn
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
tail -n $num_of_lines $log_fn | awk '{ ORS=""; \
 if( NR % 5 == 2)
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
tail -n $num_of_lines $log_fn | awk '{ ORS=""; \
 if( NR % 5 == 2)
  {
   ccy=$2;
   print "   var "ccy"_qty = document.getElementById(\""ccy"_qty\").value;\n"
   print "   var "ccy"_conv = document.getElementById(\""ccy"_conv\").value;\n"
   print "   var "ccy"_result = "ccy"_qty * "ccy"_conv;\n"
   print "   document.cookie = \""ccy"_qty=\"+"ccy"_qty+c_expires+\"; path=/;\";\n"
   print "   document.getElementById(\""ccy"_result\").innerHTML = "ccy"_result.toFixed(2);\n\n"
   ccy_total = ccy_total ccy "_result + "
  };
} END {
  sub( / \+ $/, ";", ccy_total)
  print "   var CCY_total = " ccy_total "\n"
}' >> $html_output_fn

# echo "   var CCY_total = BCH_result + BTC_result;" >> $html_output_fn
echo "   document.getElementById(\"CCY_total\").innerHTML = CCY_total.toFixed(2);" >> $html_output_fn
echo "  }" >> $html_output_fn
echo " </script>" >> $html_output_fn

echo "<h3 class="h3">source: <a href=\"https://coinmarketcap.com\">coinmarketcap.com</a></h3>" >> $html_output_fn
echo " <form action=\"ccy_index.html\" onsubmit=\"return calculate()\">" >> $html_output_fn
echo "  <table border=\"0\" cellspacing=\"7\" cellpadding=\"1\" class=\"TableTXT\">" >> $html_output_fn
echo "   <colgroup>" >> $html_output_fn
echo "    <col width=\"80\">\n    <col width=\"60\">\n    <col width=\"227\">\n    <col width=\"127\">\n    <col width=\"207\">" >> $html_output_fn
echo "   </colgroup>" >> $html_output_fn
echo "   <tr align=left>" >> $html_output_fn
echo "    <th>Quantity</th>\n    <th>Currency</th>\n    <th>Conversion Rate (BTC)</th>\n    <th>in EUR</th>\n    <th align=\"right\">Value in Euro</th>" >> $html_output_fn
echo "   </tr>" >> $html_output_fn
echo "   <tr align=left>" >> $html_output_fn

# tail -n $num_of_lines $log_fn | awk '{ ORS=""; \
awk '{ ORS=""; \
 if( NR % 5 == 1) { ccy_id=$2; }; 
 if( NR % 5 == 2) { ccy=$2; };
 if( NR % 5 == 3) { price_btc=$2 }; 
 if( NR % 5 == 4) { price_eur=$2 }; 
 if( NR % 5 == 0) {
   print "    <td><input type=\"text\" id=\""ccy"_qty\" size=\"4\" value=\"0\"></td>\n"
   print "    <td><a href=\""
   print $1 "\" target=\"_blank\">"ccy"</a></td>\n"
   print "    <td><a href=\"https://coinmarketcap.com/currencies/"
   print ccy_id"\" target=\"_blank\">"price_btc"</a></td>\n"
   print "    <td><input type=\"hidden\" id=\""ccy"_conv\" value=\""price_eur"\">"price_eur"</td>\n" 
   print "    <td align=\"right\"><span id=\""ccy"_result\"></span></td>\n   </tr>\n   <tr>\n"
  }
}' $log_fn >> $html_output_fn

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

echo " "
echo "##################################################"
echo "### processing blockchain.info,                ###"
echo "### with >10sec break between each request ... ###"
echo "##################################################"
echo "1 BTC = $btc2eur EUR" | tee $tmp_bci_fn

echo "<h3 class="h3">source: <a href=\"https://blockchain.info\">blockchain.info</a></h3>" >> $html_output_fn
echo " <table border=\"0\" cellspacing=\"7\" cellpadding=\"1\" class=\"TableTXT\">" >> $html_output_fn
echo "  <colgroup>" >> $html_output_fn
echo "   <col width=\"80\">\n   <col width=\"227\">\n   <col width=\"140\">\n   <col width=\"140\">" >> $html_output_fn
echo "  </colgroup>" >> $html_output_fn
echo "  <tr align=left>" >> $html_output_fn
echo "   <th>Satoshi</th>\n   <th>Bitcoin Address</th>\n   <th>Description</th>\n   <th align=\"right\">Value in Euro</th>" >> $html_output_fn
echo "  </tr>" >> $html_output_fn

#################################################
### processing file with addresses ...        ###
#################################################
bci_values 

echo "  <tr class=\"TableTOTAL\">" >> $html_output_fn
echo "   <td>Total</td><td></td><td></td><td></td>" >> $html_output_fn
echo "   <td align=\"right\"><span id=\"CCY_total\"></span></td>" >> $html_output_fn
echo "  </tr>" >> $html_output_fn
echo " </table>" >> $html_output_fn
echo " <p class="LastUpdated">Last updated: <span id="LastUpdated">$today_d, $today_h</span></p>" >> $html_output_fn
echo "</font>" >> $html_output_fn
echo "</BODY>"  >> $html_output_fn
echo "</HTML>"  >> $html_output_fn

# clean up and bye 
echo "cleaning up, deleting files "
# echo "  rm $tmp_cmc_fn"
# echo "  rm $tmp_bci_fn"
rm $tmp_cmc_fn
rm $tmp_bci_fn
echo "bye ... "


