-module(sf_transform).

%% API exports
-export([parse_transform/2]).

%%====================================================================
%% API functions
%%====================================================================
parse_transform(AST, Options) ->
    PrefixFilename = proplists:get_value(sf_prefix, Options, cwd),
    NthTail = proplists:get_value(sf_nth_tail, Options, 0),
    Module = lists:concat([parse_trans:get_module(AST), ".erl"]),
    lists:map(
        fun({attribute, Line, file, {Filename, _Line}} = Form) ->
            case {filename:pathtype(Filename), filename:basename(Filename)} of
                {absolute, Module} ->
                    NewFilename = rename_filename(PrefixFilename, Filename, NthTail),
                    {attribute, Line, file, {NewFilename, Line}};
                _ -> Form
            end;
            (Form) -> Form
        end, AST).

%%====================================================================
%% Internal functions
%%====================================================================
rename_filename(cwd, Filename, NthTail) ->
    {ok, Cwd} = file:get_cwd(),
    rename_filename(Cwd, Filename, NthTail);
rename_filename(PrefixFilename, Filename, NthTail) ->
    List = filename:split(Filename) -- filename:split(PrefixFilename),
    filename:join(lists:nthtail(NthTail, List)).
