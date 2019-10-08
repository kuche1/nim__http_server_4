import socket
from time import sleep, time


s= socket.socket()
s.connect(('localhost', 80))

s.sendall(b"""dasdas dasdas dasdasd\r
\r
\r
""")

data= s.recv(5555)
print(data)

uploaded= 0
start= time()
sleep( 0.01)
while True:
    uploaded+= len(s.recv( 1024*1024 ) )

    print( "DOWNLAOD SPEED: ", (uploaded / (time() - start)) )


s.shutdown()
s.close()
