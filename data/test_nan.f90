PROGRAM TEST_NAN
    IMPLICIT NONE
    real*8 :: x=4.0, R
    WRITE(*,*) rnan(x) 
    !R=rnan(x)
    !WRITE(*,*) R
END PROGRAM TEST_NAN

function rnan(x)
    implicit none
    real*8 :: x
    real*8 :: rnan
    !dir$ optimize:0
    rnan = (x-x)/(x-x)
    return
end 
