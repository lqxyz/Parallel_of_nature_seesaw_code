The program is a Monte Carlo simulation program to calculate the lead time of polar seesaw.

The program is adapted from a MATLAB version, and downloaded from nature.com.

Notice:
1.Some programs are downloaded from network, such as fitting.f90 and interp_linear.f90, and modified by Qun Liu. Thanks for the authors of the open source programs.
2.The program also needs lapack and Intel MKL (Math Kernel Library), please modify the libraries path in Makefile.

Usage:
```bash
$ make
$ nohup make run &> MC_result &
```

The results will be writen to the file t_MC.dat and t_MCc.dat for warm and cool event.
