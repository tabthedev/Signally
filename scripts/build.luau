-- scripts/build.luau

local multitarget = require("../lune_packages/multitarget")

multitarget.build(
	"pesde.toml", -- defaults to "pesde.toml"
	{ -- pesde project file path defaults to "pesde.toml"
		luau = true,
        lune = true,
		roblox = true,
	},
	"dist", -- defaults to "dist"
	{
		"src" -- files/directories to be built
	},
	"LUA_ENV", -- defaults to "LUA_ENV"
	"pkg", -- defaults to "pkg"
	"luau_pkg", -- defaults to "luau_pkg"
	true -- defaults to true
)