-- 封禁时间
--local ip_block_time=300 
-- 访问的时间范围
--local ip_time_out=30  
-- 访问IP计数  
local ip_max_count=20 


-- 连接redis
local redis = require "resty.redis"  
local conn = redis:new()  
ok, err = conn:connect("127.0.0.1", 6379)  
conn:set_timeout(2000) 
if not ok then
    ngx.log(ngx.ERR,"connect redis timeout." )
    local ok, err = conn:close()
    goto FLAG
end

-- 模块开关
limited,err = conn:set('limited',off)
limited,err = conn:get("limited")
if limited == off then
    goto CLOSE
end


local ip_block_time,err = conn:get('adidasBlockexpireTime')
local ip_time_out,err1 = conn:get('adidasIpTimeout')


-- 禁止
--is_block, err = conn:get("BLOCK"..ngx.var.clientRealIp)  
--if is_block == '1' then
--    ngx.exit(403)
--    ngx.log(ngx.ERR,"BLOCK:",ngx.var.clientRealIp )
 --   goto FLAG
--end

ip_count, err = conn:get(ngx.var.clientRealIp)

if ip_count == ngx.null then 
    res, err = conn:set(ngx.var.clientRealIp, 1)
    res, err = conn:expire(ngx.var.clientRealIp, ip_time_out)
else
    ip_count = ip_count + 1 
    --ip_count,err = conn:incr(ngx.var.clientRealIp)
  
    if ip_count >= ip_max_count then 
        res, err = conn:set("BLOCK"..ngx.var.clientRealIp, 1)
        res, err = conn:expire("BLOCK"..ngx.var.clientRealIp, ip_block_time)
    else
        res, err = conn:set(ngx.var.clientRealIp,ip_count)
        res, err = conn:expire(ngx.var.clientRealIp, ip_time_out)
        
    end
end

::FLAG::

