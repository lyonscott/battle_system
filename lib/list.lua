local list={}
list.__index=list

function list.new()
    local t={
        _first=1,
        _last=0,
    }
    return setmetatable(t,list)
end

function list:fpush(v)
    self._first=self._first-1
    self[self._first]=v
end
function list:lpush(v)
    self._last=self._last+1
    self[self._last]=v
end
function list:fpop()
    local x=self._first
    if x>self._last then return nil end
    local v=self[x]
    self[x]=nil
    self._first=x+1
    return v
end
function list:lpop()
    local y=self._last
    if y<self._first then return nil end
    local v=self[y]
    self[y]=nil
    self._last=y-1
    return v
end

function list:len() return self._last-self._first+1 end
function list:clear()
    for i=self._first,self._last do
        self[i]=nil
    end
    self._first,self._last=1,0
end

return list
