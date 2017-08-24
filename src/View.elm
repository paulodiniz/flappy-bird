
module View exposing (view)

import Html exposing (Html, text)
import Element exposing (..)
import Collage exposing (..)
import Color exposing (..)

import Model exposing (..)
import Update exposing (..)

view : Game -> Html msg
view game =
    let
        ( w, h ) =
            game.windowDimensions

        bird =
            game.bird

        birdImage =
            image 35 35 "./src/flappy.png"

        groundY =
            10

        pipesForms =
            List.concatMap pipeToForms game.pipes

        backgroundForms =
            [ rect gameWidth gameHeight |> filled blueSky ]

        birdForm =
            [ birdImage |> toForm |> move ( bird.x, bird.y + groundY ) ]

        formList =
            List.append backgroundForms <|
                List.append birdForm <|
                    pipesForms
    in
        toHtml <|
            container w h middle <|
                collage gameWidth gameHeight formList


blueSky : Color
blueSky =
    rgb 174 238 238

pipeToForms : Pipe -> List Form
pipeToForms pipe =
    let
        pipeWidth =
            75

        pipeHeight =
            100
    in
        [ image pipeWidth pipeHeight "./src/pipe_down.png"
            |> toForm
            |> move ( pipe.x, pipe.height - gameHeight / 2 )
        , image pipeWidth pipeHeight "./src/pipe_up.png"
            |> toForm
            |> move ( pipe.x, gameHeight / 2 - pipe.height )
        ]
