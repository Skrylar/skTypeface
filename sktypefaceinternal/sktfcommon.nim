
type
  ## Describes the style of font face which is being requested. Only
  ## public fonts allow this, as they will automatically determine the
  ## correct font for the style and synthesize one if needed. Private
  ## fonts are loaded as-is from their files, and it is assumed you
  ## already know the style when you are asking for the TTF directly.
  NFaceStyle* = enum
    fsPlain
    fsBold
    fsBoldItalic
    fsItalic
    fsLight
    fsLightItalic

  ## Describes the type of rasterization result that is desired. If the
  ## subsystem does anything special for the style (some fonts won't be
  ## antialiased for monochrome renders) then that will be invoked,
  ## otherwise the closest method is run and the result is corrected
  ## before being returned.
  NRasterizeStyle* = enum
    rsMonochrome ## Returned values will be 0 or 1.
    rsGreyscale  ## Returned values will be normalized from 0-255.

  RTypefaceSystem* = ref TypefaceSystem
  TypefaceSystem*  = object {.inheritable.}
    ## A system which provides access to type faces.

  RFontFace* = ref FontFace
  FontFace*  = object {.inheritable.}
    ## An object which provides access to a single font face of a given
    ## size and style.

  FaceGlyphMetrics* = object {.final.}
    ## Metrics for a single glyph within a font face. Note that
    ## skTypeface metrics are always returned in pixels, regardless of
    ## the font system's native preference.
    boundingWidth*, boundingHeight*: int
    advanceWidth*, advanceHeight*: int
    offsetX*, offsetY*: int

  ## Callback invoked when asked to rasterize a glyph using the callback
  ## technique.
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

method KerningPair*(self: RFontFace; first, second: uint32): int =
  ## Asks the font to look up the kerning pair between the first and
  ## second Unicode code points. The number of pixels the second glyph
  ## should be horizontally translated is returned.
  doAssert(false)

# }}} kerning

# Glyph duties {{{1

# Selection {{{2

method SelectGlyph*(self: RFontFace; glyph: uint32) =
  ## Asks the font to select a glyph with the given Unicode code point.
  ## That glyph, if available, will be selected after this method is
  ## called. Note that when glyphs are selected, some extra resources
  ## might be allocated to facilitate extracting data from it; so when
  ## you are done with a glyph, either `SelectGlyph` the next one you
  ## need or explicitly `DeselectGlyph` if you won't need the typeface
  ## for a while.
  discard

method DeselectGlyph*(self: RFontFace) =
  ## Asks the font to deselect the current glyph (if any.) No glyph will
  ## be selected after this method is called.
  discard

# }}} selection

# Metrics {{{2

method MetricActiveGlyph*(self: RFontFace): FaceGlyphMetrics =
  ## Asks the font for the metrics on the currently selected glyph.
  doAssert(false)

# }}} metrics

# Rendering {{{2

method RasterizeActiveGlyph*(self: RFontFace; style: NRasterizeStyle;
  width, height: var int; cb: FRasterizeFacePixel): bool =
    ## Asks the font to rasterize a glyph in to a given rasterization
    ## style; the provided closure is invoked for each pixel, allowing
    ## full control over where the result is painted. On some backends
    ## this version of `Rasterize` avoids extra allocations.
    doAssert(false)

method RasterizeActiveGlyph*(self: RFontFace; style: NRasterizeStyle;
  width, height: var int; buffer: var seq[uint8]): bool =
    ## Asks the font to rasterize a glyph in to a given rasterization
    ## style, returning the buffer along with its width and height.
    doAssert(false)

# }}} rendering

# }}} glyph duties

