{-
S -> X | X + S
X -> id * X | id | (S) * X | (S)
-}

import Data.Char

main = print (parse ['i', '*', 'i', '$'])

data Node a = Empty | Terminal a | NonTerminal a [Node a] deriving (Show)

trans = []

parse :: [Char] -> (Bool, [String]) 
parse tokens = parseRX tokens ['S','$'] trans 

parseRX :: [Char] -> [Char] -> [(Char, Char, String)] -> (Bool, [String])
parseRX [] [] _ = (True, [])
parseRX tokens [] _ = (False, [])
parseRX (x:xs) (y:ys) trans 
    | (isLower y) = if x == y then parseRX xs ys trans
        else (False, [])
    | otherwise =
        let (valid_trans, valid_moves) = getTran x y trans in
        if valid_trans then branchMoves (x:xs) ys y valid_moves trans
        else (False, [])

branchMoves :: [Char] -> [Char] -> Char -> [String] -> [(Char, Char, String)] -> (Bool, [String])
branchMoves _ _ _ [] _ = (False, [])
branchMoves (x:xs) stack lhs (m:ms) trans =
    let (valid_parse, moves) = parseRX (x:xs) (m ++ stack) trans in
    if valid_parse then (True, (lhs:m):moves)
        else branchMoves (x:xs) stack lhs ms trans


{-
parseR :: [Char] -> [Char] -> [String] -> [(Char, Char, String)] -> (Bool, [String])
parseR [] [] moves _ = (True, moves)
parseR tokens [] _ _ = (False, [])
parseR (x:xs) (y:ys) moves trans
    | (isLower y) = if x == y then parseR xs ys moves trans
        else (False, [])
    | otherwise = 
        let (valid, move) = getTran x y trans in 
        if valid then parseR (x:xs) (move ++ ys) ((y:move):moves) trans
            else (False, [])
-}
getTran :: Char -> Char -> [(Char, Char, String)] -> (Bool, [String])
getTran _ _ _ = (True, ["dummy"])

buildParseTree :: [String] -> (Node Char, [String])
buildParseTree [] = (Empty, [])
buildParseTree ((lhs:rhs):rest) = 
    let (nodes, moves) = buildChildren rhs rest in
    (NonTerminal lhs nodes, moves)

buildChildren :: [Char] -> [String] -> ([Node Char], [String])
buildChildren children moves = buildChildrenR children moves []

buildChildrenR :: [Char] -> [String] -> [Node Char] -> ([Node Char], [String])
buildChildrenR [] moves nodes = (nodes, moves)
buildChildrenR (x:xs) moves nodes = 
    if (isLower x) then buildChildrenR xs moves ((Terminal x):nodes)
        else let (child, new_moves) = buildParseTree moves in  
        buildChildrenR xs new_moves (child:nodes)








