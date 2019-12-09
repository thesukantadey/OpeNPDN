#BSD 3-Clause License
#
#Copyright (c) 2019, The Regents of the University of Minnesota
#
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#
#* Redistributions of source code must retain the above copyright notice, this
#  list of conditions and the following disclaimer.
#
#* Redistributions in binary form must reproduce the above copyright notice,
#  this list of conditions and the following disclaimer in the documentation
#  and/or other materials provided with the distribution.
#
#* Neither the name of the copyright holder nor the names of its
#  contributors may be used to endorse or promote products derived from
#  this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#!/usr/bin/tclsh
#set OPDN_DIR "/home/sachin00/chhab011/OpeNPDN/"
#set OPDN_OpenDB_BUILD_DIR "/home/sachin00/chhab011/OpenDB/build"
#write_db "${OPDN_DIR}/work/PDN.db"

sta::define_cmd_args "openpdn" {
    [-OPDN_DIR OPDN_DIR]\
    [-OPDN_OpenDB_BUILD_DIR OPDN_OpenDB_BUILD_DIR]\
    [-help]}

proc openpdn { args } {
    sta::parse_key_args "openpdn" args \
    keys {-OPDN_DIR -OPDN_OpenDB_BUILD_DIR} \
    flags {-help}

    if [info exists flags(-help)] {
        puts "Usage: openpdn -OPDN_DIR <OpeNPDN path> -OPDN_OpenDB_BUILD_DIR <OpeDB path>"
        exit 0
    }
    set OPDN_DIR ""
    if [info exists keys(-OPDN_DIR)] {
      set OPDN_DIR $keys(-OPDN_DIR)
    } else {
      sta::sta_error "no -OPDN_DIR specified."
    }
    set OPDN_OpenDB_BUILD_DIR ""
    if [info exists keys(-OPDN_OpenDB_BUILD_DIR)] {
      set OPDN_OpenDB_BUILD_DIR $keys(-OPDN_OpenDB_BUILD_DIR)
    } else {
      sta::sta_error "no -OPDN_OpenDB_BUILD_DIR specified."
    }
#proc openpdn {OPDN_DIR OPDN_OpenDB_BUILD_DIR} {}
#if {![info exists OPDN_DIR]} {
#    puts "OPDN_DIR variable not defined please set it before running OpeNPDN"
#    exit 1
#}
#if {![info exists OPDN_OpenDB_BUILD_DIR]} {
#    puts "OPDN_OpenDB_BUILD_DIR variable not defined please set it before running OpeNPDN"
#    exit 1
#}
#if {![file exists "${OPDN_DIR}/work/PDN.db"]} {
#    puts "OpenDB database for OpeNPDN not defined, please export the db before running OpeNPDN"
#    exit 1
#}
file mkdir ${OPDN_DIR}/work
write_db "${OPDN_DIR}/work/PDN.db"

set openpdn_congestion_enable "no_congestion"
set WD [pwd]

cd ${OPDN_DIR}

foreach x [get_cells *] {
	set y [get_property $x full_name]
	report_power -instance $y -digits 10 >> ./work/power_instance.rpt
	}

set OPDN_ODB_LOC "${OPDN_OpenDB_BUILD_DIR}/src/swig/python/opendbpy.py"
set OPDN_MODE "INFERENCE"

exec python3 src/T6_PSI_settings.py "${OPDN_ODB_LOC}" "${OPDN_MODE}"
#if {![file isdirectory templates]} {
    file mkdir templates
    puts "create template"
    exec python3 src/create_template.py
#}
exec python3 src/current_map_generator.py work/power_instance.rpt $openpdn_congestion_enable
if {![file isdirectory checkpoints]} {
    puts "OpeNPDN CNN checkpoints directory not found. Downloading default checkpoints"
    exec git clone --depth 1 https://github.com/VidyaChhabria/OpeNDPN-Checkpoint-FreePDK45.git checkpoints
    cd  "${OPDN_DIR}/checkpoints"
    pwd
    exec python3 scripts/build.py $openpdn_congestion_enable
    cd  ${OPDN_DIR}
} elseif {![file exists checkpoints/checkpoint_wo_cong/checkpoint]} {
     sta::sta_error "OpeNPDN CNN checkpoint not found. Please run the training flow or download the default checkpoint"
} else { 
    puts "Using stored OpeNPDN CNN checkpoint"
}

exec python3 src/cnn_inference.py $openpdn_congestion_enable
exec python3 src/IR_map_generator.py


cd ${WD}
}
