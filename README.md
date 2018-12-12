# Lin-Lab
Matrix calculator that performs many of the same functions as an expensive calculator or software package but for a fraction of the cost.

★ Add, view, delete, edit, and resize matrix variables with an easy-to-use interface.

★ Do basic matrix operations such as addition, subtraction, and multiplication.

★ Perform advanced matrix calculations, including Gaussian and Gauss-Jordan elimination, inverse, determinant, and trace.

★ Command history makes running the same operation over and over again fast and easy.

★ Shortcut buttons simplify generating identity matrices and random data.

★ Documentation page clearly explains all supported matrix operations and functions.

★ Impress your friends by solving those cumbersome systems of linear equations that occur in your daily life!

The expression calculator can be built standalone and ran at the command-line for scalar (non-matrix) operands.
For example, run the script run.sh to build and run the demo app for a few test cases:
```
$ cd Lin Lab/exp_eval
$ ./run.sh
g++ -c  -std=c++14 -g -Wall main.cpp
g++ -c  -std=c++14 -g -Wall All_Functions.cpp
g++ -c  -std=c++14 -g -Wall All_Operators.cpp
g++ -c  -std=c++14 -g -Wall Expression_Evaluator.cpp
g++  -std=c++14 -g -Wall -o exp_eval main.o  All_Functions.o All_Operators.o Expression_Evaluator.o   -lm
1 + 2 = 3
1 + 2 + 3 = 6
1 + 2 * 3 = 7
(1 + 2) * 3 = 9
(1 + 2) * (3^2 / 3) = 9
sqrt(3^2) = 3
1 <= 2 = 1
1 > 2 = 0
1 - -1 = 2
1.2 - .2 = 1
```
