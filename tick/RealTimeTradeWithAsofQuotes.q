/
The purpose of this script is as follows:
1. Demonstrate how custom real-time subscribers can be created in q
2. In this example, create an efficient engine for calculating
   the prevalent quotes as of trades in real-time.
   This removes the need for ad-hoc invocations of the aj function.
3. In this example, this subscriber also maintains its own binary
   log file for replay purposes.
   This replaces the standard tickerplant log file replay functionality.
\
show "RealTimeTradeWithAsofQuotes.q";
/sample usage
/q tick/RealTimeTradeWithAsofQuotes.q -tp localhost:5000 -syms MSFT.O IBM.N GS.N

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

/initialize schemas for custom real-time subscriber
InitializeSchemas:`trade`quote!
  (
   {[x]`TradeWithQuote insert update bid:0n,bsize:0N,ask:0n,asize:0N from x};
   {[x]`LatestQuote upsert select by sym from x}
  );

/intraday update functions
/Trade Update
/1. Update incoming data with latest quotes
/2. Insert updated data to TradeWithQuote table
/3. Append message to custom logfile
updTrade:{[d]
  d:d lj LatestQuote;
  `TradeWithQuote insert d;
  LogfileHandle enlist (`replay;`TradeWithQuote;d); };

/Quote Update
/1. Calculate latest quote per sym for incoming data
/2. Update LatestQuote table
updQuote:{[d]
  `LatestQuote upsert select by sym from d; };

/upd dictionary will be triggered upon incoming update from tickerplant
upd:`trade`quote!(updTrade;updQuote);

/end of day function - triggered by tickerplant at EOD
.u.end:{
  hclose LogfileHandle; /close the connection to the old log file
  /create the new logfile
  logfile::hsym `$"RealTimeTradeWithAsofQuotes_",string .z.D;
  .[logfile;();:;()]; /Initialise the new log file
  LogfileHandle::hopen logfile;
  {delete from x}each tables `. /clear out tables
  };

/Initialize name of custom logfile
logfile:hsym `$"RealTimeTradeWithAsofQuotes_",string .z.D;

replay:{[t;d]t insert d} /custom log file replay function;

/attempt to replay custom log file
@[{-11!x;show"successfully replayed custom log file"}; logfile;
  {[e]
    m:"failed to replay custom log file";
    show m," - assume it does not exist. Creating it now";
    .[logfile;();:;()]; /Initialise the log file
  } ];

/open a connection to log file for writing
LogfileHandle:hopen logfile;

/ connect to tickerplant and subscribe to trade and quote for portfolio
h:hopen args`tp /connect to tickerplant
InitializeSchemas . h(".u.sub";`trade;args`syms);
InitializeSchemas . h(".u.sub";`quote;args`syms);
