module Main where

import Data.Aeson.Encode.Pretty (encodePretty)
import Data.Swagger
import Servant.Swagger
import qualified Data.ByteString.Lazy.Char8 as BL8

import App
import Types

instance ToSchema Snippet
instance ToSchema SnippetId

main :: IO ()
main = BL8.putStrLn $ encodePretty $ toSwagger api
