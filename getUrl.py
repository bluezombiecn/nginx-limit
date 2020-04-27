from urllib import request
import time
from multiprocessing import Pool

def getUrl(remoteIP,url):
    req = request.Request(url)
    req.add_header('X-Forwarded-For',remoteIP)
    start = time.time()   
    try:
        with request.urlopen(req) as f:        
            end = time.time()
            print('status:',f.getcode(),'body:',f.read(),'resptime:',(end - start))
    except Exception as e:
        print(e)
        
if __name__ == "__main__":
    p = Pool(4)
    remoteIP = '10.10.10.128'
    url= 'http://192.168.56.101'

    for i in range(250):
        getUrl(remoteIP,url)
    """ for i in range(100):
        p.apply_async(getUrl,args=(remoteIP,url,))
    p.close()
    p.join() """


