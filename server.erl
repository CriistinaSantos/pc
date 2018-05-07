-module(server).
-compile(export_all).
-import(loginmanager,[start/0]).

server(Port) -> 
	loginmanager:start(),
	Room = spawn(fun() -> room([]) end),
	{ok,LSock} = gen_tcp:listen(Port,[binary, {packet, line}, {reuseaddr, true}]),
	acceptor(LSock,Room).

acceptor(LSock,Room) ->
	{ok,Sock} = gen_tcp:accept(LSock),
	spawn(fun() -> acceptor(LSock,Room) end),
	user(Sock,Room).

room(Pids) ->
    receive
        {enter, Pid} ->
            io:format("user entered~n", []),
            room([Pid | Pids]);
        {line, Data,Socket} ->
            io:format("received ~p~n", [Data]),
            [Pid ! {line,Data} || Pid <- Pids],
            room(Pids);
        {leave, Pid} ->
            io:format("user left~n", []),
            room(Pids -- [Pid])
    end.

user(Sock, Room) ->
    receive
        {line, Data} ->
            gen_tcp:send(Sock, Data);

        {tcp, Socket, Data} ->
            StrData = binary:bin_to_list(Data),
            case StrData of
             "\\login " ++ Dados ->
             St = string:tokens(Dados, " "),
             [U | P] = St,
             case loginmanager:login(U, P) of
              ok -> gen_tcp:send(Socket,<<"ok_login\n">>),
              		Room ! {enter,self()},
              		userauthenticated(Sock, Room);
              _ -> gen_tcp:send(Socket,<<"invalid_login\n">>)
              end;

          
          "\\create_account " ++ Dados ->
            St = string:tokens(Dados, " "),
            [U | P] = St,
            case loginmanager:create_account(U, P) of
              ok -> gen_tcp:send(Socket,<<"ok_create_account\n">>);
              _ -> gen_tcp:send(Socket,<<"user_exists\n">>)
            end;

            _ -> invalid
           end,
           
           user(Sock,Room);

        {tcp_closed, _} ->
            Room ! {leave, self()};
        {tcp_error, _, _} ->
            Room ! {leave, self()}
    end.

    userauthenticated(Sock,Room) ->
    	receive 
    	 {line, Data} ->
            gen_tcp:send(Sock, Data),
            userauthenticated(Sock, Room);
        {tcp, Socket, Data} ->
        	StrData = binary:bin_to_list(Data),
        	case StrData of 

          	"\\logout " ++ Dados ->
            St = string:tokens(Dados, " "),
            [U | P] = St,
            case loginmanager:logout(U, P) of
            	ok -> gen_tcp:send(Socket,<<"ok_logout\n">>),
            		  Room ! {leave,self()}, user(Sock,Room);
            	_ -> userauthenticated(Sock,Room)
            end;

            _ ->
        	Room ! {line, Data,Socket},
        	userauthenticated(Sock, Room)
        end;
        {tcp_closed, _} ->
            Room ! {leave, self()};
        {tcp_error, _, _} ->
            Room ! {leave, self()}
    end.

