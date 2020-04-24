-- 功能： 限流脚本
-- Date： 2020/4/24
-- Ver： 0.1


local limit_req = require "resty.limit.req"
local rate = 2 
local burst = 1 
local error_status = 404
local nodelay = false 

local lim, err = limit_req.new("limit_req_store", rate, burst)
if not lim then
    ngx.exit(error_status)
end

local key = ngx.var.remote_addr 
local delay, err = lim:incoming(key, true)

if not dealy and err == "rejected" then
      ngx.exit(error_status)
      
end


if delay > 0 then 
    if nodelay then
        
    else
        ngx.sleep(delay) 
        
    end
end


