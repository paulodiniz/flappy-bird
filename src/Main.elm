module Main exposing (..)

import AnimationFrame
import Collage exposing (..)
import Color exposing (..)
import Element exposing (..)
import Html exposing (Html, text)
import Keyboard exposing (KeyCode)
import Time exposing (..)


type alias Space =
    Bool


main : Program Never Game Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Bird =
    { x : Float
    , y : Float
    , vx : Float
    , vy : Float
    }


initialBird : Bird
initialBird =
    { x = 30
    , y = 100
    , vx = 0
    , vy = 0
    }


( gameWidth, gameHeight ) =
    ( 600, 400 )


type alias Game =
    { windowDimensions : ( Int, Int )
    , bird : Bird
    }


initialGame : Game
initialGame =
    { windowDimensions = ( gameWidth, gameHeight )
    , bird = initialBird
    }


init : ( Game, Cmd Msg )
init =
    ( initialGame, Cmd.none )



-- UPDATE


type Msg
    = TimeUpdate Time
    | KeyDown KeyCode
    | GeneratePipe Time


update : Msg -> Game -> ( Game, Cmd Msg )
update msg game =
    case msg of
        TimeUpdate dt ->
            ( updateFlappy game, Cmd.none )

        KeyDown keyCode ->
            ( { game | bird = jump game.bird }, Cmd.none )

        GeneratePipe _ ->
            ( game, Cmd.none )


updateFlappy : Game -> Game
updateFlappy game =
    game
        |> gravity
        |> physics


gravity : Game -> Game
gravity game =
    let
        bird =
            game.bird

        newBird =
            { bird
                | vy =
                    if bird.y > -(gameHeight / 2) then
                        bird.vy - gravityValue
                    else
                        0
            }
    in
        { game | bird = newBird }


physics : Game -> Game
physics game =
    let
        bird =
            game.bird

        newBird =
            { bird | y = bird.y + bird.vy }
    in
        { game | bird = newBird }


gravityValue : Float
gravityValue =
    0.45


jump : Bird -> Bird
jump bird =
    { bird | vy = 8 }


twoSeconds : Time
twoSeconds =
    Time.second * 2



-- SUBSCRIPTIONS


subscriptions : Game -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs TimeUpdate
        , Keyboard.downs KeyDown
        , Time.every twoSeconds GeneratePipe
        ]


view : Game -> Html msg
view game =
    let
        ( w, h ) =
            game.windowDimensions

        bird =
            game.bird

        birdImage =
            image 35 35 "flappy.png"

        groundY =
            10
    in
        toHtml <|
            container w h middle <|
                collage gameWidth
                    gameHeight
                    [ rect gameWidth gameHeight |> filled blueSky
                    , birdImage
                        |> toForm
                        |> move ( bird.x, bird.y + groundY )
                    ]


blueSky : Color
blueSky =
    rgb 174 238 238
