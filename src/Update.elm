module Update exposing (..)

-- import Keyboard exposing (KeyCode)
-- import Time exposing (..)

import Model exposing (..)
import Msg exposing (..)
import Phoenix.Socket
import Phoenix.Push
import Random
import Json.Decode as JD
import Json.Encode as JE
import Debug


update : Msg -> Game -> ( Game, Cmd Msg )
update msg game =
    case game.state of
        Play ->
            case msg of
                AskForTopPlayers _ ->
                    let
                        phxPush =
                            Phoenix.Push.init "top_players" "game:lobby"
                                |> Phoenix.Push.withPayload (scorePayload game)

                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.push phxPush game.phxSocket
                    in
                        ( { game | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

                SendScore ->
                    let
                        phxPush =
                            Phoenix.Push.init "update_score" "game:lobby"
                                |> Phoenix.Push.withPayload (scorePayload game)

                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.push phxPush game.phxSocket
                    in
                        ( { game | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

                TimeUpdate dt ->
                    updateFlappy game

                KeyDown keyCode ->
                    ( { game | bird = jump game.bird }, Cmd.none )

                GeneratePipe _ ->
                    ( game, Random.generate NewPipe (Random.float 50 400) )

                NewPipe height ->
                    ( generateNewPipe game height, Cmd.none )

                JoinGame ->
                    let
                        phxPush =
                            Phoenix.Push.init "join_game" "game:lobby"
                                |> Phoenix.Push.withPayload (JE.object [])

                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.push phxPush game.phxSocket
                    in
                        ( { game | phxSocket = phxSocket }, Cmd.map PhoenixMsg phxCmd )

                PhoenixMsg msg ->
                    let
                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.update msg game.phxSocket
                    in
                        ( { game | phxSocket = phxSocket }
                        , Cmd.map PhoenixMsg phxCmd
                        )

                JoinedGame raw ->
                    case (decodeJoiningGame raw) of
                        Ok ( name, uid ) ->
                            ( { game | name = Just name, uid = Just uid }, Cmd.none )

                        Err error ->
                            ( game, Cmd.none )

                UpdateTopPlayers raw ->
                    let
                        _ = Debug.log "RAW HERE" raw
                        result = decodeTopPlayers raw
                        _ = Debug.log "After decoding" result
                    in
                      case (decodeTopPlayers raw) of
                          Ok(name_0, score_0, name_1, score_1, name_2, score_2) ->
                              ({ game | topPlayers = (updatedTopPlayers name_0 score_0 name_1 score_1 name_2 score_2)}, Cmd.none)
                          Err _ ->
                              (game, Cmd.none)

        Start ->
            case msg of
                KeyDown keyCode ->
                    { game | state = Play } |> update JoinGame

                _ ->
                    ( game, Cmd.none )

        GameOver ->
            case msg of
                KeyDown keyCode ->
                    ({ game | state = Play, pipes = [], bird = initialBird }, Cmd.none)
                _ ->
                    ( game, Cmd.none )


updatedTopPlayers : Maybe String -> Maybe Int -> Maybe String -> Maybe Int -> Maybe String -> Maybe Int -> List TopPlayer
updatedTopPlayers name_0 score_0 name_1 score_1 name_2 score_2 =
    let
        name_0_ = case name_0 of
                      Nothing ->
                          ""
                      Just val ->
                          val
        score_0_ = case score_0 of
                      Nothing ->
                          0
                      Just val ->
                          val
        name_1_ = case name_1 of
                      Nothing ->
                          ""
                      Just val ->
                          val
        score_1_ = case score_1 of
                      Nothing ->
                          0
                      Just val ->
                          val
        name_2_ = case name_2 of
                      Nothing ->
                          ""
                      Just val ->
                          val
        score_2_ = case score_2 of
                      Nothing ->
                          0
                      Just val ->
                          val

        first =  { name = name_0_, score = score_0_ }
        second = { name = name_1_, score = score_1_ }
        third =  { name = name_2_, score = score_2_ }
    in
        [first, second, third]

decodeTopPlayers : JD.Value -> Result String (Maybe String, Maybe Int, Maybe String, Maybe Int, Maybe String, Maybe Int)
decodeTopPlayers raw =
    JD.decodeValue
        (JD.map6 (,,,,,)
             (JD.maybe (JD.field "name_0" JD.string))
             (JD.maybe (JD.field "score_0" JD.int))
             (JD.maybe (JD.field "name_1" JD.string))
             (JD.maybe (JD.field "score_1" JD.int))
             (JD.maybe (JD.field "name_2" JD.string))
             (JD.maybe (JD.field "score_2" JD.int))
        ) raw


topPlayerDecoder : JD.Value -> Result String ( String, String, Int )
topPlayerDecoder raw =
    JD.decodeValue
        (JD.map3 (,,)
            (JD.field "uid" JD.string)
            (JD.field "name" JD.string)
            (JD.field "score" JD.int)
        )
        raw


decodeJoiningGame : JD.Value -> Result String ( String, String )
decodeJoiningGame raw =
    JD.decodeValue
        (JD.map2 (,)
            (JD.field "name" JD.string)
            (JD.field "uid" JD.string)
        )
        raw


scorePayload : Game -> JE.Value
scorePayload game =
    let
        uid =
            case game.uid of
                Nothing ->
                    ""

                Just val ->
                    val
    in
        JE.object [ ( "uid", JE.string uid ), ( "score", JE.int game.score ) ]


generateNewPipe : Game -> Float -> Game
generateNewPipe game height =
    let
        bottomHeight =
            height

        upHeight =
            400 - bottomHeight + 200

        upPipe =
            { height = upHeight
            , width = 75
            , x = 300
            , y = gameHeight / 2
            , direction = Up
            , passed = False
            }

        downPipe =
            { height = bottomHeight
            , width = 75
            , x = 300
            , y = -gameHeight / 2
            , direction = Down
            , passed = False
            }
    in
        { game | pipes = List.append game.pipes [ upPipe, downPipe ] }


updateFlappy : Game -> ( Game, Cmd Msg )
updateFlappy game =
    game
        |> gravity
        |> physics
        |> upperLimit
        |> checkPipeColision
        |> updatePipes
        |> updateScore


updateScore : Game -> ( Game, Cmd Msg )
updateScore game =
    let
        score =
            List.filter (\pipe -> pipe.passed == True) game.pipes
                |> List.length
                |> (\x -> x // 2)
    in
        if (game.score == score) then
            ( game, Cmd.none )
        else
            { game | score = score } |> update SendScore


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
    { bird | vy = 6 }


updatePipes : Game -> Game
updatePipes game =
    let
        bird =
            game.bird
    in
        { game | pipes = List.map (\pipe -> updatePipe bird pipe) game.pipes }


updatePipe : Bird -> Pipe -> Pipe
updatePipe bird pipe =
    let
        birdWidth =
            35

        leftBird =
            bird.x - birdWidth / 2 + 10

        passed =
            if (leftBird >= (pipe.x + pipe.width)) then
                True
            else
                False
    in
        { pipe | x = pipe.x - bird.vx, passed = passed }


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
            bird.x + birdWidth / 2 - 10

        leftBird =
            bird.x - birdWidth / 2 + 10

        upBird =
            bird.y + birdHeight / 2

        downBird =
            bird.y - birdHeight / 2 + 17

        leftPipe =
            pipe.x - pipe.width / 2

        rightPipe =
            pipe.x + pipe.width / 2

        upPipe =
            pipe.y + pipe.height / 2

        downPipe =
            pipe.y - pipe.height / 2
    in
        not <|
            (leftPipe > rightBird)
                || (rightPipe < leftBird)
                || (upPipe < downBird)
                || (downPipe > upBird)
