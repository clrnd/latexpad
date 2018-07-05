module Main where

import Network.Wai.Handler.Warp (run)
import Servant
import Servant.Mock
import Data.Text (pack)
import Test.QuickCheck

import App
import Store

instance Arbitrary Snippet where
    arbitrary = Snippet . pack <$> arbitrary
instance Arbitrary SnippetId where
    arbitrary = SnippetId <$> arbitrary

main :: IO ()
main = run 8080 $ serve api (mock api Proxy)
