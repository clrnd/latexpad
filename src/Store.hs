{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Store
  ( GetSnippet(GetSnippet)
  , AddSnippet(AddSnippet)
  ) where

import GHC.Generics
import Control.Monad.Reader (ask)
import Control.Monad.State (modify)
import Data.Acid
import Data.SafeCopy (base, deriveSafeCopy)
import Data.Typeable
import qualified Data.Map as Map

import Types


addSnippet :: SnippetId -> Snippet -> Update SnippetDb ()
addSnippet (SnippetId id') snippet =
    modify $ \(SnippetDb db) -> SnippetDb $ Map.insert id' snippet db

getSnippet :: SnippetId -> Query SnippetDb (Maybe Snippet)
getSnippet (SnippetId id') =
    Map.lookup id' . allSnippets <$> ask

deriveSafeCopy 0 'base ''Snippet
deriveSafeCopy 0 'base ''SnippetId
deriveSafeCopy 0 'base ''SnippetDb
makeAcidic ''SnippetDb ['getSnippet, 'addSnippet]
