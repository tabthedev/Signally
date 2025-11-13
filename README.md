# Signally
A library which can generate class like RBXScriptSignal but custom event and more methods

## Install

```bash
pesde add tabthedev/signally

psede install
```

## Types

Signal<V...>


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