FC=mpiifort 
FLIB=-L/data/home/reproduce/lq/packages/lapack-3.5.0 -llapack -lrefblas -L/opt/intel_old/Compiler/11.1/072/ifort/mkl/lib/em64t -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm 
FINC=-I/opt/intel_old/Compiler/11.1/072/ifort/mkl/include 
CPP=/usr/bin/cpp 
SRC= init_paras.f90 fitting.f90 \
	 quadric.f90 interp_linear.f90 \
	 dataprocessing.f90 warm_cool_event.f90 \
	 monte_carlo_parallel.f90 
OBJS= $(SRC:.f90=.o) 
EXE=MonteCarlo

ntask=20

all : $(SRC) $(EXE)

$(EXE): $(OBJS) 
		$(FC)  $(OBJS) -openmp -o $@  $(FINC) $(FLIB)

#.SUFFIXES : .f90
%.o: %.f90
		$(FC) -c -g -openmp $< $(FINC)  $(FLIB)

.PHONY: clean	 
clean:
		rm -f *.o *.mod  $(EXE)

.PHONY: run 
run:
		mpirun -np $(ntask) ./$(EXE)
