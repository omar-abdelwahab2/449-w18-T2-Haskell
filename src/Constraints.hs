module Constraints where

import Data.Char
import Data.List.Tree
import Data.Maybe
import Data.List


--x = branchAndBound x y


meetsHardConstr :: [(Char,Char)] -> [(Char,Char)] -> [(Char,Char)] -> [Char] -> Bool

meetsHardConstr fpa fm tnt state = iterState fpa fm state && meetsTnt tnt state

-- takes the fpa, fm, and the state
iterState :: [(Char,Char)] -> [(Char,Char)] -> [Char] -> Bool

iterState fpa fm [] = True
iterState fpa fm all@(t:tasks) = meetsFpa fpa (fromJust $ elemIndex t all , t) && meetsFm fm (fromJust $ elemIndex t all , t) && iterState fpa fm tasks

-- takes a list of pairs (mach, task) from forced partial assignment input
-- and the current pair (mach,task) and returns a Bool
meetsFpa :: [(Char,Char)] -> (Int,Char) -> Bool

meetsFpa [] pair = False
meetsFpa ((m,t):pairs) (mach,task)
  | (ord m - 48) == mach && t == task = True
  | (ord m - 48) /= mach || t /= task = meetsFpa pairs (mach,task)


-- takes a list of pairs (mach, task) from forbidden machine input
-- and the current pair (mach,task) and returns a Bool
meetsFm :: [(Char,Char)] -> (Int, Char) -> Bool

meetsFm [] pair = True
meetsFm ((m,t):pairs) (mach,task)
  | (ord m - 48) == mach && t == task = False
  | (ord m - 48) /= mach || t /= task = meetsFpa pairs (mach,task)


-- takes a list of pairs and the state and returns a boolean
meetsTnt :: [(Char,Char)] -> [Char] -> Bool

-- takes a list of pairs of tasks and a tuple of two nearby tasks and returns a boolean
iterTnt :: [(Char, Char)] -> (Char, Char) -> Bool

meetsTnt list all@(t1 : tasks) = meetsTnt1 list all t1

meetsTnt1 list [] t0 = True
meetsTnt1 list [t] t0 = iterTnt list (t,t0) && iterTnt list (t0,t)
meetsTnt1 list (t1 : t2 : tasks) t0 = iterTnt list (t1,t2) && meetsTnt1 list (t2 : tasks) t0


iterTnt [] pair = True
iterTnt ((t1, t2):pairs) (t1', t2')
  | t1 == t1' && t2 == t2' = False
  | otherwise = iterTnt pairs (t1', t2')


-- returns the total penalty value so far
calcPenalty :: Int -> [[Int]] -> [(Char, Char, Int)] -> [Char] -> Int

calcPenalty mach mp tnp state = calcMp mach mp state + calcTnp tnp state

calcMp :: Int -> [[Int]] -> [Char] -> Int

calcMp n mp state
  | state !! n == 'X' = 0
  | otherwise = mp !! n !! (ord (state !! n ) - 65)


-- takes a list of triplets (tnp) and the state and returns the penalty value
calcTnp :: [(Char, Char, Int)] -> [Char] -> Int

calcTnp list all@(t1 : tasks) = calcTnp1 list all t1

calcTnp1 list [] t0 = 0
calcTnp1 list [t] t0 = iterTnp list (t,t0) + iterTnp list (t0,t)
calcTnp1 list ('X' : tasks) t0 = 0
calcTnp1 list (a : 'X' : tasks) t0 = 0
calcTnp1 list (t1 : t2 : tasks) t0 = iterTnp list (t1,t2) + calcTnp1 list (t2 : tasks) t0

iterTnp :: [(Char,Char,Int)] -> (Char,Char) -> Int

iterTnp [] pair = 0
iterTnp ((t1, t2, p):triplets) (t1', t2')
  | t1 == t1' && t2 == t2' = p
  | otherwise = iterTnp triplets (t1', t2')



