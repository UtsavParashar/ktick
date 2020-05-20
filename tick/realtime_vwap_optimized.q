// default connections to TP at 5000
// syms are the symbols we want to subscribe to

default:`tp`syms!("::5000";"");

args:`$default,.Q.opt .z.x;
args[`tp]: hsym first args[`tp];


/- .u.rep is the function which subscribes to the TP to replay the log file
/- parameters -> x~tradeInfo is a mixed list consisting of tableName and its schema
/- y~logFile is a mixed list consisting of  count of records in tplog .u.i and logfile path .u.L
.u.repTPLog:{[tradeInfo; logFile]
    `trade set tradeInfo[1];
    if[null first logFile; update notional:0n, cumulativeVol:0N, rvwap:0n from `trade;:()];
    -11!logFile;
    update notional:sums(size*price), cumulativeVol:sums size by sym from `trade;
    update rvwap:notional%cumulativeVol from `trade;
    };

/- vwap table which is to be maintained in memory
vwap:([sym:`$()]; rvwap:`float$());

/- For TP logfile replay, upd is a simple insert for trades
/-upd:{if[`trade~x;x insert y;:()]};
upd:{if[`trade=x;`trade insert y]};

/- .u.repRealTime is triggered while receiving realtime messages from TP
/- Add notional and culumativeVol columns to incoming trade record
/- Increment incoming records with the last previous s and v values  (on per sym basis)
/- 3. Add rvwap column to incoming records (rvwap is v divided by s)
/- 4. Insert these enriched incoming records to the trade table
/- 5. Update vwap table
.u.repRealTime:{[tableName;tableData]
    tableData:update cumulativeVol:sums size, notional:sums size*price by sym from tableData;
    tableData:tableData pj select last notional, last cumulativeVol by sym from trade;
    tableData:update rvwap:notional%cumulativeVol from tableData;
    `trade insert tableData;
    `vwap upsert select last rvwap by sym from trade;
    };

/- EOD behavior in RTS is very simple, clear the table.
.u.end:{{delete from x}each tables `.};

h:hopen args`tp;
.u.repTPLog . h"(.u.sub[`trade;",(.Q.s1 args`syms),"];`.u `i`L)"; /- Equivalent - ((10 100); (20 30)) . (1;0);
upd:.u.repRealTime /- Switch to intraday realtime trades after replaying tpLog








