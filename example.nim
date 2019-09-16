
import net

import nhs/nhs




on_connect proc(u:var User)=
    echo "Connection attempt: ",u.ip
    
    assure u.recive_header()
    echo "Meth: ", u.meth
    echo "Url: ", u.url
    echo "Proto: ", u.proto

    assure u.recive_body()
    
    if u.send_download("dream corp llc s2 e12.mp4", "responses/s2e12.mp4"):
        echo "file not sent"
    else:
        echo "file sent"
    

