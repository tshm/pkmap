port module Pkmap exposing (main)

import Html
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
  { title : String
  , location : Location
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
  (Model "test" (Location 0.0 0.0) [], Cmd.none)


-- UPDATE

type Msg
  = NoOp
  | LocationChange Geolocation.Location
  | AddCircle
  | ResetCircle

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

    ResetCircle -> ({ model | circles = []}, resetCircle True)

port locationChange : Location -> Cmd msg
port addCircle : Circle -> Cmd msg
port resetCircle : Bool -> Cmd msg

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model = --Sub.none
  Geolocation.changes LocationChange 

-- VIEW

view : Model -> Html.Html Msg
view model =
  Html.div [ class "mdl-layout mdl-js-layout mdl-layout--fixed-header" ]
    [ header
    -- , drawer
    , Html.main' [ class "mdl-layout__content"]
      [ Html.div [ id "map"] []
      ]
    ]

header : Html.Html Msg
header =
  Html.header [ class "mdl-layout__header"]
    [ Html.div [ class "mdl-layout__header-row"]
      [ Html.span [ class "mdl-layout-title"] [ Html.text "PkMap"]
      , Html.div [ class "mdl-layout-spacer"] []
      , button "mdl-button--colored" [ onClick ResetCircle ] [ Html.text "reset"]
      , Html.div [ class "mdl-layout-spacer"] []
      , button "mdl-button--fab mdl-button--colored" [ onClick AddCircle ] [ icon ["add"]]
      ]
    ]

drawer : Html.Html Msg
drawer =
  Html.div [ class "mdl-layout__drawer"]
    [ Html.span [ class "mdl-layout-title"] [ Html.text "PkMap"]
    , Html.div [ class "mdl-layout-spacer"] []
    , button "mdl-button--fab" [ onClick AddCircle ] [ icon ["add"]]
    , button "" [ onClick ResetCircle ] [ Html.text "reset"]
    ]

