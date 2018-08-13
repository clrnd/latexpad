{-# OPTIONS_GHC -fno-warn-orphans #-}
module Main where

import Network.Wai.Handler.Warp (run)
import Servant
import Servant.Mock
import Data.Text (pack)
import Test.QuickCheck

import API
import Types

instance Arbitrary Snippet where
    arbitrary = Snippet . pack <$> arbitrary
instance Arbitrary SnippetId where
    arbitrary = SnippetId <$> arbitrary

mockApi :: Proxy SnippetAPI
mockApi = Proxy

main :: IO ()
main = run 8080 $ serve mockApi (mock mockApi Proxy)
