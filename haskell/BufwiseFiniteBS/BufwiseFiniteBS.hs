-- From https://discourse.haskell.org/t/counting-words-but-can-we-go-faster/4864

-- base
import Control.Monad (forM_, unless)
import Data.Char (isSpace)
import Data.Function (fix)
import Data.List (sortOn)
import Data.Ord (Down (..))
import System.IO (stdin)

-- bytestring
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C


import qualified Finite as H


main :: IO ()
main = do
  t <- H.new 128000
  let incr = H.count t
  flip fix B.empty $ \rec b -> do
    bs <- B.hGet stdin (64 * 1024)
    if B.null bs
      then do
        mapM_ incr (C.words b)
      else do
        let (initial, last) =
              B.spanEnd (not . isSpace)
                . mappend b
                . B.map toLower
                $ bs
        mapM_ incr (C.words initial)
        rec last
  xs <- H.toList t
  forM_ (sortOn (Down . snd) xs) $ \(w, i) -> do
    B.putStr w >> putStr " " >> print i
 where
  toLower a
    | a >= 65 && a <= 90 = a + 32
    | otherwise = a
  isSpace = (== 32)
