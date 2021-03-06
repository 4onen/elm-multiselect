module Main exposing (..)

import Browser as Browser
import Html exposing (Html, button, div, text)
import Html.Attributes
import Html.Events exposing (onClick)
import Http as Http
import Json.Decode as Decode
import Multiselect


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view =
            \m ->
                { title = "Elm 0.19 starter"
                , body = [ view m ]
                }
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


valuesA : List ( String, String )
valuesA =
    [ ( "elixir-estonia", "ELIXIR Estonia" )
    , ( "unitartu", "University of Tartu" )
    , ( "cs", "Institute of Computer Science" )
    , ( "biit", "BIIT" )
    , ( "javascript", "JavaScript" )
    , ( "elm", "Elm" )
    , ( "multiselect", "Multiselect" )
    , ( "haskell", "Haskell" )
    , ( "elixir", "Elixir" )
    , ( "clojure", "Clojure" )
    , ( "shen", "Shen" )
    ]


valuesB : List ( String, String )
valuesB =
    [ ( "0", "AAA" )
    , ( "1", "AAB" )
    , ( "2", "ABA" )
    , ( "3", "ABB" )
    , ( "4", "BAA" )
    , ( "5", "BAB" )
    , ( "6", "BBA" )
    , ( "7", "BBB" )
    ]


valuesC : List ( String, String )
valuesC =
    []


type alias Flags =
    {}


type alias Model =
    { multiselectA : Multiselect.Model
    , multiselectB : Multiselect.Model
    , multiselectC : Multiselect.Model
    , selectedA : List ( String, String )
    }


initModel : Model
initModel =
    { multiselectA = Multiselect.initModel valuesA "A"
    , multiselectB = Multiselect.initModel valuesB "B"
    , multiselectC = Multiselect.initModel valuesC "C"
    , selectedA = []
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel, prepopulateValues )



-- UPDATE


type Msg
    = NoOp
    | HOI Multiselect.Msg
    | Nyan Multiselect.Msg
    | Yay Multiselect.Msg
    | SelectA
    | Prepopulate (Result Http.Error (List String))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        HOI sub ->
            let
                ( subModel, subCmd, outMsg ) =
                    Multiselect.update sub model.multiselectA
            in
            ( { model | multiselectA = subModel }, Cmd.map HOI subCmd )

        Nyan sub ->
            let
                ( subModel, subCmd, outMsg ) =
                    Multiselect.update sub model.multiselectB
            in
            ( { model | multiselectB = subModel }, Cmd.map Nyan subCmd )

        Yay sub ->
            let
                ( subModel, subCmd, outMsg ) =
                    Multiselect.update sub model.multiselectC

                newModel =
                    { model | multiselectC = subModel }

                ( newerModel, outCommands ) =
                    case outMsg of
                        Just m ->
                            updateOutMsg m newModel

                        Nothing ->
                            ( newModel, Cmd.none )
            in
            ( newerModel, Cmd.batch [ Cmd.map Yay subCmd, outCommands ] )

        SelectA ->
            ( { model | selectedA = Multiselect.getSelectedValues model.multiselectA }, Cmd.none )

        Prepopulate (Ok vs) ->
            let
                multiselectModel =
                    model.multiselectC

                values =
                    List.map (\v -> ( v, v )) vs
            in
            ( { model | multiselectC = Multiselect.populateValues multiselectModel values [] }, Cmd.none )

        Prepopulate (Err _) ->
            Debug.log "error" ( model, Cmd.none )


updateOutMsg : Multiselect.OutMsg -> Model -> ( Model, Cmd Msg )
updateOutMsg msg model =
    case msg of
        Multiselect.Selected ( k, v ) ->
            let
                _ =
                    ( Debug.log "Received Selected msg from Multiselect, key" k
                    , Debug.log "value" v
                    )
            in
            ( model, Cmd.none )

        Multiselect.Unselected ( k, v ) ->
            let
                _ =
                    ( Debug.log "Received Unselected msg from Multiselect, key" k
                    , Debug.log "value" v
                    )
            in
            ( model, Cmd.none )

        Multiselect.Cleared ->
            let
                _ =
                    Debug.log "Received Cleared msg from Multiselect" ""
            in
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [
        div [ Html.Attributes.class "wrapper" ] [
            Html.header [] [
                div [] [
                    Html.h1 [] [ text "elm-multiselect"]
                    , Html.p [] [ text "A multiselect control built with and for Elm" ]
                ]
            ]
            , div [ Html.Attributes.class "subheader" ] [
                Html.a [ Html.Attributes.class "github-button", Html.Attributes.href "https://github.com/inkuzmin/elm-multiselect"
                , Html.Attributes.attribute "data-size" "large" , Html.Attributes.attribute "data-show-count" "true"
                , Html.Attributes.attribute "aria-label" "Star inkuzmin/elm-multiselect on GitHub" ] [ text "Star" ]
            ]
            , div [ Html.Attributes.id "main" ]
                [ Html.h3 [] [ text "Submit on button click" ]
                , Html.map HOI <| Multiselect.view model.multiselectA
                , showSelected model.selectedA
                , Html.button [ Html.Attributes.class "btn", onClick SelectA ] [ text "Select!" ]
                , div [ Html.Attributes.style "height" "300px" ] [ text "" ]
                , Html.h3 [] [ text "Submit on select" ]
                , Html.map Nyan <| Multiselect.view model.multiselectB
                , showSelected (Multiselect.getSelectedValues model.multiselectB)
                , div [ Html.Attributes.style "height" "300px" ] [ text "" ]
                , Html.h3 [] [ text "Contributors (dynamic fetching of values)" ]
                , Html.map Yay <| Multiselect.view model.multiselectC
                , showSelected (Multiselect.getSelectedValues model.multiselectC)
                ]
            , div [ Html.Attributes.class "push" ] []
        ]
        , Html.footer [] [
            div [ Html.Attributes.class "acknowledgements" ] [
                Html.a [ Html.Attributes.class "image unitartu", Html.Attributes.href "https://www.ut.ee/en" ] [ Html.img [ Html.Attributes.alt "Emblem of the University of Tartu", Html.Attributes.src "https://inkuzmin.github.io/logos/assets/unitartu.svg" , Html.Attributes.width 100 ] [] ]
                , Html.a [ Html.Attributes.class "image biit", Html.Attributes.href "https://biit.cs.ut.ee/" ] [ Html.img [ Html.Attributes.alt "BIIT research group", Html.Attributes.src "https://inkuzmin.github.io/logos/assets/biit.svg" , Html.Attributes.width 100 ] [] ]
            ]
            , div [ Html.Attributes.class "copy" ] [
                Html.p [] [ text "© 2018 ", Html.a [ Html.Attributes.href "https://github.com/inkuzmin" ] [ text "Ivan Kuzmin" ] ]
            ]
        ]
    ]


showSelected : List ( String, String ) -> Html Msg
showSelected values =
    Html.ul [] (List.map (\( name, value ) -> Html.li [] [ text value ]) values)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map HOI <| Multiselect.subscriptions model.multiselectA
        , Sub.map Nyan <| Multiselect.subscriptions model.multiselectB
        , Sub.map Yay <| Multiselect.subscriptions model.multiselectC
        ]



-- HELPERS


prepopulateValues : Cmd Msg
prepopulateValues =
    let
        url =
            "https://api.github.com/repos/inkuzmin/elm-multiselect/contributors"

        request =
            Http.get url decodeUrl
    in
    Http.send Prepopulate request


decodeUrl : Decode.Decoder (List String)
decodeUrl =
    Decode.list (Decode.field "login" Decode.string)
