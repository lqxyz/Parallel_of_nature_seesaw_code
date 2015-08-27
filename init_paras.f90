module init_paras

    implicit none

    integer                 :: Nt= 2401, M1=16, M2=101
    real*8                  :: t_break, ch4lag = 56
    integer                 :: N_mp=24, N_Da = 800, N_MC = 100, N_ave = 50, teller,&
                               N_18O=6114, N_18o_wd=6373, N_CH4=1313, N_new=3401 
    integer, allocatable    :: allDO(:), ofinterest(:), smallDO(:)
    integer, dimension(5)   :: bigDO = (/6, 11, 15, 17, 23/) 
    real*8, allocatable     :: wdstackc(:), t(:), outvec(:), breakvec1(:), breakvec2(:),fit_curve(:)
    real*8, allocatable     ::  NGtimed(:,:),do_18o(:,:), wd_18o(:,:),&
                               ages_18o(:), ng_18o(:,:), z_sens1(:), z_sens2(:), z_sens3(:),z_sens4(:), & 
                               sp1_gas(:,:), sp1_ice(:,:), sp2_gas(:,:),sp2_ice(:,:), sp3_gas(:,:),&
                               sp3_ice(:,:), sp4_gas(:,:),sp4_ice(:,:),temp(:), wd_mpnew(:), wd_cmpnew(:), &
                               aim_18o(:,:), aimc_18o(:,:),wdtimed(:,:),wdtimedc(:,:), wdstack(:)
    real*8, dimension(24,4) :: ng_mp, wd_mp, ng_cmp, wd_cmp

contains

subroutine readfile(fn, dat, nx, ny)

    implicit none

    character(len=*)            :: fn
    integer                     :: nx, ny, i, j, ferr
    real*8, dimension(nx, ny)   :: dat

    open(unit=99, file=fn, access='direct', form='unformatted', recl=8*nx*ny)
    read(99, rec=1, iostat=ferr) ((dat(i,j), i=1,nx), j=1,ny) 
    if(ferr /= 0) then
        write(*,*) "Read file ", fn, "error."
        stop 1
    end if
    close(unit=99)
    return
end subroutine readfile

subroutine init
    implicit none
    integer :: i

    allocate(allDO(20), ofinterest(20), smallDo(15))
    allocate(t(Nt), temp(Nt), wdstackc(Nt), fit_curve(Nt), breakvec1(M1), breakvec2(M2))
    allocate(NGtimed(N_mp,Nt),& 
             outvec(Nt), do_18o(N_18O,N_mp),ng_18o(N_18O,4), sp1_ice(200,N_new),&
             sp1_gas(200,N_new), sp2_ice(200,N_new), sp2_gas(200,N_new), &
             sp3_gas(200,N_new), sp3_ice(200,N_new), sp4_gas(200,N_new), &
             sp4_ice(200,N_new), z_sens1(N_new), z_sens2(N_new),z_sens3(N_new),&
             z_sens4(N_new), wd_18o(N_18o_wd,3), ages_18o(N_18o_wd), &
             wd_mpnew(N_mp), wd_cmpnew(N_mp), aim_18o(N_18o_wd, N_mp), &
             aimc_18o(N_18o_wd, N_mp), wdtimed(N_mp,Nt), wdtimedc(N_mp,Nt),&
             wdstack(Nt))

    allDO = (/(i, i=5,24)/)
    ofinterest = allDO
    bigDO = (/6, 11, 15, 17, 23/) 
    smallDO =(/5, (i, i=7,10), (i, i=12,14), 16,(i, i=18,22), 24/)
    t=(/(i, i=-(Nt-1)/2,(Nt-1)/2)/)

    breakvec1=(/(i, i=50,350,20)/)

    call readfile('./data/NG_mp.dat', ng_mp, N_mp, 4)
    call readfile('./data/NG_cmp.dat', ng_cmp, N_mp, 4)
    call readfile('./data/WD_mp.dat', wd_mp, N_mp, 4)
    call readfile('./data/WD_cmp.dat', wd_cmp, N_mp, 4)

    call readfile('./data/WDtimed.dat', wdtimed, N_mp, Nt)
    call readfile('./data/WDtimedc.dat', wdtimedc, N_mp, Nt)

    call readfile('./data/DO_18O.dat', do_18o, N_18o, N_mp)
    call readfile('./data/NG_18O.dat', ng_18o, N_18o, 4)
    call readfile('./data/WD_18O.dat', wd_18o, N_18o_wd, 3)
    call readfile('./data/AIM_18O.dat', aim_18o, N_18o_wd, N_mp)
    call readfile('./data/AIMc_18O.dat', aimc_18o, N_18o_wd, N_mp)

    call readfile('./data/wdstackc.dat', wdstackc, Nt, 1)

    call readfile('./data/SP1_gas.dat', sp1_gas, 200, N_new)
    call readfile('./data/SP1_ice.dat', sp1_ice, 200, N_new)
    call readfile('./data/SP2_gas.dat', sp2_gas, 200, N_new)
    call readfile('./data/SP2_ice.dat', sp2_ice, 200, N_new)
    call readfile('./data/SP3_gas.dat', sp3_gas, 200, N_new)
    call readfile('./data/SP3_ice.dat', sp3_ice, 200, N_new)
    call readfile('./data/SP4_gas.dat', sp4_gas, 200, N_new)
    call readfile('./data/SP4_ice.dat', sp4_ice, 200, N_new)

    call readfile('./data/z_sens1.dat', z_sens1, N_new, 1)
    call readfile('./data/z_sens2.dat', z_sens2, N_new, 1)
    call readfile('./data/z_sens3.dat', z_sens3, N_new, 1)
    call readfile('./data/z_sens4.dat', z_sens4, N_new, 1)
    return
end subroutine init

end module init_paras
