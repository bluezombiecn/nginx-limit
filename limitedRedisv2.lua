-- 功能： 限流脚本
-- Date： 2020/4/27
-- Ver： 0.2




local ip_block_time=300 
local ip_time_out=30  
local ip_max_count=20 
local ip_brust=10
local delay=0.8
local white_ip={'10.10.10.101'}
local dealy_switch = on
--local passwd=os.getenv('redis_passwd')
--[[ local list={ip_block_time='300',ip_time_out='30',ip_max_count='20',ip_brust='10',delay='0.8',dealy_switch='on'}
local white_ip={'10.10.10.101'}
 ]]
-- 连接redis
local redis = require "resty.redis"  
local conn = redis:new()  
ok, err = conn:connect("127.0.0.1", 6379)  
conn:set_timeout(2000) 
if not ok then  
    --goto CLOSE
    local ok, err = conn:close()
    return
end

-- 认证
local res, error = conn:get_reused_times()
ngx.log(ngx.ERR,'res:',res,"error",error)
if 0 == res then
    local auth_ok, auth_error = conn:auth("1234")
    if not auth_ok then
        ngx.log(ngx.ERR,"failed to auth redis: ", auth_err)
        --goto CLOSE
        local ok, err = conn:close()
        return        
    end
--[[ elseif err then
    ngx.say("failed to get reused times: ", err)
    return ]]
end

-- 初始化参数，开关

--[[ for key,val in ipairs(list)
do 
    res,err = conn:get(key)
    if not res then
        res1,err1 = conn:set(key,val)
    end
end
 ]]


-- 白名单
for _,ip in ipairs(white_ip)
do 
    if ngx.var.clientRealIp == ip then
        --goto PASS
        return
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
local ok, err = conn:set_keepalive(10000, 100)
if not ok then
    ngx.log(ngx.ERR,"failed to set keepalive: ",err)
    return
    
        
end


::CLOSE::

local ok, err = conn:close()



::PASS::
kep_ok1, kep_err1 = conn:set_keepalive(10000, 100)
if not kep_ok1 then
    ngx.log(ngx.ERR,"failed to set keepalive: ", kep_err1)
        
end