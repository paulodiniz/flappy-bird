module Main exposing (..)

import AnimationFrame
import Html exposing (Html, text)
import Keyboard exposing (KeyCode)
import Time exposing (..)

import View exposing (..)
import Model exposing (..)
import Update exposing (..)

main : Program Never Game Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL



init : ( Game, Cmd Msg )
init =
    ( initialGame, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        , Time.every second GeneratePipe
        ]




