/- If we want to replay a TPLog File based on a condition i.e create a new log file which consists of only trade table records then we can follow below procedure

// Back existing tplog file from which we want to replay the records
\cp ./sym2020.05.13 ./sym2020.05.13_bkp;

// Create a new file where you want to replay the data
new:`:tradeLog;
// Set empty list to it so that we can use get command the get the records
new set ();
// Open an handle to the new file
h:hopen new;
// update upd function as per replay required in this case if table=trade then persist it in new
upd:{[t;x]if[t=`trade;h enlist(`upd;t;x)]};
// -11! can be used to replay the messages
-11!`:sym2020.05.13;

hclose h;

//- Testing and we are good
2#get `:tradeLog