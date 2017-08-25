module Update exposing (..)

import Keyboard exposing (KeyCode)
import Time exposing (..)
import Model exposing (..)

type Msg
    = TimeUpdate Time
    | KeyDown KeyCode
    | GeneratePipe Time


update : Msg -> Game -> ( Game, Cmd Msg )
update msg game =
    case game.state of
        Play ->
            case msg of
                TimeUpdate dt ->
                    -- This is not regular
                    ( updateFlappy game, Cmd.none )

                KeyDown keyCode ->
                    ( { game | bird = jump game.bird }, Cmd.none )

                GeneratePipe _ ->
                    ( generateNewPipe game, Cmd.none )

        Start ->
            case msg of
                KeyDown keyCode ->
                    ( { game | state = Play }, Cmd.none )

                _ ->
                    ( game, Cmd.none )

        GameOver ->
            ( game, Cmd.none )


generateNewPipe : Game -> Game
generateNewPipe game =
    let
        upPipe =
            { height = 300
            , width = 75
            , x = 300
            , y = gameHeight / 2
            , direction = Up
            }

        downPipe =
            { height = 300
            , width = 75
            , x = 300
            , y = -gameHeight / 2
            , direction = Down
            }
    in
        { game | pipes = List.append game.pipes [ upPipe, downPipe ] }


updateFlappy : Game -> Game
updateFlappy game =
    game
        |> gravity
        |> physics
        |> updatePipes
        |> upperLimit
        |> checkPipeColision


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
            if bird.y <= (gameHeight / 2) then
                { bird | y = bird.y + bird.vy }
            else
                { bird | y = (gameHeight / 2) }
    in
        { game | bird = newBird }


gravityValue : Float
gravityValue =
    0.45


jump : Bird -> Bird
jump bird =
    { bird | vy = 8 }


updatePipes : Game -> Game
updatePipes game =
    let
        bird =
            game.bird
    in
        { game | pipes = List.map (\pipe -> updatePipe bird pipe) game.pipes }


updatePipe : Bird -> Pipe -> Pipe
updatePipe bird pipe =
    { pipe | x = pipe.x - bird.vx }


upperLimit : Game -> Game
upperLimit game =
    let
        bird =
            game.bird
    in
        if bird.y <= -(gameHeight / 2) then
            { game | state = GameOver }
        else
            game


checkPipeColision : Game -> Game
checkPipeColision game =
    let
        bird =
            game.bird

        pipesToCheck =
            List.filter (\pipe -> pipe.x >= bird.x) game.pipes

        pipesColiding =
            List.any (\pipe -> isColiding bird pipe) pipesToCheck
    in
        if pipesColiding then
            { game | state = GameOver }
        else
            game


isColiding : Bird -> Pipe -> Bool
isColiding bird pipe =
    let
        birdWidth =
            35

        birdHeight =
            35

        rightBird =
            bird.x + birdWidth / 2

        leftBird =
            bird.x - birdWidth / 2

        leftPipe =
            pipe.x - pipe.width / 2

        rightPipe =
            pipe.x + pipe.width / 2

        upPipe =
            pipe.y + pipe.height / 2

        downPipe =
            pipe.y - pipe.height / 2

        upBird =
            bird.y + birdHeight / 2

        downBird =
            bird.y - birdHeight / 2

    in
        case pipe.direction of
            Down ->
                (rightBird > leftPipe) && (leftBird < rightPipe) && (downBird < upPipe) && (upBird > downPipe)
            Up ->
                (rightBird > leftPipe) && (leftBird < rightPipe) && (upBird > downPipe) && (upBird > downPipe)



