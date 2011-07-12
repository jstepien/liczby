# Liczby

**Liczby** (IPA: ˈlʲid͡ʐbɨ) is a tiny tool which converts decimal numerals to
Polish words. It accepts a single number as the only command line argument and
returns a string on its standard output. It's written in Haskell.

TL;DR? Get [GHC](http://www.haskell.org/ghc/) and `make && ./liczby 123456789`.

We begin with importing the `getArgs` function, which will be necessary to read
the argument passed to the main function.

    module Main where
    import System.Environment (getArgs)

As specified in the first paragraph, the algorithm takes an `Integer` and
returns a `String`. The `makeWords` function calls an appropriate helper
function depending on the magnitude of the input.

    makeWords :: Integer -> String
    makeWords x | x < 20 && x >= 0  = makeLessThenTwenty x
                | x < 100           = makeTens x
                | x < 1000          = makeHundreds x
                | x < 1000000       = makeThousands x
                | x < 1000000000    = makeMillions x
                | x < 1000000000000 = makeMilliards x

Values lesser than twenty are hardcoded.

    makeLessThenTwenty x = case x of
      0 -> "zero"
      1 -> "jeden"
      2 -> "dwa"
      3 -> "trzy"
      4 -> "cztery"
      5 -> "pięć"
      6 -> "sześć"
      7 -> "siedem"
      8 -> "osiem"
      9 -> "dziewięć"
      10 -> "dziesięć"
      11 -> "jedenaście"
      12 -> "dwanaście"
      13 -> "trzynaście"
      14 -> "czternaście"
      15 -> "piętnaście"
      16 -> "szesnaście"
      17 -> "siedemnaście"
      18 -> "osiemnaście"
      19 -> "dziewiętnaście"

Numbers greater than 19 and lesser than 100 are divided into two parts: the
number of hundreds concatenated with the rest of the input. The concatenation is
performed by the `prefixedWith` function, which will be described shortly.

    makeTens x = (x `mod` 10) `prefixedWith` case x `div` 10 of
      2 -> "dwadzieścia"
      3 -> "trzydzieści"
      4 -> "czterdzieści"
      5 -> "pięćdziesiąt"
      6 -> "sześćdziesiąt"
      7 -> "siedemdziesiąt"
      8 -> "osiemdziesiąt"
      9 -> "dziewięćdziesiąt"

The conversion of remaining numbers lower than 1000 is analogous.

    makeHundreds x = (x `mod` 100) `prefixedWith` case x `div` 100 of
      1 -> "sto"
      2 -> "dwieście"
      3 -> "trzysta"
      4 -> "czterysta"
      5 -> "pięćset"
      6 -> "sześćset"
      7 -> "siedemset"
      8 -> "osiemset"
      9 -> "dziewięćset"

Now it's time for something more interesting. Numbers greater than 1000 may need
both singular and plural forms. Quite funnily, in Polish there are two forms of
plural. The rules are pretty simple.

    data Plural = Singular | FirstPlural | SecondPlural

    plural x | x == 1                        = Singular
             | x < 5                         = FirstPlural
             | x > 20 && x' `elem` [2, 3, 4] = FirstPlural
             | otherwise                     = SecondPlural
             where x' = x `mod` 10

Now we'll need a function which will use singular or plural appropriately. The
`makePlural` function takes as its arguments the base number, its singular and
plural forms and the number to be converted.

    makePlural n singular firstPlural secondPlural x =
      (x `mod` n) `prefixedWith` pluralize (plural x')
        where x' = x `div` n
              prefix = makeWords x'
              pluralize Singular     = singular
              pluralize FirstPlural  = prefix ++ " " ++ firstPlural
              pluralize SecondPlural = prefix ++ " " ++ secondPlural

By using `makePlural` we can easily implement conversion functions for numbers
greater than or equal to 1000.

    makeThousands = makePlural 1000       "tysiąc"  "tysiące"  "tysięcy"
    makeMillions  = makePlural 1000000    "milion"  "miliony"  "milionów"
    makeMilliards = makePlural 1000000000 "miliard" "miliardy" "miliardów"

The last necessary function is `prefixedWith`. It takes a number and a prefix
string and concatenates the prefix and the number if the number isn't equal to
zero.

    prefixedWith :: Integer -> String -> String
    prefixedWith rest prefix = if rest /= 0
                                then prefix ++ " " ++ makeWords rest
                                else prefix

Finally, the `main` function reads the first argument given in the command line,
converts it to an `Integer`, translates it to Polish and prints it.

    main = do x:_ <- getArgs
              putStrLn $ makeWords (read x :: Integer)

Simple, isn't it?

© 2011 Jan Stępień. Feel free to use the code under terms of the
[MIT license](http://www.opensource.org/licenses/mit-license.php).
