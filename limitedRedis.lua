-- 封禁时间
local ip_block_time=300 
-- 访问的时间范围
local ip_time_out=30  
-- 访问IP计数  
local ip_max_count=20 


-- 连接redis
local redis = require "resty.redis"  
local conn = redis:new()  
ok, err = conn:connect("127.0.0.1", 6379)  
conn:set_timeout(2000) 
if not ok then
    goto FLAG
end



-- 禁止
is_block, err = conn:get("BLOCK"..ngx.var.remote_addr)  
if is_block == '1' then
    ngx.exit(403)
    ngx.log(ngx.ERR,"BLOCK:"ngx.var.remote_addr )
    goto FLAG
end

-- 限流
ip_count, err = conn:get(ngx.var.remote_addr)

if ip_count == ngx.null then 
    res, err = conn:set(ngx.var.remote_addr, 1)
	res, err = conn:expire(ngx.var.remote_addr, ip_time_out)
else
    --ip_count = ip_count + 1 
    res,err = conn:incr(ngx.var.remote_addr)
  
    if ip_count >= ip_max_count then 
        res, err = conn:set("BLOCK"..ngx.var.remote_addr, 1)
        res, err = conn:expire("BLOCK"..ngx.var.remote_addr, ip_block_time)
	else
        res, err = conn:set(ngx.var.remote_addr,ip_count)
		res, err = conn:expire(ngx.var.remote_addr, ip_time_out)
    end
end


::FLAG::
local ok, err = conn:close()