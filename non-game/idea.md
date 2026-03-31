# Dwarfs & Giants

The puzzle shows a random selection of dwarves/giants at different sizes. You have to **tap them in the right order** (smallest to largest).

* Later Level = When a dwarf and giant are exactly equally large, dwarves come first.
* Later Level = when you tap one, they disappear, but all NEIGHBOR people **change size**.
  * Tap a dwarf and its neighbors shrink
  * Tap a giant and its neighbors grow
  * _Things can't become TOO SMALL or TOO LARGE? That's the puzzle element?_

So ...

* EASIEST: Each turn, tap a dwarf or giant. You must always tap the **smallest one**. If equally large, order does not matter.
* EASY: If a dwarf and giant are **equally large**, tap the dwarf first.
* MEDIUM: If you tap a dwarf, its neighbors **shrink**.
* HARD: If you tap a giant, its neighbors **grow**.
* HARDEST: If you make any dwarf/giant _too small_ or _too large_ you lose.

HOW TO GENERATE?

* Place dwarfs and giants of random sizes. Crucially, at the moment, their size is just a random integer that doesn't mean anything yet.
* Every turn,
  * Pick a random option (from list of _smallest ones_)
  * Change the neighbors accordingly. => At all points, track the _smallest_ and _largest_ anything has been.
* At the end, we "recalibrate" the sizes such that the _smallest one_ = size 0, and the _largest one_ = max size.
  * If needed, we move _everything above the threshold down_. 
  * That is, we reduce the _starting size_ of anything that gets bigger than maximum. This is fine ... because those will just be grouped with everything else at max size, and _you_ need to pick the right order to solve the puzzle.
  * (This is only _impossible_ if reducing the starting height would bring it below 0, but that's rare and can just be puzzle fail OR we move the max size. But I'd rather not---keep it consistent for the kids.)




# To-Do


## Finishing

* SETTING: Control the number of "different scale levels", because my code will work just fine with any number of them.
* HARDEST DIFFICULTY: Allow a range of grid sizes?
* Tutorial (we need a unique one per level, to explain the next rule; maybe also show an IMAGE of this rule at the sides of the map?)
  * Make this a built-in feature of the `PuzzleTutorial` system => showing images around the map and/or like pop-ups


## Discarded

### Other Algorithm

Possible different approach:

* All cells start with _no_ defined size (just size 0?)
* We take turns by pressing a random character (a dwarf if they need to come before giants)
  * This automatically sets a lower boundary on _all_ other characters -> they could not have been SMALLER than this at this point, otherwise we'd have to press _them_.
  * We track all changes to other characters (min_size,max_size ever)
* Once done, all characters have a lower bound and an upper bound. They set themselves to any size within that.

