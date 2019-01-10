-module(after_timeout).

-concuerror_options([{after_timeout, 1000},
                     {treat_as_normal, killed}]).

-export([scenarios/0]).

-export(['receive'/0,
         timer/0,
         send_after/0]).

scenarios() ->
  [{N,inf,dpor} || N <- ['receive', timer, send_after]].

'receive'() ->
  test(fun (Time, Pid, Msg) ->
           spawn(fun () ->
                     receive after Time -> ok end,
                     Pid ! Msg
                 end)
       end,
       fun (Pid) -> exit(Pid, kill) end).

timer() ->
  test(fun erlang:start_timer/3, fun erlang:cancel_timer/1).

send_after() ->
  test(fun erlang:send_after/3, fun erlang:cancel_timer/1).

test(StartFun, CancelFun) ->
  Timer = StartFun(1000, self(), foo),
  CancelFun(Timer),
  receive
    foo -> exit(after_timeout_has_no_effect)
  after
    0 -> ok
  end.
