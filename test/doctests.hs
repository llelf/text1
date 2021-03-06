{-# LANGUAGE CPP #-}

module Main where

#if !(MIN_VERSION_base(4,8,0))
import Control.Applicative(Applicative((<*>), pure))
#endif
import Build_doctests (deps)
import Control.Monad
import Data.List
import System.Directory
import System.FilePath
import Test.DocTest

main ::
  IO ()
main =
  getSources >>= \sources -> doctest $
      "-isrc"
    : "-idist/build/autogen"
    : "-optP-include"
    : "-optPdist/build/autogen/cabal_macros.h"
    : "-hide-all-packages"
    : map ("-package="++) deps ++ sources

getSources :: IO [FilePath]
getSources = filter (isSuffixOf ".hs") <$> go "src"
  where
    go dir = do
      (dirs, files) <- getFilesAndDirectories dir
      (files ++) . concat <$> mapM go dirs

getFilesAndDirectories :: FilePath -> IO ([FilePath], [FilePath])
getFilesAndDirectories dir = do
  c <- map (dir </>) . filter (`notElem` ["..", "."]) <$> getDirectoryContents dir
  (,) <$> filterM doesDirectoryExist c <*> filterM doesFileExist c
