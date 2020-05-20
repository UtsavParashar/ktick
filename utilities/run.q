q tick.q sym ./tick/ -p 5000; /- TP
q tick/r.q localhost:5000 localhost:5002 -p 5001; /- RDB
q tick/SampleFeed.q /-FH
