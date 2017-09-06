module Model exposing (..)

import Phoenix.Socket
import Msg exposing (..)


type alias Game =
    { bird : Bird
    , pipes : List Pipe
    , windowDimensions : ( Int, Int )
    , state : GameState
    , score : Int
    , player : Player
    , phxSocket : Phoenix.Socket.Socket Msg
    , name : Maybe String
    , uid : Maybe String
    , topPlayers : List TopPlayer
    }


type alias TopPlayer =
    { name : String
    , score : Int
    }


type alias Bird =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


type alias Pipe =
    { height : Float
    , width : Float
    , x : Float
    , y : Float
    , direction : Direction
    , passed : Bool
    }


type Direction
    = Up
    | Down


type GameState
    = Play
    | Start
    | GameOver


type Player
    = Anonymous
    | String


initialBird : Bird
initialBird =
    { x = -150
    , y = 20
    , vx = 2
    , vy = 0
    }


socketServer : String
socketServer =
    "ws://limitless-tor-81039.herokuapp.com/socket/websocket"


( gameWidth, gameHeight ) =
    ( 600, 400 )
