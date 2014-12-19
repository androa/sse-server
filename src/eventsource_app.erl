-module(eventsource_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Messages = ets:new(message_queue, []),
    Dispatch = cowboy_router:compile([
        {'_', [
            %{"/broadcast", broadcast_handler, Messages},
            {"/sse", eventsource_emitter, Messages},
            {"/connections", connections_handler, []}
        ]}
    ]),
    cowboy:start_http(sse_handler, 100, [
            {port, 1942},
            {max_connections, infinity}
        ],
        [{env, [{dispatch, Dispatch}]}]
    ),
    timer:apply_interval(1000, erlang, apply, [ fun sendMessage/2, [Messages, self()] ]),
    eventsource_sup:start_link().

stop(_State) ->
    ok.

sendMessage(Messages, Pid) ->
    ets:insert(Messages, {Pid, "bar"}).

%bcast(Pids, Message) ->
%    [P ! {bcast, Message} || P <- Pids],
%    ok.
