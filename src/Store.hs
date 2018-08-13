{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Store
  ( GetSnippet(GetSnippet)
  , AddSnippet(AddSnippet)
  ) where

import Control.Monad.Reader (ask)
import Control.Monad.State (modify)
import Data.Acid
import Data.SafeCopy (base, deriveSafeCopy)
import qualified Data.Map as Map

import Types


addSnippet :: SnippetId -> Snippet -> Update SnippetDb ()
addSnippet id' snippet =
    modify $ \(SnippetDb db) -> SnippetDb $ Map.insert id' snippet db

getSnippet :: SnippetId -> Query SnippetDb (Maybe Snippet)
getSnippet id' =
    Map.lookup id' . allSnippets <$> ask

deriveSafeCopy 0 'base ''Snippet
deriveSafeCopy 0 'base ''SnippetId
deriveSafeCopy 0 'base ''SnippetDb
makeAcidic ''SnippetDb ['getSnippet, 'addSnippet]
