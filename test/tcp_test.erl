%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. 十一月 2015 22:30
%%%-------------------------------------------------------------------
-module(tcp_test).
-author("Administrator").

%% API
-export([start_nano_server/0, nano_client_eval/1]).

-export([start_seq_server/0]).

start_nano_server() ->
  {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]),
  {ok, Socket} = gen_tcp:accept(Listen),
  gen_tcp:close(Listen),
  loop(Socket).

start_seq_server() ->
  {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4}, {reuseaddr, true}, {active, true}]),
  seq_loop(Listen).

seq_loop(Listen) ->
  {ok, Socket} = gen_tcp:accept(Listen),
  loop(Socket),
  seq_loop(Listen).

loop(Socket) ->
  receive
    {tcp, Socket, Bin} ->
      Str = binary_to_term(Bin),
      io:format("server received binary = ~p\n", [Str]),
      gen_tcp:send(Socket, term_to_binary("ok, success")),
      loop(Socket);
    {tcp_closed, Socket} ->
      io:format("server closed")
  end.

nano_client_eval(Str) ->
  {ok, Socket} = gen_tcp:connect("localhost", 2345, [binary, {packet, 4}]),
  ok = gen_tcp:send(Socket, term_to_binary(Str)),
  receive
    {tcp, Socket, Bin} ->
      Str_1 = binary_to_term(Bin),
      io:format("Client received binary = ~p\n", [Str_1]),
      gen_tcp:close(Socket)
  end.
