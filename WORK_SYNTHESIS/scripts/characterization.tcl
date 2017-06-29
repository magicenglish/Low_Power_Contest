source ./scripts/dualVth_Group_23.tcl

# restore all cells to LVT
proc LVT_restore {} {
    set lvt_cell [get_cells]
    foreach z [get_attribute $lvt_cell full_name ] y [get_attribute $lvt_cell ref_name ] {
      set   lvt_type_temp [string replace $y 5 6 LL ]
      size_cell $z CORE65LPLVT_nom_1.20V_25C.db:CORE65LPLVT/$lvt_type_temp > /dev/null
    }
    #report_threshold_voltage_group
}

# Characterization
foreach blockName [list "c5315" "aes_cipher_top" "c1908"] {
  source ./scripts/myAnalysis.tcl
  echo [get_attribute [get_design] leakage_power] > saved/$blockName/startingLeakage.rpt

  foreach constraint [list "soft" "hard"] {
    for {set percentage 1} {$percentage < 100} {incr percentage } {
        set lvt_percentage [expr { $percentage / 100.0 } ]
        set TIME_start [clock clicks -milliseconds]
        dualVth -lvt $lvt_percentage -constraint $constraint 
        set time_op [expr {[clock clicks -milliseconds] - $TIME_start}]
        update_power
        set leakage [get_attribute [get_design] leakage_power]
        set LVT_number [sizeof_collection [get_cells -filter "@lib_cell.threshold_voltage_group == LVT"]]
        set HVT_number [sizeof_collection [get_cells -filter "@lib_cell.threshold_voltage_group == HVT"]]
        echo $percentage "; " $time_op "; " $leakage "; " $LVT_number "; " $HVT_number >> saved/$blockName/$constraint.csv
        LVT_restore
    }
  }
}
exit

