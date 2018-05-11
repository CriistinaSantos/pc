-module(avatar).
-export([generateAvatar/0]).

generateAvatar() ->
	{20, 120.0, rand:uniform(500)+0.0, 50.0, 50, 50}.