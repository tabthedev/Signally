# Signally
A luau library which can generate class like RBXScriptSignal but custom event and more methods
<br><br>
Inspired by [typed-remote](https://github.com/Sleitnick/RbxUtil/blob/main/modules/typed-remote/init.luau) from [Sleitnick/RbxUtil](https://github.com/Sleitnick/RbxUtil)

## Install

```bash
pesde add tabthedev/signally

pesde install
```

## Types

(private) connectionCallback<V...>
```luau
type connectionCallback<V...> = (V...)->()
```

(public) Connection<V...>
```luau
type Connection<V...> = {
	Connected: boolean,
    
	Disconnect: (self: Connection<V...>)->()
}
```

(public) Signal<V...>
```luau
type Signal<V...> = {
	Connections: { Connection<V...> },
	Yields: { thread },

    Connect: (self: Signal<V...>, callback: connectionCallback<V...>)->Connection<V...>,
	Once: (self: Signal<V...>, callback: connectionCallback<V...>)->Connection<V...>,
	Wait: (self: Signal<V...>)->V...,

	DisconnectAll: (self: Signal<V...>)->(),
	CloseAllYields: (self: Signal<V...>)->(),
	KillAllEffects: (self: Signal<V...>)->(),

	Fire: (self: Signal<V...>, V...)->()
}
```


## Usage

No Argument Signal

```luau
local signal = signally.new() :: Signal<>
```

Argument(s) Signal

```luau
local signal = signally.new() :: Signal<number, string>
```

Overload Agrument(s) Signal

```luau
local signal = signally.new() :: Signal<number, string> & Signal<boolean>
```


