module quad_roots_and_val 

contains

    subroutine quadric_roots(a, b, c, roots, stat)

        implicit none
        real*8                  :: a, b, c, e, discriminant
        real*8, dimension(1:2)  :: roots
        integer                 :: stat

        e = 1.0e-6
        discriminant = b*b - 4.0*a*c

        if (a==0) then 
            roots = -1.0 * c / b 
            stat = 1
        else if (abs(discriminant) < e) then 
            roots = -b / (2.0 * a)
            stat = 2
        else if (discriminant > 0) then
            roots(1) = -(b + sign(sqrt(discriminant),b)) / (2.0 * a)
            roots(2) = c / (a * roots(1))
            stat = 3
        else
            roots(1) = -99999 ! Default value
            roots(2) = -99999
            stat = 4
        end if
        
        return 
    end subroutine quadric_roots

    subroutine quadric_val(p, pv, fitorder, t, N)

        implicit none

        integer                         :: fitorder, N, i
        real*8, dimension(fitorder+1)   :: p
        real*8, dimension(N)            :: pv, t

        pv = 0
        do i = 0, fitorder
            pv = pv + p(i+1) * t**i
        end do

        return
    end subroutine quadric_val

end module quad_roots_and_val
