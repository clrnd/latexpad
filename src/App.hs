{-# LANGUAGE LambdaCase #-}
module App
  ( api
  , app
  ) where

import Data.Acid
import Data.ByteString.Char8 (unpack)
import Data.Text.Encoding (encodeUtf8)
import Control.Exception (bracket)
import Control.Monad.IO.Class
import Crypto.Hash
import Servant
import qualified Data.Map as Map

import API
import Store
import Types

server :: Server API
server = (save :<|> load) :<|> serveDirectoryFileServer "static"
  where
    save :: Snippet -> Handler SnippetId
    save (Snippet s) = do
        let bytes = encodeUtf8 s
        let hex = digestToHexByteString (hash bytes :: Digest MD5)
        let sid = SnippetId . unpack $ hex
        liftIO $ bracket
            (openLocalState $ SnippetDb Map.empty)
            closeAcidState
            (flip update . AddSnippet sid $ Snippet s)
        pure sid

    load :: String -> Handler Snippet
    load sid = do
        snip <- liftIO $ bracket
            (openLocalState $ SnippetDb Map.empty)
            closeAcidState
            (flip query . GetSnippet $ SnippetId sid)
        case snip of
            Nothing -> throwError err404
            Just c -> pure c

api :: Proxy API
api = Proxy

app :: Application
app = serve api server
