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
show "RealTimeTradeWithAsofQuotes.q"
/sample usage
/q tick/RealTimeTradeWithAsofQuotes.q -tp localhost:5000 -syms MSFT.O IBM.N GS.N

/default command line arguments - tp is location of tickerplant.
/syms are the symbols we wish to subscribe to
default:`tp`syms!("::5000";"")

args:.Q.opt .z.x /transform incoming cmd line arguments into a dictionary
args:`$default,args /upsert args into default
args[`tp] : hsym first args[`tp]

/drop into debug mode if running in foreground AND
/errors occur (for debugging purposes)
\e 1

if[not "w"=first string .z.o;system "sleep 1"]

InitializeSchemas:`trade`quote!
  (
   {[x]`TradeWithQuote insert update bid:0n,bsize:0N,ask:0n,asize:0N from x};
   {[x]`LatestQuote upsert select by sym from x}
  )

/intraday update functions
/Trade Update
/1. Update incoming data with latest quotes
/2. Insert updated data to TradeWithQuote table
/3. Append message to custom logfile
updTrade:{[d]
  d:d lj LatestQuote;
  `TradeWithQuote insert d;
  LogfileHandle enlist (`replay;`TradeWithQuote;d); }

/Quote Update
/1. Calculate latest quote per sym for incoming data
/2. Update LatestQuote table
updQuote:{[d]
  `LatestQuote upsert select by sym from d; }

upd:`trade`quote!(updTrade;updQuote)




