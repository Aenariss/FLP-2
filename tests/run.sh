#!/bin/bash
## Testy pro FLP Projekt 2 - Jednoduche porovnavani vstupu a ocekavaneho vystupu
## Idealne spustene pres `make test`

tmpfile="./tests/tmp"
n_tests=14
tests=1
pass=0

for i in $(seq 1 $n_tests) 
do
    tests=$((tests+1))
    ./flp22-log < "tests/input$i.txt" > $tmpfile
    diff "tests/expected$i.txt" $tmpfile
    if [ $? == 0 ]; then # test passed, diff returns 0 on same res
        pass=$((pass+1))
        echo "Test $i passed"
    else
        echo "Test $i failed"
    fi
    echo "Running test - tests/input$i"
done

rm $tmpfile

echo "Tests passed: $pass"
echo "Tests failed: $((n_tests-pass))"
