module Main exposing (..)

import Json.Decode exposing (int, string, float, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Html
import Html.Attributes
import Http


uri =
    "http://demo-kinto.scalingo.io/v1/buckets/11d2d8f1-20a2-0625-79fb-5de483ba5b0b/collections/metrics/records?_limit=1&_sort=-end_date,-begin_date"


type Msg
    = UpdateModel (Result Http.Error Data)


type alias Data =
    { data : List Model
    }


type alias Model =
    { begin_date : String
    , end_date : String
    , facebook : Facebook
    , twitter : Twitter
    , linkedin : LinkedIn
    }


type alias Facebook =
    { likes : Int
    , views : Int
    , posts : Int
    , interactions : Int
    }


type alias Twitter =
    { analytics : TwitterAnalytics
    , gender_audience : TwitterGenderAudience
    , countries_audience : List Reach
    }


type alias TwitterAnalytics =
    { followers : Int
    , links_clicks : Int
    , likes : Int
    , retweets : Int
    }


type alias LinkedIn =
    { followers : Int
    , professional_status : List Reach
    }


type alias Reach =
    { name : String
    , reach : Float
    }


type alias TwitterGenderAudience =
    { men : Int
    , woman : Int
    }


getData : Cmd Msg
getData =
    Http.send UpdateModel <|
        Http.get uri listDecoder


listDecoder : Decoder Data
listDecoder =
    decode Data
        |> required "data" (list modelDecoder)


modelDecoder : Decoder Model
modelDecoder =
    decode Model
        |> required "begin_date" string
        |> required "end_date" string
        |> required "facebook" facebookDecoder
        |> required "twitter" twitterDecoder
        |> required "linkedin" linkedInDecoder


facebookDecoder : Decoder Facebook
facebookDecoder =
    decode Facebook
        |> required "likes" int
        |> required "views" int
        |> required "posts" int
        |> required "interactions" int


twitterDecoder : Decoder Twitter
twitterDecoder =
    decode Twitter
        |> required "analytics" twitterAnalyticsDecoder
        |> required "gender_audience" twitterGenderDecoder
        |> required "countries_audience" (list reachDecoder)


twitterAnalyticsDecoder : Decoder TwitterAnalytics
twitterAnalyticsDecoder =
    decode TwitterAnalytics
        |> required "followers" int
        |> required "links_clicks" int
        |> required "likes" int
        |> required "retweets" int


twitterGenderDecoder : Decoder TwitterGenderAudience
twitterGenderDecoder =
    decode TwitterGenderAudience
        |> required "men" int
        |> required "woman" int


linkedInDecoder : Decoder LinkedIn
linkedInDecoder =
    decode LinkedIn
        |> required "followers" int
        |> required "professional_status" (list reachDecoder)


reachDecoder : Decoder Reach
reachDecoder =
    decode Reach
        |> required "name" string
        |> required "reach" float


init : ( Model, Cmd Msg )
init =
    ( Model "unknown"
        "unknown"
        { likes = 0
        , views = 0
        , posts = 0
        , interactions = 0
        }
        { analytics =
            { followers = 0
            , links_clicks = 0
            , likes = 0
            , retweets = 0
            }
        , gender_audience = { men = 0, woman = 0 }
        , countries_audience = []
        }
        { followers = 0
        , professional_status = []
        }
    , getData
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateModel results ->
            case (Debug.log "results:" results) of
                Ok r ->
                    case (List.head r.data) of
                        Just new ->
                            ( new, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

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
        , Html.section [ Html.Attributes.id "twitter" ]
            [ Html.h2 [] [ Html.text "Twitter analytics" ]
            , Html.dl [ Html.Attributes.class "metrics" ]
                [ Html.dt []
                    [ Html.span [] [ Html.text (toString model.twitter.analytics.followers) ]
                    , Html.text "followers"
                    ]
                , Html.dd [ Html.Attributes.class "up" ]
                    [ Html.text "65" ]
                , Html.dt []
                    [ Html.span [] [ Html.text (toString model.twitter.analytics.links_clicks) ]
                    , Html.text "clicks on links"
                    ]
                , Html.dd [ Html.Attributes.class "stalled" ]
                    [ Html.text "--,-" ]
                , Html.dt []
                    [ Html.span [] [ Html.text (toString model.twitter.analytics.retweets) ]
                    , Html.text "retweets"
                    ]
                , Html.dd [ Html.Attributes.class "stalled" ]
                    [ Html.text "--,-" ]
                , Html.dt []
                    [ Html.span [] [ Html.text (toString model.twitter.analytics.likes) ]
                    , Html.text "likes"
                    ]
                , Html.dd [ Html.Attributes.class "stalled" ]
                    [ Html.text "--,-" ]
                ]
            , Html.div [ Html.Attributes.class "engagement" ]
                [ Html.span []
                    [ Html.text "1,8%" ]
                , Html.text " engagement rate"
                ]
            , Html.dl [ Html.Attributes.class "audience" ]
                [ Html.dt []
                    [ Html.text "Men" ]
                , Html.dd []
                    [ Html.text (toString model.twitter.gender_audience.men) ]
                , Html.dt []
                    [ Html.text "Woman" ]
                , Html.dd []
                    [ Html.text (toString model.twitter.gender_audience.woman) ]
                ]
            ]
        , Html.section [ Html.Attributes.id "linkedin" ]
            [ Html.h2 [] [ Html.text "LinkedIn analytics" ]
            , Html.dl [ Html.Attributes.class "metrics" ]
                [ Html.dt []
                    [ Html.span [] [ Html.text (toString model.linkedin.followers) ]
                    , Html.text "followers"
                    ]
                , Html.dd [ Html.Attributes.class "up" ]
                    [ Html.text "100" ]
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
