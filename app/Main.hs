module Main where

import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.RequestLogger (logStdoutDev)

import App

startApp :: Int -> IO ()
startApp port = run port (logStdoutDev app)

main :: IO ()
main = do
    let port = 8080
    putStrLn $ "Running in http://localhost:" ++ show port ++ "/"
    startApp port
