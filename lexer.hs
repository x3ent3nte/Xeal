import Data.Char

data Token = ID | INTEGER | FLOAT | STRING | DEF | LOGIC | OPEN_PAREN | CLOSED_PAREN 
    | OPEN_CURLY | CLOSED_CURLY | WHITE_SPACE | NEW_LINE | ASSIGNMENT | EQUALS | SEMICOLON | ERROR | NONE deriving (Show)

data MetaType = ANY | ALPHA | DIGIT

type Symbol = Either Char MetaType

type TokenStr = (Token, String)

type Machine = (Token, [(Int, Symbol, Int)], [Int])

main = do
    text <- getContents
    print (lexer text)


fsa_id = (ID, 
    [(0, Right ALPHA, 1),
    (1, Left '_', 0),
    (1, Right ALPHA, 1),
    (1, Right DIGIT, 1)]
    ,[1])

fsa_integer = (INTEGER,
    [(0, Right DIGIT, 2),
    (0, Left '+', 1),
    (0, Left '-', 1),
    (1, Right DIGIT, 2),
    (2, Right DIGIT, 2)],
    [2])

fsa_float = (FLOAT,
    [(0, Right DIGIT, 2),
    (0, Left '+', 1),
    (0, Left '-', 1),
    (1, Right DIGIT, 2),
    (2, Right DIGIT, 2),
    (2, Left '.', 3),
    (3, Right DIGIT, 4),
    (4, Right DIGIT,4),
    (4, Left 'E', 5),
    (5, Right DIGIT, 7),
    (5, Left '+', 6),
    (5, Left '-', 6),
    (6, Right DIGIT, 7),
    (7, Right DIGIT, 7)],
    [2,4,7])

machines = [fsa_id, fsa_integer, fsa_float]
   
lexer :: [Char] -> [TokenStr]
lexer text = lexerR text []

lexerR :: [Char] -> [TokenStr] -> [TokenStr]
lexerR [] acc = acc
lexerR text acc = 
    let (length, token_type) = run_machines text machines in 
    let (munch, rest) = bite_off text length in
    lexerR rest ((token_type, munch):acc)

bite_off :: [Char] -> Int -> ([Char], [Char])
bite_off str n = bite_offR str n []

bite_offR :: [Char] -> Int -> [Char] -> ([Char], [Char])
bite_offR str 0 munch = ((reverse munch), str)
bite_offR (x:xs) n munch = bite_offR xs (n - 1) (x:munch)



run_machines :: [Char] -> [Machine] -> (Int, Token)
run_machines text machines = run_machinesR text machines (1, NONE)

run_machinesR :: [Char] -> [Machine] -> (Int, Token) -> (Int, Token)
run_machinesR text [] best = best
run_machinesR text (m:ms) (longest, longest_token) = 
    let (length, token_type) = run_machine text m in  
    if length > longest then run_machinesR text ms (length, token_type)
        else run_machinesR text ms (longest, longest_token)



run_machine :: [Char] -> Machine -> (Int, Token)
run_machine text machine = run_machineR text machine 0 0 0

run_machineR :: [Char] -> Machine -> Int -> Int -> Int -> (Int, Token)
run_machineR [] (token, _, _) _ _ highest = (highest, token)
run_machineR (x:xs) machine state current highest = 
    let (next_state, accepting) = transition machine state x in
    if next_state == -1 then 
        let (token, _, _) = machine in
        (highest, token) 
        else 
            let next_highest = if accepting then current + 1 else highest in 
            run_machineR xs machine next_state (current + 1) next_highest

transition :: Machine -> Int -> Char -> (Int, Bool)
transition (_, trans, accepting) state symbol = 
    let next_state = find_transition trans state symbol in
    if next_state == (-1) then (-1, False)
        else (next_state, elem next_state accepting)

find_transition :: [(Int, Symbol, Int)] -> Int -> Char -> Int
find_transition [] _ _ = -1
find_transition ((s, i, n):tl) state symbol
    | valid_transition (s,i) state symbol = n
    | otherwise = find_transition tl state symbol

valid_transition :: (Int, Symbol) -> Int -> Char -> Bool
valid_transition (s, Left i) state symbol = if s == state && i == symbol then True else False
valid_transition (s, Right i) state symbol = if s /= state then False
    else case i of 
        ANY -> True
        ALPHA -> isAlpha symbol
        DIGIT -> isDigit symbol


 













