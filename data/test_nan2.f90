program main
    implicit none
    ! Quiet NAN, double precision.
    REAL(8), PARAMETER :: D_QNAN = TRANSFER((/ Z'00000000', Z'7FF80000' /),1.0_8)
    real(kind=D_QNAN)  x
    write(*,*) x

end program

