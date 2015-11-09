-module(tcp_server_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CLIENT_SUP, tcp_client_sup).

%% ===================================================================
%% API functions
%% ===================================================================

start_child(Socket) ->
  ChildSpec = {{tcp_client_handler}, {tcp_client_handler, start_link, [Socket]},
    transient, infinity, worker, [esockd_listener_sup]},
    supervisor:start_child(?CLIENT_SUP, [ChildSpec]).

start_link() ->
  {ok, Sup} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
  supervisor:start_child(Sup,
    {?CLIENT_SUP,
      {?CLIENT_SUP, start_link, []},
      permanent, infinity, supervisor, [?CLIENT_SUP]}).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    Child = [{tcp_server_accept, {tcp_server_accept, start_link, []}, permanent, brutal_kill, worker, [tcp_server_accept]}],
    {ok, { {one_for_one, 5, 10}, Child} }.

