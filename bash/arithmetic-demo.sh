#!/bin/bash
#
# this script demonstrates doing arithmetic

# Task 1: Remove the assignments of numbers to the first and second number variables. Use one or more read commands to get 3 numbers from the user.
# Task 2: Change the output to only show:
#    the sum of the 3 numbers with a label
#    the product of the 3 numbers with a label
prompt="Please enter three numbers: "
#Not a very safe way to do input!
read -p "$prompt" firstnum secondnum thirdnum
#firstnum=5
#secondnum=2
sum=$((firstnum + secondnum + thirdnum))
dividend=$((firstnum / secondnum))
fpdividend=$(awk "BEGIN{printf \"%.2f\", $firstnum/$secondnum}")
product=$((firstnum * secondnum * thirdnum))

cat <<EOF
Sum: $sum
Product: $product
EOF
