%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2023. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%
%% %CopyrightEnd%
%%
-module(core_scan_SUITE).

-export([all/0, suite/0,groups/0,init_per_suite/1, end_per_suite/1,
	 init_per_group/2,end_per_group/2,
	 heredoc/1]).

suite() -> [{ct_hooks,[ts_install_cth]}].

all() ->
    [heredoc].

groups() ->
    [].

init_per_suite(Config) ->
    test_lib:recompile(?MODULE),
    Config.

end_per_suite(_Config) ->
    ok.

init_per_group(_GroupName, Config) ->
    Config.

end_per_group(_GroupName, Config) ->
    Config.

heredoc(Config) when is_list(Config) ->
    {ok,[{string,1,""}],2} =
        core_scan:string("\"\"\"\n"
                        "\"\"\""),

    {ok,[{string,1,"this is a\nvery long\nstring\n"}],5} =
        core_scan:string("\"\"\"\n"
                        "this is a\n"
                        "very long\n"
                        "string\n"
                        "\"\"\""),

    {ok,[{string,1,"  this is a\n    very long\n  string\n"}],5} =
        core_scan:string("\"\"\"\n"
                         "  this is a\n"
                         "    very long\n"
                         "  string\n"
                         "\"\"\""),

    %% NOTE: Shouldn't end in pos 5 instead of 2?
    %%       This result comes from line 94:
    %%       {ok,Toks} -> {ok,Toks,Ep};
    %%       Shouldn't it be the below?
    %%       {ok,Toks,Pos} -> {ok,Toks,Pos};
    %%       erl_scan result is 5!
    {ok,[{string,1,"this is a very long string"}],2} =
        core_scan:string("\"\"\"\n"
                         "this is a \\\n"
                         "very long \\\n"
                         "string\\\n"
                         "\"\"\""),

    {ok,[{string,1,"this is a \\\nvery long \\\nstring\\\n"}],5} =
        core_scan:string("\"\"\"\n"
                         "this is a \\\\\n"
                         "very long \\\\\n"
                         "string\\\\\n"
                         "\"\"\""),

    {ok,[{string,1,"this contains \"quotes\"\n"
                   "and \"\"\"triple quotes\"\"\" and\n"
                   "ends here\n"}],5} =
        core_scan:string("\"\"\"\n"
                         "this contains \"quotes\"\n"
                         "and \"\"\"triple quotes\"\"\" and\n"
                         "ends here\n"
                         "\"\"\""),

    {ok,[{string,1,"```erlang\n"
                   "foo() ->\n"
                   "    \"\"\"\n"
                   "    foo\n"
                   "    bar\n"
                   "    \"\"\".\n"
                   "```\n"}],9} =
        core_scan:string("\"\"\"\"\n"
                         "```erlang\n"
                         "foo() ->\n"
                         "    \"\"\"\n"
                         "    foo\n"
                         "    bar\n"
                         "    \"\"\".\n"
                         "```\n"
                         "\"\"\"\""),

    {error,{1,core_scan,{heredoc,syntax}},2} =
        core_scan:string("\"\"\"foo\n"
                         "\"\"\""),

    {error,{1,core_scan,{heredoc,outdented}},3} =
        core_scan:string("\"\"\"\n"
                         "foo\n"
                         "  \"\"\""),

    {error,{1,core_scan,{heredoc,eof}},2} =
        core_scan:string("\"\"\"\n"
                         "foo\""),

    ok.
