-- 功能： 限流脚本
-- Date： 2020/4/24
-- Ver： 0.1


local limit_req = require "resty.limit.req"
local rate = 2 
local burst = 1 
local error_status = 404
local nodelay = false 
local white_ip={'10.10.10.101'}

-- 没有字典，退出
local lim, err = limit_req.new("limit_req_store", rate, burst)
if not lim then
    ngx.exit(error_status)
end


local key = ngx.var.clientRealIp 
local delay, err = lim:incoming(key, true)

-- 白名单
for _,ip in ipairs(white_ip)
do 
    if ngx.var.clientRealIp == ip then
        goto PASS
    end
end



-- 超过rate+burst禁止IP
if not dealy and err == "rejected" then
      ngx.exit(error_status)
      --ngx.redirect('www.baidu.com')
      
end

-- 超过rate，未超rate+brust限流
if delay > 0 then 
    if nodelay then
        
    else
        ngx.sleep(delay) 
        
    end
end


