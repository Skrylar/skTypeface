
import sktypefaceinternal.sktfcommon
export sktfcommon

## Retrieves a new typeface system based on whatever OS/build
## circumstances dictate are the default text system.
proc NewTypefaceSystem*(): RTypefaceSystem

when hostOS == "windows":
  import sktypefaceinternal.sktfgdi
  export sktfgdi
  proc NewTypefaceSystem*(): RTypefaceSystem =
    result = NewGdiTypefaceSystem()

when hostOS != "windows":
  import macros
  error("No typeface backend is present for this build.")

