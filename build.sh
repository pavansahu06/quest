#!/bin/sh -xe

# Author : Kuldeep Sangal, Syed Saheb
# Script follows here:

# Script is written for user SMDEV, User needs to modify script if they want to run for particular user

set -o emacs

if [ $1 == "PSLSMLinux01" ]
then
    user=/home/smdev
    tz_file=Linux64-3.10-x86-Ora

    export PATH=/usr/local/qtools/bin:/usr/local/bin:$PATH:.
    export PATH=/usr/bin:/bin:$PATH

    export LIBEXT=so
    export LIBTYPE=shared
    export PRODUCT=Reorg
    export PLATFORM=Linux64

    export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
    export ORAVER=19
    export ORAEXT=0

    export TOP=/home/smdev/workspace/SM/QSA19C

    export PATH=/usr/local/qtools/bin:$PATH:$TOP/script:$ORACLE_HOME/bin:$TOP/script_reorg
    export SHLIBLOC=$TOP/../SHLIBLOC
	
	
elif [ $1 == "soaxp428" ]
then 
    user=/nis/home/dpdev/jenkins
    tz_file=AIX64-7.2-PPC-Ora

    export PATH=/opt/freeware/lib:/usr/local/x/bin:/usr/local/bin:$PATH:.
    export PATH=/usr/bin:/bin:$PATH

    export LIBEXT=a
    export LIBTYPE=linked
    export PRODUCT=Reorg
    export PLATFORM=AIX
	
    export ORACLE_HOME=/workspace/app/oracle/product/19.0.0/dbhome_1
    export ORAVER=19
    export ORAEXT=0

    export TOP=/nis/home/dpdev/jenkins/workspace/SM/QSA19C
 
    export PATH=/usr/local/qtools/bin:$PATH:$TOP/script:$ORACLE_HOME/bin
    export SHLIBLOC=$TOP/../SHLIBLOC
    export PATH=$PATH:$TOP/script_reorg
    export PATH=/opt/freeware/lib:/opt/freeware/bin:$PATH:$TOP/script	
    export LIBPATH=/opt/freeware/lib:$LIBPATH
	
else
    echo "Agent is not matching"
    exit 1;
fi


rm dep.inc */dep.inc
touch dep.inc
make depend
make clean
make
make install


#HouseKeeping the Backup location
if [ -d "$user/backup" ]
then
    echo "Directory $user/backup exist"
else
    mkdir $user/backup/
fi

bkp_tar_file=`ls -ltr $user/backup | tail -n 1 | awk {'print $9'} | tr -d '/'`
find $user/backup -mindepth 1 ! -regex '^'$user'/backup/'$bkp_tar_file'\(/.*\)?' | xargs rm -rf



#Taking Backup
cd $user

if [ -f "$user/tar_file/QSA/$tz_file.tar.Z" ]
then
mv $user/tar_file $user/backup/tar_file_bkp_"$(date +"%d-%m-%Y-%T")"_build_no_$2
fi

if [ -d "$user/tar_file" ]
then
    rm -rf $user/tar_file
else
    mkdir $user/tar_file/
fi


cd $user/tar_file

cp $user/workspace/SM/QSA19C/ship/QSA_osmatch.sh .
cp $user/workspace/SM/QSA19C/ship/QSA_cpu_arch.sh .
cp $user/workspace/SM/QSA19C/ship/Platform.sh .
cp $user/workspace/SM/QSA19C/ship/qsaparms.sh .
cp $user/workspace/SM/QSA19C/ship/Install.sh .
cp $user/workspace/SM/QSA19C/ship/Uninstall.sh .

cp -rf $user/workspace/SM/QSA19C/ship/QSA .

cd QSA
mv .txt $tz_file.txt
mkdir $tz_file
mv `ls -p | grep -v $tz_file` $tz_file 
mv $tz_file.txt $tz_file

cp $user/workspace/SM/QSA19C/ship/QSAVersion.txt .
cp $user/workspace/SM/QSA19C/ship/QSAOSMatch.txt .

tar -cvf $tz_file\.tar *

compress -f $tz_file\.tar
