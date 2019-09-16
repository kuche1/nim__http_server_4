
type User* =object
    con:Socket
    download_started:float
    downloaded:int
    http_header:string
    next_read_from_disk:float
    next_upload:float
    upload_started:float
    uploaded_bytes:int64
    
    ip:string
    meth:string
    url:string
    proto:string

proc ip*(s:User):string= s.ip
proc meth*(s:User):string= s.meth
proc url*(s:User):string= s.url
proc proto*(s:User):string= s.proto


proc newUser(con:Socket, ip:string):User=
    result.con= con
    result.download_started= epoch_time()
    result.http_header= "HTTP/1.X 200 OK\n"
    
    result.ip= ip


