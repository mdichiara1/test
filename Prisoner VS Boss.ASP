%Prisoner VS Boss
%Developed by Michael Dichiara
% Started: 07/31/2020 Completed: August 5, 2020



%Module
%The module below describes a scenario where there is a prisoner stuck in a cell
%and the prisoner has to get out the cell and travel through the building to find
%and fight the boss in order to become free. The prisoner can find items throughout
%the building such as keys, a sword, and a shield. The items are located in specific
%rooms and if the prisoner is located in that room he can pickup the item and is 
%now holding that item. The prisoner can hold multiple items at once. The keys are
%used for to unlock locked rooms. The sword and shield are used to fight and kill
%the boss. If the prisoner tries to figt the boss it means certain death. When
%the prisoner kills the boss he is declared free.




%objects
room(roomOne).
room(roomTwo).
room(roomThree).
room(roomFour).
room(cell).
room(mainRoom).
room(bossRoom).
key(bossKey).
key(mainKey).
weapon(sword).
defensive_weapon(shield).
prisoner(pippin).
boss(demon).




%definitions
connected(cell, mainRoom).
connected(mainRoom, roomOne).
connected(mainRoom, roomTwo).
connected(mainRoom, roomThree).
connected(mainRoom, roomFour).
connected(roomOne, bossRoom).
connected(X, Y):- connected(Y, X).
match(mainRoom, mainKey).
match(bossRoom, bossKey).
at(mainKey, cell).
at(bossKey, roomFour).
at(sword, roomThree).
at(shield, roomTwo).


%actions
action(unlock(R)):- room(R).
action(move(X,Y)):- connected(X,Y), room(X), room(Y), X!=Y.
action(pickup(K)):- key(K).
action(pickup(X)):- weapon(X).
action(pickup(Y)):- defensive_weapon(Y).
action(fight).

%fluents
fluent(located(R)):- room(R).
fluent(locked(R)):- room(R).
fluent(holding(K)):- key(K).
fluent(holding(X)):- weapon(X).
fluent(holding(Y)):- defensive_weapon(Y).
fluent(alive(X)):- prisoner(X).
fluent(alive(B)):- boss(B).
fluent(dead(X)):- prisoner(X).
fluent(dead(B)):- boss(B).
fluent(free(X)):- prisoner(X).





%Dynamic Casual Laws
%unlock causes room to be locked if not holding key, room has a key, and located in the previous room
holds(locked(R), T+1):- occurs(unlock(R), T), -holds(holding(K), T), match(R,K), holds(located(X), T), connected(X,R), time(T).


%unlock causes the room to be not locked if holding key, room and key match, and located in the previous room
-holds(locked(R), T+1):- occurs(unlock(R), T), holds(holding(K), T), match(R,K), holds(located(X), T), connected(X,R), time(T).

%move causes to be located in the next room if currently located room is connected to the next room, and is not locked.
holds(located(R), T+1):- occurs(move(S,R), T), room(S), room(R), connected(S,R), holds(located(S), T), -holds(locked(R), T), time(T), S!=R.

%move causes to located in the previous room if located in at deadend that is connected to the previous room.
holds(located(mainRoom), T+1):- occurs(move(X,mainRoom), T), holds(located(X), T), connected(X, mainRoom), -holds(locked(mainRoom), T), room(mainRoom), room(X), time(T), X!=mainRoom.

%pickup key, sword, or shield causes holding key, sword, or shield if at the room the item is located in 
holds(holding(K), T+1):- occurs(pickup(K), T), holds(located(R), T), at(K, R), time(T).

%fight causes boss to be dead if located in the bossroom, holding sword, and holding key
holds(dead(X), T+1):- occurs(fight, T), holds(located(bossRoom), T), holds(holding(sword),T), holds(holding(shield), T), time(T), boss(X).

%fight causes priosner to be  dead if located in the bossroom, not holding sword, and holding key
holds(dead(X), T+1):- occurs(fight, T), holds(located(bossRoom), T), -holds(holding(sword),T), holds(holding(shield), T), time(T), prisoner(X).

%fight causes priosner to be dead if located in the bossroom, holding sword, and not holding key
holds(dead(X), T+1):- occurs(fight, T), holds(located(bossRoom), T), holds(holding(sword),T), -holds(holding(shield), T), time(T), prisoner(X).

%fight causes prisoner to be dead if located in the bossroom, not holding sword, and not holding key
holds(dead(X), T+1):- occurs(fight, T), holds(located(bossRoom), T), -holds(holding(sword),T), -holds(holding(shield), T), time(T), prisoner(X).

%State Constraints:

%Cannot be located in the two or more rooms at the same time.
-holds(located(R), T):-  holds(located(X), T), X!=R, time(T), room(X), room(R).
%not alive if boss or prisoner is dead
-holds(alive(X), T):- holds(dead(X), T), time(T). 
%if boss is dead the prisoner is free
holds(free(X), T):- prisoner(X), holds(dead(Y), T), boss(Y), time(T).

% Inertia Axioms
holds(F,T+1) :- fluent(F), time(T), holds(F,T), not -holds(F,T+1).
-holds(F,T+1) :- fluent(F), time(T), -holds(F,T), not holds(F,T+1).


%Goal
goal :- goal(T), time(T).
:- not goal.
1{occurs(A,T):action(A)}1 :- not goal(T), time(T).
#show occurs/2.
#show holds/2.
%#show -holds/2.
%occurs(pickup(mainKey),0).
%occurs(unlock(mainRoom), 1).
%occurs(move(cell, mainRoom), 2).
%occurs(move(mainRoom, roomTwo), 3).
%occurs(pickup(shield), 4).
%occurs(move(roomTwo, mainRoom), 5).
%occurs(move(mainRoom, roomThree), 6).
%occurs(pickup(sword), 7).
%occurs(move(roomThree, mainRoom), 8).
%occurs(move(mainRoom, roomFour), 9).
%occurs(pickup(bossKey), 10).
%occurs(move(roomFour, mainRoom), 11).
%occurs(move(mainRoom, roomOne), 12).
%occurs(unlock(bossRoom),13).
%occurs(move(roomOne, bossRoom), 14).
%occurs(fight, 15).

%Initial
holds(located(cell), 0).
holds(locked(mainRoom), 0).
holds(locked(bossRoom), 0).
-holds(locked(R), 0):- not holds(locked(R), 0), room(R).
-holds(holding(K), 0):- not holds(holding(K), 0), key(K).
-holds(holding(K), 0):- not holds(holding(K), 0), weapon(K).
-holds(holding(K), 0):- not holds(holding(K), 0), defensive_weapon(K).
holds(alive(X), 0):- not -holds(alive(X), 0), prisoner(X).
-holds(dead(X), 0):- not holds(dead(X), 0), prisoner(X).
holds(alive(X), 0):- not -holds(alive(X), 0), boss(X).
-holds(dead(X), 0):- not holds(dead(X), 0), boss(X).
-holds(free(X), 0):- not holds(free(X), 0), prisoner(X).

goal(T):- holds(free(pippin), T), time(T).

time(0..16).