


proc raw_raw_send_str(s:var User, text:string):bool=
    while true:
        try:
            s.con.send(text)
            break
        except OSError:
            let time_passed= (epoch_time() - s.upload_started)
            if time_passed > no_min_upload_scan_before:
                let upload_speed= s.uploaded_bytes div int(time_passed)
                if upload_speed < min_upload_speed:
                    echo "TOO SLOW DOWNLOAD: ", s.ip
                    return true
            sleep sleep_on_no_send
    s.uploaded_bytes.inc text.len
  
# da polzvam unsafeAddr za access do socket-a
proc raw_send_str(s:var User, text:string):bool=
    var start= 0
    while working:
        let now= epoch_time()
        let time_left= s.next_upload - now
        if time_left > 0:
            sleep int(time_left*1000)
            s.next_upload= now + time_left
        else:
            s.next_upload= now
            
        let buffer= int(max_upload_speed / working_threads)
        let end_at= start + buffer
        if end_at > text.len:
            if s.raw_raw_send_str(text[start ..< ^1]):
                return true
            s.next_upload += ((text.len-start) / buffer)
            return
        else:
            if s.raw_raw_send_str(text[start ..< end_at]):
                return true
            s.next_upload += 1
    return true

proc raw_send_file(s:var User, dir:string):bool=
    let f= open dir
    while working:
        let now= epoch_time()
        let time_left= s.next_read_from_disk - now
        if time_left > 0:
            sleep int(time_left*1000)
            s.next_read_from_disk= now + time_left
        else:
            s.next_read_from_disk= now
            
        let buffer= int(max_read_from_disk_speed / working_threads)
        var to_be_sent= newString(buffer)
        let red_amount= f.readChars(to_be_sent, 0, buffer)
        if red_amount == 0:
            close f
            return
        elif red_amount < buffer:
            s.next_read_from_disk += red_amount / buffer
            close f
            return s.raw_send_str to_be_sent[0 ..< red_amount]
        elif s.raw_send_str to_be_sent:
            close f
            return true
        s.next_read_from_disk += 1
    return true


# http lower
proc http_content_disposition(s:var User, info:string)=
    s.http_header.add "Content-disposition: " & info & '\n'
    
proc http_content_type(s:var User, info:string)=
    s.http_header.add "Content-Type: " & info & '\n'

proc http_end(s:var User)=
    s.http_header.add "\n"

# http higher
    
proc finish(s:var User):bool=
    s.http_end()
    s.upload_started= epoch_time()
    result= s.raw_send_str s.http_header
    s.http_header= ""
   
proc send_file*(s:var User, content_type:string, dir:string):bool=
    s.http_content_type content_type
    if s.finish(): return true
    result= s.raw_send_file dir
   
proc send_download*(s:var User, name:string, dir:string):bool=
    s.http_content_disposition("attachment; filename=\"" & name & '\"')
    if s.finish(): return true
    result= s.raw_send_file dir
    
proc send_str*(s:var User, text:string):bool=
    s.http_content_type "text/plain"
    if s.finish(): return true
    result= s.raw_send_str text
    

