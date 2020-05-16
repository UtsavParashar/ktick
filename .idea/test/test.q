upd_old::upd;
// Create a new log file and a handle to use
`:tradeLog set ();
h::hopen `:tradeLog;
// Define a new upd
upd:{[t;x] if[t=`trade;h enlist (`upd;t;x)]};
// Replay the log file
-11!(-2;`:./sym2020.05.13) /- 1016748j
// Revert the upd functionality
upd::upd_old

trade
quote

\pwd
\cd /Users/utsav/Desktop/repos/ktick/tick

\ts value each get`:sym2020.05.13 /- 3886 356523680j
\ts -11!`:sym2020.05.13 /- 3496 188744432j

\cp ./sym2020.05.13 ./sym2020.05.13_bkp
new:`:sym2020.05.13_new
new set ()
h:hopen new
upd:{[t;x]if[t=`trade;h enlist(`upd;t;x)]}
-11!`:./sym2020.05.13

2#get `:./sym2020.05.13_new






