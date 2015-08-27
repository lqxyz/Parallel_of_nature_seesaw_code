!! This code is download from network and has been changed.
module interpmethod
contains
    function r8vec_descends_strictly ( n, x )
    !  Parameters:
    !    Input, integer ( kind = 4 ) N, the size of the array.
    !    Input, real ( kind = 8 ) X(N), the array to be examined.
    !    Output, logical R8VEC_DESCENDS_STRICTLY, is TRUE if the
    !    entries of X strictly ascend.
    !
      implicit none

      integer ( kind = 4 ) n
      integer ( kind = 4 ) i
      logical r8vec_descends_strictly
      real ( kind = 8 ) x(n)

      do i = 2, n 
        if ( x(i-1) <= x(i) ) then
          r8vec_descends_strictly = .false.
          return
        end if
      end do

      r8vec_descends_strictly = .true.

      return
    end function r8vec_descends_strictly

    function r8vec_ascends_strictly ( n, x )
    !  Parameters:
    !    Input, integer ( kind = 4 ) N, the size of the array.
    !    Input, real ( kind = 8 ) X(N), the array to be examined.
    !    Output, logical R8VEC_ASCENDS_STRICTLY, is TRUE if the
    !    entries of X strictly ascend.
    !
      implicit none

      integer ( kind = 4 ) n

      integer ( kind = 4 ) i
      logical r8vec_ascends_strictly
      real ( kind = 8 ) x(n)

      do i = 1, n - 1
        if ( x(i+1) <= x(i) ) then
          r8vec_ascends_strictly = .false.
          return
        end if
      end do

      r8vec_ascends_strictly = .true.

      return
    end function r8vec_ascends_strictly

    subroutine interp_linear( m, data_num, t_data, p_data, interp_num, &
      t_interp, p_interp )
    ! INTERP_LINEAR: piecewise linear interpolation to a curve in M dimensions.
    !  Parameters:
    !    Input, integer ( kind = 4 ) M, the spatial dimension.
    !    Input, integer ( kind = 4 ) DATA_NUM, the number of data points.
    !    Input, real ( kind = 8 ) T_DATA(DATA_NUM), the value of the
    !    independent variable at the sample points.  The values of T_DATA
    !    must be strictly increasing.
    !    Input, real ( kind = 8 ) P_DATA(M,DATA_NUM), the value of the
    !    dependent variables at the sample points.
    !    Input, integer ( kind = 4 ) INTERP_NUM, the number of points
    !    at which interpolation is to be done.
    !    Input, real ( kind = 8 ) T_INTERP(INTERP_NUM), the value of the
    !    independent variable at the interpolation points.
    !    Output, real ( kind = 8 ) P_INTERP(M,DATA_NUM), the interpolated
    !    values of the dependent variables at the interpolation points.
    !
      implicit none

      integer ( kind = 4 ) data_num
      integer ( kind = 4 ) m
      integer ( kind = 4 ) interp_num

      integer ( kind = 4 ) interp
      integer ( kind = 4 ) left
      real ( kind = 8 ) p_data(m,data_num)
      real ( kind = 8 ) p_interp(m,interp_num)
      !logical r8vec_ascends_strictly
      logical :: ascend, descend
      integer ( kind = 4 ) right
      real ( kind = 8 ) t
      real ( kind = 8 ) t_data(data_num)
      real ( kind = 8 ) t_interp(interp_num)

      ascend = r8vec_ascends_strictly( data_num, t_data)
      descend = r8vec_descends_strictly( data_num, t_data)
      !if ( .not. r8vec_ascends_strictly ( data_num, t_data ) ) then
      if ( .not. ascend .and. .not. descend ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) 'INTERP_LINEAR - Fatal error!'
        write ( *, '(a)' ) &
          '  Independent variable array T_DATA is not strictly increasing or decreasing.' 
        stop 1
      end if

      do interp = 1, interp_num
        t = t_interp(interp)
        !  Find the interval [ TDATA(LEFT), TDATA(RIGHT) ] that contains, or is
        !  nearest to, TVAL.
        if (ascend) then
            !call r8vec_bracket ( data_num, t_data, t, left, right )
            left = binarySearch_I(t_data, t)
        else 
            !call r8vec_bracket_descend ( data_num, t_data, t, left, right )
            left = binarySearch_D(t_data, t)
        end if
        if ( left == data_num) then
            left = data_num-1
            right = data_num
        else if (left == 0) then
            left = 1
            right = 2
        else
            right = left+1
        end if

        p_interp(1:m,interp) = &
          ( ( t_data(right) - t                ) * p_data(1:m,left)   &
          + (                 t - t_data(left) ) * p_data(1:m,right) ) &
          / ( t_data(right)     - t_data(left) )

      end do

      return
    end subroutine interp_linear

    subroutine r8vec_bracket ( n, x, xval, left, right )
    !! R8VEC_BRACKET searches a sorted R8VEC for successive brackets of a value.
    !  Parameters:
    !    Input, integer ( kind = 4 ) N, length of input array.
    !    Input, real ( kind = 8 ) X(N), an array sorted into ascending order.
    !    Input, real ( kind = 8 ) XVAL, a value to be bracketed.
    !    Output, integer ( kind = 4 ) LEFT, RIGHT, the results of the search.
    !    Either:
    !      XVAL < X(1), when LEFT = 1, RIGHT = 2;
    !      X(N) < XVAL, when LEFT = N-1, RIGHT = N;
    !    or
    !      X(LEFT) <= XVAL <= X(RIGHT).
    !
      implicit none

      integer ( kind = 4 ) n

      integer ( kind = 4 ) i
      integer ( kind = 4 ) left
      integer ( kind = 4 ) right
      real ( kind = 8 ) x(n)
      real ( kind = 8 ) xval

      do i = 2, n - 1

        if ( xval < x(i) ) then
          left = i - 1
          right = i
          return
        end if

       end do

      left = n - 1
      right = n

      return
    end subroutine r8vec_bracket 

    subroutine r8vec_bracket_descend ( n, x, xval, left, right )
    !  Parameters:
    !    Input, integer ( kind = 4 ) N, length of input array.
    !    Input, real ( kind = 8 ) X(N), an array sorted into ascending order.
    !    Input, real ( kind = 8 ) XVAL, a value to be bracketed.
    !    Output, integer ( kind = 4 ) LEFT, RIGHT, the results of the search.
    !    Either:
    !      XVAL > X(1), when LEFT = 1, RIGHT = 2;
    !      X(N) > XVAL, when LEFT = N-1, RIGHT = N;
    !    or
    !      X(LEFT) >= XVAL >= X(RIGHT).
    !
      implicit none

      integer ( kind = 4 ) n
      integer ( kind = 4 ) i
      integer ( kind = 4 ) left
      integer ( kind = 4 ) right
      real ( kind = 8 ) x(n)
      real ( kind = 8 ) xval

      do i = 2, n - 1

        if ( xval > x(i) ) then
          left = i - 1
          right = i
          return
        end if

       end do

      left = n - 1
      right = n

      return
    end subroutine r8vec_bracket_descend


    function binarySearch_I (a, value)
        implicit none
        integer                     :: binarySearch_I
        real*8, intent(in), target  :: a(:)
        real*8, intent(in)          :: value
        real*8, pointer             :: p(:)
        integer                     :: mid, offset

        p => a
        binarySearch_I = 0
        offset = 0
        do while (size(p) > 0)
            mid = size(p)/2 + 1
            if (p(mid) > value) then
                p=>p(:mid-1)
            else if(p(mid)<value) then
                offset=offset+mid
                p=>p(mid+1:)
                binarySearch_I = offset
            else
                binarySearch_I=offset+mid
                ! SUCCESS!!
                return
            end if
        end do
    end function binarySearch_I

    function binarySearch_D (a, value)
        implicit none
        integer                     :: binarySearch_D
        real*8, intent(in), target  :: a(:)
        real*8, intent(in)          :: value
        real*8, pointer             :: p(:)
        integer                     :: mid, offset

        p => a
        binarySearch_D = 0
        offset = 0
        do while (size(p) > 0)
            mid = size(p)/2 + 1
            if (p(mid) < value) then
                p=>p(:mid-1)
            else if(p(mid)>value) then
                offset=offset+mid
                p=>p(mid+1:)
                binarySearch_D = offset
            else
                binarySearch_D=offset+mid
                ! SUCCESS!!
                return
            end if
        end do
    end function binarySearch_D

end module interpmethod
