#! /bin/sh
#
# Usage: cd E;spec_version.sh <dest>
#
# - Copy all public core source files for eprover to <dest>
# - Remove all __inline__ stuff
# - Transform all CLIB includes to "" form
# - Create Makefile.flat
# - Add "#define NDEBUG" to clb_defines.h"

if [ "$1" = "" ] ; then
    echo "spec_version: Usage: spec_version.sh <dest>"
    exit 1
fi;

if test -e $1 ; then
    echo "spec_version: Target directory $1 exists"
    exit 1;
fi;

mkdir $1
cp [^Si]*/*.[ch] $1
cp etc/Makefile.flat.template1 $1/Makefile.flat
cp etc/Makefile.flat.template2 $1/Makefile.tmp
cd $1
touch CSSCPA_filter.c cex_csscpa.c cex_csscpa.h che_G_E___auto.c \
    che_G_N___auto.c che_H_____auto.c che_U_____auto.c \
    checkproof.c classify_problem.c direct_examples.c eground.c \
    ekb_create.c ekb_delete.c ekb_ginsert.c ekb_insert.c \
    epclanalyse.c epclextract.c patterntest.c \
    proofanalyze.c termprops.c tsm_classify.c clb_newmem.[ch] cl_test.c
rm CSSCPA_filter.c cex_csscpa.c cex_csscpa.h che_G_E___auto.c \
    che_G_N___auto.c che_H_____auto.c che_U_____auto.c \
    checkproof.c classify_problem.c direct_examples.c eground.c \
    ekb_create.c ekb_delete.c ekb_ginsert.c ekb_insert.c \
    epclanalyse.c epclextract.c patterntest.c \
    proofanalyze.c termprops.c tsm_classify.c clb_newmem.[ch] cl_test.c

for file in *.[ch] ; do
    gawk '/#include *<..._.*>/{gsub(/[<>]/,"\""); print; next}{print}' $file | sed -e 's/__inline__//' > tmpfile
    mv tmpfile $file
done;

echo "PROJ="`ls *.c | grep -v che_X_____auto_pp_opt.c | grep -v che_auto_cases.c | sed -e 's/\.c/\.o/'` >> Makefile.flat
cat Makefile.tmp >> Makefile.flat
rm Makefile.tmp
makedepend -f Makefile.flat *.c
mv clb_defines.h tmpfile
echo "#define NDEBUG /* Automatically added for SPEC */" > clb_defines.h
echo "#define CONSTANT_MEM_ESTIMATE /* Automatically added for SPEC */" >> clb_defines.h
cat tmpfile >> clb_defines.h
rm tmpfile
