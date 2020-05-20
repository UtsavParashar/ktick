/-q tick/real_time_vwap.q -tp localhost:5000 -syms MSFT.O IBM.N GS.N -p 5004

/default command line arguments - tp is location of tickerplant.
/syms are the symbols we wish to subscribe to
default:`tp`syms!("::5000";"");

args:.Q.opt .z.x; /transform incoming cmd line arguments into a dictionary
args:`$default,args; /upsert args into default
args[`tp] : hsym first args[`tp];

/drop into debug mode if running in foreground AND
/errors occur (for debugging purposes)
\e 1

if[not "w"=first string .z.o;system "sleep 1"];

/initialize schema function
/- below function is similar to .u.rep
InitializeTrade:{[TradeInfo;logfile]
    0N!TradeInfo; /- Messages coming from log file
  `trade set TradeInfo 1;
  if[null first logfile;update v:0n,s:0Ni,rvwap:0n from `trade;:()];
  -11!logfile;
  update v:sums (size*price),s:sums size by sym from `trade;
  update rvwap:v%s from `trade; };

/this keyed table maps a symbol to its current vwap
vwap:([sym:`$()] rvwap:`float$());

/- upd:{if[not `trade=x;:()];`trade insert y};
upd:{if[`trade=x;`trade insert y]};

/
This intraday function is triggered upon incoming updates from TP.
Its behavior is as follows:
1. Add s and v columns to incoming trade records
2. Increment incoming records with the last previous s and v values
   (on per sym basis)
3. Add rvwap column to incoming records (rvwap is v divided by s)
4. Insert these enriched incoming records to the trade table
5. Update vwap table
\
updIntraDay:{[t;d]
  0N!d; /- Messages coming directly from the feed
  d:update s:sums size,v:sums size*price by sym from d;
  d:d pj select last v,last s by sym from trade;
  d:update rvwap:v%s from d;
  `trade insert d;
  `vwap upsert select last rvwap by sym from trade; };

/end of day function - triggered by tickerplant at EOD
/Empty tables
.u.end:{{delete from x}each tables `. }; /clear out trade and vwap tables

h:hopen args`tp /connect to tickerplant
InitializeTrade . h "(.u.sub[`trade;",(.Q.s1 args`syms),"];`.u `i`L)"
upd:updIntraDay /switch upd to intraday update mode