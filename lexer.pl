
machines(
    [(integer,
    [(0, digit, 2),
    (0, '+', 1),
    (0, '-', 1),
    (1, digit, 2),
    (1, digit, 2),
    (2, digit, 2)],
    [2])]
    ).

lexer([], []).
lexer(Text, [(Type, Munch)|Tokens]) :- 
    machines(Machines),
    run_machines(Text, Machines, Length, Type),
    bite_off(Text, Length, Munch, Rest),
    lexer(Rest, Tokens).

run_machines(Text, Machines, Length, Type) :- run_machinesR(Text, Machines, 1, none, Length, Type).
run_machinesR(_, [], Length, Type, Length, Type).
run_machinesR(Text, [M|Ms], Longest, LongestType, Length, Type) :-
    run_machine(Text, M, L, T),
    (
        (
            L >= Longest,
            run_machinesR(Text, Ms, L, T, Length, Type)
        );
        (
            L < Longest,
            run_machinesR(Text, Ms, Longest, LongestType, Length, Type)
        )
    ).

run_machine(Text, (Type, Trans, Accepting), Length, Type) :- run_machineR(Text, (Type, Trans, Accepting), 0, 0, 0, Length, Type).
run_machineR([], (Type,_,_), _, _, Length, Length, Type).
run_machineR([Sym|Rest], M, State, Current, Highest, Length, Type) :-
    transition(M, State, Sym, NextState, Accepting),
    (
        (
            NextState = -1,
            Length = Highest 
        );
        (
            Accepting,
            C2 is Current + 1,
            run_machineR(Rest, M, NextState, C2, C2, Length, Type)
        );
        (
            not(Accepting),
            C2 is Current + 1,
            run_machineR(Rest, M, NextState, C2, Highest, Length, Type)
        )
    ).

transition((_, Transitions, Accepting), State, Symbol, NextState, IsAccepting) :- 
    find_transition(Transitions, State, Symbol, NextState),
    contains(NextState, Accepting, IsAccepting).

find_transition([], _, _, -1).
find_transition([(State, Symbol, NextState)|_], State, Symbol, NextState).
find_transition([(State, any, NextState)|_], State, _, NextState).
find_transition([(State, digit, NextState)|_], State, Symbol, NextState) :- number(Symbol).
find_transition([(State, alpha, NextState)|_], State, Symbol, NextState) :- letter(Symbol).
find_transition([_|Tl], State, Symbol, NextState) :- find_transition(Tl, State, Symbol, NextState).

contains(_, [], false).
contains(X, [X|_], true).
contains(X, [_|Xs], IsAccepting) :- contains(X, Xs, IsAccepting).

bite_off(Text, 0, [], Text).
bite_off([H|T], N, [H|Munch], Rest) :- 
    N2 is N - 1,
    bite_off(T, N2, Munch, Rest).

reverse(List, Rev) :- reverseR(List, [], Rev).
reverseR([], Acc, Acc).
reverseR([H|T], Acc, Rev) :- reverseR(T, [H|Acc], Rev).













