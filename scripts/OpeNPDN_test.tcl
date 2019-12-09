read_lef /home/sachin00/chhab011/OpenDB/tests/data/Nangate45/NangateOpenCellLibrary.mod.lef
read_def /home/sachin00/chhab011/aes/aes.def
read_liberty /home/sachin00/chhab011/aes/NangateOpenCellLibrary_typical.lib
read_sdc /home/sachin00/chhab011/aes/aes_cipher_top.sdc

set OPDN_DIR "/home/sachin00/chhab011/OpenROAD/src/OpeNPDN/"
set OPDN_OpenDB_BUILD_DIR "/home/sachin00/chhab011/OpenDB/build/"

#source "${OPDN_DIR}/scripts/OpeNPDN.tcl"

openpdn  -OPDN_DIR ${OPDN_DIR} -OPDN_OpenDB_BUILD_DIR ${OPDN_OpenDB_BUILD_DIR}
