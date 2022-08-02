-- https://discourse.haskell.org/t/counting-words-but-can-we-go-faster/4864/2

import qualified Streaming.ByteString.Char8 as BS8
import qualified Streaming.Prelude as P
import qualified Streaming as S
import Streaming (Stream, Of)
import Data.HashMap.Strict as Map (HashMap)
import qualified Data.HashMap.Strict as Map (alter, empty, toList)
import Data.ByteString (ByteString)
import Data.ByteString.Char8 (unpack)
import Data.List (sortOn)
import Data.Ord (Down(..))

fastLower :: Char -> Char
fastLower x | x >= 'A' && x <= 'Z' = toEnum (fromEnum x - (fromEnum 'A' - fromEnum 'a'))
            | otherwise = x

main :: IO ()
main = do
    let words :: Stream (Of ByteString) IO ()
        words = S.mapped BS8.toStrict $ BS8.words $ BS8.map fastLower  BS8.stdin
        update :: HashMap ByteString Word -> ByteString -> HashMap ByteString Word
        update m w = Map.alter (Just . maybe 1 (+1)) w m
    counts <- P.fold_ update Map.empty id words
    let sorted = sortOn (Down . snd) $ Map.toList counts
    let display (word,count) = putStrLn $ unpack word ++ " " ++ show count
    mapM_ display sorted
