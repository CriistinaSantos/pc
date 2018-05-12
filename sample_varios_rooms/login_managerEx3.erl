-module(login_managerEx3).
-export([start/0, create_account/2, close_account/2, login/2, logout/1, online/0, loginmanager/1]).

%1. Escreva um módulo que implemente um gestor de logins que permita a criação de contas bem
%como controlar o login/logout de utilizadores: Deverão ser disponibilizadas nomeadamente as
%funções:


%create_account(Username, Passwd) -> ok | user_exists
%close_account(Username, Passwd) -> ok | invalid
%login(Username, Passwd) -> ok | invalid
%logout(Username) -> ok
%online() -> [Username]

%find, get, remove, put, (update)


start() ->
	Pid = spawn(fun() -> loginmanager(#{}) end),
	register(?MODULE, Pid).


loginmanager(M) ->
	receive
		{Username, Passwd, create, Pid} ->
			case maps:find(Username, M) of
				error ->
					M2 = maps:put(Username, {Passwd, 0, Pid}, M),
					Pid ! {?MODULE, ok},
					loginmanager(M2);
				_ -> 
					Pid ! {?MODULE, invalid},
					loginmanager(M)
			end;

		% Colocar password
		{Username, Passwd, close, Pid} ->
			case maps:find(Username, M) of
				{ok, {Passwd, _, _}} ->
					M2 = maps:remove(Username, M),
					Pid ! {?MODULE, ok},
					loginmanager(M2);
				_ ->
					Pid ! {?MODULE, invalid},
					loginmanager(M)
			end;

		{Username, Passwd, login, Pid} ->
			case maps:find(Username, M) of
				{ok, {Passwd, 0, _}} ->
					M2 = maps:update(Username, {Passwd, 1, Pid}, M),
					Pid ! {?MODULE, ok},
					loginmanager(M2);
				_ ->
					Pid ! {?MODULE, invalid},
					loginmanager(M)
			end;

		{Username, logout, Pid} ->
			case maps:find(Username, M) of
				{ok, {Passwd, 1, Pid}} ->
					M2 = maps:update(Username, {Passwd, 0, Pid}, M),
					Pid ! {?MODULE, ok},
					loginmanager(M2);
				_ ->
					Pid ! {?MODULE, invalid}, %optional
					loginmanager(M)
			end;

		{online, Pid} ->
			Pid ! {?MODULE,[Username|| {Username,{_,1,_}} <- maps:to_list(M)]},
			loginmanager(M)
	end.
	



close_account(Username, Passwd) ->
	?MODULE ! {Username, Passwd, close, self()},
	receive {?MODULE, Msg} -> Msg end.


create_account(Username, Passwd) ->
	?MODULE ! {Username, Passwd, create, self()},
	receive {?MODULE, Msg} -> Msg end.

login(Username, Passwd) ->
	?MODULE ! {Username, Passwd, login, self()},
	receive {?MODULE, Msg} -> Msg end.

logout(Username) ->
	?MODULE ! {Username, logout, self()},
	receive {?MODULE, Msg} -> Msg end.

online() ->
	?MODULE ! {online, self()},
	receive {?MODULE, Msg} -> Msg end.