module Msg exposing (..)

import Phoenix.Socket
import Keyboard exposing (KeyCode)
import Json.Encode
import Time exposing (..)

type Msg
    = TimeUpdate Time
    | KeyDown KeyCode
    | GeneratePipe Time
    | NewPipe Float
    | JoinGame
    | JoinedGame Json.Encode.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | SendScore
    | AskForTopPlayers Time
    | UpdateTopPlayers Json.Encode.Value
