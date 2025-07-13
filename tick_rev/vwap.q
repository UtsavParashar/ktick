/ connect to TP
h:hopen `::5000;

/ syms to subscribe to
s:`MSFT.O`IBM.N
/ table to hold info used in vwap calc
ttrades:([sym:`$()]price:`float$();size:`int$())

/ action for real-time data
upd_rt:{[x;y]ttrades+:select size wsum price,sum size by sym from y}

/ action for data received from log file
upd_replay:{[x;y]if[x~`trade;upd_rt[`trade; select from (trade upsert flip y) where sym in s]];}

/ clear table on end of day
.u.end:{[x]
  0N!"End of Day ",string x;
  delete from `ttrades;}

/ replay log file
replay:{[x]
  logf:x[1];
  if[null first logf;:()];      / return if logging not enabled on TP
  .[set;x[0]];                  / create empty table for data being sent
  upd::upd_replay;
  0N!"Replaying ",(string logf[0])," messages from log ",string logf[1];
  -11!logf;
  0N!"Replay done";}

/ subscribe and initialize
replay h"(.u.sub[`trade;",(.Q.s1 s),"];.u `i`L)";
upd:upd_rt;

/ client function to retrieve vwap
/ e.g. getVWAP[`IBM.N`MSFT.O]
getVWAP:{select sym,vwap:price%size from ttrades where sym in x}