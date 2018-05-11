-module(state).
-export([start/0]).
-import(avatar,[generateAvatar/0]).

start() ->
	Pid = spawn(fun() -> state(#{},[]) end),
	register(?MODULE,Pid).

%funcao que recebe socket do user que acabou de fazer login e map dos Online e envia mensagem
statelogin(Online,Socket) ->
  case maps:to_list(Online) of
    [] -> fail;
    L ->
  			[gen_tcp:send(Socket,list_to_binary("online " ++ Username ++ " 0 " ++ integer_to_list(Speed) ++ " " ++ float_to_list(Dir)
			++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(H)
			++ " " ++ integer_to_list(W) ++ "\n"))
            || {Username,{Speed, Dir, X, Y, H, W}} <- L]    
  end.
%Online #{Username => Avatar = ({Speed,Dir,X,Y,H,W})}
state(Online,Socket) ->
	receive
		{online, add, Username} ->
			{Speed, Dir, X, Y, H, W} = generateAvatar(),
			%0 é o score
			Data = "online " ++ Username ++  " 0 " ++ integer_to_list(Speed) ++ " " ++ float_to_list(Dir)
			++ " " ++ float_to_list(X) ++ " " ++ float_to_list(Y) ++ " " ++ integer_to_list(H)
			++ " " ++ integer_to_list(W) ++ "\n",
			[gen_tcp:send(Sock,list_to_binary(Data)) || Sock <- Socket],
			NewOnline = maps:put(Username, {Speed, Dir, X, Y, H, W},Online),
			state(NewOnline,Socket);
		
		{time,Sock,Username} ->
			{_,Seconds,_} = os:timestamp(),
			% Associar depois os segundos com a pontuação
			statelogin(Online,Sock),
			state(Online,[Sock | Socket]);

		{left,Username} ->
			case maps:is_key(Username,Online) of
				false -> state(Online,Socket);
				true ->
					{Speed, Dir, X, Y, H, W} = maps:get(Username,Online),
					O = maps:update(Username,{Speed, Dir-10, X, Y, H, W},Online),
					Data = "on_update_left " ++ Username ++ " " ++ float_to_list(Dir-10) ++ " " ++ "\n",
					[gen_tcp:send(Sock,list_to_binary(Data)) || Sock <- Socket],
					state(O,Socket)
			end;

		{right,Username} ->
			case maps:is_key(Username,Online) of
				false -> state(Online,Socket);
				true ->
					{Speed, Dir, X, Y, H, W} = maps:get(Username,Online),
					O = maps:update(Username,{Speed, Dir+10, X, Y, H, W},Online),
					Data = "on_update_right " ++ Username ++ " " ++ float_to_list(Dir+10) ++ " " ++ "\n",
					[gen_tcp:send(Sock,list_to_binary(Data)) || Sock <- Socket],
					state(O,Socket)
			end

			%colocar front aqui 
		end.
				
