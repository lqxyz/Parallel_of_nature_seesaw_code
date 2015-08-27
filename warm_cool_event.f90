include "mkl_vsl.fi"
module warm_cool_event

contains

subroutine cool_event(wdstackc_new, t_break_MCc_ij, wdtimedc_new, cmp_mismatch)

    use mkl_vsl_type
    use mkl_vsl
    use init_paras
    use fitting
    use dataprocessing
    use interpmethod

    implicit none

    real*8, dimension(Nt)       :: wdstackc_new
    real*8, dimension(N_mp,Nt)  :: wdtimedc_new
    real*8                      :: t_break_MCc_ij
    integer                     :: i, np=50, flag=2
    ! for the randn
    integer                     :: stat, brng=VSL_BRNG_MCG31, seed, &
                                   method = VSL_METHOD_DGAUSSIAN_BOXMULLER2
    TYPE(VSL_STREAM_STATE)      :: stream
    real(kind=8)                :: a=0.0, sigma=1.0, nanmean_temp
    real*8, allocatable         :: r(:,:), r2(:), dummy(:,:)
    real*8, dimension(N_mp)     :: mc_shuffler, cmp_mismatch

    call system_clock(count = seed)
    stat = vslnewstream( stream, brng, seed )

    allocate(dummy(N_mp, Nt),r(N_mp,4), r2(2))
        
    do i = 1, 4
        stat = vdrnggaussian(method, stream, N_mp, r(:,i), a, sigma)
    end do
    !mc_shuffler = 0.5d0*27.d0*r(:,1) + 0.5d0*ng_mp(:,4)*r(:,2)+0.5d0*wd_mp(:,4)*r(:,3)            
    mc_shuffler = aint(0.5d0*27.d0*sqrt(2.d0)*r(:,1) + 0.5d0*ng_cmp(:,4)*r(:,2)&
                +0.5d0*wd_cmp(:,4)*r(:,3)+0.5d0*cmp_mismatch*r(:,4))
    do i = 1, 2
        stat = vdrnggaussian(method, stream, 1, r2(i), a, sigma)
    end do
    mc_shuffler = mc_shuffler + (0.5d0*27.d0*r2(1) + 0.5d0*50.8d0*r2(2))
    mc_shuffler = aint(mc_shuffler) 

    if (N_MC ==1) then
        MC_shuffler = 0
    end if

    dummy = mynan()
    do i = 1, N_mp
        if ( mc_shuffler(i) == 0 ) then
            dummy(i, :) = wdtimedc_new(i, :)
        else if( mc_shuffler(i) > 0 ) then
            dummy(i, mc_shuffler(i)+1:Nt) = wdtimedc_new(i, 1:Nt-mc_shuffler(i))
        else
            dummy(i, 1:Nt+mc_shuffler(i)) = wdtimedc_new(i, 1-mc_shuffler(i):Nt)
        end if
    end do

    ! make the composite
    call nanmean_dim1(dummy(allDO,:), size(allDO), Nt, wdstackc_new)
    call WDC_breakpoint(t, wdstackc_new, breakvec1, 1, t_break_MCc_ij, fit_curve, Nt, M1)
    breakvec2= (/(i, i=-100,100,2)/) + anint(t_break_MCc_ij)
    call WDC_breakpoint(t, wdstackc_new, breakvec2, 2, t_break_MCc_ij, fit_curve, Nt, M2)

    return 
end subroutine cool_event

subroutine warm_event(wdstack_new, t_break_MC_ij, wdtimed_new)

    use mkl_vsl_type
    use mkl_vsl
    use init_paras
    use fitting
    use dataprocessing
    use interpmethod

    implicit none

    real*8, dimension(Nt)       :: wdstack_new
    real*8, dimension(N_mp, Nt) :: wdtimed_new 
    real*8                      :: t_break_MC_ij
    integer                     :: i, np=50, flag=1
    ! for the randn
    integer                     :: stat, brng=VSL_BRNG_MCG31, seed, &
                                   method = VSL_METHOD_DGAUSSIAN_BOXMULLER2
    TYPE(VSL_STREAM_STATE)      :: stream
    real(kind=8)                :: a=0.0, sigma=1.0, nanmean_temp
    real*8, allocatable         :: r(:,:), r2(:), dummy(:,:)
    real*8, dimension(N_mp)     :: mc_shuffler

    ! Use Intel MKL to produce random number
    call system_clock(count = seed)
    stat = vslnewstream( stream, brng, seed )

    allocate(dummy(N_mp, Nt),r(N_mp,3), r2(2))
        
    do i = 1, 3
        stat = vdrnggaussian(method, stream, N_mp, r(:,i), a, sigma)
    end do
    mc_shuffler = 0.5d0*27.d0*r(:,1) + 0.5d0*ng_mp(:,4)*r(:,2)+0.5d0*wd_mp(:,4)*r(:,3)            

    do i = 1, 2
        stat = vdrnggaussian(method, stream, 1, r2(i), a, sigma)
    end do
    mc_shuffler = mc_shuffler + (0.5d0*27.d0*r2(1) + 0.5d0*50.8d0*r2(2))
    mc_shuffler = aint(mc_shuffler) 

    if (N_MC ==1) then
        MC_shuffler = 0
    end if

    dummy = mynan()
    do i = 1, N_mp
        if ( mc_shuffler(i) == 0 ) then
            dummy(i, :) = wdtimed_new(i, :)
        else if( mc_shuffler(i) > 0 ) then
            dummy(i, mc_shuffler(i)+1:Nt) = wdtimed_new(i, 1:Nt-mc_shuffler(i))
        else
            dummy(i, 1:Nt+mc_shuffler(i)) = wdtimed_new(i, 1-mc_shuffler(i):Nt)
        end if
    end do

    ! make the composite
    call nanmean_dim1(dummy(allDO,:), size(allDO), Nt, wdstack_new)
    call WDC_breakpoint(t, wdstack_new, breakvec1, 1, t_break_MC_ij, fit_curve, Nt, M1)
    breakvec2= (/(i, i=-100,100,2)/) + anint(t_break_MC_ij)
    call WDC_breakpoint(t, wdstack_new, breakvec2, 2, t_break_MC_ij, fit_curve, Nt, M2)
    return 
end subroutine warm_event

end module warm_cool_event
