


proc recv(s:var User, size:int, timeout:int):(bool,string)=
    result[1]= newString(size)
    try:
        if s.con.recv(result[1], size, timeout) == 0:
            echo "TIMEOUT WHILE RECIVING: ", s.ip
            return (true,"")
    except TimeoutError:
        return (true,"")
    
    inc s.downloaded,size
    while true:
        let max_download= int( max_download_speed / working_threads )
        if s.downloaded >= max_download:
            let waited= epoch_time() - s.download_start
            if waited < 1:
                sleep 1000
            s.download_start= epoch_time()
            s.downloaded.dec max_download
        else:
            break
        
        

proc recv_line(s:var User, maxlen:int):(bool,string)=
    var data:string
    let timeout= maxlen / min_download_speed
    let end_at= epoch_time() + timeout
    while true:
        if not working:
            return (true,"")
        let remains= int( (end_at - epoch_time())*1000 )
        if remains <= 0:
            return (true,"")
        
        let (bad,recived)= s.recv(1, remains)
        if bad:
            return (true,"")
        data.add recived
        if data.endsWith("\r\L"):
            return (false,data[0 .. ^3])


proc recive_header*(s:var User, maxlen=maxlen_header):bool=
    let (bad,data)= s.recv_line(maxlen)
    if bad:
        return true
    if data.count(' ') != 2:
        echo "Bad pre header format: ", s.ip
        
    (s.meth, s.url, s.proto)= data.split(' ')
    s.meth= decode_url s.meth
    s.url= decode_url s.url
    s.proto= decode_url s.proto


proc recive_body*(s:var User, maxlen=maxlen_body):bool=
    var remains_size= maxlen
    while true:
        if not working:
            return true
        let (bad,line)= s.recv_line(remains_size)
        if bad or (line == ""):
            return
        remains_size.dec len(line)
        # echo "RECIVED BODY: ", line
