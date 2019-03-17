module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, button, p)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

---- MODEL ----

type alias Model =
    { operator1: Int
    , operator2: Int
    , operation: String
    }

init : ( Model, Cmd Msg )
init =
    ( { operator1 = 0
      , operator2 = 0
      , operation = ""
      }
    , Cmd.none
    )

getResult: Model -> String
getResult model =
    case model.operation of
        ""  -> model.operator1 |> String.fromInt
        "+" -> model.operator1 + model.operator2 |> String.fromInt
        "-" -> model.operator1 - model.operator2 |> String.fromInt
        "*" -> model.operator1 * model.operator2 |> String.fromInt
        "/" -> if model.operator2 == 0 then
                    "NaN"
               else
                    String.fromInt (model.operator1 // model.operator2)
                    ++ " R" ++
                    String.fromInt (model.operator1 - (model.operator1 // model.operator2) * model.operator2)

        _ -> "Unknown Operation: " ++ model.operation

---- UPDATE ----

type Msg
    = Number Int
    | Delete
    | Op String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Number x ->
            ( if model.operation == "" then
                { model | operator1 = model.operator1*10+x}
              else
                { model | operator2 = model.operator2*10+x}
            , Cmd.none
            )

        Delete ->
            ( if model.operator2 == 0 && model.operation == "" then
                { model | operator1 = model.operator1//10 }
              else if model.operator2 == 0 then
                { model | operation = "" }
              else
                { model | operator2 = model.operator2//10 }
            , Cmd.none
            )
        
        Op x ->
            ( case model.operation of 
                "" -> { model | operation = x }
                "/"-> { model 
                      | operator1 = model.operator1 // model.operator1
                      , operator2 = 0
                      , operation = x
                      }
                _  -> { model
                      | operator1 =
                          getResult model
                          |> String.toInt
                          |> Maybe.withDefault 0
                      , operator2 = 0
                      , operation = x
                      }
            , Cmd.none
            )

---- VIEW ----

view : Model -> Html Msg
view model =
    div [ class "h-100" ]
    [ div [ class "but-box h-100" ]
        [ div [ class "output" ]
            [ p [ class "calculation" ]
                [ text
                    (
                        if model.operation == "" then
                            String.fromInt model.operator1
                        else
                            String.fromInt model.operator1 ++ model.operation ++ String.fromInt model.operator2
                    )
                ]
            , p [ class "result" ] [ text ("=" ++ getResult model) ]
            ]
        , button [ class "key", onClick (Number 1) ] [ text "1" ]
        , button [ class "key", onClick (Number 2) ] [ text "2" ]
        , button [ class "key", onClick (Number 3) ] [ text "3" ]
        , button [ class "key-op", onClick (Op "+") ] [ text "➕" ]
        , button [ class "key", onClick (Number 4) ] [ text "4" ]
        , button [ class "key", onClick (Number 5) ] [ text "5" ]
        , button [ class "key", onClick (Number 6) ] [ text "6" ]
        , button [ class "key-op", onClick (Op "-") ] [ text "➖" ]
        , button [ class "key", onClick (Number 7) ] [ text "7" ]
        , button [ class "key", onClick (Number 8) ] [ text "8" ]
        , button [ class "key", onClick (Number 9) ] [ text "9" ]
        , button [ class "key-op", onClick (Op "*") ] [ p [ class "rot" ] [ text "➕" ] ]
        , button [ class "key-double", onClick (Number 0) ] [ text "0" ]
        , button [ class "key-del", onClick Delete ] [ text "⌫" ]
        , button [ class "key-op", onClick (Op "/") ] [ text "➗" ]
        ]
    ]    

---- PROGRAM ----

main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
