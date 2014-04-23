
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

  RFontFace* = ref RFontFace
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

method LoadPublicFace*(self: RTypefaceSystem; face: string; style: NFaceStyle = fsPlain): RFontFace =
  ## Loads a font with the given `face` name from the OS' reserve of
  ## globally installed fonts. Returns nil if the font is unloadable, or
  ## a reference to a font face object.
  discard

# }}} public fonts

# Private fonts {{{1

method LoadPrivateFaceFromBuffer*(self: RTypefaceSystem; buffer: pointer; size: int): RFontFace =
  ## Loads a font file from the given filename. Returns nil if the font
  ## is unloadable, or a reference to a font face object.
  discard

method LoadPrivateFaceFromFile*(self: RTypefaceSystem; filename: string): RFontFace =
  ## Loads a font file from the given filename. Returns nil if the font
  ## is unloadable, or a reference to a font face object.
  discard

# }}} private fonts

# Font information {{{1

# method FontFilename(self: FontFace): string =
#   ## Returns the filename to this font, if such information is knowable.
#   ## Mostly useful for finding the exact path to a system font.
#   discard

# }}}1 font information 

# Glyph metrics {{{1

proc GlyphMetrics*(self: FontFace; glyph: uint32): GlyphMetrics

# }}} glyph metrics

# Kerning {{{1

proc KerningPair*(self: FontFace; first, second: uint32): int

# }}} kerning

# Rendering {{{1

method Rasterize*(self: FontFace; glyph: uint32; style: RasterizeStyle; cb: FRasterizeFacePixel) =
  ## Asks the font to rasterize a glyph in to a given rasterization
  ## style; the provided closure is invoked for each pixel, allowing
  ## full control over where the result is painted. On some backends
  ## this version of `Rasterize` avoids extra allocations.
  doAssert(false)

method Rasterize*(self: FontFace; glyph: uint32; style: RasterizeStyle; width, height: var int): pointer =
  ## Asks the font to rasterize a glyph in to a given rasterization
  ## style, returning the buffer along with its width and height.
  doAssert(false)

# }}} rendering

