.r.rdbDir:`:/Users/utsav/rdb
.r.hdbDir:`:/Users/utsav/hdb;
.r.sorted:enlist[`trade]!enlist`transacttime;
.r.grouped:enlist[`trade]!enlist`sym;
.r.parted:enlist[`trade]!enlist`sym;

.rdb.flush:{[tb;d] /- tb- tables, d - date
    /1. get hdb path where data is to be splayed and partition is to be created
    rdbDir:.Q.dd[.r.rdbDir;d];
    hdbDir:.Q.dd[.r.hdbDir;d];

    /2. enumerate tables
    {[t] t set .Q.en[.r.rdbDir]value t}@'tb;

    /3. sort the data and apply attributes
    .rdb.applyAttr@'tb;

    /4 compress the data
    .z.zd:17 2 6

    /5. splay the table
    {[r;t].Q.dd[r,t,`]set get t}[rdbDir;]@'tb

}

.rdb.applyAttr:{[t]
    (.r.parted[t],.r.sorted[t])xasc t;
    if[count g:.r.grouped t; @[t;g;`g#]];
    if[count p:.r.parted t; @[t;p;`p#]];
}