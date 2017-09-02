module Model exposing (..)


import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Msg exposing (..)

type alias Game =
    { bird : Bird
    , pipes : List Pipe
    , windowDimensions : ( Int, Int )
    , state : GameState
    , score : Int
    , player : Player
    , showDialog : Bool
    , phxSocket : Phoenix.Socket.Socket Msg
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
    , direction: Direction
    , passed : Bool
    }

type Direction = Up | Down

type GameState
    = Play
    | Start
    | GameOver

type Player = Anonymous | String

initialBird : Bird
initialBird =
    { x = -150
    , y = 20
    , vx = 2
    , vy = 0
    }

socketServer : String
socketServer = "ws://localhost:4000/socket/websocket"

( gameWidth, gameHeight ) =
    ( 600, 400 )

