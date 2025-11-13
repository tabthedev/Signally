--!strict

----------------------
---- Type : Connection
----------------------

type connectionCallback<V...> = (V...)->()
type __meta__connection<V...> = {
	__index: __meta__connection<V...>,
	__call: (V...)->(),
	new: ((connectionsFromSignal: {Connection<V...>}, callback: connectionCallback<V...>)->Connection<V...>),

	Disconnect: (self: Connection<V...>)->()
}
export type Connection<V...> = typeof(setmetatable({} :: {
	Connected: boolean,
}, {} :: __meta__connection<V...>))



----------------------
---- Type : Signal
----------------------

type __meta__signal<V...> = {
	__index: __meta__signal<V...>,
	new: ()->Signal<V...>,

	Connect: (self: Signal<V...>, callback: connectionCallback<V...>)->Connection<V...>,
	Once: (self: Signal<V...>, callback: connectionCallback<V...>)->Connection<V...>,
	Wait: (self: Signal<V...>)->V...,

	DisconnectAll: (self: Signal<V...>)->(),
	CloseAllYields: (self: Signal<V...>)->(),
	KillAllEffects: (self: Signal<V...>)->(),

	Fire: (self: Signal<V...>, V...)->()
}
export type Signal<V...> = typeof(setmetatable({} :: {
	Connections: { Connection<V...> },
	Yields: { thread },
}, {} :: __meta__signal<V...>))



----------------------
---- Struct : Connection
----------------------

local Connection = {} :: __meta__connection<...any>
Connection.__index = Connection
Connection.__call = function() end

function Connection.new(connectionsFromSignal, callback)
	local meta = table.clone(Connection)
	meta.__index = meta
	meta.__call = callback
	--print(meta)

	local self = setmetatable({connectionsFromSignal, Connected = true}, meta)
	table.insert(connectionsFromSignal, self)

	return self
end

function Connection:Disconnect()
	self.Connected = false

	local ind = table.find(self[1], self)
	if not ind then
		return
	end

	table.remove(self[1], ind)
end

----------------------
---- Struct : Signal
----------------------

local Signal = {} :: __meta__signal<...any>
Signal.__index = Signal

--Creates new signal object
--새로운 Signal 개체 생성
function Signal.new()
	local self = setmetatable({
		Connections = {},
		Yields = {},
	}, Signal)

	return self
end


--Calls "callback" when the signal is fired by :Fire(args?) with the (args?) until it gets disconnected
--Signal 개체가 :Fire(인수?)에 의해 게시되면 disconnect되지 않은 이상 "callback" 함수를 (인수?)와 함께 호출함
function Signal:Connect(callback)
	local _type = typeof(callback)
	assert(_type == "function", `Expected callback function on arg 1 but got {_type}`)

	local connection = Connection.new(self.Connections, function(connection, ...)
		callback(...)
	end)

	return connection
end

--Calls "callback" when the signal is fired by :Fire(args?) with the (args?) for once if it isn't disconnected
--Signal 개체가 :Fire(인수?)에 의해 게시되면 disconnect되지 않은 이상 최초 1회만 "callback" 함수를 (인수?)와 함께 호출함
function Signal:Once(callback)
	local _type = typeof(callback)
	assert(_type == "function", `Expected callback function on arg 1 but got {_type}`)

	local connection = Connection.new(self.Connections, function(connection, ...)
		callback(...)
		connection:Disconnect()
	end)

	return connection
end

--Yields until the signal gets fired by :Fire(args?), also returns the (args?)
--Signal 개체가 :Fire(인수?)에 의해 게시될 때 까지 기다린 후, 그 (인수?)를 반환함
function Signal:Wait()
	local runningThread = coroutine.running()

	table.insert(self.Yields, runningThread)

	return coroutine.yield()
end

--Fires the signal to effect for Connections and :Wait() Yields
--Connection들과 :Wait() 대기들에게 효과를 입히기 위해 신호를 게시함
function Signal:Fire(...)
	for i = 1, #self.Connections do
		--self.Connections[i](...)
		coroutine.wrap(self.Connections[i].__call)(self.Connections[i], ...)
	end

	for i = 1, #self.Yields do
		coroutine.resume(self.Yields[i], ...)
	end
end



--Disconnectes every connections created by :Connect() or :Once()
--:Connect()나 :Once()로 생성된 모든 Connection을 :Disconnect()함
function Signal:DisconnectAll()
	for i = 1, #self.Connections do
		self.Connections[i]:Disconnect()
	end

end

--Closes every thread which is still yielding due of :Wait()
--:Wait()으로 인해 대기 상태가 된 모든 스레드를 닫음
function Signal:CloseAllYields()
	for i = 1, #self.Yields do
		coroutine.close(self.Yields[i])
	end
end

--Runs both :DisconnectAll() and :CloseAllYields()
function Signal:KillAllEffects()
	self:DisconnectAll()
	self:CloseAllYields()
end



return Signal