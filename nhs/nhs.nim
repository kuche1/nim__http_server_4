

template assure*( test:bool )=
    if test == true:
        return


proc error(info:string)=
    echo " === ERROR === "
    echo info
    quit()

include imports
include settings
include user
include server
include user_recv_procs
include user_send_procs
