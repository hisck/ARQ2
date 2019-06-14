#!/bin/bash

#FLAGS, CAMINHOS & UTILS
wget=/usr/bin/wget
tar=/bin/tar
DIR=$(pwd)
RESULTS="$DIR/resultados"
CONFIGS="$DIR/configuracoes"
GEM5="$DIR/gem5"
THREAD_COUNT=$(nproc)
CAP="$DIR/CAPBenchmarks"
TSP="$CAP/gem5/src/TSP"
SYSCALL="$GEM5/src/arch/x86/linux"

#-i
instalarGem5eBuildar()
{
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install g++ -y
    sudo apt-get install git -y
    sudo apt-get install gfortran m4 -y
    sudo apt-get update -y
    sudo apt-get install sed libgoogle-perftools-dev python-six python-dev scons swig binutils build-essential curl libboost-dev libbz2-dev libc6:i386 libncurses5:i386 libsqlite3-dev libstdc++6:i386 python wget zlib1g-dev libsqlite3-dev xsltproc libx11-dev libxext-dev libxt-dev libxmu-dev libxi-dev libdb1-compat tzdata -y
    sudo apt autoremove -y
    git clone https://gem5.googlesource.com/public/gem5
    echo "TARGET_ISA = 'x86'
CPU_MODELS = 'AtomicSimpleCPU,O3CPU,TimingSimpleCPU'
PROTOCOL = 'MOESI_CMP_directory'" > "$GEM5"/build_opts/x86_MOESI_CMP_directory
    echo "Number of cores : $THREAD_COUNT"
    cd $SYSCALL
    sed -i 's/ SyscallDesc("getdents64", unimplementedFunc), / SyscallDesc("getdents64", ignoreFunc), /g' 
    cd $GEM5
    echo | scons build/x86_MOESI_CMP_directory/gem5.fast -j $THREAD_COUNT
}

#edita os arquivo do TSP
editaTSP()
{
cd $TSP
sed -i 's/inline//g' tsp.h
sed -i 's/inline//g' tsp.c
sed -i 's/inline//g' main.c
sed -i 's/inline//g' job.h
sed -i 's/inline//g' job.c
sed -i 's/inline//g' exec.h
sed -i 's/inline//g' exec.c
sed -i 's/inline//g' defs.h
sed -i 's/inline//g' defs.c
sed -i 's/inline//g' common_main.h
sed -i 's/inline//g' common_main.c
cd $CAP
}

#-p
instalarBenchmarks()
{
    cd $DIR
    git clone https://github.com/cart-pucminas/CAPBenchmarks.git
    cd CAPBenchmarks/gem5/
    editaTSP
    cd gem5
    make
}

#passa resultados para a pasta RESULTS
movendo1()
{
    mv m5out/$1 $RESULTS/$4.config$5.ini
    mv m5out/$2 $RESULTS/$4.config$5.json
    mv m5out/$3 $RESULTS/$4.stats$5.txt
}

#-s
simular()
{
    if [ -d "$GEM5" ]; then
        if [ ! -d "$RESULTS" ]; then
            mkdir resultados  
        fi
        cd "$GEM5"

		build/x86_MOESI_CMP_directory/gem5.fast ./configs/example/se.py --cpu-type=DerivO3CPU --bp-type=LTAGE -n 16 --cpu-clock=3GHz --mem-size=1GB --caches --l2cache --l1d_size=32kB --l1i_size=32kB --l2_size=256kB --ruby --ruby-clock=3GHz --topology=Mesh_XY --num-dirs=16 --num-l2caches=16 --mesh-rows=4 --network=garnet2.0 --routing-algorithm=1 -c $CAP/gem5/bin/tsp -o "--class small --nthreads 17" 


    else
                echo "               #################################################
               #                                               #
               # O Gem5	não está instalado! 	               #
               # O instalador tomará todas as medidas para     #
               # que você possa prosseguir para a instalação   #
               # e configuração dos programas de benchmark     #
               #                                               #
               #################################################
             "
        instalarGem5eBuildar
        instalarBenchmarks
        simular 
    fi
}

#-h
Help()
{
    echo "
    ###########################################################################################################
    #SniperSim Installer                                                                                      #
    #                                                                                                         #
    #Versão 0.1                                                                                               #
    #                                                                                                         #
    #É valido lembrar que esse script considera que NÃO HÁ instalação do gem5 na maquina, portanto, se        #
    #existir uma instalação na maquina, ele ira sobrescrever a pré existente!                                 #
    #                                                                                                         #
    #                                                                                                         #
    #Versão 0.2                                                                                               #
    #                                                                                                         #
    #Corrigido problema de diretorios.                                                                        #
    #                                                                                                         #
    #                                                                                                         #
    #-h: Menu de ajuda(esse menu)                                                                             #
    #-i: instala o simulador Gem5, no diretório gem5	                                                      #
    #-p: instala os programas contidos em CAPBenchmarks, no diretório CAPBenchmarks                           #
    #-s: realiza as simulações e grava os resultados no diretório resultados                                  #
    #-r: gera o relatório (contido no diretório relatório)                                                    #
    #                                                                                                         #
    #Qualquer bug, relatar ra99829@uem.br                                                                     #
    ###########################################################################################################


"
}

#-r
geraRelatorio(){
    if [ ! -d "$REPORTDIR" ]; then
        #if [ -L "$REPORTDIR" ]; then
            cd "$DIR"
            mkdir relatório
        #fi
    fi
    cd "$REPORTDIR"
    make -i
}

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do 
    case $1 in
        -h) Help;
        ;;
        -i) instalarGem5eBuildar;
        ;;
        -p) instalarBenchmarks;
        ;;
        -s) simular;
        ;;
        -r) geraRelatorio;
        ;;
    esac;
    cd "$DIR";
    shift;
done
if [[ "$1" == '--' ]]; then shift; fi



