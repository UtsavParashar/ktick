//- Directly from tpLog to disk
quote:([]time:`timespan$();sym:`symbol$();bid:`float$();ask:`float$();bsize:`int$();asize:`int$());
trade:([]time:`timespan$();sym:`symbol$();price:`float$();size:`int$());


`:/Users/utsav/db/2020.05.23/quote/ set .Q.en[`:/Users/utsav/db;]quote;
`:/Users/utsav/db/2020.05.23/trade/ set .Q.en[`:/Users/utsav/db;]trade;




write:{$["trade"~y;`:/Users/utsav/db/2020.05.23/trade/ upsert .Q.en[`:/Users/utsav/db;value x];`:/Users/utsav/db/2020.05.23/quote/ upsert .Q.en[`:/Users/utsav/db;value x]];
delete from x};

upd:{[t;d]
    if[`trade~t;`trade insert d;`quote insert d];
    if[10000<count value t;$[`trade~t;write[`trade;"trade"];write[`quote;"quote"]]];
    };
    
-11!`:/Users/utsav/Desktop/repos/ktick/tick/sym2020.05.23;
if[0<count trade;write[`trade]]; /need to write the leftovers
if[0<count quote;write[`quote]];


delete from `.
\l /Users/utsav/db
select from trade

`sym`time xasc `:/Users/utsav/db/2020.05.23/trade/;
@[`:/Users/utsav/db/2020.05.23/trade/;`sym;`p#];

