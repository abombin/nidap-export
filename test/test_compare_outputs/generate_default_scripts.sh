# This script is used to generate required files for unit test with DICE
echo $(bash runme) 0> input.txt
echo $(bash runme) 1> correct-output.txt
echo $(bash runme) 2> expected-errors.txt
