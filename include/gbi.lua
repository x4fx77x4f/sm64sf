-- Derived from https://github.com/sm64js/sm64js/blob/a4b809b055119b1c716f25610a59543bc9e6b2a2/src/include/gbi.js
-- FUN FACT: Lua has a hardcoded limit of 200 local variables. I found that out while making this file.
-- ALSO: Fuck this Gbi prefix.

Gbi = {}

-- graphics opcodes
Gbi.G_MTX = 1
Gbi.G_POPMTX = 2
Gbi.G_MOVEMEM = 3
Gbi.G_MOVEWORD = 4
Gbi.G_TEXTURE = 5
Gbi.G_VTX = 6
Gbi.G_DL = 7
Gbi.G_ENDDL = 8
Gbi.G_SETGEOMETRYMODE = 9
Gbi.G_CLEARGEOMETRYMODE = 10
Gbi.G_TRI1 = 11
Gbi.G_SETOTHERMODE_L = 12
Gbi.G_SETOTHERMODE_H = 13
Gbi.G_SETTIMG = 14
Gbi.G_LOADBLOCK = 15
Gbi.G_SETTILE = 16
Gbi.G_SETTILESIZE = 17
Gbi.G_LOADTLUT = 18
Gbi.G_SETENVCOLOR = 19
Gbi.G_SETPRIMCOLOR = 20
Gbi.G_SETFOGCOLOR = 21
Gbi.G_SETFILLCOLOR = 22
Gbi.G_SETCOMBINE = 23
Gbi.G_TEXRECTFLIP = 24
Gbi.G_FILLRECT = 25
Gbi.G_SETSCISSOR = 26
Gbi.G_SETZIMG = 27
Gbi.G_SETCIMG = 28
Gbi.G_RDPLOADSYNC = 29
Gbi.G_TEXRECT = 30

-- Custom Opcodes
Gbi.G_SETPLAYERDATA = 30

Gbi.G_ZBUFFER = 0x00000001
Gbi.G_SHADE = 0x00000004
Gbi.G_TEXTURE_ENABLE = 0x00000002
Gbi.G_SHADING_SMOOTH = 0x00000200
Gbi.G_CULL_FRONT = 0x00001000
Gbi.G_CULL_BACK = 0x00002000
Gbi.G_FOG = 0x00010000
Gbi.G_LIGHTING = 0x00020000
Gbi.G_TEXTURE_GEN = 0x00040000
Gbi.G_TEXTURE_GEN_LINEAR = 0x00080000
Gbi.G_CLIPPING = 0x00000000
Gbi.G_CULL_BOTH = 0x00003000
Gbi.G_LOD = 0x00100000

Gbi.G_ON = 1
Gbi.G_OFF = 0

-- flags to inhibit pushing of the display list (on branch)
Gbi.G_DL_PUSH = 0x00
Gbi.G_DL_NOPUSH = 0x01

Gbi.G_TEXTURE_IMAGE_FRAC = 2
Gbi.G_TEXTURE_SCALE_FRAC = 16
Gbi.G_SCALE_FRAC = 8
Gbi.G_ROTATE_FRAC = 16

-- Gbi.G_SETOTHERMODE_L sft: shift count
Gbi.G_MDSFT_ALPHACOMPARE = 0
Gbi.G_MDSFT_ZSRCSEL = 2
Gbi.G_MDSFT_RENDERMODE = 3
Gbi.G_MDSFT_BLENDER = 16

-- Gbi.G_SETOTHERMODE_H sft: shift count
Gbi.G_MDSFT_BLENDMASK = 0 -- unsupported
Gbi.G_MDSFT_ALPHADITHER = 4
Gbi.G_MDSFT_RGBDITHER = 6

Gbi.G_MDSFT_COMBKEY = 8
Gbi.G_MDSFT_TEXTCONV = 9
Gbi.G_MDSFT_TEXTFILT = 12
Gbi.G_MDSFT_TEXTLUT = 14
Gbi.G_MDSFT_TEXTLOD = 16
Gbi.G_MDSFT_TEXTDETAIL = 17
Gbi.G_MDSFT_TEXTPERSP = 19
Gbi.G_MDSFT_CYCLETYPE = 20
Gbi.G_MDSFT_COLORDITHER = 22 -- unsupported in HW 2.0
Gbi.G_MDSFT_PIPELINE = 23

-- Gbi.G_SETOTHERMODE_H gPipelineMode
Gbi.G_PM_1PRIMITIVE = 1
Gbi.G_PM_NPRIMITIVE = 0

-- Gbi.G_SETOTHERMODE_H gSetCycleType
Gbi.G_CYC_1CYCLE = 0
Gbi.G_CYC_2CYCLE = 1
Gbi.G_CYC_COPY = 2
Gbi.G_CYC_FILL = 3

-- Gbi.G_SETOTHERMODE_H gSetTexturePersp
Gbi.G_TP_NONE = 0
Gbi.G_TP_PERSP = 1

-- Gbi.G_SETOTHERMODE_H gSetTextureDetail
Gbi.G_TD_CLAMP = 0
Gbi.G_TD_SHARPEN = 1
Gbi.G_TD_DETAIL = 2

-- Gbi.G_SETOTHERMODE_H gSetTextureLOD
Gbi.G_TL_TILE = 0
Gbi.G_TL_LOD = 1

-- Gbi.G_SETOTHERMODE_H gSetTextureLUT
Gbi.G_TT_NONE = 0
Gbi.G_TT_RGBA16 = 2
Gbi.G_TT_IA16 = 3

-- Gbi.G_SETOTHERMODE_H gSetTextureFilter
Gbi.G_TF_POINT = 0
Gbi.G_TF_AVERAGE = 3
Gbi.G_TF_BILERP = 2

-- Gbi.G_SETOTHERMODE_H gSetTextureConvert
Gbi.G_TC_CONV = 0
Gbi.G_TC_FILTCONV = 5
Gbi.G_TC_FILT = 6

-- Gbi.G_SETOTHERMODE_H gSetCombineKey
Gbi.G_CK_NONE = 0
Gbi.G_CK_KEY = 1

-- Gbi.G_SETOTHERMODE_H gSetColorDither
Gbi.G_CD_MAGICSQ = 0
Gbi.G_CD_BAYER = 1
Gbi.G_CD_NOISE = 2

-- Gbi.G_SETOTHERMODE_H gSetAlphaDither
Gbi.G_AD_PATTERN = 0
Gbi.G_AD_NOTPATTERN = 1
Gbi.G_AD_NOISE = 2
Gbi.G_AD_DISABLE = 3

-- Gbi.G_SETOTHERMODE_L gSetAlphaCompare
Gbi.G_AC_NONE = bit.lshift(0, Gbi.G_MDSFT_ALPHACOMPARE)
Gbi.G_AC_THRESHOLD = bit.lshift(1, Gbi.G_MDSFT_ALPHACOMPARE)
Gbi.G_AC_DITHER = bit.lshift(3, Gbi.G_MDSFT_ALPHACOMPARE)

-- Gbi.G_SETOTHERMODE_L gSetDepthSource
Gbi.G_ZS_PIXEL = bit.lshift(0, Gbi.G_MDSFT_ZSRCSEL)
Gbi.G_ZS_PRIM = bit.lshift(1, Gbi.G_MDSFT_ZSRCSEL)

-- Gbi.G_SETOTHERMODE_L gSetRenderMode
AA_EN = 0x8
Z_CMP = 0x10
Z_UPD = 0x20
IM_RD = 0x40
CLR_ON_CVG = 0x80
CVG_DST_CLAMP = 0
CVG_DST_WRAP = 0x100
CVG_DST_FULL = 0x200
CVG_DST_SAVE = 0x300
ZMODE_OPA = 0
ZMODE_INTER = 0x400
ZMODE_XLU = 0x800
ZMODE_DEC = 0xc00
CVG_X_ALPHA = 0x1000
ALPHA_CVG_SEL = 0x2000
FORCE_BL = 0x4000
TEX_EDGE = 0x0000 -- used to be 0x8000

Gbi.G_BL_CLR_IN = 0
Gbi.G_BL_CLR_MEM = 1
Gbi.G_BL_CLR_BL = 2
Gbi.G_BL_CLR_FOG = 3
Gbi.G_BL_1MA = 0
Gbi.G_BL_A_MEM = 1
Gbi.G_BL_A_IN = 0
Gbi.G_BL_A_FOG = 1
Gbi.G_BL_A_SHADE = 2
Gbi.G_BL_1 = 2
Gbi.G_BL_0 = 3

Gbi.CC_0 = 0
Gbi.CC_TEXEL0 = 1
Gbi.CC_TEXEL1 = 2
Gbi.CC_PRIM = 3
Gbi.CC_SHADE = 4
Gbi.CC_ENV = 5
Gbi.CC_TEXEL0A = 6
Gbi.CC_LOD = 7

Gbi.SHADER_0 = 0
Gbi.SHADER_INPUT_1 = 1
Gbi.SHADER_INPUT_2 = 2
Gbi.SHADER_INPUT_3 = 3
Gbi.SHADER_INPUT_4 = 4
Gbi.SHADER_TEXEL0 = 5
Gbi.SHADER_TEXEL0A = 6
Gbi.SHADER_TEXEL1 = 7

Gbi.SHADER_OPT_ALPHA = bit.lshift(1, 24)
Gbi.SHADER_OPT_FOG = bit.lshift(1, 25)
Gbi.SHADER_OPT_TEXTURE_EDGE = bit.lshift(1, 26)

-- Gbi.G_SETCOMBINE: color combine modes
-- Color combiner constants:
Gbi.G_CCMUX_COMBINED = 0
Gbi.G_CCMUX_TEXEL0 = 1
Gbi.G_CCMUX_TEXEL1 = 2
Gbi.G_CCMUX_PRIMITIVE = 3
Gbi.G_CCMUX_SHADE = 4
Gbi.G_CCMUX_ENVIRONMENT = 5
Gbi.G_CCMUX_CENTER = 6
Gbi.G_CCMUX_SCALE = 6
Gbi.G_CCMUX_COMBINED_ALPHA = 7
Gbi.G_CCMUX_TEXEL0_ALPHA = 8
Gbi.G_CCMUX_TEXEL1_ALPHA = 9
Gbi.G_CCMUX_PRIMITIVE_ALPHA = 10
Gbi.G_CCMUX_SHADE_ALPHA = 11
Gbi.G_CCMUX_ENV_ALPHA = 12
Gbi.G_CCMUX_LOD_FRACTION = 13
Gbi.G_CCMUX_PRIM_LOD_FRAC = 14
Gbi.G_CCMUX_NOISE = 7
Gbi.G_CCMUX_K4 = 7
Gbi.G_CCMUX_K5 = 15
Gbi.G_CCMUX_1 = 6
Gbi.G_CCMUX_0 = 31

-- Alpha combiner constants:
Gbi.G_ACMUX_COMBINED = 0
Gbi.G_ACMUX_TEXEL0 = 1
Gbi.G_ACMUX_TEXEL1 = 2
Gbi.G_ACMUX_PRIMITIVE = 3
Gbi.G_ACMUX_SHADE = 4
Gbi.G_ACMUX_ENVIRONMENT = 5
Gbi.G_ACMUX_LOD_FRACTION = 0
Gbi.G_ACMUX_PRIM_LOD_FRAC = 6
Gbi.G_ACMUX_1 = 6
Gbi.G_ACMUX_0 = 7

-- Gbi.G_SETIMG fmt: set image formats
Gbi.G_IM_FMT_RGBA = 0
Gbi.G_IM_FMT_YUV = 1
Gbi.G_IM_FMT_CI = 2
Gbi.G_IM_FMT_IA = 3
Gbi.G_IM_FMT_I = 4

-- Gbi.G_SETIMG siz: set image pixel size
Gbi.G_IM_SIZ_4b = 0
Gbi.G_IM_SIZ_8b = 1
Gbi.G_IM_SIZ_16b = 2
Gbi.G_IM_SIZ_32b = 3
Gbi.G_IM_SIZ_DD = 5

Gbi.G_IM_SIZ_INCR_TABLE = {[0]=
	1,
	0
}
Gbi.G_IM_SIZ_SHIFT_TABLE = {[0]=
	1,
	0
}

Gbi.G_IM_SIZ_LOAD_BLOCK_TABLE = {[0]=
	Gbi.G_IM_SIZ_16b,
	Gbi.G_IM_SIZ_16b
}
Gbi.G_IM_SIZ_BYTES_TABLE = {[0]=
	Gbi.G_IM_SIZ_8b,
	Gbi.G_IM_SIZ_16b
}

Gbi.G_IM_SIZ_LINE_BYTES_TABLE = {[0]=
	Gbi.G_IM_SIZ_8b,
	Gbi.G_IM_SIZ_16b
}

Gbi.G_TX_LOADTILE = 7
Gbi.G_TX_RENDERTILE = 0

Gbi.G_TX_NOMIRROR = 0
Gbi.G_TX_WRAP = 0
Gbi.G_TX_MIRROR = 0x1
Gbi.G_TX_CLAMP = 0x2
Gbi.G_TX_NOMASK = 0
Gbi.G_TX_NOLOD = 0

-- Render Modes
Gbi.G_RM_OPA_SURF_SURF2 = 0xf0a4000
Gbi.G_RM_AA_OPA_SURF_SURF2 = 0x552048
Gbi.G_RM_AA_XLU_SURF_SURF2 = 0x5041c8

Gbi.G_RM_ZB_OPA_SURF_SURF2 = 0x552230
Gbi.G_RM_AA_ZB_TEX_EDGE_NOOP2 = 0x443078
Gbi.G_RM_AA_ZB_OPA_INTER_NOOP2 = 0x442478
Gbi.G_RM_AA_ZB_XLU_DECAL_DECAL2 = 0x504dd8
Gbi.G_RM_AA_ZB_XLU_SURF_SURF2 = 0x5049d8
Gbi.G_RM_AA_ZB_XLU_SURF_NOOP2 = 0x4049d8
Gbi.G_RM_AA_ZB_OPA_SURF_NOOP2 = 0x442078
Gbi.G_RM_AA_ZB_OPA_SURF_SURF2 = 0x552078
Gbi.G_RM_AA_ZB_OPA_DECAL_DECAL2 = 0x552d58
Gbi.G_RM_AA_ZB_OPA_DECAL_NOOP2 = 0x442d58
Gbi.G_RM_AA_ZB_XLU_INTER_INTER2 = 0x5045d8
Gbi.G_RM_FOG_SHADE_A_AA_ZB_OPA_SURF2 = 0xc8112078
Gbi.G_RM_FOG_SHADE_A_AA_ZB_TEX_EDGE2 = 0xc8113078
Gbi.G_RM_FOG_SHADE_A_AA_ZB_OPA_DECAL2 = 0xc8112d58
Gbi.G_RM_FOG_SHADE_A_AA_ZB_XLU_SURF2 = 0xc81049d8

-- Gbi.G_MOVEWORD types
Gbi.G_MW_MATRIX = 0x00 -- NOTE: also used by movemem
Gbi.G_MW_NUMLIGHT = 0x02
Gbi.G_MW_CLIP = 0x04
Gbi.G_MW_SEGMENT = 0x06
Gbi.G_MW_FOG = 0x08
Gbi.G_MW_LIGHTCOL = 0x0a
Gbi.G_MW_POINTS = 0x0c
Gbi.G_MW_PERSPNORM = 0x0e

-- Gbi.G_MOVEMEM types
Gbi.G_MV_VIEWPORT = 1
Gbi.G_MV_L = 2

-- Gbi.G_MTX parameter flags
Gbi.G_MTX_MODELVIEW = 0 -- matrix types
Gbi.G_MTX_PROJECTION = 1
Gbi.G_MTX_MUL = 0 -- concat or load
Gbi.G_MTX_LOAD = 2
Gbi.G_MTX_NOPUSH = 0 -- push or not
Gbi.G_MTX_PUSH = 4

Gbi.G_CC_PRIMITIVE = {
	alpha = {7, 7, 7, 3},
	rgb = {15, 15, 31, 3}
}

Gbi.G_CC_MODULATERGB = {
	alpha = {7, 7, 7, 4},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATEI = {
	alpha = {7, 7, 7, 4},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATERGBFADE = { 
	alpha = {7, 7, 7, 5},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATERGBA = {
	alpha = {1, 7, 4, 7},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATEIA = {
	alpha = {1, 7, 4, 7},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATEIFADEA = {
	alpha = {1, 7, 5, 7},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATEIDECALA = {
	alpha = {7, 7, 7, 1},
	rgb = {1, 15, 4, 7}
}

Gbi.G_CC_MODULATERGBA_PRIM = {
	alpha = {1, 7, 3, 7},
	rgb = {1, 15, 3, 7}
}

Gbi.G_CC_SHADE = {
	alpha = {7, 7, 7, 4},
	rgb = {15, 15, 31, 4}
}

Gbi.G_CC_SHADEFADEA = {
	alpha = {7, 7, 7, 5},
	rgb = {15, 15, 31, 4}
}

Gbi.G_CC_BLENDRGBFADEA = {
	alpha = {7, 7, 7, 5},
	rgb = {1, 4, 8, 4}
}

Gbi.G_CC_DECALFADE = {
	alpha = {7, 7, 7, 5},
	rgb = {15, 15, 31, 1}
}

Gbi.G_CC_DECALFADEA = {
	alpha = {1, 7, 5, 7},
	rgb = {15, 15, 31, 1}
}

Gbi.G_CC_DECALRGBA = {
	alpha = {7, 7, 7, 1},
	rgb = {15, 15, 31, 1}
}

Gbi.G_CC_DECALRGB = {
	alpha = {7, 7, 7, 4},
	rgb = {15, 15, 31, 1}
}

Gbi.G_CC_HILITERGBA = {
	alpha = {3, 4, 1, 4},
	rgb = {3, 4, 1, 4}
}

function Gbi.gdSPDefLights1(ar, ag, ab, r1, g1, b1, x1, y1, z1)
	return {
		a = {col = {ar, ag, ab}},
		l = {
			{
				col = {r1, g1, b1},
				dir = {x1, y1, z1}
			}
		}
	}
end

function Gbi.gSPLight(displaylist, lightData, index)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_MOVEMEM,
			w1 = {type = Gbi.G_MV_L, data = lightData, index = index - 1}
			-- the `index - 1` I don't like and isn't needed, but it makes matching with decomp code easier
		}
	})
end

function Gbi.gSPNumLights(displaylist, num)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_MOVEWORD,
			w1 = {type = Gbi.G_MW_NUMLIGHT, data = num + 1} -- includes 1 ambient light
		}
	})
end

function Gbi.gSPFogFactor(displaylist, f_mul, f_offset)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_MOVEWORD,
			w1 = {
				type = Gbi.G_MW_FOG,
				data = {
					mul = f_mul,
					offset = f_offset
				}
			}
		}
	})
end

function Gbi.gSPFogPosition(displaylist, min, max)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_MOVEWORD,
			w1 = {
				type = Gbi.G_MW_FOG,
				data = {
					mul = (128000 / ((max) - (min))),
					offset = ((500 - (min)) * 256 / ((max) - (min)))
				}
			}
		}
	})
end

function Gbi.gDPSetFogColor(displaylist, r, g, b, a)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETFOGCOLOR,
			w1 = {r=r, g=g, b=b, a=a}
		}
	})
end

function Gbi.gDPSetEnvColor(displaylist, r, g, b, a)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETENVCOLOR,
			w1 = {r=r, g=g, b=b, a=a}
		}
	})
end

function Gbi.gDPSetFillColor(displaylist, color)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETFILLCOLOR,
			w1 = {color=color}
		}
	})
end

function Gbi.gDPFillRectangle(displaylist, ulx, uly, lrx, lry)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_FILLRECT,
			w1 = {ulx=ulx, uly=uly, lrx=lrx, lry=lry}
		}
	})
end

function Gbi.gSPTextureRectangle(displaylist, ulx, uly, lrx, lry, tile, uls, ult, dsdx, dtdy)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_TEXRECT,
			w1 = {ulx=ulx, uly=uly, lrx=lrx, lry=lry, tile=tile, uls=uls, ult=ult, dsdx=dsdx, dtdy=dtdy}
		}
	})
end

function Gbi.gSPTextureRectangleFlip(displaylist, ulx, uly, lrx, lry, tile, uls, ult, dsdx, dtdy)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_FILLRECTFLIP,
			w1 = {ulx=ulx, uly=uly, lrx=lrx, lry=lry, tile=tile, uls=uls, ult=ult, dsdx=dsdx, dtdy=dtdy}
		}
	})
end

function Gbi.gSPTexture(displaylist, s, t, level, tile, on)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_TEXTURE,
			w1 = {s=s, t=t}
		}
	})
end

function Gbi.gDPSetCombineMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETCOMBINE,
			w1 = {mode=mode}
		}
	})
end

function Gbi.gDPSetTileSize(displaylist, t, uls, ult, lrs, lrt)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETTILESIZE,
			w1 = {t=t, uls=uls, ult=ult, lrs=lrs, lrt=lrt}
		}
	})
end

function Gbi.gDPSetHilite1Tile(displaylist, tile, hilite, width, height)
	gDPSetTileSize(displaylist, tile,
		bit.band(hilite.x1, 0xfff),
		bit.band(hilite.y1, 0xfff),
		bit.band((((width - 1) * 4) + hilite.x1), 0xfff),
		bit.band((((height - 1) * 4) + hilite.y1), 0xfff)
	)
end

function Gbi.gSPMatrix(displaylist, matrix, parameters)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_MTX,
			w1 = {matrix=matrix, parameters=parameters}
		}
	})
end

function Gbi.gDPSetRenderMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETOTHERMODE_L,
			w1 = {mode=mode}
		}
	})
end
function Gbi.gDPSetTextureFilter(displaylist, newmode)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETOTHERMODE_H,
			w1 = {category = Gbi.G_MDSFT_TEXTFILT, newmode=newmode}
		}
	})
end

function Gbi.gDPSetCycleType(displaylist, newmode)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETOTHERMODE_H,
			w1 = {category = Gbi.G_MDSFT_CYCLETYPE, newmode=newmode}
		}
	})
end

function Gbi.gSPVertex(displaylist, vertices, num_vertices, dest_index)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_VTX,
			w1 = {vertices=vertices, dest_index=dest_index}
		}
	})
end

function Gbi.gSP1Triangle(displaylist, v0, v1, v2, flag)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_TRI1,
			w1 = {v0=v0, v1=v1, v2=v2, flag=flag}
		}
	})
end

function Gbi.gSPViewport(displaylist, viewportData)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_MOVEMEM,
			w1 = {type = Gbi.G_MV_VIEWPORT, data = viewportData}
		}
	})
end

function Gbi.gDPSetPrimColor(displaylist, m, l, r, g, b, a)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETPRIMCOLOR,
			w1 = {m=m, l=l, r=r, g=g, b=b, a=a}
		}
	})
end


function Gbi.gSPSetGeometryMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_SETGEOMETRYMODE,
			w1 = {mode=mode}
		}
	})
end

function Gbi.gSPClearGeometryMode(displaylist, mode)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_CLEARGEOMETRYMODE,
			w1 = {mode=mode}
		}
	})
end

function Gbi.gSPEndDisplayList(displaylist)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_ENDDL
		}
	})
end

function Gbi.gSPBranchList(displaylist, childDisplayList)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_DL,
			w1 = {childDisplayList=childDisplayList, branch = Gbi.G_DL_NOPUSH}
		}
	})
end

function Gbi.gSPDisplayList(displaylist, childDisplayList)
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_DL,
			w1 = {childDisplayList=childDisplayList, branch = Gbi.G_DL_PUSH}
		}
	})
end

function Gbi.gDPSetTextureImage(displaylist, format, size, width, imageData)
	table.insert(displaylist, {
		 words = {
			w0 = Gbi.G_SETTIMG,
			w1 = {format=format, size=size, width=width, imageData=imageData}
		}
	})
end

function Gbi.gDPLoadBlock(displaylist, tile, uls, ult, lrs) -- dxt skipped
	table.insert(displaylist, {
		words = {
			w0 = Gbi.G_LOADBLOCK,
			w1 = {tile=tile, uls=uls, ult=ult, lrs=lrs}
		}
	})
end


function Gbi.gDPLoadBlockTexture(displaylist, width, height, format, image)
	table.insert(displaylist, Gbi.gsDPSetTextureImage(format, Gbi.G_IM_SIZ_16b, 1, image))
	table.insert(displaylist, Gbi.gsDPSetTile(format, Gbi.G_IM_SIZ_16b, 0, 0, Gbi.G_TX_LOADTILE, 0, Gbi.G_TX_NOMIRROR, Gbi.G_TX_NOMASK, Gbi.G_TX_NOLOD, Gbi.G_TX_NOMIRROR, Gbi.G_TX_NOMASK, Gbi.G_TX_NOLOD))
	table.insert(displaylist, Gbi.gsDPLoadBlock(G_TX_LOADTILE, 0, 0, (width * height) - 1))
end

function Gbi.gDPLoadTextureBlock(displaylist, timg, fmt, siz, width, height, pal, cms, cmt, masks, maskt, shifts, shiftt)
	table.insert(displaylist, Gbi.gsDPSetTextureImage(fmt, Gbi.G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 1, timg))
	table.insert(displaylist, Gbi.gsDPSetTile(fmt, Gbi.G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 0, 0, Gbi.G_TX_LOADTILE, 0, cmt, maskt, shiftt, cms, masks, shifts))
	table.insert(displaylist, Gbi.gsDPLoadBlock(G_TX_LOADTILE, 0, 0, bit.rshift(((width) * (height) + Gbi.G_IM_SIZ_INCR_TABLE[siz]), Gbi.G_IM_SIZ_SHIFT_TABLE[siz]) - 1))
	table.insert(displaylist, Gbi.gsDPSetTile(
		fmt, siz,
		bit.rshift((((width) * Gbi.G_IM_SIZ_LINE_BYTES_TABLE[siz]) + 7), 3),
		0, Gbi.G_TX_RENDERTILE, pal, cmt, maskt, shiftt, cms, masks, shifts)
	)
	table.insert(displaylist, Gbi.gsDPSetTileSize(G_TX_RENDERTILE, 0, 0, bit.lshift(((width) - 1), Gbi.G_TEXTURE_IMAGE_FRAC), bit.lshift(((height) - 1), Gbi.G_TEXTURE_IMAGE_FRAC)))
end

function Gbi.gsSPDisplayList(childDisplayList)
	return {
		words = {
			w0 = Gbi.G_DL,
			w1 = {childDisplayList=childDisplayList, branch = Gbi.G_DL_PUSH}
		}
	}
end

function Gbi.gsSPBranchList(childDisplayList)
	return {
		words = {
			w0 = Gbi.G_DL,
			w1 = {childDisplayList, branch = Gbi.G_DL_NOPUSH}
		}
	}
end

function Gbi.gsSPEndDisplayList()
	return {
		words = {
			w0 = Gbi.G_ENDDL
		}
	}
end

function Gbi.gsDPSetRenderMode(mode)
	return {
		words = {
			w0 = Gbi.G_SETOTHERMODE_L,
			w1 = {mode=mode}
		}
	}
end

function Gbi.gsDPSetTextureFilter(newmode)
	return {
		words = {
			w0 = Gbi.G_SETOTHERMODE_H,
			w1 = {category = Gbi.G_MDSFT_TEXTFILT, newmode=newmode}
		}
	}
end

function Gbi.gsDPSetCycleType(newmode)
	return {
		words = {
			w0 = Gbi.G_SETOTHERMODE_H,
			w1 = {category = Gbi.G_MDSFT_CYCLETYPE, newmode=newmode}
		}
	}
end

function Gbi.gsSPLight(lightData, index)
	return {
		words = {
			w0 = Gbi.G_MOVEMEM,
			w1 = {type = Gbi.G_MV_L, data = lightData, index = index - 1}
			-- the `index - 1` I don't like and isn't needed, but it makes matching with decomp code easier
		}
	}
end

function Gbi.gsSPNumLights(num)
	return {
		words = {
			w0 = Gbi.G_MOVEWORD,
			w1 = {type = Gbi.G_MW_NUMLIGHT, data = num + 1} -- includes 1 ambient light
		}
	}
end

function Gbi.gsSPFogFactor(f_mul, f_offset)
	return {
		words = {
			w0 = Gbi.G_MOVEWORD,
			w1 = {
				type = Gbi.G_MW_FOG,
				data = {
					mul = f_mul,
					offset = f_offset
				}
			}
		}
	}
end

function Gbi.gsSPFogPosition(min, max)
	return {
		words = {
			w0 = Gbi.G_MOVEWORD,
			w1 = {
				type = Gbi.G_MW_FOG,
				data = {
					mul = (128000 / ((max) - (min))),
					offset = ((500 - (min)) * 256 / ((max) - (min)))
				}
			}
		}
	}
end

function Gbi.gsSPClearGeometryMode(mode)
	return {
		words = {
			w0 = Gbi.G_CLEARGEOMETRYMODE,
			w1 = {mode=mode}
		}
	}
end

function Gbi.gsSPSetGeometryMode(mode)
	return {
		words = {
			w0 = Gbi.G_SETGEOMETRYMODE,
			w1 = {mode=mode}
		}
	}
end

function Gbi.gsDPSetCombineMode(mode)
	return {
		words = {
			w0 = Gbi.G_SETCOMBINE,
			w1 = {mode=mode}
		}
	}
end

function Gbi.gsSPMatrix(matrix, parameters)
	return {
		words = {
			w0 = Gbi.G_MTX,
			w1 = {matrix=matrix, parameters=parameters}
		}
	}
end

function Gbi.gsDPSetFogColor(r, g, b, a)
	return {
		words = {
			w0 = Gbi.G_SETFOGCOLOR,
			w1 = {r=r, g=g, b=b, a=a}
		}
	}
end

function Gbi.gsDPSetEnvColor(r, g, b, a)
	return {
		words = {
			w0 = Gbi.G_SETENVCOLOR,
			w1 = {r=r, g=g, b=b, a=a}
		}
	}
end

function Gbi.gsDPSetPrimColor(m, l, r, g, b, a)
	return {
		words = {
			w0 = Gbi.G_SETPRIMCOLOR,
			w1 = {m=m, l=l, r=r, g=g, b=b, a=a}
		}
	}
end

function Gbi.gsDPSetTile(fmt, siz, line, tmem, tile, palette, cmt, maskt, shiftt, cms, masks, shifts)
	return {
		words = {
			w0 = Gbi.G_SETTILE,
			w1 = {fmt=fmt, siz=siz, line=line, tmem=tmem, tile=tile, palette=palette, cmt=cmt, cms=cms}
		}
	}
end

function Gbi.gsSPTexture(s, t, level, tile, on)
	return {
		words = {
			w0 = Gbi.G_TEXTURE,
			w1 = {s=s, t=t}
		}
	}
end

function Gbi.gsDPSetTileSize(t, uls, ult, lrs, lrt)
	return {
		words = {
			w0 = Gbi.G_SETTILESIZE,
			w1 = {t=t, uls=uls, ult=ult, lrs=lrs, lrt=lrt}
		}
	}
end

function Gbi.gsDPSetTextureImage(format, size, width, imageData)
	return {
		words = {
			w0 = Gbi.G_SETTIMG,
			w1 = {format=format, size=size, width=width, imageData=imageData}
		}
	}
end

function Gbi.gsDPLoadBlock(tile, uls, ult, lrs) -- dxt skipped
	return {
		words = {
			w0 = Gbi.G_LOADBLOCK,
			w1 = {tile=tile, uls=uls, ult=ult, lrs=lrs}
		}
	}
end

function Gbi.gsSPVertex(vertices, num_vertices, dest_index)
	return {
		words = {
			w0 = Gbi.G_VTX,
			w1 = {vertices=vertices, dest_index=dest_index}
		}
	}
end

function Gbi.gsSP1Triangle(v0, v1, v2, flag)
	return {
		words = {
			w0 = Gbi.G_TRI1,
			w1 = {v0=v0, v1=v1, v2=v2, flag=flag}
		}
	}
end

function Gbi.gsSP2Triangles(v00, v01, v02, flag0, v10, v11, v12, flag1)
	return {{
		words = {
			w0 = Gbi.G_TRI1,
			w1 = {v0 = v00, v1 = v01, v2 = v02, flag = flag0}
		}
	}, {
		words = {
			w0 = Gbi.G_TRI1,
			w1 = {v0 = v10, v1 = v11, v2 = v12, flag = flag1}
		}
	}}
end

function Gbi.gsDPLoadTextureBlock(timg, fmt, siz, width, height, pal, cms, cmt, masks, maskt, shifts, shiftt)
	return {
		Gbi.gsDPSetTextureImage(fmt, Gbi.G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 1, timg),
		Gbi.gsDPSetTile(fmt, Gbi.G_IM_SIZ_LOAD_BLOCK_TABLE[siz], 0, 0, Gbi.G_TX_LOADTILE, 0, cmt, maskt, shiftt, cms, masks, shifts),
		Gbi.gsDPLoadBlock(G_TX_LOADTILE, 0, 0, bit.rshift(((width) * (height) + Gbi.G_IM_SIZ_INCR_TABLE[siz]), Gbi.G_IM_SIZ_SHIFT_TABLE[siz]) - 1),
		Gbi.gsDPSetTile(fmt, siz,
			bit.rshift((((width) * Gbi.G_IM_SIZ_LINE_BYTES_TABLE[siz]) + 7), 3),
			0, Gbi.G_TX_RENDERTILE, pal, cmt, maskt, shiftt, cms, masks, shifts),
		Gbi.gsDPSetTileSize(G_TX_RENDERTILE, 0, 0, bit.lshift(((width) - 1), Gbi.G_TEXTURE_IMAGE_FRAC), bit.lshift(((height) - 1), Gbi.G_TEXTURE_IMAGE_FRAC))
	}
end
