-- 连接redis
local redis = require "resty.redis"  
local red = redis:new()  
ok, err = red:connect("127.0.0.1", 6379)  
red:set_timeout(2000) 
if not ok then  
    --goto CLOSE
    local ok, err = red:close()
    return
end

local count
count, err = red:get_reused_times()
ngx.log(ngx.ERR,count,err)
if 0 == count then
    ok, err = red:auth("1234")
    if not ok then
        ngx.say("failed to auth: ", err)
        return
    end
elseif err then
    ngx.say("failed to get reused times: ", err)
    return
end

ok, err = red:set("dog", "an animal")
if not ok then
    ngx.say("failed to set dog: ", err)
    return
end

ngx.say("set result: ", ok)

-- 连接池大小是100个，并且设置最大的空闲时间是 10 秒
--[[ local ok, err = red:set_keepalive(10000, 100)
ngx.log(ngx.ERR,"kep_ok:",ok,"kep_err:",err)
if not ok then
    ngx.log(ngx.ERR,"failed to set keepalive: ", err)
    return
end ]]