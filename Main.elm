module Main exposing (..)

import Json.Decode exposing (int, string, float, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Html
import Html.Attributes
import Http


uri =
    "http://demo-kinto.scalingo.io/v1/buckets/11d2d8f1-20a2-0625-79fb-5de483ba5b0b/collections/metrics/records"


type Msg
    = UpdateModel (Result Http.Error Model)


type alias Model =
    { begin_date : String
    , end_date : String
    , facebook : Facebook
    }


type alias Facebook =
    { likes : Int
    , views : Int
    , posts : Int
    , interactions : Int
    }


getData : Cmd Msg
getData =
    Http.send UpdateModel <|
        Http.get uri modelDecoder


modelDecoder : Decoder Model
modelDecoder =
    decode Model
        |> required "begin_date" string
        |> required "end_date" string
        |> required "facebook" facebookDecoder


facebookDecoder : Decoder Facebook
facebookDecoder =
    decode Facebook
        |> required "likes" int
        |> required "views" int
        |> required "posts" int
        |> required "interactions" int


init : ( Model, Cmd Msg )
init =
    ( Model "unknown"
        "unknown"
        { likes = 0
        , views = 0
        , posts = 0
        , interactions = 0
        }
    , getData
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateModel results ->
            case (Debug.log "results:" results) of
                Ok new ->
                    ( new, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.header []
            [ Html.h1 [ Html.Attributes.id "logo" ] [ Html.text "Backnut" ]
            , Html.p [] [ Html.text "Social Media Metrics" ]
            , Html.p [] [ Html.text ("From " ++ model.begin_date ++ " to " ++ model.end_date) ]
            ]
        , Html.section [ Html.Attributes.id "facebook" ]
            [ Html.h2 [] [ Html.text "Facebook analytics" ]
            , Html.dl [ Html.Attributes.class "metrics" ]
                [ Html.dt []
                    [ Html.span [] [ Html.text (toString model.facebook.likes) ]
                    , Html.text "people who liked our page"
                    ]
                , Html.dd [ Html.Attributes.class "up" ]
                    [ Html.text "117" ]
                , Html.dt []
                    [ Html.span [] [ Html.text (toString model.facebook.views) ]
                    , Html.text "people who have seen any content associated with our page"
                    ]
                , Html.dd [ Html.Attributes.class "up" ]
                    [ Html.text "289" ]
                , Html.dt []
                    [ Html.span [] [ Html.text (toString model.facebook.posts) ]
                    , Html.text "number of Facebook posts"
                    ]
                , Html.dd [ Html.Attributes.class "up" ]
                    [ Html.text "100" ]
                , Html.dt []
                    [ Html.span [] [ Html.text (toString model.facebook.interactions) ]
                    , Html.text "number of interactions: shares, likes"
                    ]
                , Html.dd [ Html.Attributes.class "down" ]
                    [ Html.text "58" ]
                ]
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
