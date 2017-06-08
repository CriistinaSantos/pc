-module(chat).
-export([server/1]).
-import(user_management, [start/0, create_account/2, login/2, logout/1, online/0]).

server(Port) ->
	Room = spawn(fun()-> room([]) end),
	user_management:start(),
	{ok, LSock} = gen_tcp:listen(Port, [list, {packet, line}, {reuseaddr, true}]),
	acceptor(LSock, Room).

acceptor(LSock, Room) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock, Room) end),
	Room ! {enter, self()},
	user(Sock, Room).
		
room(Pids) ->
	receive
		{enter, Pid} ->
			io:format("user entered~n", []),
			room([Pid | Pids]);
		{line, Data} = Msg ->
			io:format("received ~p~n", [Data]),
			[Pid ! Msg || Pid <- Pids],
			room(Pids);
		{leave, Pid} ->
			io:format("user_left~n", []),
			room(Pids -- [Pid])
end.


user(Sock, Room) ->
	receive			
		{line, Data} ->
			gen_tcp:send(Sock, Data),
			user(Sock, Room);
		{tcp, _, Data} ->
			L=string:tokens(Data," "),
			L=string:strip(L,both,$\n),
			L=string:strip(L,both,$\n),
			case L of
				["login", Username, Passwd] -> io:format("user logined~p~n", [Data]),
						   					   user_management:login(Username, Passwd);
				["create_account", Username, Passwd] -> io:format("user create_account~p~n", [Data]),
						   					   user_management:create_account(Username, Passwd);
				["logout", Username] -> io:format("user create_account~p~n", [Data]),
						   					   user_management:logout(Username);
				_ -> io:format("xd~p~n", [Data])
			end,
			Room ! {line, Data},
			user(Sock, Room);
		{tcp_closed, _} ->
			Room ! {leave, self()};
		{tcp_error, _, _} ->
			Room ! {leave, self()}
end. 