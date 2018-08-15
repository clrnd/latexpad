{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE QuasiQuotes #-}
module Main where

import NeatInterpolation
import Data.Aeson.Text (encodeToLazyText)
import Data.Swagger
import Servant.Swagger
import Data.Text (Text)
import qualified Data.Text.IO as T
import qualified Data.Text.Lazy as Lazy

import App
import Types

instance ToSchema Snippet
instance ToSchema SnippetId

jsonSwagger :: Lazy.Text
jsonSwagger = encodeToLazyText $ toSwagger api

render :: Text -> Text
render json = [text|
    <html>
    <head>
        <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@3.12.1/swagger-ui.css">
        <script src="https://unpkg.com/swagger-ui-dist@3/swagger-ui-standalone-preset.js"></script>
        <script src="https://unpkg.com/swagger-ui-dist@3/swagger-ui-bundle.js"></script>
    </head>
    <body>
        <div id="swagger-ui">
        </div>
        <script>
        const SPEC = ${json};
        const ui = SwaggerUIBundle({
            spec: SPEC,
            dom_id: '#swagger-ui',
            presets: [
                SwaggerUIBundle.presets.apis,
                SwaggerUIStandalonePreset
            ],
            layout: "StandaloneLayout"
        })
        </script>
    </body>
    </html>
|]

main :: IO ()
main = T.putStrLn . render . Lazy.toStrict $ jsonSwagger
