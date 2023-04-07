#!/bin/bash 

cd packages/contract

expect -c "
 spawn truffle develop
 expect truffle(develop)>
 send \"truffle test\n\"

 expect truffle(develop)>
 send \".exit\n\"
 interact
"> polygon-mobile-test.txt

grep -n '1 passing' polygon-mobile-test.txt