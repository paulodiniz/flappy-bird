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
import Phoenix.Channel

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
    let
        channel = Phoenix.Channel.init "game:lobby"
        (initSocket, phxCmd) =
          Phoenix.Socket.init socketServer
              |> Phoenix.Socket.withDebug
              |> Phoenix.Socket.on "joined_game" "game:lobby" JoinedGame
              |> Phoenix.Socket.on "top_players" "game:lobby" UpdateTopPlayers
              |> Phoenix.Socket.join channel

        initialGame =
            { bird = initialBird
            , pipes = []
            , windowDimensions = ( gameWidth, gameHeight )
            , state = Start
            , score = 0
            , player = Anonymous
            , phxSocket = initSocket
            , name = Nothing
            , uid = Nothing
            }
    in
      ( initialGame , Cmd.map PhoenixMsg phxCmd )


-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        , Time.every (Time.second * 2) GeneratePipe
        , Phoenix.Socket.listen model.phxSocket PhoenixMsg
        , Time.every Time.second AskForTopPlayers
        ]
