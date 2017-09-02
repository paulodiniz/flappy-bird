module Main exposing (..)

import AnimationFrame
import Html exposing (Html, text)
import Keyboard exposing (KeyCode)
import Time exposing (..)

import View exposing (..)
import Model exposing (..)
import Update exposing (..)
import Msg exposing (..)
import Phoenix.Socket

main : Program Never Game Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



init : ( Game, Cmd Msg )
init =
    ( initialGame, Cmd.none )


-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        , Time.every (Time.second * 2) GeneratePipe
        , Phoenix.Socket.listen model.phxSocket PhoenixMsg
        ]




