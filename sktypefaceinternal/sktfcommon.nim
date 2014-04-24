
type
  NFaceStyle* = enum
    fsPlain
    fsBold
    fsBoldItalic
    fsItalic
    fsLight
    fsLightItalic

  RTypefaceSystem* = ref TypefaceSystem
  TypefaceSystem*  = object {.inheritable.}

  RFontFace* = ref FontFace
  FontFace*  = object {.inheritable.}

  ## Metrics for a single glyph within a font face. Note that skTypeface
  ## metrics are always returned in pixels, regardless of the font
  ## system's native preference.
  FaceGlyphMetrics* = object {.final.}
    boundingWidth*, boundingHeight*: int
    advanceWidth*, advanceHeight*: int
    offsetX*, offsetY*: int

  FRasterizeFacePixel* = proc(x, y, amount: int) {.closure.}

# Public fonts {{{1

method LoadPublicFace*(self: RTypefaceSystem; face: string; size: int; style: NFaceStyle = fsPlain): RFontFace =
  ## Loads a font with the given `face` name from the OS' reserve of
  ## globally installed fonts. Returns nil if the font is unloadable, or
  ## a reference to a font face object.
  doAssert(false)

# }}} public fonts

# Private fonts {{{1

method LoadPrivateFaceFromBuffer*(self: RTypefaceSystem; size: int; buffer: pointer; bufferSize: int): RFontFace =
  ## Loads a font file from the given filename. Returns nil if the font
  ## is unloadable, or a reference to a font face object.
  doAssert(false)

method LoadPrivateFaceFromFile*(self: RTypefaceSystem; filename: string; size: int): RFontFace =
  ## Loads a font file from the given filename. Returns nil if the font
  ## is unloadable, or a reference to a font face object.
  doAssert(false)

# }}} private fonts

# Font information {{{1

# method FontFilename(self: FontFace): string =
#   ## Returns the filename to this font, if such information is knowable.
#   ## Mostly useful for finding the exact path to a system font.
#   discard

# }}}1 font information 

# Kerning {{{1

method KerningPair*(self: FontFace; first, second: uint32): int =
  ## Asks the font to look up the kerning pair between the first and
  ## second Unicode code points. The number of pixels the second glyph
  ## should be horizontally translated is returned.
  doAssert(false)

# }}} kerning

# Glyph duties {{{1

# Selection {{{2

method SelectGlyph*(self: FontFace; glyph: uint32) =
  ## Asks the font to select a glyph with the given Unicode code point.
  ## That glyph, if available, will be selected after this method is
  ## called.
  discard

method DeselectGlyph*(self: FontFace) =
  ## Asks the font to deselect the current glyph (if any.) No glyph will
  ## be selected after this method is called.
  discard

# }}} selection

# Metrics {{{2

method MetricActiveGlyph*(self: FontFace): FaceGlyphMetrics =
  ## Asks the font for the metrics on the currently selected glyph.
  doAssert(false)

# }}} metrics

# Rendering {{{2

method RasterizeActiveGlyph*(self: FontFace; style: RasterizeStyle; cb: FRasterizeFacePixel) =
  ## Asks the font to rasterize a glyph in to a given rasterization
  ## style; the provided closure is invoked for each pixel, allowing
  ## full control over where the result is painted. On some backends
  ## this version of `Rasterize` avoids extra allocations.
  doAssert(false)

method RasterizeActiveGlyph*(self: FontFace; style: RasterizeStyle; width, height: var int): pointer =
  ## Asks the font to rasterize a glyph in to a given rasterization
  ## style, returning the buffer along with its width and height.
  doAssert(false)

# }}} rendering

# }}} glyph duties

