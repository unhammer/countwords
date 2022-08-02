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

-- vector-hashtable
import qualified Data.Vector.Hashtables as H

-- vector
import qualified Data.Vector.Mutable as VM
import qualified Data.Vector.Unboxed.Mutable as UM

type HashTable k v =
  H.Dictionary (H.PrimState IO) VM.MVector k UM.MVector v

main :: IO ()
main = do
  t <- H.initialize 10000 :: IO (HashTable B.ByteString Int)
  let incr = H.alter t (Just . maybe 1 (+ 1))
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
