defmodule Hangman.Type do
  # NOTE - Elixir does NOT have enums but we can use a list of atoms for that
  #     Here we define the `state` type saying it can be any of the following atoms
  #     as they are linked by OR
  @type state :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  # NOTE - Type definition uses a syntax like a variable definition
  #     but using type names instead.
  #     Here, as we nedd `tally`  to be a compound type we use a map
  #     defining each entry as "name": "type name"
  @type tally :: %{
          turns_left: integer,
          # Possible valid game states ... we do not have enum so ...
          game_state: state,
          # Word to be guessed as a list of letters
          letters: list(String.t()),
          # list of letters asked by the user ( should be a set )
          used: list(String.t())
        }
end
