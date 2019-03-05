set xml_path [lindex $argv 0]
set repo_path [lindex $argv 1]
set proc_1 [lindex $argv 2]
set output [lindex $argv 3]


puts "xml_path: $xml_path , proc: $proc_1 ,  repo path : $repo_path output : $output"
set hw [hsi open_hw_design $xml_path]
hsi set_repo_path $repo_path
hsi create_sw_design sw1 -proc ${proc_1}  -os device_tree
hsi generate_target -dir ${output} 
