/** FLP 2023 - Projekt 2 (Nedeterministicky Turinguv Stroj) */
/** Autor: Vojtech Fiala <xfiala61> */

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

/** Posledni prvek listu, pro ziskani pasky */
lastElem([X], X).
lastElem([_|T], X) :- lastElem(T, X).

/** Ziskani vsech prvku listu krom posledniho, pro ziskani pouze listu pravidel */
listWithoutLast([_], []).
listWithoutLast([H|T], [H|Res]) :- listWithoutLast(T, Res).

/** Ziskej ze vstupu array pouze s uzitecnymi symboly. Predpoklada validni vstupy */
getSingleRule([State, _, Symb, _, NewState, _, NewSymb], [State,Symb,NewState,NewSymb]).

/** Uprav nactena pravidla do zpracovatelne formy (ignoruj zbytecne mezery) */
editRules([], []).
editRules([H|T], [X|Res]) :- getSingleRule(H, X), editRules(T, Res).

/** Dynamicke pravidlo */
:- dynamic rule/4.

/** Pridani samotneho pravidla */
createRule([State, CurrentSymbol, NewState, NewSymbol]) :- assertz(rule(State, CurrentSymbol, NewState, NewSymbol)).

/** Pridani pravidel, pravidlo se bere jako jeden prvek z 2D listu */
createRules([]).
createRules([H|T]) :- createRule(H), createRules(T).

/** Ziskej prvek na pasce podle indexu */
tapeSymbol(T, I, X) :- nth0(I, T, X).

/** Urceni noveho indexu podle R nebo L */
findIndex(Symbol, Ind, NewInd) :-
    ( Symbol == 'R' ->
        NewInd is Ind + 1
        ;
        ( Symbol == 'L' ->
            NewInd is Ind - 1 
            ;
            NewInd is Ind
        )
    ).

/** Nahrazeni znaku na danem indexu pasky jinym znakem **/
changeTape(_, _, _, [], []). % Prazdna paska - konec
changeTape(_, _, 0, _, []) :-  !. % Cela paska projdena 
changeTape(NewSymbol, Ind, MaxIndex, [H|TapeTail], [H|NewTape]) :- 
    Ind \= 0,
    MaxIndex > 0, 
    NewLength is MaxIndex-1,
    NewIndex is Ind - 1,
    changeTape(NewSymbol, NewIndex, NewLength, TapeTail, NewTape).
changeTape(NewSymbol, Ind, MaxIndex, [_|TapeTail], [NewSymbol|NewTape]) :- 
    Ind == 0,
    MaxIndex > 0, 
    NewIndex is Ind - 1,
    NewLength is MaxIndex-1,
    changeTape(NewSymbol, NewIndex, NewLength, TapeTail, NewTape).

/** Vlozeni daneho stavu do pasky na zadany index */
addState(Ind, NewTape, State, Tape) :- nth0(Ind, NewTape, State, Tape).

/** Prochazeni veskerych stavu, ktere je mozne dosahnout, a s vyuzitim backtrackingu navrat cesty k finalnimu */
goThroughTape(State, Tape, _, _, Ind, [[WriteNewTape]]) :- 
    State == 'F', 
    addState(Ind, NewTape, State, Tape), % Vlozeni na zadany index, Tape je muj vysledek a NewTape je, odkud jsem symbol vzal, jdu odzadu
    atom_string(NewTape, WriteNewTape),
    !.
goThroughTape(State, Tape, PrevTape, PrevPrevTape, Ind, [[WriteNewTape]|Configs]) :- 
    length(Tape, Length),
    tapeSymbol(Tape, Ind, CurrSymbol),

    rule(State, CurrSymbol, NewState, NewSymbol),
    findIndex(NewSymbol, Ind, NewIndex), % Najiti noveho indexu, bud je to R nebo L nebo vracim puvodni

    ( NewIndex >= Length -> % Pridani blanku na konec, prekrocil jsem puvodni pasku
        append(Tape, [' '], NextTape)
        ;
        NextTape = Tape
    ),

    addState(Ind, NewTape, State, Tape),
    atom_string(NewTape, WriteNewTape),

    PrevTape \= WriteNewTape,
    PrevPrevTape \= WriteNewTape, % Pojistka proti zaseknuti behem zanorovani

    ( NewSymbol \= 'R' -> 
            ( NewSymbol \= 'L' -> 
                changeTape(NewSymbol, NewIndex, Length, NextTape, EditedTape), % Nahrazeni znaku na pasce (pokud to neni L nebo R) na danem indexu
                goThroughTape(NewState, EditedTape, WriteNewTape, PrevTape, NewIndex, Configs)
                ; 
                goThroughTape(NewState, NextTape, WriteNewTape, PrevTape, NewIndex, Configs)
            ) 
        ; 
        goThroughTape(NewState, NextTape, WriteNewTape, PrevTape, NewIndex, Configs)
    ).

/** Vypis vsech ziskanych stavu TS, ktere jsou ve forme 2D pole */
readResults([]).
readResults([[H]|T]) :-
    write(H),
    nl,
    readResults(T).

/** Rizeni programu */
start :-
    /** Cteni vstupu */
    prompt(_, ''),
    read_lines(LL),
    /*****************/

    !, % pokud dostanu abnormalni zastaveni, prolog backtrackingem dojde zpet sem - nezacne cist znovu, skonci

    /** Tvorba Pravidel */
    listWithoutLast(LL, InputRules),
    editRules(InputRules, Rules),
    createRules(Rules),
    /********************/

    /** Beh TS */
    lastElem(LL, Tape), % Posledni na vstupu je paska
    goThroughTape('S', Tape, Tape, Tape, 0, Configs), % 0 reprezentuje prvni znak na pasce, kterym zpracovavani zacina. S je prvni stav.
    /***********/

    /* Vypis konfiguraci pasky */
    readResults(Configs),
    /***************************/
    halt.
