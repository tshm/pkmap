port module Pkmap exposing (main)

import Html exposing (text, div, span)
import Geolocation
import Html.App
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import StyledHtml exposing (..)

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
  div [ class "mdl-layout mdl-js-layout mdl-layout--fixed-header" ]
    [ header
    , drawer
    , Html.main' [ class "mdl-layout__content"]
      [ div [ id "map"] []
      ]
    ]

header : Html.Html Msg
header =
  Html.header [ class "mdl-layout__header"]
    [ div [ class "mdl-layout__header-row"]
      [ span [ class "mdl-layout-title"] [ text "PkMap"]
      , spacer
      , button "mdl-button--fab mdl-button--mini-fab"
        [ onClick RemoveCircle ] [ icon ["delete"]]
      , spacer
      , button "mdl-button--fab mdl-button--mini-fab mdl-button--colored"
        [ onClick AddCircle ] [ icon ["add"]]
      ]
    ]

drawer : Html.Html Msg
drawer =
  div [ class "mdl-layout__drawer"]
    [ span [ class "mdl-layout-title"] [ text "PkMap"]
    , button ""
      [ onClick ResetCircle ]
      [ text "Reset ", icon ["delete_sweep"]]
    , spacer
    , Html.a [ href "http://github.com/tshm/pkmap" ]
      [ icon ["link"]
      , text "github"
      ]
    ]

spacer : Html.Html Msg
spacer = div [ class "mdl-layout-spacer"] []

