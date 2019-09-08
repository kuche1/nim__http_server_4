
const
    steal_port= true
    port= 80
    listen:int32= 12
    
    max_acccepting_threads= 2
    sleep_on_max_acccepting_threads= 100
    
    sleep_on_no_new_connection= 100
    
    max_working_threads= 16
    sleep_on_max_working_threads= 100
    
    min_download_speed= 1024 * 10
    maxlen_header= 100
    maxlen_body= 1024 * 3
    max_download_speed= 1024 * 1024 * 2
    
    max_upload_chunk= 1024 * 10
    no_min_upload_scan_before= 3
    min_upload_speed= 1024 * 10
    sleep_on_no_send= 100
    max_upload_speed= 1024 * 1024 * 4
    
    max_read_from_disk_chunk= 1024 * 1024
    #max_read_from_disk_speed= 1024 * 1024
