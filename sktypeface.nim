
import sktypefaceinternal.sktfcommon
export sktfcommon

proc NewTypefaceSystem*(): RTypefaceSystem
  ## Retrieves a new typeface system based on whatever OS/build
  ## circumstances dictate are the default text system.

when hostOS == "windows":
  import sktypefaceinternal.sktfgdi
  export sktfgdi
  proc NewTypefaceSystem*(): RTypefaceSystem =
    ## Implementation for the Windows GDI platform.
    result = NewGdiTypefaceSystem()

when hostOS != "windows":
  import macros
  error("No typeface backend is present for this build.")

