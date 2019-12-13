read_lef /home/sachin00/chhab011/OpenDB/tests/data/Nangate45/NangateOpenCellLibrary.mod.lef
read_def /home/sachin00/chhab011/aes/aes.def
read_liberty /home/sachin00/chhab011/aes/NangateOpenCellLibrary_typical.lib
read_sdc /home/sachin00/chhab011/aes/aes_cipher_top.sdc

set test_dir [file dirname [file normalize [info script]]]
set openroad_dir [file dirname [file dirname [file dirname $test_dir]]]
set OPDN_DIR [file join "src/OpeNPDN"]
set opendbpy [file join "build/src/swig/python/opendbpy.py"
#puts $test_dir

#set OPDN_DIR "/home/sachin00/chhab011/OpenROAD/src/OpeNPDN/"
#set opendbpy "/home/sachin00/chhab011/OpenDB/build/src/swig/python/opendbpy.py"
set checkpoints "./OpeNPDN-Checkpoint-FreePDK45"

run_openpdn  -OPDN_DIR ${OPDN_DIR} -opendbpy ${opendbpy} -checkpoints ${checkpoints} -verbose
exit 0
