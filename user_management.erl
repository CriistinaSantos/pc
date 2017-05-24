-module(user_management).
-export([start/0, create_account/2, login/2, logout/2, online/0]).
%start com 0 parametros, create_account com 2 parametros

start() ->
	Pid = spawn(fun() -> loop(#{}) end),
	register(?MODULE, Pid).
	%map começa vazio no ciclo

create_account(Username,Passwd) -> 
	?MODULE ! {create_account, Username, Passwd, self()},
	receive {?MODULE, Res } -> Res end.

	%com nomes registados, envio uma mensagem ao processo que está registado com o nome user_management.
	% envio a operação a realizar, o meu username, passwd e o pid para receber a resposta de verificação vinda do user_management
	% fico a espera de uma resposta que tenha o nome do module e a resposta propriamente dita que vou retornar.
login(Username,Passwd) -> 
	?MODULE ! {login, Username, Passwd, self()},
	receive {?MODULE, Res } -> Res end.

logout(Username,Passwd) -> 
	?MODULE ! {logout, Username, Passwd, self()},
	receive {?MODULE, Res } -> Res end.

online() -> 
	?MODULE ! {online, self()},
	receive {?MODULE, Res } -> Res end.

loop(M) ->
	receive %está bloqueada (receive) a espera de um pedido de criar conta, ou bloquear, etc. é necessário saber distinguir
		{create_account, Username, Passwd, From} ->
			case maps:find(Username,M) of  %find recebe key,Map e devolve ok,Value ou Error. Vê se o username já está presente
				{ok, _} ->
					From ! {?MODULE, user_exists}, %mensagem que o cliente está a espera "user_exists no Res"
					loop(M);
				error ->
					From ! {?MODULE, ok},
					M1 = maps:put(Username,{Passwd,true},M),
					loop(M1)
			end;  %map com o novo valor (M1), e bloqueia novamente no receive
		{close_account, Username, Passwd, From} ->
			case maps:find(Username,M) of
				{ok, {Passwd, _}} -> %caso a chave esteja no map dá ok, e só faz match se o tuplo que for retornado pelo find tiver o valor que vem na mensagem (Password)
					From ! {?MODULE, ok},
					M1 = maps:remove(Username,M),
					loop(M1);
				_ -> %_ ou error
					From ! {?MODULE, invalid},
					loop(M)
				end;
		{login, Username, Passwd, From} ->
			case maps:find(Username,M) of
				{ok, {Passwd, _}} -> % o _ poderia ser True ou False
					From ! {?MODULE, ok},
					M1 = maps:update(Username, {Passwd,true}, M),
					loop(M1);
				_ ->
					From ! {?MODULE, invalid},
					loop(M)
				end;
		{logout, Username, Passwd, From} ->
			case maps:find(Username,M) of
				{ok, {Passwd, true}} ->
					From ! {?MODULE, ok},
					M1 = maps:update(Username, {Passwd,false}, M),
					loop(M1)
				end;
		{online, From} ->
		 	Online = [Username || {Username, {_,true}} <- maps:to_list(M)],  %lista de compreensao só faz match só se os pares correspondentes ao Username, tenham password true. Não se quer saber qual a Passwd
		 	From ! {?MODULE, Online},
		 	loop(M)
	end.
	