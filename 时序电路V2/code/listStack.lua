local listStack = {}

function listStack:new(o)
	o = o or {}  
    setmetatable(o,self);  
    self.__index = self; 
----初始化,初始栈长度为0
	o.length = 0
    return o;  
end

function listStack:push( v )
	self.top = { next = self.top,value = v }
	self.length = self.length + 1
	return self.top
end

function listStack:pop( )
	if self.length <= 0 then
		print("错误，栈中没有数据，无法弹出")
		return
	end

	local p = self.top.next
----释放顶指针指向资源
	self.top = nil
	self.top = p
	self.length = self.length - 1
	return self.top
end

function listStack:ifexist( v )
	local p = self.top
	while p do
		if (p.value == v) then
			print("已存在此节点")
			return true
		end
		p = p.next
	end
end

_G.listStack = listStack