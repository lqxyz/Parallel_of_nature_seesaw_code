module dataprocessing

contains

subroutine fillNaN(invec, N_ave, outvec, N)

    implicit none

    integer :: N_ave, N, i
    real*8, dimension(N) :: invec, outvec
    if (count(isnan(invec)) == size(invec)) then
        outvec = invec
    else
        outvec = invec
        if(isnan(invec(1))) then
            do i = 1, N
                if (.not. isnan(invec(i))) then
                    goto 100
                end if
            end do            
        100 outvec(1:i-1) = sum(invec(i:i+N_ave)) / (N_ave+1) 
        end if

        if(isnan(invec(N))) then
            do i = N, 1, -1
                if (.not. isnan(invec(i))) then
                    goto 200
                end if
            end do            
        200 outvec(i+1:N) = sum(invec(i-N_ave:i)) / (N_ave+1) 
        end if
    end if

end subroutine fillNaN

recursive subroutine WDC_breakpoint(t, WDstack, breakvec, fitorder, t_break, fit_curve, N, M)

    use fitting
    use quad_roots_and_val
    use omp_lib

    implicit none

    ! N is length of t; M is the length of breakvec
    real*8, dimension(N)  :: t, WDstack, fit_curve, pv1, pv2
    real*8, dimension(M) :: breakvec, RMSD, breakpoints, mode
    integer :: i, j, fitorder, N, M, stat, dummy2_index
    real*8 :: t_break, dummy2
    real*8, dimension(2) :: roots
    real*8, dimension(M, N) :: solutions
    real*8, dimension(2,M)  :: temp_breakvec
    real*8, allocatable :: dummy(:), p1(:), p2(:)
    !real*8, dimension(1:fitorder+1)  :: p1, p2

    ! the routine will not work outside these limits
    temp_breakvec(1,:) = breakvec
    temp_breakvec(2,:) = 500
    temp_breakvec(1,:) = minval(temp_breakvec, 1)
    temp_breakvec(2,:) = -200
    breakvec = maxval(temp_breakvec, 1)


    allocate(p1(fitorder+1), p2(fitorder+1))                
    !$OMP parallel do
    do i = 1, size(breakvec)
        allocate(dummy(1201-201+1))                
        dummy = (/(j, j=201,1201)/) + breakvec(i)
        p1 = polyfit(t(int(dummy)), WDstack(int(dummy)), fitorder)
        deallocate(dummy)

        allocate(dummy(1901-1201+1))                
        dummy = (/(j, j=1201,1901)/) + breakvec(i)
        p2 = polyfit(t(int(dummy)), WDstack(int(dummy)), fitorder)
        deallocate(dummy)

        if (fitorder == 2) then
            call quadric_roots(p1(3)-p2(3), p1(2)-p2(2), p1(1)-p2(1), roots, stat) 
        else
            call quadric_roots(0.d0, p1(2)-p2(2), p1(1)-p2(1), roots, stat) 
        end if

        call quadric_val(p1, pv1, fitorder, t, N)
        call quadric_val(p2, pv2, fitorder, t, N)

        if (stat == 4) then
            call WDC_breakpoint(t, WDstack, breakvec, 1, breakpoints(i), solutions(i,:), N, M)
            mode(i) = 1
        else if (stat ==1 .or. stat== 2 .and. roots(1) > t(1) .and. roots(1) < t(N)) then  ! count(dummy > t(1) .and. dummy < t(N))==1) then
            dummy2 = roots(1) 
            where(t <= dummy2)
                solutions(i,:) = pv1
            elsewhere
                solutions(i,:) = pv2
            end where
            breakpoints(i) = dummy2
            mode(i) = 2
        else ! stat == 3

            where(t < minval(roots))
                solutions(i,:) = pv1
            end where
            where(t > maxval(roots))
                solutions(i,:) = pv2
            end where

            dummy2_index = minloc(abs(roots-breakvec(i)), 1)
            breakpoints(i) = roots(dummy2_index)
            mode(i) = 3
            where(t > minval(roots) .and. t < maxval(roots))
                   solutions(i,:) = pv1
            end where
            where(t > minval(roots) .and. t < maxval(roots)) 
                    solutions(i,:) = pv2
            end where

        end if
        RMSD(i) = sqrt(sum((WDstack(601:1901)-solutions(i,601:1901))**2)/(1901-601+1))
    end do
    !$OMP end parallel do

    where((abs(breakvec-breakpoints))>50)
        RMSD = RMSD + 1.d0
    endwhere

    dummy2_index = minloc(RMSD, 1)
    fit_curve = solutions(dummy2_index,:)
    t_break = breakpoints(dummy2_index)

end subroutine 

real*8 function mynan
    mynan = sqrt(-1.0d0)
end function mynan

subroutine nanmean_dim1(A, nx, ny, B)

    implicit none

    integer :: nx, ny
    real*8, dimension(nx, ny) :: A
    real*8, dimension(ny) :: B
    B = sum(A, 1, MASK=.not. isnan(A)) / count(.not. isnan(A), 1)
    return
end subroutine nanmean_dim1

subroutine nanmean(A, nx, ny, B)

    implicit none

    integer :: nx, ny
    real*8, dimension(nx, ny) :: A
    real*8 :: B
    B = sum(A, MASK=.not. isnan(A)) / count(.not. isnan(A))
    return
end subroutine nanmean

end module dataprocessing
