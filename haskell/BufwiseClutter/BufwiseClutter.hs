-- From https://discourse.haskell.org/t/counting-words-but-can-we-go-faster/4864
-- and https://discourse.haskell.org/t/counting-words-but-can-we-go-faster/4864/13

-- base
import Control.Monad (forM_, unless)
import Data.Char (isSpace)
import Data.Function (fix)
import Data.List (sortOn)
import Data.Ord (Down (..))
import System.IO (stdin)

import Data.FastChar

-- text
import qualified Data.Text as T
import qualified Data.Text.IO as T

-- clutter
import qualified TextCounter as C

main :: IO ()
main = do
  t <- C.new 48000 16000
  let incr = C.count t
  flip fix T.empty $ \rec b -> do
    bs <- T.hGetChunk stdin -- (64 * 1024)
    if T.null bs
      then do
        mapM_ incr (T.words b)
      else do
        (initial, last) <-
              T.spanEndM (pure . not . isSpace)
                . mappend b
                . T.toLower
                $ bs
        mapM_ incr (T.words initial)
        rec last
  xs <- C.toList t
  forM_ (sortOn (Down . snd) xs) $ \(w, i) -> do
    T.putStr w >> putStr " " >> print i
 where
  isSpace = (== ' ')
