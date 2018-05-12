-module(chatEx3).
-export([start/1]).

start(Port) ->
	login_managerEx3:start(),
	Lobby = spawn(fun() -> lobby(#{}, []) end),
	{ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]), 
	acceptor(LSock, Lobby).

acceptor(LSock, Lobby) ->
	{ok, Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock, Lobby) end),
	Lobby ! {enter, self()},
	userInLobby(Sock, Lobby).

lobby(Rooms, Pids) ->
	io:format("entrei no loop do lobby ~n"),
	receive
		{enter, Pid} ->
			io:format("user entered the lobby~n", []),
			lobby(Rooms, [Pid | Pids]);

		{login, Username, Passwd, RoomName, Lobby, Sock, Pid} ->
			case maps:find(RoomName, Rooms) of
				{ok, {Room}} ->
					%spawn(fun() -> lobby(Rooms, Pids -- [Pid]) end),
					Pid ! {Lobby, ok_login, Room},
					lobby(Rooms, Pids -- [Pid]);
					%Room ! {enter, self()},
					%user(Sock, Room);
				_ ->
					Pid ! {Lobby, error},
					lobby(Rooms, Pids)
			end;

		{create_room, RoomName, Lobby, Port, Pid} -> 
			case maps:find(RoomName, Rooms) of
				error ->
					Room = spawn(fun() -> room(RoomName, []) end),
					M2 = maps:put(RoomName, {Room}, Rooms),
					Pid ! {Lobby, room_created},
					lobby(M2, Pids);
				_ -> 
					Pid ! {Lobby, room_not_created},
					lobby(Rooms, Pids)
			end;

		{rooms, Lobby, Pid} -> 
			Pid ! {Lobby ,[RoomName|| {RoomName,_} <- maps:to_list(Rooms)]},
			lobby(Rooms, Pids);

		{leave, Pid} ->
			io:format("user left ~n", []),
			lobby(Rooms, Pids -- [Pid])
	end.


userInLobby(Sock, Lobby) ->
	receive
		{line, Data} ->
			gen_tcp:send(Sock, Data),
			userInLobby(Sock, Lobby);
		{tcp, _, Data} ->
			L = binary_to_list(Data),
			T = string:strip(L,both,$\n),
			S = string:tokens(T," "),
			case S of
				["login", Username, Passwd, Room] -> 
					case login_managerEx3:login(Username, Passwd) of
						ok -> gen_tcp:send(Sock, <<"ok\n">>),
							  Lobby ! {login, Username, Passwd, Room, Lobby, Sock, self()},
							  io:format("antes do receive ~n"),
							  receive {Lobby, Msg, R} -> 
							  		io:format("depois do receive ~n"),
									gen_tcp:send(Sock, atom_to_list(Msg) ++ "\n"),
									R ! {enter, self()},
									user(Sock, R)
							  end;
						_ -> gen_tcp:send(Sock, <<"login invalid\n">>)
					end;

				["logout", Username] -> 
						case login_managerEx3:logout(Username) of
						   	ok -> gen_tcp:send(Sock, <<"logout sucessfully\n">>);
						   	_ -> gen_tcp:send(Sock, <<"logout invalid\n">>)
						end;

				["create_account", Username, Passwd] ->
						F = login_managerEx3:create_account(Username, Passwd),
						io:format("bool ~p~n", [F]),
						case F of
						   	ok -> gen_tcp:send(Sock, <<"created sucessfully\n">>);
						   	_ -> gen_tcp:send(Sock, <<"create invalid\n">>)
						end;

				["close_account", Username, Passwd] -> 
						case login_managerEx3:close_account(Username, Passwd) of
						   	ok -> gen_tcp:send(Sock, <<"closed sucessfully\n">>);
						   	_ -> gen_tcp:send(Sock, <<"close invalid\n">>)
						end;

				["create_room", RoomName, Port] -> 
					Lobby ! {create_room, RoomName, Lobby, Port, self()},
					receive {Lobby, Msg} -> 
						gen_tcp:send(Sock, atom_to_list(Msg) ++ "\n"),
						Msg end;

				["rooms"] ->
					Lobby ! {rooms, Lobby, self()},
					receive {Lobby, Msg} -> 
						gen_tcp:send(Sock, atom_to_list(Msg) ++ "\n"),
						Msg end;

				_ ->
						gen_tcp:send(Sock, <<"invalid message\n">>)


			end,
			userInLobby(Sock, Lobby);

		{tcp_closed, _} ->
			Lobby ! {leave, self()};

		{tcp_error, _, _} ->
			Lobby ! {leave, self()}
	end.


room(RoomName, Pids) ->
	receive
		{enter, Pid} ->
			io:format("user entered room ~p ~n", [RoomName]),
			room(RoomName, [Pid | Pids]);
		{line, Data} = Msg ->
			io:format("received ~p ~n", [Data]),
			[Pid ! Msg || Pid <- Pids],
			room(RoomName, Pids);
		{leave, Pid} ->
			io:format("user left ~n", []),
			room(RoomName, Pids -- [Pid])
	end.


user(Sock, Room) ->
	io:format("Sou user e tou no room ~p ~n",[Room]),
	receive
		{line, Data} ->
			gen_tcp:send(Sock, Data),
			user(Sock, Room);
		{tcp, _, Data} ->
			Room ! {line, Data},
			user(Sock, Room);
		{tcp_closed, _} ->
			Room ! {leave, self()};
			{tcp_error, _, _} ->
			Room ! {leave, self()}
	end.