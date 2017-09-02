module Msg exposing (..)

import Phoenix.Socket
import Keyboard exposing (KeyCode)

import Time exposing (..)

type Msg
    = TimeUpdate Time
    | KeyDown KeyCode
    | GeneratePipe Time
    | NewPipe Float
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
