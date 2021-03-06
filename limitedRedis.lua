-- 功能： 限流脚本
-- Date： 2020/4/27
-- Ver： 0.1




local ip_block_time=300 
local ip_time_out=30  
local ip_max_count=20 
local ip_brust=10
local delay=0.8
local white_ip={'10.10.10.101'}
local dealy_switch = on
--local passwd=os.getenv('redis_passwd')


-- 连接redis
local redis = require "resty.redis"  
local conn = redis:new()  
ok, err = conn:connect("127.0.0.1", 6379)  
conn:set_timeout(2000) 
if not ok then
    goto CLOSE
end

-- 认证
res, error = conn:get_reused_times()
if 0 == res then
    auth_ok, auth_error = conn:auth("2345")
    if not auth_ok then
        ngx.log(ngx.ERR,"failed to auth redis: ", auth_err)
        goto CLOSE        
    end
--[[ elseif err then
    ngx.say("failed to get reused times: ", err)
    return ]]
end

-- 白名单
for _,ip in ipairs(white_ip)
do 
    if ngx.var.clientRealIp == ip then
        goto PASS
    end
end


-- 禁止
is_block, err = conn:get("BLOCK"..ngx.var.clientRealIp)  
if is_block == '1'  then
    ngx.exit(403)
    --[[ gx.say('Forbidden:'..ngx.var.clientRealIp)
    goto PASS ]]
    ngx.log(ngx.ERR,"BLOCK:"..ngx.var.clientRealIp)
end

-- 限流
ip_count, err = conn:get(ngx.var.clientRealIp)

if ip_count == ngx.null then 
    res, err = conn:set(ngx.var.clientRealIp, 1)
	res, err = conn:expire(ngx.var.clientRealIp, ip_time_out)
else
    ip_count = ip_count + 1      
    if ip_count >= ip_max_count then 
        res, err = conn:set("BLOCK"..ngx.var.clientRealIp, 1)
        res, err = conn:expire("BLOCK"..ngx.var.clientRealIp, ip_block_time)
    elseif ip_count >= ip_brust and dealyswitch == on then        
        res, err = conn:set(ngx.var.clientRealIp,ip_count)
        res, err = conn:expire(ngx.var.clientRealIp, ip_time_out)
        ngx.sleep(delay)
        ngx.say("delay time:"..delay)
    else
        res, err = conn:set(ngx.var.clientRealIp,ip_count)
		res, err = conn:expire(ngx.var.clientRealIp, ip_time_out)
    end
end

-- 连接池
kep_ok, kep_err = conn:set_keepalive(10000, 100)
if not kep_ok then
    ngx.log(ngx.ERR,"failed to set keepalive: ", kep_err)
        
end


::CLOSE::
clo_ok, clo_err = conn:close()

::PASS::
kep_ok, kep_err = conn:set_keepalive(10000, 100)
if not kep_ok then
    ngx.log(ngx.ERR,"failed to set keepalive: ", kep_err)
        
end