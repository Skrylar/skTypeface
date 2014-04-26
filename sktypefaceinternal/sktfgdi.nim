
import
  unsigned,
  sktfcommon

# Windows stuff {{{1

type
  DWORD   = uint32
  LONG    = int32
  SHORT   = int16
  WORD    = uint16
  HANDLE  = distinct pointer
  HFONT   = HANDLE
  HGDIOBJ = HANDLE
  HWND    = HANDLE
  HDC     = HANDLE
  HBITMAP = HANDLE
  WinBool = cint

  FIXED = object {.importc: "FIXED".}
    fract: WORD
    value: SHORT

  POINT = object {.importc: "POINTER".}
    x, y: LONG

  PMAT2 = ptr MAT2
  MAT2 = object {.importc: "MAT2".}
    eM11, eM12, eM21, eM22: FIXED

  GlyphMetrics = object {.importc: "GLYPHMETRICS".}
    gmBlackBoxX, gmBlackBoxY: cuint
    gmptGlyphOrigin: POINT
    gmCellIncX, gmCellIncY: SHORT

  WinKERNINGPAIR = object {.importc: "KERNINGPAIR".}
    wFirst, wSecond: WORD
    iKernAmount: cint

const
  DEFAULT_CHARSET     = 1
  OUT_DEFAULT_PRECIS  = 0
  CLIP_DEFAULT_PRECIS = 0
  CLEARTYPE_QUALITY   = 5
  DEFAULT_PITCH       = 0
  FF_DONTCARE         = 0
  MM_TEXT             = 1
  GGO_METRICS         = 0
  GGO_GRAY8_BITMAP    = 6
  GDI_ERROR           = 0xFFFFFFFF.DWORD
  LOGPIXELSY          = 90

proc CreateFont(nHeight, nWidth, nEscapement, nOrientation, fnWeight: cint;
  fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet,
  fdwOutputPrecision, fdwClipPrecision, fdwQuality,
  fdwPitchAndFamily: DWORD; lpszFace: cstring): HFONT {.importc: "CreateFontA", stdcall.}
proc DeleteObject(hObject: HGDIOBJ): WinBool {.importc: "DeleteObject", stdcall.}
proc GetGlyphOutlineA(
  handle: HDC; uChar, uFormat: cuint; lpgm: ptr GlyphMetrics;
  cbBuffer: DWORD; lpvBuffer: pointer; lpmat2: PMAT2
  ): DWORD {.importc: "GetGlyphOutlineA", stdcall.}
proc GetDC(handle: HWND): HDC {.importc: "GetDC", stdcall.}
proc ReleaseDC(handle: HWND; context: HDC): cint {.importc: "ReleaseDC", stdcall.}
proc SetMapMode(handle: HDC; fnMapMode: cint): cint {.importc: "SetMapMode", stdcall.}
proc SelectObject(context: HDC; obj: HGDIOBJ): HGDIOBJ {.importc: "SelectObject", stdcall.}
proc MulDiv(nNumber, nNumerator, nDenominator: cint): cint {.importc: "MulDiv", stdcall.}
proc GetDeviceCaps(context: HDC; nIndex: cint): cint {.importc: "GetDeviceCaps", stdcall.}
proc GetKerningPairs(context: HDC; nNumPairs: DWORD; lpkrnpair: ptr WinKERNINGPAIR): DWORD {.importc: "GetKerningPairs", stdcall.}

var identityMatrix: MAT2
identityMatrix.eM11.fract = 0
identityMatrix.eM11.value = 1
identityMatrix.eM12.fract = 0
identityMatrix.eM12.value = 0
identityMatrix.eM21.fract = 0
identityMatrix.eM21.value = 0
identityMatrix.eM22.fract = 0
identityMatrix.eM22.value = 1

proc Weight(self: NFaceStyle): int =
  case self
  of fsPlain, fsItalic:
    return 400
  of fsBold, fsBoldItalic:
    return 700
  of fsLight, fsLightItalic:
    return 300

proc Italicized(self: NFaceStyle): int =
  case self
  of fsPlain, fsBold, fsLight:
    return 0
  of fsItalic, fsBoldItalic, fsLightItalic:
    return 1

# }}} windows

type
  RGdiTypefaceSystem* = ref GdiTypefaceSystem
  GdiTypefaceSystem*  = object of TypefaceSystem

  RGdiFontFace* = ref GdiFontFace
  GdiFontFace*  = object of FontFace
    parent   : RGdiTypefaceSystem
    kerning  : seq[WinKERNINGPAIR]
    context  : HDC
    handle   : HFONT
    selected : uint32     ## Currently selected glyph.

# Cleanup {{{1

proc FinalizeGdiFace(self: RGdiFontFace) =
  self.DeselectGlyph
  doAssert(DeleteObject(self.handle.HGDIOBJ) != 0,
    "Could not free font handle.")

# }}} cleanup

# Typeface {{{1

proc NewGdiTypefaceSystem*(): RGdiTypefaceSystem =
  new(result)

# }}} typeface

# Public fonts {{{1

method LoadPublicFace*(self: RGdiTypefaceSystem;
  face: string; size: int; style: NFaceStyle = fsPlain): RFontFace =
    result = nil
    # Prepare to create fhe font
    let height = size.abs.int # TODO: Actually adjust this to pixel/point size.

    doAssert(height != 0,
      "Font size must be in points or pixels, not zero.")

    let dc = GetDC(nil.HWND)
    let AdjustedHeight =
      if height > 0:
        -MulDiv(height.cint, GetDeviceCaps(dc, LOGPIXELSY), 72.cint)
      else:
        height.abs.cint
    discard ReleaseDC(nil.HWND, dc)

    # Create the font!
    let handle = CreateFont(AdjustedHeight, 0.cint, 0.cint, 0.cint,
      style.Weight.cint, style.Italicized.dword,
      0.dword, 0.dword, DEFAULT_CHARSET.dword, # NB Uses the locale charset, might cause derp?
      OUT_DEFAULT_PRECIS.dword,
      CLIP_DEFAULT_PRECIS.dword,
      CLEARTYPE_QUALITY.dword,
      DEFAULT_PITCH.dword or FF_DONTCARE.dword,
      face)

    # Check if we got the font
    if handle.pointer != nil:
      var face: RGdiFontFace
      new(face, FinalizeGdiFace)
      face.parent   = self
      face.handle   = handle
      face.context  = HDC(nil)
      face.kerning  = nil
      face.selected = 0
      return face

# }}} public fonts

# Private fonts {{{1

method LoadPrivateFaceFromBuffer*(self: RTypefaceSystem; size: int; buffer: pointer; bufferSize: int): RFontFace =
  doAssert(false)

method LoadPrivateFaceFromFile*(self: RTypefaceSystem; filename: string; size: int): RFontFace =
  doAssert(false)

# }}} private fonts

# Font information {{{1

# method FontFilename(self: FontFace): string =
#   ## Returns the filename to this font, if such information is knowable.
#   ## Mostly useful for finding the exact path to a system font.
#   discard

# }}}1 font information 

# Kerning {{{1

method KerningPair*(self: RGdiFontFace; first, second: uint32): int =
  # Initialize the kerning table, if necessary
  if self.kerning == nil:
    let dc = GetDC(nil.HDC)                       # Get a screen DC
    let oldFont = SelectObject(dc, self.handle.HGDIOBJ)
    let tableLength = GetKerningPairs(dc, 0, nil) # Get pair count
    if tableLength > 0.dword:
      newSeq(self.kerning, tableLength.int) # Create local table for reception
      let received = GetKerningPairs(dc, tableLength, addr(self.kerning[0]))
      doAssert(received == tableLength,
        "Did not receive as many kerning pairs as expected.")
      discard SelectObject(dc, oldFont)
      discard ReleaseDC(nil.HWND, dc) # Return the screen DC
    else:
      discard SelectObject(dc, oldFont)
      discard ReleaseDC(nil.HWND, dc) # Return the screen DC
      return 0

  # Search the kerning table for our entry
  for x in items(self.kerning):
    if x.wFirst != first.WORD: continue
    if x.wSecond != second.WORD: continue
    return x.iKernAmount.int
  return 0

# }}} kerning

# Glyph duties {{{1

# Selection {{{2

method SelectGlyph*(self: RGdiFontFace; glyph: uint32) =
  if self.context.pointer == nil:
    self.context = GetDC(nil.HDC)
    doAssert(self.context.pointer != nil,
      "Could not get screen DC during selection.")
  self.selected = glyph

method DeselectGlyph*(self: RGdiFontFace) =
  assert(self != nil)
  if self.context.pointer != nil: discard ReleaseDC(nil.HWND, self.context)
  self.selected = 0

# }}} selection

# Metrics {{{2

method MetricActiveGlyph*(self: RGdiFontFace): FaceGlyphMetrics =
  if self.selected == 0: return

  # Select our font of inquiry
  let sizzurp = SelectObject(self.context, self.handle)
  doAssert(cast[DWORD](sizzurp) != GDI_ERROR,
    "Could not select font for measuring.")

  # Grab metric info
  var metrics: GLYPHMETRICS
  discard SetMapMode(self.context, MM_TEXT)
  let x = GetGlyphOutlineA(self.context, self.selected,
    GGO_METRICS, addr(metrics), 0, nil, addr(identityMatrix))
  doAssert(x != GDI_ERROR, "Grabbing metrics failed.")

  # Put the fonts back where we found them
  discard SelectObject(self.context, sizzurp)

  # TODO: Convert metrics in to pixels?
  # TODO: Actually copy metrics from windows.
  result.boundingWidth  = metrics.gmBlackBoxX.int
  result.boundingHeight = metrics.gmBlackBoxY.int
  result.advanceWidth   = metrics.gmCellIncX.int
  result.advanceHeight  = metrics.gmCellIncY.int
  result.offsetX        = metrics.gmptGlyphOrigin.x.int
  result.offsetY        = metrics.gmptGlyphOrigin.y.int

# }}} metrics

# Rendering {{{2

method RasterizeActiveGlyph*(self: RGdiFontFace; style: NRasterizeStyle;
  cb: FRasterizeFacePixel) =
    doAssert(false)

method RasterizeActiveGlyph*(self: RGdiFontFace; style: NRasterizeStyle;
  width, height: var int; buffer: var seq[uint8]): bool =
    # TODO: Support the monochrome rasterizer.
    doAssert(style == rsGreyscale, "Only greyscale rasterizer is supported.")
    if self.selected > 0.uint32:
      # Select our font
      let sizzurp = SelectObject(self.context, self.handle)
      # Now rasterize
      var metrics: GLYPHMETRICS
      # Check the size of a buffer we will require
      discard SetMapMode(self.context, MM_TEXT)
      let required = GetGlyphOutlineA(self.context, self.selected.cuint,
        GGO_GRAY8_BITMAP.cuint, addr(metrics),
        0.cuint, nil, addr(identityMatrix))
      doAssert(required > 0.dword,
        "Could not get buffer size for glyph rendering.")
      # Prepare buffer space
      if buffer == nil:
        newSeq(buffer, required.int)
      else:
        buffer.setLen(required.int)
      let result = GetGlyphOutlineA(self.context, self.selected.cuint,
        GGO_GRAY8_BITMAP.cuint, addr(metrics), required,
        cast[pointer](addr(buffer[0])), addr(identityMatrix))
      doAssert(result != GDI_ERROR.dword, "Could not rasterize glyph.")
      # Now lets do some stupid shit to clean up after windows
      let stride = (metrics.gmBlackBoxX + 3) and (not 3.cuint)
      # Return the metrics
      # TODO: Correct the output buffer instead of doing this crap
      width = stride.int
      height = metrics.gmBlackBoxY.int
      # Return sizzurp
      discard SelectObject(self.context, sizzurp)
      # We're done
      return true
    else:
      width = 0
      height = 0
      return false

# }}} rendering

# }}} glyph duties

# Testing {{{1

when isMainModule:
  var ts = NewGdiTypefaceSystem()
  doAssert(ts != nil, "Typeface system was not created.")
  var arial = ts.LoadPublicFace("Arial", 12)
  doAssert(arial != nil, "Arial font was [somehow] not created.")
  arial.SelectGlyph('g'.uint32)
  let g = arial.MetricActiveGlyph()
  echo "Bounds: ", g
  let k = arial.KerningPair('W'.uint32, 'A'.uint32)
  echo "Kerning W/A: ", k
  var outbuf: seq[uint8]
  var width, height: int

  doAssert(arial.RasterizeActiveGlyph(rsGreyscale, width, height, outbuf) == true,
    "Could not rasterize test character.")
  
  debugEcho "Rasterized ", width, "x", height," glyph:"
  var outStr: string = ""
  setLen(outStr, width)
  for y in 0..height-1:
    for x in 0..width-1:
      let v = outbuf[(y*width)+x]
      outStr[x] = '.'
      if v > 10.uint8: outStr[x] = ','
      if v > 25.uint8: outStr[x] = ';'
      if v > 50.uint8: outStr[x] = '#'
    echo outStr

  arial.DeselectGlyph

# }}} testing

