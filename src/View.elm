module View exposing (view)

import Html exposing (Html, text)
import Element exposing (..)
import Collage exposing (..)
import Color exposing (..)
import Model exposing (..)


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
            round pipe.width

        pipeHeight =
            round pipe.height

        img =
            case pipe.direction of
                Up ->
                    "./src/pipe_up.png"

                Down ->
                    "./src/pipe_down.png"
    in
        [ image pipeWidth pipeHeight img
            |> toForm
            |> move ( pipe.x, pipe.y )
        ]
