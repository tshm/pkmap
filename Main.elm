port module Pkmap exposing (main)

import Html exposing (input, label, img, a, nav, text, div, span, button)
import Geolocation
import Html.App
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)

main : Program Never
main = Html.App.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }


-- MODEL

type alias Model =
  { location : Location
  , circles : List Circle
  }

type alias Location =
  { latitude : Float
  , longitude : Float
  }

type alias Circle =
  { center : Location
  , radius : Float
  }

init : (Model, Cmd Msg)
init =
  let
    model =
      { location = Location 0.0 0.0
      , circles = []
      }
  in (model, initMap True)

port initMap : Bool -> Cmd msg


-- UPDATE

type Msg
  = NoOp
  | LocationChange Geolocation.Location
  | AddCircle
  | ResetCircle
  | RemoveCircle

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp -> (model, Cmd.none)

    LocationChange geoloc ->
      let
        location = Location geoloc.latitude geoloc.longitude
      in ({ model | location = location }, locationChange location )

    AddCircle ->
      let
        circle = Circle model.location 200.0
        circles = circle :: model.circles
      in ({ model | circles = circles }, addCircle circle)

    RemoveCircle ->
        case List.tail model.circles of
          Just circles -> ({ model | circles = circles }, removeCircle True)
          Nothing -> (model, Cmd.none)

    ResetCircle -> ({ model | circles = []}, resetCircle True)

port locationChange : Location -> Cmd msg
port addCircle : Circle -> Cmd msg
port removeCircle : Bool -> Cmd msg
port resetCircle : Bool -> Cmd msg


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Geolocation.changes LocationChange 


-- VIEW

view : Model -> Html.Html Msg
view model =
  div []
    [ header model
    , modal
    , Html.main' []
      [ div [ id "map"] []
      , button [ onClick AddCircle, class "plus warning"] [ text "+"]
      ]
    ]

header : Model -> Html.Html Msg
header model =
  let
    buttons =
      [ label [for "bmenub", class "burger pseudo button"] [ text "≡"]
      , button [ onClick RemoveCircle ]
        [ text "Delete"
        , Html.sup [] [ text <| toString (List.length model.circles )]
        ]
      , div [ class "menu"]
        [ label [ for "modal", class "error button"] [ text "Reset"]
        ]
      ]
  in
    Html.header []
      [ nav [] <|
        [ input [id "bmenub", type' "checkbox", class "show"] []
        , a [ href "#", class "brand"] [ text "PkMap" ]
        ] ++ if List.isEmpty model.circles then [] else buttons
      ]

modal : Html.Html Msg
modal =
  Html.div [ class "modal"]
    [ input [ id "modal", type' "checkbox"] []
    , label [ for "modal", class "overlay"] []
    , Html.article []
      [ Html.header []
        [ text "Confirm"
        , label [ for "modal", class "close"] [ text "×"]
        ]
      , Html.section [] [ text "Are you sure to remove all marks?"]
      , Html.footer []
        [ label [ for "modal"]
          [ a [ class "button dangerous", onClick ResetCircle ] [text "OK"]
          ]
        ]
      ]
    ]

