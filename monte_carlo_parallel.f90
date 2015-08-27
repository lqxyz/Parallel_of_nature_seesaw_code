program MonteCarlo
    
    use mpi
    use init_paras
    use fitting
    use dataprocessing
    use interpmethod
    use warm_cool_event

    implicit none

    integer, parameter                  :: xproc = 4, yproc = 5
    integer                             :: xsize, ysize, fh1, fh2, filetype, myid, numprocs, ierr, &
                                           i, j, k, row, col, global_i, global_j, idx, idy
    integer                             :: gsize(2), lsize(2), coords(2), starts(2), psize(2)
    integer, dimension(MPI_STATUS_SIZE) :: stat
    real*8, dimension(24, 2)            :: mean_cmp
    real*8, dimension(24)               :: cmp_mismatch, mc_shuffler
    real*8                              :: nanmean_temp, mpi_time_start, mpi_time_end
    real*8, allocatable                 :: t_MC(:,:), t_MCc(:,:)

    call init

    xsize = N_Da/xproc
    ysize = N_MC/yproc 

    allocate(t_MC(ysize, xsize), t_MCc(ysize, xsize))

    do i=1,size(allDO)
        teller = allDO(i)
        call interp_linear(1, N_18O, ng_18o(:,2)-ng_mp(teller,2), do_18o(:,teller), Nt, -t, temp)
        call fillNaN(temp, N_ave, outvec, Nt)
        NGtimed(i,:)=outvec
    end do
    deallocate(temp)

    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, myid, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, numprocs, ierr)

    mpi_time_start = MPI_WTIME()

    ! Subarray infomation
    gsize = (/N_MC, N_Da/)
    lsize = (/ ysize, xsize /)
    psize = (/ yproc, xproc /)
    coords=(/mod(myid,psize(1)),myid/psize(1)/)
    starts=(/coords(1)*lsize(1), coords(2)*lsize(2)/)

    write(*,*) "Begin...", myid, numprocs
    if(numprocs /= xproc * yproc) then
        write(*,*) "Error: mpirun -n p xxx should be: mpi -n ",xproc*yproc, "xxx."
        call MPI_FINALIZE(ierr)
        stop
    end if
    !if(xproc >= 4) then
    !    dataset_id = myid/yproc / (200/xsize)
    !end if
    row = myid / yproc
    col = mod(myid, yproc)

    do i = 1, xsize
        global_i = i + row*xsize
        idx = int((global_i-1)/200) + 1 
        idy = mod(global_i-1, 200) + 1

        ! Find the new WAIS Divide chronology:
        select case(idx)
        case(1)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens1,0.d0/), &
            (/68000.d0,sp1_ice(idy,:),-57.d0/), N_18o_wd, wd_18o(:,1), ages_18o)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens1,0.d0/), &
            (/68000.d0,sp1_gas(idy,:),-57.d0/), N_mp, wd_mp(:,1), wd_mpnew)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens1,0.d0/), &
            (/68000.d0,sp1_gas(idy,:),-57.d0/), N_mp, wd_cmp(:,1), wd_cmpnew)
        case(2)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens2,0.d0/), &
            (/68000.d0,sp2_ice(idy,:),-57.d0/), N_18o_wd, wd_18o(:,1), ages_18o)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens2,0.d0/), &
            (/68000.d0,sp2_gas(idy,:),-57.d0/), N_mp, wd_mp(:,1), wd_mpnew)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens2,0.d0/), &
            (/68000.d0,sp2_gas(idy,:),-57.d0/), N_mp, wd_cmp(:,1), wd_cmpnew)
        case(3)
            call interp_linear(1, N_new+2,(/z_sens3(1:32),3405.d0,z_sens3(33:),0.d0/), &
            (/68000.d0,sp3_ice(idy,:),-57.d0/), N_18o_wd, wd_18o(:,1), ages_18o)
            call interp_linear(1, N_new+2,(/z_sens3(1:32),3405.d0,z_sens3(33:),0.d0/), &
            (/68000.d0,sp3_gas(idy,:),-57.d0/), N_mp, wd_mp(:,1), wd_mpnew)
            call interp_linear(1, N_new+2,(/z_sens3(1:32),3405.d0,z_sens3(33:),0.d0/), &
            (/68000.d0,sp3_gas(idy,:),-57.d0/), N_mp, wd_cmp(:,1), wd_cmpnew)
        case(4)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens4,0.d0/), &
            (/68000.d0,sp4_ice(idy,:),-57.d0/), N_18o_wd, wd_18o(:,1), ages_18o)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens4,0.d0/), &
            (/68000.d0,sp4_gas(idy,:),-57.d0/), N_mp, wd_mp(:,1), wd_mpnew)
            call interp_linear(1, N_new+2,(/3405.d0,z_sens4,0.d0/), &
            (/68000.d0,sp4_gas(idy,:),-57.d0/), N_mp, wd_cmp(:,1), wd_cmpnew)
        case default
            write(*,*) "pass" 
        end select

        ! WD cooling timing uses the average of WD and NGRIP
        mean_cmp(:,1) = 0.5*(wd_cmpnew+25+ng_cmp(:,2))
        mean_cmp(:,2) = 0.5*(wd_cmpnew-25+ng_cmp(:,2))
        mean_cmp(1:7,1) = ng_cmp(1:7,2)
        mean_cmp(1:7,2) = wd_cmpnew(1:7)
        cmp_mismatch = wd_cmpnew+25-ng_cmp(:,2)
        call nanmean(abs(cmp_mismatch(8:)), N_mp-8+1, 1, nanmean_temp)
        cmp_mismatch(1:7) = nanmean_temp

        ! Redo the sampling on the new chronology
        allocate(temp(Nt))
        do k=1,size(allDO)
            teller = allDO(k)
            call interp_linear(1, N_18o_wd, ages_18o-wd_mpnew(teller)-ch4lag, aim_18o(:, teller), Nt, -t, temp)
            call fillNaN(temp, N_ave, wdtimed(teller,:), Nt) 
            call interp_linear(1, N_18o_wd, ages_18o-mean_cmp(teller,2)-ch4lag, aimc_18o(:, teller), Nt, -t, temp)
            call fillNaN(temp, N_ave, wdtimedc(teller,:), Nt) 
        end do
        !write(*,*) "Nan count",count(isnan(wdtimed)), "size", size(wdtimed)
        deallocate(temp)

        do j = 1, ysize 
            global_j = j + col*ysize
            call warm_event(wdstack, t_MC(j, i), wdtimed)
            call cool_event(wdstackc, t_MCc(j, i), wdtimedc, cmp_mismatch)
        end do
    end do

    !call MPI_BARRIER(MPI_COMM_WORLD, ierr)

    ! Parallel IO
    call MPI_TYPE_CREATE_SUBARRAY(2, gsize, lsize, starts, MPI_ORDER_FORTRAN, MPI_DOUBLE_PRECISION, filetype, ierr)
    call MPI_TYPE_COMMIT(filetype, ierr)

    call MPI_FILE_OPEN(MPI_COMM_WORLD, "t_MC.dat", MPI_MODE_CREATE+MPI_MODE_WRONLY, MPI_INFO_NULL,fh1,ierr)
    call MPI_FILE_SET_VIEW(fh1, 0_MPI_OFFSET_KIND, MPI_DOUBLE_PRECISION, filetype, "native", MPI_INFO_NULL, ierr)
    call MPI_FILE_WRITE_ALL(fh1, t_MC, xsize*ysize , MPI_DOUBLE_PRECISION,stat, ierr)
    call MPI_FILE_CLOSE(fh1, ierr)

    call MPI_FILE_OPEN(MPI_COMM_WORLD, "t_MCc.dat", MPI_MODE_CREATE+MPI_MODE_WRONLY, MPI_INFO_NULL,fh2,ierr)
    call MPI_FILE_SET_VIEW(fh2, 0_MPI_OFFSET_KIND, MPI_DOUBLE_PRECISION, filetype, "native", MPI_INFO_NULL, ierr)
    call MPI_FILE_WRITE_ALL(fh2, t_MCc, xsize*ysize , MPI_DOUBLE_PRECISION,stat, ierr)
    call MPI_FILE_CLOSE(fh2, ierr)

    mpi_time_end= MPI_WTIME()
    write(*,*) "mpi run time", mpi_time_end-mpi_time_start

    call MPI_FINALIZE(ierr) 

end program MonteCarlo
