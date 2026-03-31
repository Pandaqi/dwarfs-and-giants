# Dwarfs & Giants (Devlog)

Welcome to the devlog (or "developer's diary") for my educational puzzle game [Dwarfs & Giants](@TODO: Link). It's one of the smallest and simplest, which is why I originally did not keep a devlog, but it ended up with some interesting insights anyway that I wanted to share. This article will briefly explain the game, the problems I faced, and how I solved them. I'll try to keep the language simple and not technical, but it _is_ a puzzle game that relies on some programming tricks that I need to explain!

## What's the idea?

I wanted to make a puzzle game for the topic of _Comparing_. Puzzle games for colors and shapes were somewhat easy to figure out, but what to do for comparing? How to make a game that's an actual interesting puzzle, but which does not require being able to read, or count, or anything else I can't expect from very young kids?

I let the idea rest for a few days, until my brain found an answer: a puzzle game about **size**.

* The map shows a bunch of dwarfs and giants.
* You always have to tap the **smallest**. (Which plays a happy sound and makes the character disappear.)
* Until you've cleared the whole field!
* (When two are the same size, you simply get to choose which one you tap first.)

It seemed simple enough. Of course, at the easiest difficulty, this is not so much a puzzle and more of an ... exercise. Testing if you're able to tap characters in order from smallest to largest.

But that's fine! That's the whole point of the easiest/introduction difficulty. That's what makes it an _educational_ puzzle game: we don't just check if you can solve hard puzzles, we also gradually teach and explore the skills needed for it.

I always try to keep that easiest difficulty level as simple as this, but try to find nice rule tweaks to make the puzzle harder. And, well, more _puzzly_. If I _can't_ find simple ways to expand or upgrade the puzzle to keep it interesting for all ages (and for longer than a minute), then I discard the idea.

How could I advance this idea?

* If you press a **dwarf**, all characters around it get **smaller**.
* If you press a **giant**, all characters around it get **bigger**.
* There is a clear minimum and maximum size. Going over it "kills" the character (in a cartoony way) and makes you lose.

My intuition told me this was enough to get actual puzzles. Now it actually mattered which one you tapped first, if you had multiple options, because one might lead to making a giant too big or a dwarf too small.

But that's also where the issues started ...

## Sizeable Issues

There was one extra rule I always wanted to add: 

> **If multiple characters are the same size, DWARFS come before GIANTS.**

This rule is great for educational purposes. It teaches sorting within sorting, in a very simple way. It also wasn't hard to implement.

But it made puzzles "obvious". 

* The chance of two things being the same size was already quite low. (I just assign random sizes at the start of puzzle generation; more on that later.)
* But when it happened, and you had to make a smart choice, that rule I just mentioned ruined the occasion again! Because if a DWARF and GIANT are the same size, well, the rules literally say you must tap the dwarf first. You don't have any choice. It's not a _puzzle_.

I implemented some tweaks to soften the issue.

* During generation, I _prefer_ placing multiple of the same type and size at once. (So if I place a dwarf of size 2, then with some high probability place _another_ dwarf of size 2 somewhere else. Now the player has a _choice_ on that turn for which one to press.)
* On higher difficulties, this rule is turned off.

The issue remained, however. It remained and remained until I decided to ... get rid of this rule. It was working against everything else in the puzzle!

I even went some steps further on the highest difficulties, because they were too similar now to the easy levels.

* On higher difficulties, you can tap _in any order_. (This still teaches size and comparing, but in a more advanced way for which the player is now ready.) You must find precisely the right order such that no dwarf/giant gets too big/small.
* On higher difficulties, neighbors include _diagonals_. (So when you tap a dwarf, all characters in the 8 cells around it shrink one step.)

This made the HARD and HARDEST difficulties pretty strong puzzles that will interest older ages and those who have no trouble comparing size (anymore).

I took a break, had dinner, distracted myself with finding audio effects for the game, and when I returned to coding my mind had found the last piece of the puzzle.

You see, so far I'd set a pretty random number of "size steps". I had 6 steps (from 0--5). Anything below 0 was too small, anything above 5 was too large. But this number inherently made puzzles much easier. It's pretty hard to become too big if you might have _six growth steps to go_.

I reduced the number to 4 steps (0--3). This made the visuals much clearer too---easier to see what is smaller or larger---and made puzzles more "tight". Anything but the right solution would be a fail.

## The Squash Algorithm

Now let's get a bit technical. _How_ do we generate an endless supply of these puzzles? With any number of rules/settings turned on or off? 

For this one I invented the "squash algorithm"! My initial implementation had some serious (but subtle) flaws that will take me a long while to explain, so I won't. Instead, I'll explain the simplified and much better version that runs the game.

The major steps are as follows.

* Create an empty grid.
* Assign random cells a **size** (`0--3`) and a **character** (dwarf/giant).
* Now take **a random valid move**! (_Example: find the smallest character currently on the field, pretend we clicked that._)
* Once done, every character has a range of sizes that it has been during the puzzle. 
  * Some might be `-1`, too small. Some might be `4` or higher. 
  * We **squash** these sizes so they're all within the right range (`0--3`).
  * Which basically means we "pretend" the character was always this other size that makes the puzzle solution work. The size _after_ squashing is the final puzzle, the thing we present to players to solve.

The "solution" to this puzzle is simply that list of random moves we took while generating. It can happen that squashing is impossible, in which case we just throw away the puzzle and try again. It usually finds a puzzle with the first or second attempt

Okay, what does squashing mean? How does it work? 

Let's say that, during generation, a giant has been size `5` at some point. If we leave it like that, then the puzzle would be incorrect. The giant should have died when it became that large! So we need to change the giant's size such that it's maximum is actually `3`. In this case, that means pushing their initial size down by `2`.

Similarly, some character might end up with minimum size `-1`. To correct for that, we push their initial size up by `1`. (So that, at its worst/smallest, that character is now size 0 and does not die.)

That's what I mean by "squashing" extreme values back into the range we like. 

There is just one final problem: the _order_ matters a lot in this puzzle. You must tap smallest to largest. What used to be the "smallest element currently" should _still_ be the smallest element, otherwise we ruined the puzzle.

That's why that old rule of mine (_dwarfs before giants, always_) was discarded. Squashing might push some dwarfs into a lower size range, and suddenly the move that the generator took was not even a valid one anymore. But _without_ that rule, it does not matter. All giants above size `3` are all pushed down to `3` ... which means the player just needs to be smart and tap them in the right order.

{{% remark %}}
Later I also realized that on the hardest difficulty I did NOT even have to consider this. When you're allowed to tap them in ANY order, I am allowed to squash the starting size to _anything_ that still fits within my bounds. So, instead of pushing `5` down to `3` (always), I could push it down to `2` or `1`. This simple change really improved the complexity and diversity of those hardest puzzles. Without changing any rules or doing anything complicated, those hardest puzzles are also a nice challenge for _me_.
{{% /remark %}}

## Improvements to the Framework

Whenever I make the next puzzle game, I also try to make 1 to 3 improvements to my "puzzle framework". That is, the general bit of code that I can drop into any game to immediately get things like "do/undo", "restart level", "win/loss sound effects", etcetera. Having a strong and clean framework makes it _much_ easier, faster, and more pleasant to make every next puzzle game. Because, well, 90% of it---or at least the boring, repetitive parts---is already handled by that framework.

Anyway, this game made me add some pretty crucial improvements.

* A **hint button**. It shows you the next move. 
* An **undo** even after failing the level. (It "re-opens" the puzzle for you to try again from that fail state.)
* An easy way to customize the **fonts** used in the project. (This game has a clear fantasy theme, so I wanted to set matching fonts for it.)
* A few useful shaders and sprites, such as **shadows** and **outlines**, which you need in almost any project anyway.
* Randomized **background music**. (As in, I can set a few tracks and when one ends it picks a different one to play next.) I'm still not sure how much background music these puzzle games even _want_ or _need_, but at least I have the option now.

The hint button was the hardest one. Because you have no guarantee that the player is aligned with the right solution. They might have taken 5 completely wrong moves, so how can you give the "next hint"?

* We go through all moves the player has made, checking what was the **last move that matches the solution**.
* Then, we **go back in time** ( = undo turn after turn) until that moment.
* And _then_ we automatically execute the **next move** in the correct solution.

It felt a bit tricky to figure out, but in the end it wasn't as hard as I feared. (Which is why I did NOT implement it yet in the previous puzzle games!) If you already have support for doing/undoing turns, then it's "easy" to just undo multiple turns until you're in line with the solution again.

It might surprise players the first time they see it, because the game suddenly shifts to some earlier state. But it's not that bad, especially not once you have nice animations and transitions in the game, so the players _see_ that you're rewinding to the last correct move.

## Conclusion

As with the previous puzzle games, this is nothing groundbreaking. It's an educational puzzle game for the youngest of kids, with higher difficulty levels to also challenge older kids or those whose skill has grown enough over time. 

So the most important metric is, or so I believe right now,

* If the first level _teaches_ the skill well.
* If later levels _explore_ that skill in different ways. (Advancing your understanding, challenging it, growing it.)
* If the final level _tests_ all you learned in a puzzle that will be a fun challenge for any player of any age.

And that it does! Kids only need to tap the right one, repeatedly. There's clear immediate feedback when you're wrong, and a reward when right. Comparing sizes and sorting smallest to largest is easily taught this way, while being a very useful skill. (There is no penalty, no other confusing system or rules, on the easiest difficulty, which would make this learning process more nebulous and less direct.)

Higher difficulties explore the skill in different ways. By growing/shrinking those around you, that order now _changes_ on the fly. When you're allowed to tap them in any order, you now need to learn thinking in reverse: instead of "tap the smallest one", it's "tap such that the right one is smallest next".

Finally, I've started doing this silly "click anything"-test with these puzzles, and on the highest difficulty it passes. That is, I can't solve those puzzles by just randomly clicking cells. Those puzzles are good enough that you actually need to think and make the right moves.

The extra features of the framework (_hints, undo, etc_), and the special attention to fantasy visuals and theme, make the game look quite good. Better, at least, than many other games in this space. That's the _other_ important metric: the game needs to be attractive to kids and fun to play. (I keep changing my mind about which of the two is "most" important.) If it doesn't look fun and lively, then it doesn't matter how great the educational value is---nobody will actually play.

And, so, I think this is a good educational tool and a good execution of the idea (in terms of visuals, gameplay, feeling). Let's end it on that positive note!

Until the next devlog,

Pandaqi