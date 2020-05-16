/- REPLAY CORRUPT TPLOG FILE:
/- -11!(-2;tpLog) comes to rescue when we want to replay a corrupt log file.

/- Let's get the count of the records till where file is not corrupt.
0N!-11!(-2;`tpLog); /- 10167 -  shows count and byte till where we have good records

/- BackUp the file:
\cp ./tpLog ./tpLog_bkp;

/-  Create a variable for new file
new:`:newTpLog;
// Set empty list to it so that we can use get command the get the records
new set ();
// Open an handle to the new file
h:hopen new;
// update upd function as per replay required in this case if table=trade then persist it in new
upd:{[t;x]h enlist(`upd;t;x)};
// -11!(n,file)  where n=count till good records; can be used to replay the messages
-11!(10167;`:tpLog) /- 10167 - Good messages are replayed

/- hclose h;

//- Testing and we are good
2#get `:newTpLog
quote:([]time:`timespan$();sym:`symbol$();bid:`float$();ask:`float$();bsize:`int$();asize:`int$());
trade:([]time:`timespan$();sym:`symbol$();price:`float$();size:`int$());
upd:insert
-11!new

/- Rename to new tpLog File to existing log file
\mv ./newTpLog ./tpLog

/- Restart both(Tp,RDB)  processes so that RDB reads from new non corrupt tplog file

