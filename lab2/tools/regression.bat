call run_test.bat 5 5 0 0 test_inc_inc c
cd ../tools
call run_test.bat 5 5 0 1 test_inc_dec c
cd ../tools
call run_test.bat 5 5 0 2 test_inc_rnd c
cd ../tools
call run_test.bat 5 5 1 0 test_dec_inc c
cd ../tools
call run_test.bat 5 5 1 1 test_dec_dec c
cd ../tools
call run_test.bat 5 5 1 2 test_dec_rnd c
cd ../tools
call run_test.bat 5 5 2 0 test_rnd_inc c
cd ../tools
call run_test.bat 5 5 2 1 test_rnd_dec c
cd ../tools
call run_test.bat 5 5 2 2 test_rnd_rnd c
cd ../tools