-module(eventsource_emitter).
-behaviour(cowboy_loop_handler).

-export([init/3]).
-export([info/3]).
-export([terminate/3]).

-record(state, {messages}).

init({_Any, http}, Req, Messages) ->
    % Prepare event-stream HTTP headers
    Headers = [
        {<<"content-type">>, <<"text/event-stream">>},
        {<<"cache-control">>, <<"no-cache">>},
        {<<"connection">>, <<"keep-alive">>}
    ],

    % Start a chunked reply
    {ok, Req2} = cowboy_req:chunked_reply(200, Headers, Req),

    % Send initial chunk
    ok = cowboy_req:chunk([":ok", "\n\n"], Req2),

    % Handover the response to loop
    {loop, Req2, #state{messages=Messages}}.

info({message, Msg}, Req, State) ->
    % Forward any Erlang messages as a chunk in the request
    ok = cowboy_req:chunk(Msg, Req),
    {loop, Req, State}.

terminate(_Reason, _Req, _State) ->
    ok.
