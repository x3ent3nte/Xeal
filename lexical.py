import sys

file_name = sys.argv[1]

with open(file_name) as file:
    source = file.read()

print(repr(source))
print()

class FSA:
    def __init__(self, name, transitions, accepting):
        self.name = name
        self.transitions = transitions
        self.accepting = accepting

    def nextTransition(self, state, symbol):
        next_state = -1
        if (state, symbol) in self.transitions:
            next_state = self.transitions[(state, symbol)]
        elif (state, "ANY") in self.transitions:
            next_state = self.transitions[(state, "ANY")]
        elif symbol.isalpha() and (state, "ALPHA") in self.transitions:
            next_state = self.transitions[(state, "ALPHA")]
        elif symbol.isdigit() and (state, "DIGIT") in self.transitions:
            next_state = self.transitions[(state, "DIGIT")]
        
        if next_state in self.accepting:
            return (next_state, True)
        else:
            return (next_state, False)

fsa_id_transitions = {(0, "ALPHA"): 1,
            (1, "_"): 0,
            (1, "ALPHA"): 1,
            (1, "DIGIT"): 1}
fsa_id_accepting = {1: True}
fsa_id = FSA("ID", fsa_id_transitions, fsa_id_accepting)

fsa_integer_transitions  = {(0, "DIGIT"): 2,
                (0, "+"): 1,
                (0, "-"): 1,
                (1, "DIGIT"): 2,
                (2, "DIGIT"): 2}
fsa_integer_accepting = {2: True}
fsa_integer = FSA("INTEGER", fsa_integer_transitions, fsa_integer_accepting)

fsa_float_transitions  = {(0, "DIGIT"): 2,
                (0, "-"): 1,
                (0, "+"): 1,
                (1, "DIGIT"): 2,
                (2, "DIGIT"): 2,
                (2, "."): 3,
                (3, "DIGIT"): 4,
                (4, "DIGIT"): 4,
                (4, "E"): 5,
                (5, "-"): 6,
                (5, "+"): 6,
                (5, "DIGIT"): 7,
                (6, "DIGIT"): 7,
                (7, "DIGIT"): 7}
fsa_float_accepting = {2: True,
                        4: True,
                        7: True}
fsa_float = FSA("FLOAT", fsa_float_transitions, fsa_float_accepting)

fsa_string_transitions  = {(0, "\""): 1,
                (1, "\""): 2,
                (1, "ANY"): 1}
fsa_string_accepting = {2: True}
fsa_string = FSA("STRING", fsa_string_transitions, fsa_string_accepting)

fsa_def_transitions  = {(0, "d"): 1, 
            (1, "e"): 2, 
            (2, "f"): 3,}
fsa_def_accepting = {3: True}
fsa_def = FSA("DEF", fsa_def_transitions, fsa_def_accepting)

fsa_logic_transitions  = {(0, "n"): 1,
            (1, "o"): 2,
            (2, "t"): 3,
            (0, "a"): 4,
            (4, "n"): 5,
            (5, "d"): 3,
            (0, "o"): 6,
            (6, "r"): 3}
fsa_logic_accepting = {3: True}
fsa_logic = FSA("LOGIC", fsa_logic_transitions, fsa_logic_accepting)

fsa_open_paren_transitions  = {(0, "("): 1,}
fsa_open_paren_accepting = {1: True}
fsa_open_paren = FSA("OPEN_PAREN", fsa_open_paren_transitions, fsa_open_paren_accepting)

fsa_closed_paren_transitions  = {(0, ")"): 1,}
fsa_closed_paren_accepting = {1: True}
fsa_closed_paren = FSA("CLOSED_PAREN", fsa_closed_paren_transitions, fsa_closed_paren_accepting)

fsa_open_curly_transitions  = {(0, "{"): 1,}
fsa_open_curly_accepting = {1: True}
fsa_open_curly = FSA("OPEN_CURLY", fsa_open_curly_transitions, fsa_open_curly_accepting)

fsa_closed_curly_transitions  = {(0, "}"): 1,}
fsa_closed_curly_accepting = {1: True}
fsa_closed_curly = FSA("CLOSED_CURLY", fsa_closed_curly_transitions, fsa_closed_curly_accepting)

fsa_white_space_transitions  = {(0, " "): 1,
                    (0, "\t"): 1,
                    (1, " "): 1,
                    (1, "\t"): 1,}
fsa_white_space_accepting = {1: True}
fsa_white_space = FSA("WHITE_SPACE", fsa_white_space_transitions, fsa_white_space_accepting)

fsa_new_line_transitions  = {(0, "\n"): 1,}
fsa_new_line_accepting = {1: True}
fsa_new_line = FSA("NEW_LINE", fsa_new_line_transitions, fsa_new_line_accepting)

fsa_assignment_transitions  = {(0, "="): 1}
fsa_assignment_accepting = {1: True}
fsa_assignment = FSA("ASSIGNMENT", fsa_assignment_transitions, fsa_assignment_accepting)

fsa_equals_transitions  = {(0, "="): 1,
                (1, "="): 2}
fsa_equals_accepting = {2: True}
fsa_equals = FSA("EQUALS", fsa_equals_transitions, fsa_equals_accepting)

fsa_semicolon_transitions = {(0, ";"): 1}
fsa_semicolon_accepting = {1: True}
fsa_semicolon = FSA("SEMICOLON", fsa_semicolon_transitions, fsa_semicolon_accepting)

fsa_error_transitions = {(0, "ANY"): 1}
fsa_error_accepting = {1: True}
fsa_error = FSA("ERROR", fsa_error_transitions, fsa_error_accepting)


def run_fsa(tape, machine):
    token_type = machine.name
    
    state = 0
    position = 0

    longest_accepted = 0

    while position < len(tape):
        next_state, is_accepting = machine.nextTransition(state, tape[position])
        if next_state == -1:
            break

        state = next_state 
        position += 1
        if is_accepting and position > longest_accepted:
            longest_accepted = position

    return (longest_accepted, token_type)

def lexer(tape):
    machines = [fsa_logic, 
                fsa_def,
                fsa_id,
                fsa_integer,
                fsa_float, 
                fsa_string, 
                fsa_open_paren, 
                fsa_closed_paren, 
                fsa_open_curly, 
                fsa_closed_curly, 
                fsa_white_space, 
                fsa_new_line, 
                fsa_assignment,
                fsa_equals,
                fsa_semicolon,
                fsa_error,]
    position = 0

    tokens = []

    while position < len(tape):
        results = []

        for machine in machines:
            results.append(run_fsa(tape[position:], machine))

        longest_accept = 0
        longest_token = "NONE"

        for result in results:
            length = result[0]
            token_name = result[1]

            if length > longest_accept:
                longest_accept = length
                longest_token = token_name

        if longest_accept > 0:
            tokens.append((longest_token,tape[position: position + longest_accept]))
            position += longest_accept
        else:
            position += 1

    return tokens

tokens = lexer(source)
for token in tokens:
    print(token)




