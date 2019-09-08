

var acccepting_threads, working_threads:int
var acccepting_threads_lock, working_threads_lock:Lock
initLock acccepting_threads_lock
initLock working_threads_lock


var running= true
var working= true
var sock= newSocket()
let sock_addr= sock.addr
when steal_port:
        sock.set_sock_opt OptReuseAddr, true
sock.get_fd().set_blocking false


include control_panel


proc accept_new_connections( on_connect:proc(_:var User) )=
    while acccepting_threads == max_acccepting_threads:
        sleep sleep_on_max_acccepting_threads
        
    if running:
        acquire acccepting_threads_lock
        inc acccepting_threads
        echo "Accepting threads: ",acccepting_threads
        release acccepting_threads_lock
        spawn accept_new_connections( on_connect )
    else:
        return
    
    var con:Socket
    var ip:string
    while true:
        try:
            sock_addr[].acceptAddr con,ip
        except OSError:
            if running:
                sleep sleep_on_no_new_connection
                if running:
                    continue
            acquire acccepting_threads_lock
            dec acccepting_threads
            echo "Accepting threads: ",acccepting_threads
            release acccepting_threads_lock
            return
        break
    acquire acccepting_threads_lock
    dec acccepting_threads
    echo "Accepting threads: ",acccepting_threads
    release acccepting_threads_lock
    
    while working_threads == max_working_threads:
        sleep sleep_on_max_working_threads
    
    acquire working_threads_lock
    inc working_threads
    echo "Working threads: ",working_threads
    release working_threads_lock
    
    var user= newUser( con, ip )
    on_connect( user )
    close con
    
    acquire working_threads_lock
    dec working_threads
    echo "Working threads: ",working_threads
    release working_threads_lock
                
    
    
    


proc on_connect*( action:proc(u:var User) )=
    
    echo "Binding port: ",port
    try:
        sock.bindAddr(Port port)
    except OSError:
        error getCurrentExceptionMsg()
        
    echo "Listening: ", listen
    sock.listen listen
    
    spawn accept_new_connections( action )
    
    control_panel()
    echo "Waiting for threads to end..."
    sync()
