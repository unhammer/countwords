-- From https://discourse.haskell.org/t/counting-words-but-can-we-go-faster/4864

-- base
import Control.Monad (forM_)
import Data.List (sortOn)
import Data.Ord (Down (..))

-- bytestring
import qualified Data.ByteString as B
import qualified Data.ByteString.Char8 as C

-- unordered-containers
import qualified Data.HashMap.Strict as M

countWords :: B.ByteString -> [(B.ByteString, Int)]
countWords =
  sortOn (Down . snd)
    . count
    . C.words
    . B.map toLower
 where
  count =
    M.toList . M.fromListWith (+) . map (\x -> (x, 1))
  toLower a
    | a >= 65 && a <= 90 = a + 32
    | otherwise = a

main :: IO ()
main = do
  contents <- B.getContents
  forM_ (countWords contents) $ \(w, i) -> do
    B.putStr w >> putStr " " >> print i
