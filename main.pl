/** FLP 2020
Toto je ukazkovy soubor zpracovani vstupu v prologu.
Tento soubor muzete v projektu libovolne pouzit.

autor: Martin Hyrs, ihyrs@fit.vutbr.cz
preklad: swipl -q -g start -o flp19-log -c input2.pl
*/


/** cte radky ze standardniho vstupu, konci na LF nebo EOF */
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).


/** testuje znak na EOF nebo LF */
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).


/** Odstran zbytecne mezery (hlavne v pravidlech) */
removeSpaces([], []).
removeSpaces([' '|Tail], Res) :- removeSpaces(Tail, Res).
removeSpaces([H|Tail], [H|Res]) :- removeSpaces(Tail, Res).

/** Posledni prvek listu, pro ziskani pasky */
getLast([X], X).
getLast([_|T], X) :- getLast(T, X).

/** Ziskani vsech prvku listu krom posledniho, pro ziskani pouze listu pravidel */
listWithoutLast([_], []).
listWithoutLast([H|T], [H|Res]) :- listWithoutLast(T, Res).

/** Funkce na pridani "dimenze" seznamu -> [a] -> [[a]] */
addDimension(X, [X]).

/** Funkce na projiti seznamu a vraceni jeho upravene verze*/
goThroughListRemoveSpaces([], []).
goThroughListRemoveSpaces([H|T], Res) :- call(removeSpaces, H, NoSpace), goThroughListRemoveSpaces(T, X), addDimension(NoSpace, Y), append(Y, X, Res).

/** Dynamicke pravidlo */
dynamic rule(State, CurrentSymbol, NewState, NewSymbol)/4.

/** Funkce na pridani samotneho pravidla */
createRule([State, CurrentSymbol, NewState, NewSymbol]) :- assertz(rule(State, CurrentSymbol, NewState, NewSymbol)).

/** Funkce na pridani pravidel, pravidlo se bere jako jeden prvek z 2D listu */
createRules([]) :- !.
createRules([H|T]) :- createRule(H), createRules(T).

/** Ukradene z internetu https://swi-prolog.discourse.group/t/split-list/4836/10, nepouzivam, jenom pro inspiraci, ten LstSPlit jak funguje odzadu je interesting
split_list_into_lens([], _, []).
split_list_into_lens([H|T], Len, [LstSplit|Lsts]) :-
    length(LstSplit, Len),
    append(LstSplit, LstRemainder, [H|T]),
    split_list_into_lens(LstRemainder, Len, Lsts).
*/

/** Ziskej prvek na pasce podle indexu */
tapeState(T, I, X) :- nth0(I, T, X).

/** Funkce, ktera prochazi pasku znak po znaku a na zaklade aktualniho znaku na zaklade pravidel hleda vystup 
Spoleham na Prolog, ze bude prochazett a backtrackovat*/

goThroughTape(_, Tape, Ind) :- length(Tape, Length), Ind >= Length, !. % Jen docasne, vetsi ez toto znamena ze prida mezeru, realny konec je jen s F stavem.. i kdy co kdyz to da False at pomuzu prologu?
goThroughTape(State, _, _) :- Symbol == "F", !.
goThroughTape(State, Tape, Ind) :- 
    length(Tape, Length),
    Ind < Length,
    tapeState(Tape, Ind, CurrSymbol),
    nth0(Ind, NewTape, State, Tape), % Vlozeni na zadany index, Tape je muj vysledek a NewTape je, odkud jsem symbol vzal, jdu odzadu
    atomics_to_string(NewTape, WriteNewTape),
    write(WriteNewTape),
    nl,

    rule(State, CurrSymbol, NewState, NewSymbol),
    findIndex(NewSymbol, Ind, NewIndex), % Najiti noveho indexu, bud je to R nebo L nebo vracim puvodni
    changeTape(NewSymbol, Ind, Tape, NewTape), % Nahrazeni znaku na pasce (pokud to neni L nebo R) na danem indexu


    goThroughTape(NewState, NewTape, NewIndex).

/** Tady mit nejaky citac, ktery zacina na 0 a pokud mam L, jde -1, pokud R, +1.  
Ziskam si stav na jaky dojdu, to bude muj novy stav a taky si najdu symbol, ktery je novy, podle toho se zachovam (posunu index, nahradim...)*/

start :-
    /** Cteni vstupu */
	prompt(_, ''),
	read_lines(LL),
    /*****************/

    /** Tvorba Pravidel */
    listWithoutLast(LL, InputRules),
    goThroughListRemoveSpaces(InputRules, Rules),
    createRules(Rules),
    /********************/

    /** Beh TS */
    getLast(LL, Tape),

    % zavolani funkce co dostane vstup a bude volat pravidla podle vstupu a aktualniho stavu (prvni je S)
    goThroughTape("S", Tape, 0), % 0 reprezentuje prvni znak na pasce, kterym zpracovavani zacina

    %write(LL),
	%write(Rules),
	halt.
