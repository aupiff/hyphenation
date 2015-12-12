{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ >= 702
{-# LANGUAGE Trustworthy #-}
#endif
#if EMBED
{-# LANGUAGE TemplateHaskell #-}
#endif
-----------------------------------------------------------------------------
-- |
-- Module      :  Text.Hyphenation.Language
-- Copyright   :  (C) 2012-2015 Edward Kmett,
--                (C) 2007 Ned Batchelder
-- License     :  BSD-style (see the languageAffix LICENSE)
--
-- Maintainer  :  Edward Kmett <ekmett@gmail.com>
-- Stability   :  provisional
-- Portability :  portable
--
----------------------------------------------------------------------------
module Text.Hyphenation.Language
  (
  -- * Pattern file support
    Language(..)
  , languageHyphenator
  -- * Provided language hyphenators
  , afrikaans, basque, bengali, bulgarian, catalan, chinese
  , coptic, croatian, czech, danish, dutch, english_US, english_GB, esperanto
  , estonian, ethiopic, {- farsi, -} finnish, french, friulan, galician, georgian, german_1901, german_1996
  , german_Swiss, greek_Ancient, greek_Mono, greek_Poly, gujarati, hindi, hungarian
  , icelandic, indonesian, interlingua, irish, italian, kannada, kurmanji, lao, latin, latin_Classic
  , latvian, lithuanian, malayalam, marathi, mongolian, norwegian_Bokmal
  , norwegian_Nynorsk, oriya, panjabi, piedmontese, polish, portuguese, romanian, romansh
  , russian, sanskrit, serbian_Cyrillic, serbocroatian_Cyrillic
  , serbocroatian_Latin, slovak, slovenian, spanish, swedish, tamil
  , telugu, thai, turkish, turkmen, ukrainian, uppersorbian, welsh
  , loadHyphenator
  , languageAffix
  ) where

#if __GLASGOW_HASKELL__ < 710
import Data.Functor ((<$>))
#endif
import Data.Maybe (fromMaybe)
import qualified Data.IntMap as IM
import Text.Hyphenation.Hyphenator
import Text.Hyphenation.Pattern
import Text.Hyphenation.Exception
import System.IO.Unsafe
import Data.ByteString.Lazy.Char8 as Char8
import Data.ByteString.Lazy as Lazy

#if !EMBED
import Paths_hyphenation
#else
import Data.FileEmbed
import Control.Arrow (second)

hyphenatorFiles :: [(FilePath, Strict.ByteString)]
hyphenatorFiles = $(embedDir "data")
#endif

chrLine :: String -> [(Int, Char)]
chrLine (x:xs) = fmap (\y -> (fromEnum y, x)) xs
chrLine [] = []

-- | Read a built-in language file from the data directory where cabal installed this package.
--
-- (e.g. @hyphenateLanguage \"en-us\"@ opens @\"\/Users\/ekmett\/.cabal\/share\/hyphenation-0.2\/ghc-7.4.1\/hyph-en-us.hyp.txt\"@
-- among others when run on the author's local machine)
loadHyphenator :: String -> IO Hyphenator
loadHyphenator language = return $ Hyphenator tryLookup (parsePatterns pat) (parseExceptions hyp) defaultLeftMin defaultRightMin
  where hyp = enhyp
        pat = enpat
        chr = enchr
        chrMap = IM.fromList (Prelude.lines chr >>= chrLine)
        tryLookup x = fromMaybe x $ IM.lookup (fromEnum x) chrMap

-- | A strongly typed set of available languages you can use for hyphenation.
data Language
  = Afrikaans
  | Basque
  | Bengali
  | Bulgarian
  | Catalan
  | Chinese
  | Coptic
  | Croatian
  | Czech
  | Danish
  | Dutch
  | English_US | English_GB
  | Esperanto
  | Estonian
  | Ethiopic
  -- | Farsi
  | Finnish
  | French
  | Friulan
  | Galician
  | Georgian
  | German_1901 | German_1996 | German_Swiss
  | Greek_Ancient
  | Greek_Mono
  | Greek_Poly
  | Gujarati
  | Hindi
  | Hungarian
  | Icelandic
  | Indonesian
  | Interlingua
  | Irish
  | Italian
  | Kannada
  | Kurmanji
  | Lao
  | Latin
  | Latin_Classic
  | Latvian
  | Lithuanian
  | Malayalam
  | Marathi
  | Mongolian
  | Norwegian_Bokmal | Norwegian_Nynorsk
  | Oriya
  | Panjabi
  | Piedmontese
  | Polish
  | Portuguese
  | Romanian
  | Romansh
  | Russian
  | Sanskrit
  | Serbian_Cyrillic
  | Serbocroatian_Cyrillic | Serbocroatian_Latin
  | Slovak
  | Slovenian
  | Spanish
  | Swedish
  | Tamil
  | Telugu
  | Thai
  | Turkish
  | Turkmen
  | Ukrainian
  | Uppersorbian
  | Welsh
  deriving (Eq,Ord,Show,Bounded,Enum)


-- | the infix portion of the data file names used for this language
languageAffix :: Language -> String
languageAffix s = case s of
  Afrikaans -> "af"
  Basque -> "eu"
  Bengali -> "bn"
  Bulgarian -> "bg"
  Catalan -> "ca"
  Chinese -> "zh-latn-pinyin"
  Coptic -> "cop"
  Croatian -> "hr"
  Czech -> "cs"
  Danish -> "da"
  Dutch -> "nl"
  English_US -> "en-us"
  English_GB -> "en-gb"
  Esperanto -> "eo"
  Estonian -> "et"
  Ethiopic -> "mul-ethi"
  -- Farsi -> "fa"
  Finnish -> "fi"
  French -> "fr"
  Friulan -> "fur"
  Galician -> "gl"
  Georgian -> "ka"
  German_1901  -> "de-1901"
  German_1996  -> "de-1996"
  German_Swiss -> "de-ch-1901"
  Greek_Ancient -> "grc"
  Greek_Mono -> "el-monoton"
  Greek_Poly -> "el-polyton"
  Gujarati -> "gu"
  Hindi -> "hi"
  Hungarian -> "hu"
  Icelandic -> "is"
  Indonesian -> "id"
  Interlingua -> "ia"
  Irish -> "ga"
  Italian -> "it"
  Kannada -> "kn"
  Kurmanji -> "kmr"
  Lao -> "lo"
  Latin -> "la"
  Latin_Classic -> "la-x-classic"
  Latvian -> "lv"
  Lithuanian -> "lt"
  Malayalam -> "ml"
  Marathi -> "mr"
  Mongolian -> "mn-cyrl"
  Norwegian_Bokmal  -> "nb"
  Norwegian_Nynorsk -> "nn"
  Oriya -> "or"
  Panjabi -> "pa"
  Piedmontese -> "pms"
  Polish -> "pl"
  Portuguese -> "pt"
  Romanian -> "ro"
  Romansh -> "rm"
  Russian -> "ru"
  Sanskrit -> "sa"
  Serbian_Cyrillic -> "sr-cyrl"
  Serbocroatian_Cyrillic -> "sh-cyrl"
  Serbocroatian_Latin -> "sh-latn"
  Slovak -> "sk"
  Slovenian -> "sl"
  Spanish -> "es"
  Swedish -> "sv"
  Tamil -> "ta"
  Telugu -> "te"
  Thai -> "th"
  Turkish -> "tr"
  Turkmen -> "tk"
  Ukrainian -> "uk"
  Uppersorbian -> "hsb"
  Welsh -> "cy"


-- |
-- >>> hyphenate english_US "supercalifragilisticexpialadocious"
-- ["su","per","cal","ifrag","ilis","tic","ex","pi","al","ado","cious"]
--
-- favors US hyphenation
english_US :: Hyphenator

-- |
-- >>> hyphenate english_GB "supercalifragilisticexpialadocious"
-- ["su","per","cal","i","fra","gil","istic","ex","pi","alado","cious"]
--
-- favors UK hyphenation
english_GB :: Hyphenator

-- |
-- >>> hyphenate french "anticonstitutionnellement"
-- ["an","ti","cons","ti","tu","tion","nel","le","ment"]
french :: Hyphenator

-- |
-- >>> hyphenate icelandic "va\240lahei\240avegavinnuverkf\230rageymslusk\250r"
-- ["va\240la","hei\240a","vega","vinnu","verk","f\230ra","geymslu","sk\250r"]
icelandic :: Hyphenator

-- | Hyphenators for a wide array of languages.
afrikaans, basque, bengali, bulgarian, catalan, chinese,
 coptic, croatian, czech, danish, dutch, esperanto,
 estonian, ethiopic, {- farsi, -} finnish, friulan, galician, georgian, german_1901, german_1996,
 german_Swiss, greek_Ancient, greek_Mono, greek_Poly, gujarati, hindi, hungarian,
 indonesian, interlingua, irish, italian, kannada, kurmanji, lao, latin, latin_Classic,
 latvian, lithuanian, malayalam, marathi, mongolian, norwegian_Bokmal,
 norwegian_Nynorsk, oriya, panjabi, piedmontese, polish, portuguese, romanian,
 romansh, russian, sanskrit, serbian_Cyrillic, serbocroatian_Cyrillic,
 serbocroatian_Latin, slovak, slovenian, spanish, swedish, tamil,
 telugu, thai, turkish, turkmen, ukrainian, uppersorbian, welsh :: Hyphenator

afrikaans = unsafePerformIO (loadHyphenator (languageAffix Afrikaans))
basque = unsafePerformIO (loadHyphenator (languageAffix Basque))
bengali = unsafePerformIO (loadHyphenator (languageAffix Bengali))
bulgarian = unsafePerformIO (loadHyphenator (languageAffix Bulgarian))
catalan = unsafePerformIO (loadHyphenator (languageAffix Catalan))
chinese = unsafePerformIO (loadHyphenator (languageAffix Chinese))
coptic = unsafePerformIO (loadHyphenator (languageAffix Coptic))
croatian = unsafePerformIO (loadHyphenator (languageAffix Croatian))
czech = unsafePerformIO (loadHyphenator (languageAffix Czech))
danish = unsafePerformIO (loadHyphenator (languageAffix Danish))
dutch = unsafePerformIO (loadHyphenator (languageAffix Dutch))
english_US = unsafePerformIO (loadHyphenator (languageAffix English_US))
english_GB = unsafePerformIO (loadHyphenator (languageAffix English_GB))
esperanto = unsafePerformIO (loadHyphenator (languageAffix Esperanto))
estonian = unsafePerformIO (loadHyphenator (languageAffix Estonian))
ethiopic = unsafePerformIO (loadHyphenator (languageAffix Ethiopic))
-- farsi = unsafePerformIO (loadHyphenator (languageAffix Farsi))
finnish = unsafePerformIO (loadHyphenator (languageAffix Finnish))
french = unsafePerformIO (loadHyphenator (languageAffix French))
friulan = unsafePerformIO (loadHyphenator (languageAffix Friulan))
galician = unsafePerformIO (loadHyphenator (languageAffix Galician))
georgian = unsafePerformIO (loadHyphenator (languageAffix Georgian))
german_1901 = unsafePerformIO (loadHyphenator (languageAffix German_1901))
german_1996 = unsafePerformIO (loadHyphenator (languageAffix German_1996))
german_Swiss = unsafePerformIO (loadHyphenator (languageAffix German_Swiss))
greek_Ancient = unsafePerformIO (loadHyphenator (languageAffix Greek_Ancient))
greek_Mono = unsafePerformIO (loadHyphenator (languageAffix Greek_Mono))
greek_Poly = unsafePerformIO (loadHyphenator (languageAffix Greek_Poly))
gujarati = unsafePerformIO (loadHyphenator (languageAffix Gujarati))
hindi = unsafePerformIO (loadHyphenator (languageAffix Hindi))
hungarian = unsafePerformIO (loadHyphenator (languageAffix Hungarian))
icelandic = unsafePerformIO (loadHyphenator (languageAffix Icelandic))
indonesian = unsafePerformIO (loadHyphenator (languageAffix Indonesian))
interlingua = unsafePerformIO (loadHyphenator (languageAffix Interlingua))
irish = unsafePerformIO (loadHyphenator (languageAffix Irish))
italian = unsafePerformIO (loadHyphenator (languageAffix Italian))
kannada = unsafePerformIO (loadHyphenator (languageAffix Kannada))
kurmanji = unsafePerformIO (loadHyphenator (languageAffix Kurmanji))
lao = unsafePerformIO (loadHyphenator (languageAffix Lao))
latin = unsafePerformIO (loadHyphenator (languageAffix Latin))
latin_Classic = unsafePerformIO (loadHyphenator (languageAffix Latin_Classic))
latvian = unsafePerformIO (loadHyphenator (languageAffix Latvian))
lithuanian = unsafePerformIO (loadHyphenator (languageAffix Lithuanian))
malayalam = unsafePerformIO (loadHyphenator (languageAffix Malayalam))
marathi = unsafePerformIO (loadHyphenator (languageAffix Marathi))
mongolian = unsafePerformIO (loadHyphenator (languageAffix Mongolian))
norwegian_Bokmal = unsafePerformIO (loadHyphenator (languageAffix Norwegian_Bokmal))
norwegian_Nynorsk = unsafePerformIO (loadHyphenator (languageAffix Norwegian_Nynorsk))
oriya = unsafePerformIO (loadHyphenator (languageAffix Oriya))
panjabi = unsafePerformIO (loadHyphenator (languageAffix Panjabi))
piedmontese = unsafePerformIO (loadHyphenator (languageAffix Piedmontese))
polish = unsafePerformIO (loadHyphenator (languageAffix Polish))
portuguese = unsafePerformIO (loadHyphenator (languageAffix Portuguese))
romanian = unsafePerformIO (loadHyphenator (languageAffix Romanian))
romansh = unsafePerformIO (loadHyphenator (languageAffix Romansh))
russian = unsafePerformIO (loadHyphenator (languageAffix Russian))
sanskrit = unsafePerformIO (loadHyphenator (languageAffix Sanskrit))
serbian_Cyrillic = unsafePerformIO (loadHyphenator (languageAffix Serbian_Cyrillic))
serbocroatian_Cyrillic = unsafePerformIO (loadHyphenator (languageAffix Serbocroatian_Cyrillic))
serbocroatian_Latin = unsafePerformIO (loadHyphenator (languageAffix Serbocroatian_Latin))
slovak = unsafePerformIO (loadHyphenator (languageAffix Slovak))
slovenian = unsafePerformIO (loadHyphenator (languageAffix Slovenian))
spanish = unsafePerformIO (loadHyphenator (languageAffix Spanish))
swedish = unsafePerformIO (loadHyphenator (languageAffix Swedish))
tamil = unsafePerformIO (loadHyphenator (languageAffix Tamil))
telugu = unsafePerformIO (loadHyphenator (languageAffix Telugu))
thai = unsafePerformIO (loadHyphenator (languageAffix Thai))
turkish = unsafePerformIO (loadHyphenator (languageAffix Turkish))
turkmen = unsafePerformIO (loadHyphenator (languageAffix Turkmen))
ukrainian = unsafePerformIO (loadHyphenator (languageAffix Ukrainian))
uppersorbian = unsafePerformIO (loadHyphenator (languageAffix Uppersorbian))
welsh = unsafePerformIO (loadHyphenator (languageAffix Welsh))

-- | Load (and cache) the hyphenator for a given language.
languageHyphenator :: Language -> Hyphenator
languageHyphenator s = case s of
  Afrikaans -> afrikaans
  Basque -> basque
  Bengali -> bengali
  Bulgarian -> bulgarian
  Catalan -> catalan
  Chinese -> chinese
  Coptic -> coptic
  Croatian -> croatian
  Czech -> czech
  Danish -> danish
  Dutch -> dutch
  English_US -> english_US
  English_GB -> english_GB
  Esperanto -> esperanto
  Estonian -> estonian
  Ethiopic -> ethiopic
  -- Farsi -> farsi
  Finnish -> finnish
  French -> french
  Friulan -> friulan
  Galician -> galician
  Georgian -> georgian
  German_1901  -> german_1901
  German_1996  -> german_1996
  German_Swiss -> german_Swiss
  Greek_Ancient -> greek_Ancient
  Greek_Mono -> greek_Mono
  Greek_Poly -> greek_Poly
  Gujarati -> gujarati
  Hindi -> hindi
  Hungarian -> hungarian
  Icelandic -> icelandic
  Indonesian -> indonesian
  Interlingua -> interlingua
  Irish -> irish
  Italian -> italian
  Kannada -> kannada
  Kurmanji -> kurmanji
  Lao -> lao
  Latin -> latin
  Latin_Classic -> latin_Classic
  Latvian -> latvian
  Lithuanian -> lithuanian
  Malayalam -> malayalam
  Marathi -> marathi
  Mongolian -> mongolian
  Norwegian_Bokmal  -> norwegian_Bokmal
  Norwegian_Nynorsk -> norwegian_Nynorsk
  Oriya -> oriya
  Panjabi -> panjabi
  Piedmontese -> piedmontese
  Polish -> polish
  Portuguese -> portuguese
  Romanian -> romanian
  Romansh -> romansh
  Russian -> russian
  Sanskrit -> sanskrit
  Serbian_Cyrillic -> serbian_Cyrillic
  Serbocroatian_Cyrillic -> serbocroatian_Cyrillic
  Serbocroatian_Latin -> serbocroatian_Latin
  Slovak -> slovak
  Slovenian -> slovenian
  Spanish -> spanish
  Swedish -> swedish
  Tamil -> tamil
  Telugu -> telugu
  Thai -> thai
  Turkish -> turkish
  Turkmen -> turkmen
  Ukrainian -> ukrainian
  Uppersorbian -> uppersorbian
  Welsh -> welsh

enchr = "aA\nbB\ncC\ndD\neE\nfF\ngG\nhH\niI\njJ\nkK\nlL\nmM\nnN\noO\npP\nqQ\nrR\nsS\ntT\nuU\nvV\nwW\nxX\nyY\nzZ\n"
enhyp = "as-so-ciate\nas-so-ciates\ndec-li-na-tion\noblig-a-tory\nphil-an-thropic\npresent\npresents\nproject\nprojects\nreci-procity\nre-cog-ni-zance\nref-or-ma-tion\nret-ri-bu-tion\nta-ble"
enpat = ".ach4\n.ad4der\n.af1t\n.al3t\n.am5at\n.an5c\n.ang4\n.ani5m\n.ant4\n.an3te\n.anti5s\n.ar5s\n.ar4tie\n.ar4ty\n.as3c\n.as1p\n.as1s\n.aster5\n.atom5\n.au1d\n.av4i\n.awn4\n.ba4g\n.ba5\na\n.bas4e\n.ber4\n.be5ra\n.be3sm\n.be5sto\n.bri2\n.but4ti\n.cam4pe\n.can5c\n.capa5b\n.car5ol\n.ca4t\n.ce4la\n.ch4\n.chill5i\n.ci2\n.cit5r\n.co3e\n.co4r\n.cor5ner\n.de4moi\n.de3o\n.de3ra\n.de3ri\n.des4c\n.dictio5\n.do4t\n.du4c\n.dumb5\n.earth5\n.eas3i\n.eb4\n.eer4\n.eg2\n.el5d\n.el3em\n.enam3\n.en3g\n.en3s\n.eq5ui5t\n.er4ri\n.es3\n.eu3\n.eye5\n.fes3\n.for5mer\n.ga2\n.ge2\n.gen3t4\n.ge5og\n.gi5a\n.gi4b\n.go4r\n.hand5i\n.han5k\n.he2\n.hero5i\n.hes3\n.het3\n.hi3b\n.hi3er\n.hon5ey\n.hon3o\n.hov5\n.id4l\n.idol3\n.im3m\n.im5pin\n.in1\n.in3ci\n.ine2\n.in2k\n.in3s\n.ir5r\n.is4i\n.ju3r\n.la4cy\n.la4m\n.lat5er\n.lath5\n.le2\n.leg5e\n.len4\n.lep5\n.lev1\n.li4g\n.lig5a\n.li2n\n.li3o\n.li4t\n.mag5a5\n.mal5o\n.man5a\n.mar5ti\n.me2\n.mer3c\n.me5ter\n.mis1\n.mist5i\n.mon3e\n.mo3ro\n.mu5ta\n.muta5b\n.ni4c\n.od2\n.odd5\n.of5te\n.or5ato\n.or3c\n.or1d\n.or3t\n.os3\n.os4tl\n.oth3\n.out3\n.ped5al\n.pe5te\n.pe5tit\n.pi4e\n.pio5n\n.pi2t\n.pre3m\n.ra4c\n.ran4t\n.ratio5na\n.ree2\n.re5mit\n.res2\n.re5stat\n.ri4g\n.rit5u\n.ro4q\n.ros5t\n.row5d\n.ru4d\n.sci3e\n.self5\n.sell5\n.se2n\n.se5rie\n.sh2\n.si2\n.sing4\n.st4\n.sta5bl\n.sy2\n.ta4\n.te4\n.ten5an\n.th2\n.ti2\n.til4\n.tim5o5\n.ting4\n.tin5k\n.ton4a\n.to4p\n.top5i\n.tou5s\n.trib5ut\n.un1a\n.un3ce\n.under5\n.un1e\n.un5k\n.un5o\n.un3u\n.up3\n.ure3\n.us5a\n.ven4de\n.ve5ra\n.wil5i\n.ye4\n4ab.\na5bal\na5ban\nabe2\nab5erd\nabi5a\nab5it5ab\nab5lat\nab5o5liz\n4abr\nab5rog\nab3ul\na4car\nac5ard\nac5aro\na5ceou\nac1er\na5chet\n4a2ci\na3cie\nac1in\na3cio\nac5rob\nact5if\nac3ul\nac4um\na2d\nad4din\nad5er.\n2adi\na3dia\nad3ica\nadi4er\na3dio\na3dit\na5diu\nad4le\nad3ow\nad5ran\nad4su\n4adu\na3duc\nad5um\nae4r\naeri4e\na2f\naff4\na4gab\naga4n\nag5ell\nage4o\n4ageu\nag1i\n4ag4l\nag1n\na2go\n3agog\nag3oni\na5guer\nag5ul\na4gy\na3ha\na3he\nah4l\na3ho\nai2\na5ia\na3ic.\nai5ly\na4i4n\nain5in\nain5o\nait5en\na1j\nak1en\nal5ab\nal3ad\na4lar\n4aldi\n2ale\nal3end\na4lenti\na5le5o\nal1i\nal4ia.\nali4e\nal5lev\n4allic\n4alm\na5log.\na4ly.\n4alys\n5a5lyst\n5alyt\n3alyz\n4ama\nam5ab\nam3ag\nama5ra\nam5asc\na4matis\na4m5ato\nam5era\nam3ic\nam5if\nam5ily\nam1in\nami4no\na2mo\na5mon\namor5i\namp5en\na2n\nan3age\n3analy\na3nar\nan3arc\nanar4i\na3nati\n4and\nande4s\nan3dis\nan1dl\nan4dow\na5nee\na3nen\nan5est.\na3neu\n2ang\nang5ie\nan1gl\na4n1ic\na3nies\nan3i3f\nan4ime\na5nimi\na5nine\nan3io\na3nip\nan3ish\nan3it\na3niu\nan4kli\n5anniz\nano4\nan5ot\nanoth5\nan2sa\nan4sco\nan4sn\nan2sp\nans3po\nan4st\nan4sur\nantal4\nan4tie\n4anto\nan2tr\nan4tw\nan3ua\nan3ul\na5nur\n4ao\napar4\nap5at\nap5ero\na3pher\n4aphi\na4pilla\nap5illar\nap3in\nap3ita\na3pitu\na2pl\napoc5\nap5ola\napor5i\napos3t\naps5es\na3pu\naque5\n2a2r\nar3act\na5rade\nar5adis\nar3al\na5ramete\naran4g\nara3p\nar4at\na5ratio\nar5ativ\na5rau\nar5av4\naraw4\narbal4\nar4chan\nar5dine\nar4dr\nar5eas\na3ree\nar3ent\na5ress\nar4fi\nar4fl\nar1i\nar5ial\nar3ian\na3riet\nar4im\nar5inat\nar3io\nar2iz\nar2mi\nar5o5d\na5roni\na3roo\nar2p\nar3q\narre4\nar4sa\nar2sh\n4as.\nas4ab\nas3ant\nashi4\na5sia.\na3sib\na3sic\n5a5si4t\nask3i\nas4l\na4soc\nas5ph\nas4sh\nas3ten\nas1tr\nasur5a\na2ta\nat3abl\nat5ac\nat3alo\nat5ap\nate5c\nat5ech\nat3ego\nat3en.\nat3era\nater5n\na5terna\nat3est\nat5ev\n4ath\nath5em\na5then\nat4ho\nath5om\n4ati.\na5tia\nat5i5b\nat1ic\nat3if\nation5ar\nat3itu\na4tog\na2tom\nat5omiz\na4top\na4tos\na1tr\nat5rop\nat4sk\nat4tag\nat5te\nat4th\na2tu\nat5ua\nat5ue\nat3ul\nat3ura\na2ty\nau4b\naugh3\nau3gu\nau4l2\naun5d\nau3r\nau5sib\naut5en\nau1th\na2va\nav3ag\na5van\nave4no\nav3era\nav5ern\nav5ery\nav1i\navi4er\nav3ig\nav5oc\na1vor\n3away\naw3i\naw4ly\naws4\nax4ic\nax4id\nay5al\naye4\nays4\nazi4er\nazz5i\n5ba.\nbad5ger\nba4ge\nbal1a\nban5dag\nban4e\nban3i\nbarbi5\nbari4a\nbas4si\n1bat\nba4z\n2b1b\nb2be\nb3ber\nbbi4na\n4b1d\n4be.\nbeak4\nbeat3\n4be2d\nbe3da\nbe3de\nbe3di\nbe3gi\nbe5gu\n1bel\nbe1li\nbe3lo\n4be5m\nbe5nig\nbe5nu\n4bes4\nbe3sp\nbe5str\n3bet\nbet5iz\nbe5tr\nbe3tw\nbe3w\nbe5yo\n2bf\n4b3h\nbi2b\nbi4d\n3bie\nbi5en\nbi4er\n2b3if\n1bil\nbi3liz\nbina5r4\nbin4d\nbi5net\nbi3ogr\nbi5ou\nbi2t\n3bi3tio\nbi3tr\n3bit5ua\nb5itz\nb1j\nbk4\nb2l2\nblath5\nb4le.\nblen4\n5blesp\nb3lis\nb4lo\nblun4t\n4b1m\n4b3n\nbne5g\n3bod\nbod3i\nbo4e\nbol3ic\nbom4bi\nbon4a\nbon5at\n3boo\n5bor.\n4b1ora\nbor5d\n5bore\n5bori\n5bos4\nb5ota\nboth5\nbo4to\nbound3\n4bp\n4brit\nbroth3\n2b5s2\nbsor4\n2bt\nbt4l\nb4to\nb3tr\nbuf4fer\nbu4ga\nbu3li\nbumi4\nbu4n\nbunt4i\nbu3re\nbus5ie\nbuss4e\n5bust\n4buta\n3butio\nb5uto\nb1v\n4b5w\n5by.\nbys4\n1ca\ncab3in\nca1bl\ncach4\nca5den\n4cag4\n2c5ah\nca3lat\ncal4la\ncall5in\n4calo\ncan5d\ncan4e\ncan4ic\ncan5is\ncan3iz\ncan4ty\ncany4\nca5per\ncar5om\ncast5er\ncas5tig\n4casy\nca4th\n4cativ\ncav5al\nc3c\nccha5\ncci4a\nccompa5\nccon4\nccou3t\n2ce.\n4ced.\n4ceden\n3cei\n5cel.\n3cell\n1cen\n3cenc\n2cen4e\n4ceni\n3cent\n3cep\nce5ram\n4cesa\n3cessi\nces5si5b\nces5t\ncet4\nc5e4ta\ncew4\n2ch\n4ch.\n4ch3ab\n5chanic\nch5a5nis\nche2\ncheap3\n4ched\nche5lo\n3chemi\nch5ene\nch3er.\nch3ers\n4ch1in\n5chine.\nch5iness\n5chini\n5chio\n3chit\nchi2z\n3cho2\nch4ti\n1ci\n3cia\nci2a5b\ncia5r\nci5c\n4cier\n5cific.\n4cii\nci4la\n3cili\n2cim\n2cin\nc4ina\n3cinat\ncin3em\nc1ing\nc5ing.\n5cino\ncion4\n4cipe\nci3ph\n4cipic\n4cista\n4cisti\n2c1it\ncit3iz\n5ciz\nck1\nck3i\n1c4l4\n4clar\nc5laratio\n5clare\ncle4m\n4clic\nclim4\ncly4\nc5n\n1co\nco5ag\ncoe2\n2cog\nco4gr\ncoi4\nco3inc\ncol5i\n5colo\ncol3or\ncom5er\ncon4a\nc4one\ncon3g\ncon5t\nco3pa\ncop3ic\nco4pl\n4corb\ncoro3n\ncos4e\ncov1\ncove4\ncow5a\ncoz5e\nco5zi\nc1q\ncras5t\n5crat.\n5cratic\ncre3at\n5cred\n4c3reta\ncre4v\ncri2\ncri5f\nc4rin\ncris4\n5criti\ncro4pl\ncrop5o\ncros4e\ncru4d\n4c3s2\n2c1t\ncta4b\nct5ang\nc5tant\nc2te\nc3ter\nc4ticu\nctim3i\nctu4r\nc4tw\ncud5\nc4uf\nc4ui\ncu5ity\n5culi\ncul4tis\n3cultu\ncu2ma\nc3ume\ncu4mi\n3cun\ncu3pi\ncu5py\ncur5a4b\ncu5ria\n1cus\ncuss4i\n3c4ut\ncu4tie\n4c5utiv\n4cutr\n1cy\ncze4\n1d2a\n5da.\n2d3a4b\ndach4\n4daf\n2dag\nda2m2\ndan3g\ndard5\ndark5\n4dary\n3dat\n4dativ\n4dato\n5dav4\ndav5e\n5day\nd1b\nd5c\nd1d4\n2de.\ndeaf5\ndeb5it\nde4bon\ndecan4\nde4cil\nde5com\n2d1ed\n4dee.\nde5if\ndeli4e\ndel5i5q\nde5lo\nd4em\n5dem.\n3demic\ndem5ic.\nde5mil\nde4mons\ndemor5\n1den\nde4nar\nde3no\ndenti5f\nde3nu\nde1p\nde3pa\ndepi4\nde2pu\nd3eq\nd4erh\n5derm\ndern5iz\nder5s\ndes2\nd2es.\nde1sc\nde2s5o\ndes3ti\nde3str\nde4su\nde1t\nde2to\nde1v\ndev3il\n4dey\n4d1f\nd4ga\nd3ge4t\ndg1i\nd2gy\nd1h2\n5di.\n1d4i3a\ndia5b\ndi4cam\nd4ice\n3dict\n3did\n5di3en\nd1if\ndi3ge\ndi4lato\nd1in\n1dina\n3dine.\n5dini\ndi5niz\n1dio\ndio5g\ndi4pl\ndir2\ndi1re\ndirt5i\ndis1\n5disi\nd4is3t\nd2iti\n1di1v\nd1j\nd5k2\n4d5la\n3dle.\n3dled\n3dles.\n4dless\n2d3lo\n4d5lu\n2dly\nd1m\n4d1n4\n1do\n3do.\ndo5de\n5doe\n2d5of\nd4og\ndo4la\ndoli4\ndo5lor\ndom5iz\ndo3nat\ndoni4\ndoo3d\ndop4p\nd4or\n3dos\n4d5out\ndo4v\n3dox\nd1p\n1dr\ndrag5on\n4drai\ndre4\ndrea5r\n5dren\ndri4b\ndril4\ndro4p\n4drow\n5drupli\n4dry\n2d1s2\nds4p\nd4sw\nd4sy\nd2th\n1du\nd1u1a\ndu2c\nd1uca\nduc5er\n4duct.\n4ducts\ndu5el\ndu4g\nd3ule\ndum4be\ndu4n\n4dup\ndu4pe\nd1v\nd1w\nd2y\n5dyn\ndy4se\ndys5p\ne1a4b\ne3act\nead1\nead5ie\nea4ge\nea5ger\nea4l\neal5er\neal3ou\neam3er\ne5and\near3a\near4c\near5es\near4ic\near4il\near5k\near2t\neart3e\nea5sp\ne3ass\neast3\nea2t\neat5en\neath3i\ne5atif\ne4a3tu\nea2v\neav3en\neav5i\neav5o\n2e1b\ne4bel.\ne4bels\ne4ben\ne4bit\ne3br\ne4cad\necan5c\necca5\ne1ce\nec5essa\nec2i\ne4cib\nec5ificat\nec5ifie\nec5ify\nec3im\neci4t\ne5cite\ne4clam\ne4clus\ne2col\ne4comm\ne4compe\ne4conc\ne2cor\nec3ora\neco5ro\ne1cr\ne4crem\nec4tan\nec4te\ne1cu\ne4cul\nec3ula\n2e2da\n4ed3d\ne4d1er\nede4s\n4edi\ne3dia\ned3ib\ned3ica\ned3im\ned1it\nedi5z\n4edo\ne4dol\nedon2\ne4dri\ne4dul\ned5ulo\nee2c\need3i\nee2f\neel3i\nee4ly\nee2m\nee4na\nee4p1\nee2s4\neest4\nee4ty\ne5ex\ne1f\ne4f3ere\n1eff\ne4fic\n5efici\nefil4\ne3fine\nef5i5nite\n3efit\nefor5es\ne4fuse.\n4egal\neger4\neg5ib\neg4ic\neg5ing\ne5git5\neg5n\ne4go.\ne4gos\neg1ul\ne5gur\n5egy\ne1h4\neher4\nei2\ne5ic\nei5d\neig2\nei5gl\ne3imb\ne3inf\ne1ing\ne5inst\neir4d\neit3e\nei3th\ne5ity\ne1j\ne4jud\nej5udi\neki4n\nek4la\ne1la\ne4la.\ne4lac\nelan4d\nel5ativ\ne4law\nelaxa4\ne3lea\nel5ebra\n5elec\ne4led\nel3ega\ne5len\ne4l1er\ne1les\nel2f\nel2i\ne3libe\ne4l5ic.\nel3ica\ne3lier\nel5igib\ne5lim\ne4l3ing\ne3lio\ne2lis\nel5ish\ne3liv3\n4ella\nel4lab\nello4\ne5loc\nel5og\nel3op.\nel2sh\nel4ta\ne5lud\nel5ug\ne4mac\ne4mag\ne5man\nem5ana\nem5b\ne1me\ne2mel\ne4met\nem3ica\nemi4e\nem5igra\nem1in2\nem5ine\nem3i3ni\ne4mis\nem5ish\ne5miss\nem3iz\n5emniz\nemo4g\nemoni5o\nem3pi\ne4mul\nem5ula\nemu3n\ne3my\nen5amo\ne4nant\nench4er\nen3dic\ne5nea\ne5nee\nen3em\nen5ero\nen5esi\nen5est\nen3etr\ne3new\nen5ics\ne5nie\ne5nil\ne3nio\nen3ish\nen3it\ne5niu\n5eniz\n4enn\n4eno\neno4g\ne4nos\nen3ov\nen4sw\nent5age\n4enthes\nen3ua\nen5uf\ne3ny.\n4en3z\ne5of\neo2g\ne4oi4\ne3ol\neop3ar\ne1or\neo3re\neo5rol\neos4\ne4ot\neo4to\ne5out\ne5ow\ne2pa\ne3pai\nep5anc\ne5pel\ne3pent\nep5etitio\nephe4\ne4pli\ne1po\ne4prec\nep5reca\ne4pred\nep3reh\ne3pro\ne4prob\nep4sh\nep5ti5b\ne4put\nep5uta\ne1q\nequi3l\ne4q3ui3s\ner1a\nera4b\n4erand\ner3ar\n4erati.\n2erb\ner4bl\ner3ch\ner4che\n2ere.\ne3real\nere5co\nere3in\ner5el.\ner3emo\ner5ena\ner5ence\n4erene\ner3ent\nere4q\ner5ess\ner3est\neret4\ner1h\ner1i\ne1ria4\n5erick\ne3rien\neri4er\ner3ine\ne1rio\n4erit\ner4iu\neri4v\ne4riva\ner3m4\ner4nis\n4ernit\n5erniz\ner3no\n2ero\ner5ob\ne5roc\nero4r\ner1ou\ner1s\ner3set\nert3er\n4ertl\ner3tw\n4eru\neru4t\n5erwau\ne1s4a\ne4sage.\ne4sages\nes2c\ne2sca\nes5can\ne3scr\nes5cu\ne1s2e\ne2sec\nes5ecr\nes5enc\ne4sert.\ne4serts\ne4serva\n4esh\ne3sha\nesh5en\ne1si\ne2sic\ne2sid\nes5iden\nes5igna\ne2s5im\nes4i4n\nesis4te\nesi4u\ne5skin\nes4mi\ne2sol\nes3olu\ne2son\nes5ona\ne1sp\nes3per\nes5pira\nes4pre\n2ess\nes4si4b\nestan4\nes3tig\nes5tim\n4es2to\ne3ston\n2estr\ne5stro\nestruc5\ne2sur\nes5urr\nes4w\neta4b\neten4d\ne3teo\nethod3\net1ic\ne5tide\netin4\neti4no\ne5tir\ne5titio\net5itiv\n4etn\net5ona\ne3tra\ne3tre\net3ric\net5rif\net3rog\net5ros\net3ua\net5ym\net5z\n4eu\ne5un\ne3up\neu3ro\neus4\neute4\neuti5l\neu5tr\neva2p5\ne2vas\nev5ast\ne5vea\nev3ell\nevel3o\ne5veng\neven4i\nev1er\ne5verb\ne1vi\nev3id\nevi4l\ne4vin\nevi4v\ne5voc\ne5vu\ne1wa\ne4wag\ne5wee\ne3wh\newil5\new3ing\ne3wit\n1exp\n5eyc\n5eye.\neys4\n1fa\nfa3bl\nfab3r\nfa4ce\n4fag\nfain4\nfall5e\n4fa4ma\nfam5is\n5far\nfar5th\nfa3ta\nfa3the\n4fato\nfault5\n4f5b\n4fd\n4fe.\nfeas4\nfeath3\nfe4b\n4feca\n5fect\n2fed\nfe3li\nfe4mo\nfen2d\nfend5e\nfer1\n5ferr\nfev4\n4f1f\nf4fes\nf4fie\nf5fin.\nf2f5is\nf4fly\nf2fy\n4fh\n1fi\nfi3a\n2f3ic.\n4f3ical\nf3ican\n4ficate\nf3icen\nfi3cer\nfic4i\n5ficia\n5ficie\n4fics\nfi3cu\nfi5del\nfight5\nfil5i\nfill5in\n4fily\n2fin\n5fina\nfin2d5\nfi2ne\nf1in3g\nfin4n\nfis4ti\nf4l2\nf5less\nflin4\nflo3re\nf2ly5\n4fm\n4fn\n1fo\n5fon\nfon4de\nfon4t\nfo2r\nfo5rat\nfor5ay\nfore5t\nfor4i\nfort5a\nfos5\n4f5p\nfra4t\nf5rea\nfres5c\nfri2\nfril4\nfrol5\n2f3s\n2ft\nf4to\nf2ty\n3fu\nfu5el\n4fug\nfu4min\nfu5ne\nfu3ri\nfusi4\nfus4s\n4futa\n1fy\n1ga\ngaf4\n5gal.\n3gali\nga3lo\n2gam\nga5met\ng5amo\ngan5is\nga3niz\ngani5za\n4gano\ngar5n4\ngass4\ngath3\n4gativ\n4gaz\ng3b\ngd4\n2ge.\n2ged\ngeez4\ngel4in\nge5lis\nge5liz\n4gely\n1gen\nge4nat\nge5niz\n4geno\n4geny\n1geo\nge3om\ng4ery\n5gesi\ngeth5\n4geto\nge4ty\nge4v\n4g1g2\ng2ge\ng3ger\ngglu5\nggo4\ngh3in\ngh5out\ngh4to\n5gi.\n1gi4a\ngia5r\ng1ic\n5gicia\ng4ico\ngien5\n5gies.\ngil4\ng3imen\n3g4in.\ngin5ge\n5g4ins\n5gio\n3gir\ngir4l\ng3isl\ngi4u\n5giv\n3giz\ngl2\ngla4\nglad5i\n5glas\n1gle\ngli4b\ng3lig\n3glo\nglo3r\ng1m\ng4my\ngn4a\ng4na.\ngnet4t\ng1ni\ng2nin\ng4nio\ng1no\ng4non\n1go\n3go.\ngob5\n5goe\n3g4o4g\ngo3is\ngon2\n4g3o3na\ngondo5\ngo3ni\n5goo\ngo5riz\ngor5ou\n5gos.\ngov1\ng3p\n1gr\n4grada\ng4rai\ngran2\n5graph.\ng5rapher\n5graphic\n4graphy\n4gray\ngre4n\n4gress.\n4grit\ng4ro\ngruf4\ngs2\ng5ste\ngth3\ngu4a\n3guard\n2gue\n5gui5t\n3gun\n3gus\n4gu4t\ng3w\n1gy\n2g5y3n\ngy5ra\nh3ab4l\nhach4\nhae4m\nhae4t\nh5agu\nha3la\nhala3m\nha4m\nhan4ci\nhan4cy\n5hand.\nhan4g\nhang5er\nhang5o\nh5a5niz\nhan4k\nhan4te\nhap3l\nhap5t\nha3ran\nha5ras\nhar2d\nhard3e\nhar4le\nharp5en\nhar5ter\nhas5s\nhaun4\n5haz\nhaz3a\nh1b\n1head\n3hear\nhe4can\nh5ecat\nh4ed\nhe5do5\nhe3l4i\nhel4lis\nhel4ly\nh5elo\nhem4p\nhe2n\nhena4\nhen5at\nheo5r\nhep5\nh4era\nhera3p\nher4ba\nhere5a\nh3ern\nh5erou\nh3ery\nh1es\nhe2s5p\nhe4t\nhet4ed\nheu4\nh1f\nh1h\nhi5an\nhi4co\nhigh5\nh4il2\nhimer4\nh4ina\nhion4e\nhi4p\nhir4l\nhi3ro\nhir4p\nhir4r\nhis3el\nhis4s\nhith5er\nhi2v\n4hk\n4h1l4\nhlan4\nh2lo\nhlo3ri\n4h1m\nhmet4\n2h1n\nh5odiz\nh5ods\nho4g\nhoge4\nhol5ar\n3hol4e\nho4ma\nhome3\nhon4a\nho5ny\n3hood\nhoon4\nhor5at\nho5ris\nhort3e\nho5ru\nhos4e\nho5sen\nhos1p\n1hous\nhouse3\nhov5el\n4h5p\n4hr4\nhree5\nhro5niz\nhro3po\n4h1s2\nh4sh\nh4tar\nht1en\nht5es\nh4ty\nhu4g\nhu4min\nhun5ke\nhun4t\nhus3t4\nhu4t\nh1w\nh4wart\nhy3pe\nhy3ph\nhy2s\n2i1a\ni2al\niam4\niam5ete\ni2an\n4ianc\nian3i\n4ian4t\nia5pe\niass4\ni4ativ\nia4tric\ni4atu\nibe4\nib3era\nib5ert\nib5ia\nib3in\nib5it.\nib5ite\ni1bl\nib3li\ni5bo\ni1br\ni2b5ri\ni5bun\n4icam\n5icap\n4icar\ni4car.\ni4cara\nicas5\ni4cay\niccu4\n4iceo\n4ich\n2ici\ni5cid\nic5ina\ni2cip\nic3ipa\ni4cly\ni2c5oc\n4i1cr\n5icra\ni4cry\nic4te\nictu2\nic4t3ua\nic3ula\nic4um\nic5uo\ni3cur\n2id\ni4dai\nid5anc\nid5d\nide3al\nide4s\ni2di\nid5ian\nidi4ar\ni5die\nid3io\nidi5ou\nid1it\nid5iu\ni3dle\ni4dom\nid3ow\ni4dr\ni2du\nid5uo\n2ie4\nied4e\n5ie5ga\nield3\nien5a4\nien4e\ni5enn\ni3enti\ni1er.\ni3esc\ni1est\ni3et\n4if.\nif5ero\niff5en\nif4fr\n4ific.\ni3fie\ni3fl\n4ift\n2ig\niga5b\nig3era\night3i\n4igi\ni3gib\nig3il\nig3in\nig3it\ni4g4l\ni2go\nig3or\nig5ot\ni5gre\nigu5i\nig1ur\ni3h\n4i5i4\ni3j\n4ik\ni1la\nil3a4b\ni4lade\ni2l5am\nila5ra\ni3leg\nil1er\nilev4\nil5f\nil1i\nil3ia\nil2ib\nil3io\nil4ist\n2ilit\nil2iz\nill5ab\n4iln\nil3oq\nil4ty\nil5ur\nil3v\ni4mag\nim3age\nima5ry\nimenta5r\n4imet\nim1i\nim5ida\nimi5le\ni5mini\n4imit\nim4ni\ni3mon\ni2mu\nim3ula\n2in.\ni4n3au\n4inav\nincel4\nin3cer\n4ind\nin5dling\n2ine\ni3nee\niner4ar\ni5ness\n4inga\n4inge\nin5gen\n4ingi\nin5gling\n4ingo\n4ingu\n2ini\ni5ni.\ni4nia\nin3io\nin1is\ni5nite.\n5initio\nin3ity\n4ink\n4inl\n2inn\n2i1no\ni4no4c\nino4s\ni4not\n2ins\nin3se\ninsur5a\n2int.\n2in4th\nin1u\ni5nus\n4iny\n2io\n4io.\nioge4\nio2gr\ni1ol\nio4m\nion3at\nion4ery\nion3i\nio5ph\nior3i\ni4os\nio5th\ni5oti\nio4to\ni4our\n2ip\nipe4\niphras4\nip3i\nip4ic\nip4re4\nip3ul\ni3qua\niq5uef\niq3uid\niq3ui3t\n4ir\ni1ra\nira4b\ni4rac\nird5e\nire4de\ni4ref\ni4rel4\ni4res\nir5gi\nir1i\niri5de\nir4is\niri3tu\n5i5r2iz\nir4min\niro4g\n5iron.\nir5ul\n2is.\nis5ag\nis3ar\nisas5\n2is1c\nis3ch\n4ise\nis3er\n3isf\nis5han\nis3hon\nish5op\nis3ib\nisi4d\ni5sis\nis5itiv\n4is4k\nislan4\n4isms\ni2so\niso5mer\nis1p\nis2pi\nis4py\n4is1s\nis4sal\nissen4\nis4ses\nis4ta.\nis1te\nis1ti\nist4ly\n4istral\ni2su\nis5us\n4ita.\nita4bi\ni4tag\n4ita5m\ni3tan\ni3tat\n2ite\nit3era\ni5teri\nit4es\n2ith\ni1ti\n4itia\n4i2tic\nit3ica\n5i5tick\nit3ig\nit5ill\ni2tim\n2itio\n4itis\ni4tism\ni2t5o5m\n4iton\ni4tram\nit5ry\n4itt\nit3uat\ni5tud\nit3ul\n4itz.\ni1u\n2iv\niv3ell\niv3en.\ni4v3er.\ni4vers.\niv5il.\niv5io\niv1it\ni5vore\niv3o3ro\ni4v3ot\n4i5w\nix4o\n4iy\n4izar\nizi4\n5izont\n5ja\njac4q\nja4p\n1je\njer5s\n4jestie\n4jesty\njew3\njo4p\n5judg\n3ka.\nk3ab\nk5ag\nkais4\nkal4\nk1b\nk2ed\n1kee\nke4g\nke5li\nk3en4d\nk1er\nkes4\nk3est.\nke4ty\nk3f\nkh4\nk1i\n5ki.\n5k2ic\nk4ill\nkilo5\nk4im\nk4in.\nkin4de\nk5iness\nkin4g\nki4p\nkis4\nk5ish\nkk4\nk1l\n4kley\n4kly\nk1m\nk5nes\n1k2no\nko5r\nkosh4\nk3ou\nkro5n\n4k1s2\nk4sc\nks4l\nk4sy\nk5t\nk1w\nlab3ic\nl4abo\nlaci4\nl4ade\nla3dy\nlag4n\nlam3o\n3land\nlan4dl\nlan5et\nlan4te\nlar4g\nlar3i\nlas4e\nla5tan\n4lateli\n4lativ\n4lav\nla4v4a\n2l1b\nlbin4\n4l1c2\nlce4\nl3ci\n2ld\nl2de\nld4ere\nld4eri\nldi4\nld5is\nl3dr\nl4dri\nle2a\nle4bi\nleft5\n5leg.\n5legg\nle4mat\nlem5atic\n4len.\n3lenc\n5lene.\n1lent\nle3ph\nle4pr\nlera5b\nler4e\n3lerg\n3l4eri\nl4ero\nles2\nle5sco\n5lesq\n3less\n5less.\nl3eva\nlev4er.\nlev4era\nlev4ers\n3ley\n4leye\n2lf\nl5fr\n4l1g4\nl5ga\nlgar3\nl4ges\nlgo3\n2l3h\nli4ag\nli2am\nliar5iz\nli4as\nli4ato\nli5bi\n5licio\nli4cor\n4lics\n4lict.\nl4icu\nl3icy\nl3ida\nlid5er\n3lidi\nlif3er\nl4iff\nli4fl\n5ligate\n3ligh\nli4gra\n3lik\n4l4i4l\nlim4bl\nlim3i\nli4mo\nl4im4p\nl4ina\n1l4ine\nlin3ea\nlin3i\nlink5er\nli5og\n4l4iq\nlis4p\nl1it\nl2it.\n5litica\nl5i5tics\nliv3er\nl1iz\n4lj\nlka3\nl3kal\nlka4t\nl1l\nl4law\nl2le\nl5lea\nl3lec\nl3leg\nl3lel\nl3le4n\nl3le4t\nll2i\nl2lin4\nl5lina\nll4o\nlloqui5\nll5out\nl5low\n2lm\nl5met\nlm3ing\nl4mod\nlmon4\n2l1n2\n3lo.\nlob5al\nlo4ci\n4lof\n3logic\nl5ogo\n3logu\nlom3er\n5long\nlon4i\nl3o3niz\nlood5\n5lope.\nlop3i\nl3opm\nlora4\nlo4rato\nlo5rie\nlor5ou\n5los.\nlos5et\n5losophiz\n5losophy\nlos4t\nlo4ta\nloun5d\n2lout\n4lov\n2lp\nlpa5b\nl3pha\nl5phi\nlp5ing\nl3pit\nl4pl\nl5pr\n4l1r\n2l1s2\nl4sc\nl2se\nl4sie\n4lt\nlt5ag\nltane5\nl1te\nlten4\nltera4\nlth3i\nl5ties.\nltis4\nl1tr\nltu2\nltur3a\nlu5a\nlu3br\nluch4\nlu3ci\nlu3en\nluf4\nlu5id\nlu4ma\n5lumi\nl5umn.\n5lumnia\nlu3o\nluo3r\n4lup\nluss4\nlus3te\n1lut\nl5ven\nl5vet4\n2l1w\n1ly\n4lya\n4lyb\nly5me\nly3no\n2lys4\nl5yse\n1ma\n2mab\nma2ca\nma5chine\nma4cl\nmag5in\n5magn\n2mah\nmaid5\n4mald\nma3lig\nma5lin\nmal4li\nmal4ty\n5mania\nman5is\nman3iz\n4map\nma5rine.\nma5riz\nmar4ly\nmar3v\nma5sce\nmas4e\nmas1t\n5mate\nmath3\nma3tis\n4matiza\n4m1b\nmba4t5\nm5bil\nm4b3ing\nmbi4v\n4m5c\n4me.\n2med\n4med.\n5media\nme3die\nm5e5dy\nme2g\nmel5on\nmel4t\nme2m\nmem1o3\n1men\nmen4a\nmen5ac\nmen4de\n4mene\nmen4i\nmens4\nmensu5\n3ment\nmen4te\nme5on\nm5ersa\n2mes\n3mesti\nme4ta\nmet3al\nme1te\nme5thi\nm4etr\n5metric\nme5trie\nme3try\nme4v\n4m1f\n2mh\n5mi.\nmi3a\nmid4a\nmid4g\nmig4\n3milia\nm5i5lie\nm4ill\nmin4a\n3mind\nm5inee\nm4ingl\nmin5gli\nm5ingly\nmin4t\nm4inu\nmiot4\nm2is\nmis4er.\nmis5l\nmis4ti\nm5istry\n4mith\nm2iz\n4mk\n4m1l\nm1m\nmma5ry\n4m1n\nmn4a\nm4nin\nmn4o\n1mo\n4mocr\n5mocratiz\nmo2d1\nmo4go\nmois2\nmoi5se\n4mok\nmo5lest\nmo3me\nmon5et\nmon5ge\nmoni3a\nmon4ism\nmon4ist\nmo3niz\nmonol4\nmo3ny.\nmo2r\n4mora.\nmos2\nmo5sey\nmo3sp\nmoth3\nm5ouf\n3mous\nmo2v\n4m1p\nmpara5\nmpa5rab\nmpar5i\nm3pet\nmphas4\nm2pi\nmpi4a\nmp5ies\nm4p1in\nm5pir\nmp5is\nmpo3ri\nmpos5ite\nm4pous\nmpov5\nmp4tr\nm2py\n4m3r\n4m1s2\nm4sh\nm5si\n4mt\n1mu\nmula5r4\n5mult\nmulti3\n3mum\nmun2\n4mup\nmu4u\n4mw\n1na\n2n1a2b\nn4abu\n4nac.\nna4ca\nn5act\nnag5er.\nnak4\nna4li\nna5lia\n4nalt\nna5mit\nn2an\nnanci4\nnan4it\nnank4\nnar3c\n4nare\nnar3i\nnar4l\nn5arm\nn4as\nnas4c\nnas5ti\nn2at\nna3tal\nnato5miz\nn2au\nnau3se\n3naut\nnav4e\n4n1b4\nncar5\nn4ces.\nn3cha\nn5cheo\nn5chil\nn3chis\nnc1in\nnc4it\nncour5a\nn1cr\nn1cu\nn4dai\nn5dan\nn1de\nnd5est.\nndi4b\nn5d2if\nn1dit\nn3diz\nn5duc\nndu4r\nnd2we\n2ne.\nn3ear\nne2b\nneb3u\nne2c\n5neck\n2ned\nne4gat\nneg5ativ\n5nege\nne4la\nnel5iz\nne5mi\nne4mo\n1nen\n4nene\n3neo\nne4po\nne2q\nn1er\nnera5b\nn4erar\nn2ere\nn4er5i\nner4r\n1nes\n2nes.\n4nesp\n2nest\n4nesw\n3netic\nne4v\nn5eve\nne4w\nn3f\nn4gab\nn3gel\nnge4n4e\nn5gere\nn3geri\nng5ha\nn3gib\nng1in\nn5git\nn4gla\nngov4\nng5sh\nn1gu\nn4gum\nn2gy\n4n1h4\nnha4\nnhab3\nnhe4\n3n4ia\nni3an\nni4ap\nni3ba\nni4bl\nni4d\nni5di\nni4er\nni2fi\nni5ficat\nn5igr\nnik4\nn1im\nni3miz\nn1in\n5nine.\nnin4g\nni4o\n5nis.\nnis4ta\nn2it\nn4ith\n3nitio\nn3itor\nni3tr\nn1j\n4nk2\nn5kero\nn3ket\nnk3in\nn1kl\n4n1l\nn5m\nnme4\nnmet4\n4n1n2\nnne4\nnni3al\nnni4v\nnob4l\nno3ble\nn5ocl\n4n3o2d\n3noe\n4nog\nnoge4\nnois5i\nno5l4i\n5nologis\n3nomic\nn5o5miz\nno4mo\nno3my\nno4n\nnon4ag\nnon5i\nn5oniz\n4nop\n5nop5o5li\nnor5ab\nno4rary\n4nosc\nnos4e\nnos5t\nno5ta\n1nou\n3noun\nnov3el3\nnowl3\nn1p4\nnpi4\nnpre4c\nn1q\nn1r\nnru4\n2n1s2\nns5ab\nnsati4\nns4c\nn2se\nn4s3es\nnsid1\nnsig4\nn2sl\nns3m\nn4soc\nns4pe\nn5spi\nnsta5bl\nn1t\nnta4b\nnter3s\nnt2i\nn5tib\nnti4er\nnti2f\nn3tine\nn4t3ing\nnti4p\nntrol5li\nnt4s\nntu3me\nnu1a\nnu4d\nnu5en\nnuf4fe\nn3uin\n3nu3it\nn4um\nnu1me\nn5umi\n3nu4n\nn3uo\nnu3tr\nn1v2\nn1w4\nnym4\nnyp4\n4nz\nn3za\n4oa\noad3\no5a5les\noard3\noas4e\noast5e\noat5i\nob3a3b\no5bar\nobe4l\no1bi\no2bin\nob5ing\no3br\nob3ul\no1ce\noch4\no3chet\nocif3\no4cil\no4clam\no4cod\noc3rac\noc5ratiz\nocre3\n5ocrit\noctor5a\noc3ula\no5cure\nod5ded\nod3ic\nodi3o\no2do4\nodor3\nod5uct.\nod5ucts\no4el\no5eng\no3er\noe4ta\no3ev\no2fi\nof5ite\nofit4t\no2g5a5r\nog5ativ\no4gato\no1ge\no5gene\no5geo\no4ger\no3gie\n1o1gis\nog3it\no4gl\no5g2ly\n3ogniz\no4gro\nogu5i\n1ogy\n2ogyn\no1h2\nohab5\noi2\noic3es\noi3der\noiff4\noig4\noi5let\no3ing\noint5er\no5ism\noi5son\noist5en\noi3ter\no5j\n2ok\no3ken\nok5ie\no1la\no4lan\nolass4\nol2d\nold1e\nol3er\no3lesc\no3let\nol4fi\nol2i\no3lia\no3lice\nol5id.\no3li4f\no5lil\nol3ing\no5lio\no5lis.\nol3ish\no5lite\no5litio\no5liv\nolli4e\nol5ogiz\nolo4r\nol5pl\nol2t\nol3ub\nol3ume\nol3un\no5lus\nol2v\no2ly\nom5ah\noma5l\nom5atiz\nom2be\nom4bl\no2me\nom3ena\nom5erse\no4met\nom5etry\no3mia\nom3ic.\nom3ica\no5mid\nom1in\no5mini\n5ommend\nomo4ge\no4mon\nom3pi\nompro5\no2n\non1a\non4ac\no3nan\non1c\n3oncil\n2ond\non5do\no3nen\non5est\non4gu\non1ic\no3nio\non1is\no5niu\non3key\non4odi\non3omy\non3s\nonspi4\nonspir5a\nonsu4\nonten4\non3t4i\nontif5\non5um\nonva5\noo2\nood5e\nood5i\noo4k\noop3i\no3ord\noost5\no2pa\nope5d\nop1er\n3opera\n4operag\n2oph\no5phan\no5pher\nop3ing\no3pit\no5pon\no4posi\no1pr\nop1u\nopy5\no1q\no1ra\no5ra.\no4r3ag\nor5aliz\nor5ange\nore5a\no5real\nor3ei\nore5sh\nor5est.\norew4\nor4gu\n4o5ria\nor3ica\no5ril\nor1in\no1rio\nor3ity\no3riu\nor2mi\norn2e\no5rof\nor3oug\nor5pe\n3orrh\nor4se\nors5en\norst4\nor3thi\nor3thy\nor4ty\no5rum\no1ry\nos3al\nos2c\nos4ce\no3scop\n4oscopi\no5scr\nos4i4e\nos5itiv\nos3ito\nos3ity\nosi4u\nos4l\no2so\nos4pa\nos4po\nos2ta\no5stati\nos5til\nos5tit\no4tan\notele4g\not3er.\not5ers\no4tes\n4oth\noth5esi\noth3i4\not3ic.\not5ica\no3tice\no3tif\no3tis\noto5s\nou2\nou3bl\nouch5i\nou5et\nou4l\nounc5er\noun2d\nou5v\nov4en\nover4ne\nover3s\nov4ert\no3vis\noviti4\no5v4ol\now3der\now3el\now5est\now1i\nown5i\no4wo\noy1a\n1pa\npa4ca\npa4ce\npac4t\np4ad\n5pagan\np3agat\np4ai\npain4\np4al\npan4a\npan3el\npan4ty\npa3ny\npa1p\npa4pu\npara5bl\npar5age\npar5di\n3pare\npar5el\np4a4ri\npar4is\npa2te\npa5ter\n5pathic\npa5thy\npa4tric\npav4\n3pay\n4p1b\npd4\n4pe.\n3pe4a\npear4l\npe2c\n2p2ed\n3pede\n3pedi\npedia4\nped4ic\np4ee\npee4d\npek4\npe4la\npeli4e\npe4nan\np4enc\npen4th\npe5on\np4era.\npera5bl\np4erag\np4eri\nperi5st\nper4mal\nperme5\np4ern\nper3o\nper3ti\npe5ru\nper1v\npe2t\npe5ten\npe5tiz\n4pf\n4pg\n4ph.\nphar5i\nphe3no\nph4er\nph4es.\nph1ic\n5phie\nph5ing\n5phisti\n3phiz\nph2l\n3phob\n3phone\n5phoni\npho4r\n4phs\nph3t\n5phu\n1phy\npi3a\npian4\npi4cie\npi4cy\np4id\np5ida\npi3de\n5pidi\n3piec\npi3en\npi4grap\npi3lo\npi2n\np4in.\npind4\np4ino\n3pi1o\npion4\np3ith\npi5tha\npi2tu\n2p3k2\n1p2l2\n3plan\nplas5t\npli3a\npli5er\n4plig\npli4n\nploi4\nplu4m\nplum4b\n4p1m\n2p3n\npo4c\n5pod.\npo5em\npo3et5\n5po4g\npoin2\n5point\npoly5t\npo4ni\npo4p\n1p4or\npo4ry\n1pos\npos1s\np4ot\npo4ta\n5poun\n4p1p\nppa5ra\np2pe\np4ped\np5pel\np3pen\np3per\np3pet\nppo5site\npr2\npray4e\n5preci\npre5co\npre3em\npref5ac\npre4la\npre3r\np3rese\n3press\npre5ten\npre3v\n5pri4e\nprin4t3\npri4s\npris3o\np3roca\nprof5it\npro3l\npros3e\npro1t\n2p1s2\np2se\nps4h\np4sib\n2p1t\npt5a4b\np2te\np2th\npti3m\nptu4r\np4tw\npub3\npue4\npuf4\npul3c\npu4m\npu2n\npur4r\n5pus\npu2t\n5pute\nput3er\npu3tr\nput4ted\nput4tin\np3w\nqu2\nqua5v\n2que.\n3quer\n3quet\n2rab\nra3bi\nrach4e\nr5acl\nraf5fi\nraf4t\nr2ai\nra4lo\nram3et\nr2ami\nrane5o\nran4ge\nr4ani\nra5no\nrap3er\n3raphy\nrar5c\nrare4\nrar5ef\n4raril\nr2as\nration4\nrau4t\nra5vai\nrav3el\nra5zie\nr1b\nr4bab\nr4bag\nrbi2\nrbi4f\nr2bin\nr5bine\nrb5ing.\nrb4o\nr1c\nr2ce\nrcen4\nr3cha\nrch4er\nr4ci4b\nrc4it\nrcum3\nr4dal\nrd2i\nrdi4a\nrdi4er\nrdin4\nrd3ing\n2re.\nre1al\nre3an\nre5arr\n5reav\nre4aw\nr5ebrat\nrec5oll\nrec5ompe\nre4cre\n2r2ed\nre1de\nre3dis\nred5it\nre4fac\nre2fe\nre5fer.\nre3fi\nre4fy\nreg3is\nre5it\nre1li\nre5lu\nr4en4ta\nren4te\nre1o\nre5pin\nre4posi\nre1pu\nr1er4\nr4eri\nrero4\nre5ru\nr4es.\nre4spi\nress5ib\nres2t\nre5stal\nre3str\nre4ter\nre4ti4z\nre3tri\nreu2\nre5uti\nrev2\nre4val\nrev3el\nr5ev5er.\nre5vers\nre5vert\nre5vil\nrev5olu\nre4wh\nr1f\nrfu4\nr4fy\nrg2\nrg3er\nr3get\nr3gic\nrgi4n\nrg3ing\nr5gis\nr5git\nr1gl\nrgo4n\nr3gu\nrh4\n4rh.\n4rhal\nri3a\nria4b\nri4ag\nr4ib\nrib3a\nric5as\nr4ice\n4rici\n5ricid\nri4cie\nr4ico\nrid5er\nri3enc\nri3ent\nri1er\nri5et\nrig5an\n5rigi\nril3iz\n5riman\nrim5i\n3rimo\nrim4pe\nr2ina\n5rina.\nrin4d\nrin4e\nrin4g\nri1o\n5riph\nriph5e\nri2pl\nrip5lic\nr4iq\nr2is\nr4is.\nris4c\nr3ish\nris4p\nri3ta3b\nr5ited.\nrit5er.\nrit5ers\nrit3ic\nri2tu\nrit5ur\nriv5el\nriv3et\nriv3i\nr3j\nr3ket\nrk4le\nrk4lin\nr1l\nrle4\nr2led\nr4lig\nr4lis\nrl5ish\nr3lo4\nr1m\nrma5c\nr2me\nr3men\nrm5ers\nrm3ing\nr4ming.\nr4mio\nr3mit\nr4my\nr4nar\nr3nel\nr4ner\nr5net\nr3ney\nr5nic\nr1nis4\nr3nit\nr3niv\nrno4\nr4nou\nr3nu\nrob3l\nr2oc\nro3cr\nro4e\nro1fe\nro5fil\nrok2\nro5ker\n5role.\nrom5ete\nrom4i\nrom4p\nron4al\nron4e\nro5n4is\nron4ta\n1room\n5root\nro3pel\nrop3ic\nror3i\nro5ro\nros5per\nros4s\nro4the\nro4ty\nro4va\nrov5el\nrox5\nr1p\nr4pea\nr5pent\nrp5er.\nr3pet\nrp4h4\nrp3ing\nr3po\nr1r4\nrre4c\nrre4f\nr4reo\nrre4st\nrri4o\nrri4v\nrron4\nrros4\nrrys4\n4rs2\nr1sa\nrsa5ti\nrs4c\nr2se\nr3sec\nrse4cr\nrs5er.\nrs3es\nrse5v2\nr1sh\nr5sha\nr1si\nr4si4b\nrson3\nr1sp\nr5sw\nrtach4\nr4tag\nr3teb\nrten4d\nrte5o\nr1ti\nrt5ib\nrti4d\nr4tier\nr3tig\nrtil3i\nrtil4l\nr4tily\nr4tist\nr4tiv\nr3tri\nrtroph4\nrt4sh\nru3a\nru3e4l\nru3en\nru4gl\nru3in\nrum3pl\nru2n\nrunk5\nrun4ty\nr5usc\nruti5n\nrv4e\nrvel4i\nr3ven\nrv5er.\nr5vest\nr3vey\nr3vic\nrvi4v\nr3vo\nr1w\nry4c\n5rynge\nry3t\nsa2\n2s1ab\n5sack\nsac3ri\ns3act\n5sai\nsalar4\nsal4m\nsa5lo\nsal4t\n3sanc\nsan4de\ns1ap\nsa5ta\n5sa3tio\nsat3u\nsau4\nsa5vor\n5saw\n4s5b\nscan4t5\nsca4p\nscav5\ns4ced\n4scei\ns4ces\nsch2\ns4cho\n3s4cie\n5scin4d\nscle5\ns4cli\nscof4\n4scopy\nscour5a\ns1cu\n4s5d\n4se.\nse4a\nseas4\nsea5w\nse2c3o\n3sect\n4s4ed\nse4d4e\ns5edl\nse2g\nseg3r\n5sei\nse1le\n5self\n5selv\n4seme\nse4mol\nsen5at\n4senc\nsen4d\ns5ened\nsen5g\ns5enin\n4sentd\n4sentl\nsep3a3\n4s1er.\ns4erl\nser4o\n4servo\ns1e4s\nse5sh\nses5t\n5se5um\n5sev\nsev3en\nsew4i\n5sex\n4s3f\n2s3g\ns2h\n2sh.\nsh1er\n5shev\nsh1in\nsh3io\n3ship\nshiv5\nsho4\nsh5old\nshon3\nshor4\nshort5\n4shw\nsi1b\ns5icc\n3side.\n5sides\n5sidi\nsi5diz\n4signa\nsil4e\n4sily\n2s1in\ns2ina\n5sine.\ns3ing\n1sio\n5sion\nsion5a\nsi2r\nsir5a\n1sis\n3sitio\n5siu\n1siv\n5siz\nsk2\n4ske\ns3ket\nsk5ine\nsk5ing\ns1l2\ns3lat\ns2le\nslith5\n2s1m\ns3ma\nsmall3\nsman3\nsmel4\ns5men\n5smith\nsmol5d4\ns1n4\n1so\nso4ce\nsoft3\nso4lab\nsol3d2\nso3lic\n5solv\n3som\n3s4on.\nsona4\nson4g\ns4op\n5sophic\ns5ophiz\ns5ophy\nsor5c\nsor5d\n4sov\nso5vi\n2spa\n5spai\nspa4n\nspen4d\n2s5peo\n2sper\ns2phe\n3spher\nspho5\nspil4\nsp5ing\n4spio\ns4ply\ns4pon\nspor4\n4spot\nsqual4l\ns1r\n2ss\ns1sa\nssas3\ns2s5c\ns3sel\ns5seng\ns4ses.\ns5set\ns1si\ns4sie\nssi4er\nss5ily\ns4sl\nss4li\ns4sn\nsspend4\nss2t\nssur5a\nss5w\n2st.\ns2tag\ns2tal\nstam4i\n5stand\ns4ta4p\n5stat.\ns4ted\nstern5i\ns5tero\nste2w\nstew5a\ns3the\nst2i\ns4ti.\ns5tia\ns1tic\n5stick\ns4tie\ns3tif\nst3ing\n5stir\ns1tle\n5stock\nstom3a\n5stone\ns4top\n3store\nst4r\ns4trad\n5stratu\ns4tray\ns4trid\n4stry\n4st3w\ns2ty\n1su\nsu1al\nsu4b3\nsu2g3\nsu5is\nsuit3\ns4ul\nsu2m\nsum3i\nsu2n\nsu2r\n4sv\nsw2\n4swo\ns4y\n4syc\n3syl\nsyn5o\nsy5rin\n1ta\n3ta.\n2tab\nta5bles\n5taboliz\n4taci\nta5do\n4taf4\ntai5lo\nta2l\nta5la\ntal5en\ntal3i\n4talk\ntal4lis\nta5log\nta5mo\ntan4de\ntanta3\nta5per\nta5pl\ntar4a\n4tarc\n4tare\nta3riz\ntas4e\nta5sy\n4tatic\nta4tur\ntaun4\ntav4\n2taw\ntax4is\n2t1b\n4tc\nt4ch\ntch5et\n4t1d\n4te.\ntead4i\n4teat\ntece4\n5tect\n2t1ed\nte5di\n1tee\nteg4\nte5ger\nte5gi\n3tel.\nteli4\n5tels\nte2ma2\ntem3at\n3tenan\n3tenc\n3tend\n4tenes\n1tent\nten4tag\n1teo\nte4p\nte5pe\nter3c\n5ter3d\n1teri\nter5ies\nter3is\nteri5za\n5ternit\nter5v\n4tes.\n4tess\nt3ess.\nteth5e\n3teu\n3tex\n4tey\n2t1f\n4t1g\n2th.\nthan4\nth2e\n4thea\nth3eas\nthe5at\nthe3is\n3thet\nth5ic.\nth5ica\n4thil\n5think\n4thl\nth5ode\n5thodic\n4thoo\nthor5it\ntho5riz\n2ths\n1tia\nti4ab\nti4ato\n2ti2b\n4tick\nt4ico\nt4ic1u\n5tidi\n3tien\ntif2\nti5fy\n2tig\n5tigu\ntill5in\n1tim\n4timp\ntim5ul\n2t1in\nt2ina\n3tine.\n3tini\n1tio\nti5oc\ntion5ee\n5tiq\nti3sa\n3tise\ntis4m\nti5so\ntis4p\n5tistica\nti3tl\nti4u\n1tiv\ntiv4a\n1tiz\nti3za\nti3zen\n2tl\nt5la\ntlan4\n3tle.\n3tled\n3tles.\nt5let.\nt5lo\n4t1m\ntme4\n2t1n2\n1to\nto3b\nto5crat\n4todo\n2tof\nto2gr\nto5ic\nto2ma\ntom4b\nto3my\nton4ali\nto3nat\n4tono\n4tony\nto2ra\nto3rie\ntor5iz\ntos2\n5tour\n4tout\nto3war\n4t1p\n1tra\ntra3b\ntra5ch\ntraci4\ntrac4it\ntrac4te\ntras4\ntra5ven\ntrav5es5\ntre5f\ntre4m\ntrem5i\n5tria\ntri5ces\n5tricia\n4trics\n2trim\ntri4v\ntro5mi\ntron5i\n4trony\ntro5phe\ntro3sp\ntro3v\ntru5i\ntrus4\n4t1s2\nt4sc\ntsh4\nt4sw\n4t3t2\nt4tes\nt5to\nttu4\n1tu\ntu1a\ntu3ar\ntu4bi\ntud2\n4tue\n4tuf4\n5tu3i\n3tum\ntu4nis\n2t3up.\n3ture\n5turi\ntur3is\ntur5o\ntu5ry\n3tus\n4tv\ntw4\n4t1wa\ntwis4\n4two\n1ty\n4tya\n2tyl\ntype3\nty5ph\n4tz\ntz4e\n4uab\nuac4\nua5na\nuan4i\nuar5ant\nuar2d\nuar3i\nuar3t\nu1at\nuav4\nub4e\nu4bel\nu3ber\nu4bero\nu1b4i\nu4b5ing\nu3ble.\nu3ca\nuci4b\nuc4it\nucle3\nu3cr\nu3cu\nu4cy\nud5d\nud3er\nud5est\nudev4\nu1dic\nud3ied\nud3ies\nud5is\nu5dit\nu4don\nud4si\nu4du\nu4ene\nuens4\nuen4te\nuer4il\n3ufa\nu3fl\nugh3en\nug5in\n2ui2\nuil5iz\nui4n\nu1ing\nuir4m\nuita4\nuiv3\nuiv4er.\nu5j\n4uk\nu1la\nula5b\nu5lati\nulch4\n5ulche\nul3der\nul4e\nu1len\nul4gi\nul2i\nu5lia\nul3ing\nul5ish\nul4lar\nul4li4b\nul4lis\n4ul3m\nu1l4o\n4uls\nuls5es\nul1ti\nultra3\n4ultu\nu3lu\nul5ul\nul5v\num5ab\num4bi\num4bly\nu1mi\nu4m3ing\numor5o\num2p\nunat4\nu2ne\nun4er\nu1ni\nun4im\nu2nin\nun5ish\nuni3v\nun3s4\nun4sw\nunt3ab\nun4ter.\nun4tes\nunu4\nun5y\nun5z\nu4ors\nu5os\nu1ou\nu1pe\nuper5s\nu5pia\nup3ing\nu3pl\nup3p\nupport5\nupt5ib\nuptu4\nu1ra\n4ura.\nu4rag\nu4ras\nur4be\nurc4\nur1d\nure5at\nur4fer\nur4fr\nu3rif\nuri4fic\nur1in\nu3rio\nu1rit\nur3iz\nur2l\nurl5ing.\nur4no\nuros4\nur4pe\nur4pi\nurs5er\nur5tes\nur3the\nurti4\nur4tie\nu3ru\n2us\nu5sad\nu5san\nus4ap\nusc2\nus3ci\nuse5a\nu5sia\nu3sic\nus4lin\nus1p\nus5sl\nus5tere\nus1tr\nu2su\nusur4\nuta4b\nu3tat\n4ute.\n4utel\n4uten\nuten4i\n4u1t2i\nuti5liz\nu3tine\nut3ing\nution5a\nu4tis\n5u5tiz\nu4t1l\nut5of\nuto5g\nuto5matic\nu5ton\nu4tou\nuts4\nu3u\nuu4m\nu1v2\nuxu3\nuz4e\n1va\n5va.\n2v1a4b\nvac5il\nvac3u\nvag4\nva4ge\nva5lie\nval5o\nval1u\nva5mo\nva5niz\nva5pi\nvar5ied\n3vat\n4ve.\n4ved\nveg3\nv3el.\nvel3li\nve4lo\nv4ely\nven3om\nv5enue\nv4erd\n5vere.\nv4erel\nv3eren\nver5enc\nv4eres\nver3ie\nvermi4n\n3verse\nver3th\nv4e2s\n4ves.\nves4te\nve4te\nvet3er\nve4ty\nvi5ali\n5vian\n5vide.\n5vided\n4v3iden\n5vides\n5vidi\nv3if\nvi5gn\nvik4\n2vil\n5vilit\nv3i3liz\nv1in\n4vi4na\nv2inc\nvin5d\n4ving\nvio3l\nv3io4r\nvi1ou\nvi4p\nvi5ro\nvis3it\nvi3so\nvi3su\n4viti\nvit3r\n4vity\n3viv\n5vo.\nvoi4\n3vok\nvo4la\nv5ole\n5volt\n3volv\nvom5i\nvor5ab\nvori4\nvo4ry\nvo4ta\n4votee\n4vv4\nv4y\nw5abl\n2wac\nwa5ger\nwag5o\nwait5\nw5al.\nwam4\nwar4t\nwas4t\nwa1te\nwa5ver\nw1b\nwea5rie\nweath3\nwed4n\nweet3\nwee5v\nwel4l\nw1er\nwest3\nw3ev\nwhi4\nwi2\nwil2\nwill5in\nwin4de\nwin4g\nwir4\n3wise\nwith3\nwiz5\nw4k\nwl4es\nwl3in\nw4no\n1wo2\nwom1\nwo5ven\nw5p\nwra4\nwri4\nwrita4\nw3sh\nws4l\nws4pe\nw5s4t\n4wt\nwy4\nx1a\nxac5e\nx4ago\nxam3\nx4ap\nxas5\nx3c2\nx1e\nxe4cuto\nx2ed\nxer4i\nxe5ro\nx1h\nxhi2\nxhil5\nxhu4\nx3i\nxi5a\nxi5c\nxi5di\nx4ime\nxi5miz\nx3o\nx4ob\nx3p\nxpan4d\nxpecto5\nxpe3d\nx1t2\nx3ti\nx1u\nxu3a\nxx4\ny5ac\n3yar4\ny5at\ny1b\ny1c\ny2ce\nyc5er\ny3ch\nych4e\nycom4\nycot4\ny1d\ny5ee\ny1er\ny4erf\nyes4\nye4t\ny5gi\n4y3h\ny1i\ny3la\nylla5bl\ny3lo\ny5lu\nymbol5\nyme4\nympa3\nyn3chr\nyn5d\nyn5g\nyn5ic\n5ynx\ny1o4\nyo5d\ny4o5g\nyom4\nyo5net\ny4ons\ny4os\ny4ped\nyper5\nyp3i\ny3po\ny4poc\nyp2ta\ny5pu\nyra5m\nyr5ia\ny3ro\nyr4r\nys4c\ny3s2e\nys3ica\nys3io\n3ysis\ny4so\nyss4\nys1t\nys3ta\nysur4\ny3thin\nyt3ic\ny1w\nza1\nz5a2b\nzar2\n4zb\n2ze\nze4n\nze4p\nz1er\nze3ro\nzet4\n2z1i\nz4il\nz4is\n5zl\n4zm\n1zo\nzo4m\nzo5ol\nzte4\n4z1z2\nz4zy\n.con5gr\n.de5riva\n.dri5v4\n.eth1y6l1\n.eu4ler\n.ev2\n.ever5si5b\n.ga4s1om1\n.ge4ome\n.ge5ot1\n.he3mo1\n.he3p6a\n.he3roe\n.in5u2t\n.kil2n3i\n.ko6r1te1\n.le6ices\n.me4ga1l\n.met4ala\n.mim5i2c1\n.mi1s4ers\n.ne6o3f\n.noe1th\n.non1e2m\n.poly1s\n.post1am\n.pre1am\n.rav5en1o\n.semi5\n.sem4ic\n.semid6\n.semip4\n.semir4\n.sem6is4\n.semiv4\n.sph6in1\n.spin1o\n.ta5pes1tr\n.te3legr\n.to6pog\n.to2q\n.un3at5t\n.un5err5\n.vi2c3ar\n.we2b1l\n.re1e4c\na5bolic\na2cabl\naf6fish\nam1en3ta5b\nanal6ys\nano5a2c\nans5gr\nans3v\nanti1d\nan3ti1n2\nanti1re\na4pe5able\nar3che5t\nar2range\nas5ymptot\nath3er1o1s\nat6tes.\naugh4tl\nau5li5f\nav3iou\nback2er.\nba6r1onie\nba1thy\nbbi4t\nbe2vie\nbi5d2if\nbil2lab\nbio5m\nbi1orb\nbio1rh\nb1i3tive\nblan2d1\nblin2d1\nblon2d2\nbor1no5\nbo2t1u1l\nbrus4q\nbus6i2er\nbus6i2es\nbuss4ing\nbut2ed.\nbut4ted\ncad5e1m\ncat1a1s2\n4chs.\nchs3hu\nchie5vo\ncig3a3r\ncin2q\ncle4ar\nco6ph1o3n\ncous2ti\ncri3tie\ncroc1o1d\ncro5e2co\nc2tro3me6c\n1cu2r1ance\n2d3alone\ndata1b\ndd5a5b\nd2d5ib\nde4als.\nde5clar1\nde2c5lina\nde3fin3iti\nde2mos\ndes3ic\nde2tic\ndic1aid\ndif5fra\n3di1methy\ndi2ren\ndi2rer\n2d1lead\n2d1li2e\n3do5word\ndren1a5l\ndrif2t1a\nd1ri3pleg5\ndrom3e5d\nd3tab\ndu2al.\ndu1op1o1l\nea4n3ies\ne3chas\nedg1l\ned1uling\neli2t1is\ne1loa\nen1dix\neo3grap\n1e6p3i3neph1\ne2r3i4an.\ne3spac6i\neth1y6l1ene\n5eu2clid1\nfeb1rua\nfermi1o\n3fich\nfit5ted.\nfla1g6el\nflow2er.\n3fluor\ngen2cy.\nge3o1d\nght1we\ng1lead\nget2ic.\n4g1lish\n5glo5bin\n1g2nac\ngnet1ism\ngno5mo\ng2n1or.\ng2noresp\n2g1o4n3i1za\ngraph5er.\ngriev1\ng1utan\nhair1s\nha2p3ar5r\nhatch1\nhex2a3\nhite3sid\nh3i5pel1a4\nhnau3z\nho6r1ic.\nh2t1eou\nhypo1tha\nid4ios\nifac1et\nign4it\nignit1er\ni4jk\nim3ped3a\ninfra1s2\ni5nitely.\nirre6v3oc\ni1tesima\nith5i2l\nitin5er5ar\njanu3a\njapan1e2s\nje1re1m\n1ke6ling\n1ki5netic\n1kovian\nk3sha\nla4c3i5e\nlai6n3ess\nlar5ce1n\nl3chai\nl3chil6d1\nlead6er.\nlea4s1a\n1lec3ta6b\nle3g6en2dre\n1le1noid\nlith1o5g\nll1fl\nl2l3ish\nl5mo3nell\nlo1bot1o1\nlo2ges.\nload4ed.\nload6er.\nl3tea\nlth5i2ly\nlue1p\n1lunk3er\n1lum5bia.\n3lyg1a1mi\nly5styr\nma1la1p\nm2an.\nman3u1sc\nmar1gin1\nmedi2c\nmed3i3cin\nmedio6c1\nme3gran3\nm2en.\n3mi3da5b\n3milita\nmil2l1ag\nmil5li5li\nmi6n3is.\nmi1n2ut1er\nmi1n2ut1est\nm3ma1b\n5maph1ro1\n5moc1ra1t\nmo5e2las\nmol1e5c\nmon4ey1l\nmono3ch\nmo4no1en\nmoro6n5is\nmono1s6\nmoth4et2\nm1ou3sin\nm5shack2\nmu2dro\nmul2ti5u\nn3ar4chs.\nn3ch2es1t\nne3back\n2ne1ski\nn1dieck\nnd3thr\nnfi6n3ites\n4n5i4an.\nnge5nes\nng1ho\nng1spr\nnk3rup\nn5less\n5noc3er1os\nnom1a6l\nnom5e1no\nn1o1mist\nnon1eq\nnon1i4so\n5nop1oly.\nno1vemb\nns5ceiv\nns4moo\nntre1p\nobli2g1\no3chas\nodel3li\nodit1ic\noerst2\noke1st\no3les3ter\noli3gop1o1\no1lo3n4om\no3mecha6\nonom1ic\no3norma\no3no2t1o3n\no3nou\nop1ism.\nor4tho3ni4t\north1ri\nor5tively\no4s3pher\no5test1er\no5tes3tor\noth3e1o1s\nou3ba3do\no6v3i4an.\noxi6d1ic\npal6mat\nparag6ra4\npar4a1le\nparam4\npara3me\npee2v1\nphi2l3ant\nphi5lat1e3l\npi2c1a3d\npli2c1ab\npli5nar\npoin3ca\n1pole.\npoly1e\npo3lyph1ono\n1prema3c\npre1neu\npres2pli\npro2cess\nproc3i3ty.\npro2g1e\n3pseu2d\npseu3d6o3d2\npseu3d6o3f2\npto3mat4\np5trol3\npu5bes5c\nquain2t1e\nqu6a3si3\nquasir6\nquasis6\nquin5tes5s\nqui3v4ar\nr1abolic\n3rab1o1loi\nra3chu\nr3a3dig\nradi1o6g\nr2amen\n3ra4m5e1triz\nra3mou\nra5n2has\nra1or\nr3bin1ge\nre2c3i1pr\nrec5t6ang\nre4t1ribu\nr3ial.\nriv1o1l\n6rk.\nrk1ho\nr1krau\n6rks.\nr5le5qu\nro1bot1\nro5e2las\nro5epide1\nro3mesh\nro1tron\nr3pau5li\nrse1rad1i\nr1thou\nr1treu\nr1veil\nrz1sc\nsales3c\nsales5w\n5sa3par5il\nsca6p1er\nsca2t1ol\ns4chitz\nschro1ding1\n1sci2utt\nscrap4er.\nscy4th1\nsem1a1ph\nse3mes1t\nse1mi6t5ic\nsep3temb\nshoe1st\nsid2ed.\nside5st\nside5sw\nsi5resid\nsky1sc\n3slova1kia\n3s2og1a1my\nso2lute\n3s2pace\n1s2pacin\nspe3cio\nspher1o\nspi2c1il\nspokes5w\nsports3c\nsports3w\ns3qui3to\ns2s1a3chu1\nss3hat\ns2s3i4an.\ns5sign5a3b\n1s2tamp\ns2t1ant5shi\nstar3tli\nsta1ti\nst5b\n1stor1ab\nstrat1a1g\nstrib5ut\nst5scr\nstu1pi4d1\nstyl1is\nsu2per1e6\n1sync\n1syth3i2\nswimm6\n5tab1o1lism\nta3gon.\ntalk1a5\nt1a1min\nt6ap6ath\n5tar2rh\ntch1c\ntch3i1er\nt1cr\nteach4er.\ntele2g\ntele1r6o\n3ter1gei\nter2ic.\nt3ess2es\ntha4l1am\ntho3don\nth1o5gen1i\ntho1k2er\nthy4l1an\nthy3sc\n2t3i4an.\nti2n3o1m\nt1li2er\ntolo2gy\ntot3ic\ntrai3tor1\ntra1vers\ntravers3a3b\ntreach1e\ntr4ial.\n3tro1le1um\ntrof4ic.\ntro3fit\ntro1p2is\n3trop1o5les\n3trop1o5lis\nt1ro1pol3it\ntsch3ie\nttrib1ut1\nturn3ar\nt1wh\nty2p5al\nua3drati\nuad1ratu\nu5do3ny\nuea1m\nu2r1al.\nuri4al.\nus2er.\nv1ativ\nv1oir5du1\nva6guer\nvaude3v\n1verely.\nv1er1eig\nves1tite\nvi1vip3a3r\nvoice1p\nwaste3w6a2\nwave1g4\nw3c\nweek1n\nwide5sp\nwo4k1en\nwrap3aro\nwrit6er.\nx1q\nxquis3\ny5che3d\nym5e5try\ny1stro\nyes5ter1y\nz3ian.\nz3o1phr\nz2z3w"
