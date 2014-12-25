{-# LANGUAGE OverloadedStrings #-}
--------------------------------------------------------------------------------
import Hakyll

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "css/*" $ compile compressCssCompiler

    match ("js/*" .||. "images/*") $ do
        route   idRoute
        compile copyFileCompiler

    create ["site.css"] $ do
        route     idRoute
        compile $ bundleCss
            ["css/bootstrap.css", "css/theme.css", "css/sugar.css"]

    match "templates/*" $ compile templateCompiler

    match ("about.markdown" .||. "index.markdown") $ do
        route $ setExtension "html"        
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/panel.html"  defaultContext
            >>= loadAndApplyTemplate "templates/layout.html" defaultContext
            >>= relativizeUrls

--------------------------------------------------------------------------------
-- | Bundle css files to minimize HTTP requests.
bundleCss :: [Identifier] -> Compiler (Item String)
bundleCss ids = concatMap itemBody `fmap` mapM load ids >>= makeItem
